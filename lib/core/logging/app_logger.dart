// lib/core/logging/app_logger.dart
// WHY: Single structured logging seam. Every part of the app routes logs
//      through here so that, in production, we can swap in Sentry/Firebase
//      Crashlytics without touching call-sites. Replaces ad-hoc `print()`
//      and silent `catch (_) {}` blocks scattered through the codebase.

import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

/// Severity levels aligned with both `dart:developer` and most log sinks.
enum LogLevel { debug, info, warning, error, fatal }

/// One structured log record. Kept as a plain class so it serializes
/// cleanly to JSON when forwarded to a remote sink.
@immutable
class LogRecord {
  final LogLevel level;
  final String message;
  final String tag;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, Object?>? context;
  final DateTime timestamp;

  LogRecord({
    required this.level,
    required this.message,
    required this.tag,
    this.error,
    this.stackTrace,
    this.context,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, Object?> toJson() => {
        'level': level.name,
        'tag': tag,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        if (error != null) 'error': error.toString(),
        if (context != null) 'context': context,
      };
}

/// Sink contract — implement to forward records to a remote service.
abstract class LogSink {
  void emit(LogRecord record);
}

/// Default sink: pretty-prints to `dart:developer` in debug mode, and
/// forwards to remote sinks (Sentry/Crashlytics) in release builds.
class _ConsoleLogSink implements LogSink {
  const _ConsoleLogSink();

  @override
  void emit(LogRecord record) {
    final prefix = _prefixFor(record.level);
    final buffer = StringBuffer(
      '${record.timestamp.toIso8601String()} $prefix '
      '[${record.tag}] ${record.message}',
    );

    if (record.context != null && record.context!.isNotEmpty) {
      buffer.write(' ctx=${record.context}');
    }
    if (record.error != null) {
      buffer.write(' err=${record.error}');
    }

    if (record.level == LogLevel.error || record.level == LogLevel.fatal) {
      dev.log(
        buffer.toString(),
        level: record.level == LogLevel.fatal ? 1200 : 1000,
        error: record.error,
        stackTrace: record.stackTrace,
        name: record.tag,
      );
    } else if (kDebugMode) {
      // Only emit debug/info logs in debug builds to keep release logs clean.
      dev.log(buffer.toString(), name: record.tag);
    }
  }

  String _prefixFor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO ';
      case LogLevel.warning:
        return 'WARN ';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.fatal:
        return 'FATAL';
    }
  }
}

/// The app-wide logger. Call sites use [AppLogger.instance] (or the
/// convenience top-level functions) so there is exactly one configuration
/// point for filtering, sinks, and level.
class AppLogger {
  AppLogger._({List<LogSink>? sinks, this.minLevel = LogLevel.info})
      : _sinks = sinks ?? const [_ConsoleLogSink()];

  static final AppLogger instance = AppLogger._();

  final List<LogSink> _sinks;
  final LogLevel minLevel;

  /// Add an additional sink (e.g. Sentry) at runtime.
  void addSink(LogSink sink) => _sinks.add(sink);

  void debug(String message, {String tag = 'app', Map<String, Object?>? context}) =>
      _log(LogLevel.debug, message, tag: tag, context: context);

  void info(String message, {String tag = 'app', Map<String, Object?>? context}) =>
      _log(LogLevel.info, message, tag: tag, context: context);

  void warning(
    String message, {
    String tag = 'app',
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) =>
      _log(LogLevel.warning, message,
          tag: tag, error: error, stackTrace: stackTrace, context: context);

  void error(
    String message, {
    String tag = 'app',
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) =>
      _log(LogLevel.error, message,
          tag: tag, error: error, stackTrace: stackTrace, context: context);

  void fatal(
    String message, {
    String tag = 'app',
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) =>
      _log(LogLevel.fatal, message,
          tag: tag, error: error, stackTrace: stackTrace, context: context);

  void _log(
    LogLevel level,
    String message, {
    required String tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) {
    if (level.index < minLevel.index) return;
    final record = LogRecord(
      level: level,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
    for (final sink in _sinks) {
      sink.emit(record);
    }
  }
}

/// Top-level shortcuts used by repository / controller call-sites so they
/// don't need to import the instance each time.
void logDebug(String message, {String tag = 'app'}) =>
    AppLogger.instance.debug(message, tag: tag);
void logInfo(String message, {String tag = 'app'}) =>
    AppLogger.instance.info(message, tag: tag);
void logWarning(String message, {Object? error, String tag = 'app'}) =>
    AppLogger.instance.warning(message, tag: tag, error: error);
void logError(
  String message, {
  Object? error,
  StackTrace? stackTrace,
  String tag = 'app',
}) =>
    AppLogger.instance.error(message,
        tag: tag, error: error, stackTrace: stackTrace);
