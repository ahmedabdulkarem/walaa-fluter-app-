// lib/core/perf/debounce_throttle.dart
// WHY: Search fields, list filters, and "pull to refresh" handlers benefit
//      from debounce (delay until typing pauses) and throttle (cap call
//      rate). Centralizing these primitives keeps the call-sites small and
//      the behavior predictable. Both are cancelable and dispose-aware.

import 'dart:async';

/// Debouncer — fires [call] only after [duration] of inactivity.
/// Typical use: search-as-you-type where each keystroke resets the timer.
class Debouncer {
  Debouncer(this.duration);

  final Duration duration;
  Timer? _timer;
  VoidCallback? _pending;
  bool _disposed = false;

  void run(VoidCallback action) {
    if (_disposed) return;
    _pending = action;
    _timer?.cancel();
    _timer = Timer(duration, _flush);
  }

  void _flush() {
    final cb = _pending;
    _pending = null;
    cb?.call();
  }

  /// Cancels any pending invocation.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _pending = null;
  }

  void dispose() {
    _disposed = true;
    cancel();
  }
}

/// Throttler — fires [call] immediately on first invocation, then ignores
/// subsequent invocations until [duration] elapses. Use for scroll/resize
/// style events where you want at most one invocation per window.
class Throttler {
  Throttler(this.duration);

  final Duration duration;
  Timer? _timer;
  bool _busy = false;
  bool _disposed = false;

  void run(VoidCallback action) {
    if (_disposed || _busy) return;
    _busy = true;
    action();
    _timer = Timer(duration, () {
      _busy = false;
    });
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
  }
}

typedef VoidCallback = void Function();
