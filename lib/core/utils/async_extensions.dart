// lib/core/utils/async_extensions.dart
// WHY: Boilerplate-free helpers for the most common async patterns we hit
//      over and over in this codebase: "run with timeout", "retry N times
//      with backoff", "race a stream with a deadline". Keeping them here
//      means call-sites stay one-liners and the behavior is uniform.

import 'dart:async';

/// Runs [action] and aborts if it exceeds [timeout]. Throws [TimeoutException].
Future<T> withTimeout<T>(Future<T> Function() action, Duration timeout) {
  return action().timeout(timeout);
}

/// Retries [action] up to [retries] times, with exponential backoff between
/// attempts. Only retries on [retryIf] — defaults to retrying any error.
/// Use for transient Firestore hiccups where a quick retry succeeds.
Future<T> retry<T>(
  Future<T> Function() action, {
  int retries = 3,
  Duration baseDelay = const Duration(milliseconds: 400),
  bool Function(Object error)? retryIf,
}) async {
  var attempt = 0;
  Object? lastError;
  while (attempt <= retries) {
    try {
      return await action();
    } catch (e) {
      lastError = e;
      if (attempt == retries) break;
      if (retryIf != null && !retryIf(e)) break;
      await Future<void>.delayed(baseDelay * (1 << attempt));
      attempt++;
    }
  }
  throw lastError!;
}

/// Returns the first non-null result of [sources] that completes within
/// [timeout]. Useful when a local cache and a remote read race each other.
Future<T?> raceFirst<T>(
  Iterable<Future<T?>> sources, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final completer = Completer<T?>();
  var pending = sources.length;
  for (final future in sources) {
    future.then((value) {
      if (completer.isCompleted) return;
      if (value != null) {
        completer.complete(value);
      } else {
        pending--;
        if (pending == 0) completer.complete(null);
      }
    }).catchError((_) {
      pending--;
      if (pending == 0 && !completer.isCompleted) completer.complete(null);
    });
  }
  return completer.future.timeout(timeout, onTimeout: () => null);
}
