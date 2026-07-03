// lib/core/mixins/optimistic_update.dart
// WHY: Many actions (pin a post, toggle attendance, mark ticket resolved)
//      update Firestore then wait for the stream to emit the new value.
//      Round-trip latency makes the UI feel sluggish. This mixin lets a
//      StateNotifier apply a local optimistic state immediately, send the
//      write, and roll back automatically if it fails.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../error/failure.dart';
import '../logging/app_logger.dart';

/// Mixin on [StateNotifier] for one-shot optimistic mutations.
mixin OptimisticUpdateMixin<T> on StateNotifier<T> {
  /// Runs [mutate] against the backend, applying [applyOptimistic] to the
  /// local state first. On error, [rollback] (or the previous state) is
  /// restored and a warning is logged.
  ///
  /// Returns `true` on success, `false` on failure (the caller can then
  /// surface a snackbar).
  Future<bool> runOptimistic({
    required T Function(T current) applyOptimistic,
    required Future<void> Function() mutate,
    T Function(T current)? rollback,
    String? tag,
  }) async {
    final previous = state;
    state = applyOptimistic(previous);
    try {
      await mutate();
      return true;
    } catch (e, _) {
      logWarning('optimistic mutation failed',
          error: e, tag: tag ?? 'optimistic');
      state = rollback?.call(previous) ?? previous;
      return false;
    }
  }

  /// Same as [runOptimistic] but returns the typed [Failure] on error
  /// (useful when the UI wants to show a specific message per failure kind).
  Future<Failure?> runOptimisticWithFailure({
    required T Function(T current) applyOptimistic,
    required Future<Failure?> Function() mutate,
    T Function(T current)? rollback,
    String? tag,
  }) async {
    final previous = state;
    state = applyOptimistic(previous);
    final failure = await mutate();
    if (failure != null) {
      logWarning('optimistic mutation failed with failure',
          error: failure, tag: tag ?? 'optimistic');
      state = rollback?.call(previous) ?? previous;
    }
    return failure;
  }
}
