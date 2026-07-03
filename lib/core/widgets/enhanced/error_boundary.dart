// lib/core/widgets/enhanced/error_boundary.dart
// WHY: Wraps a subtree and catches render-time errors that would otherwise
//      replace the whole app with a red screen. Provides a recoverable
//      fallback UI with a "retry" button so the user can keep working.
//
//      The framework's default `ErrorWidget.builder` (configured in
//      bootstrap.dart) shows raw exception text — fine for devs, hostile
//      for users. This widget gives us a graceful per-subtree fallback.

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

/// Catches errors that occur while building [child] and renders [fallback]
/// instead. If [fallback] is null, a sensible default is shown.
class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallback,
    this.onError,
  });

  final Widget child;
  final WidgetBuilder? fallback;
  final void Function(FlutterErrorDetails details)? onError;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallback?.call(context) ?? _DefaultFallback(error: _error!, onRetry: _reset);
    }
    return widget.child;
  }

  void _reset() {
    setState(() => _error = null);
  }

  @override
  void initState() {
    super.initState();
    FlutterError.onError = _capture;
  }

  @override
  void dispose() {
    FlutterError.onError = null;
    super.dispose();
  }

  void _capture(FlutterErrorDetails details) {
    widget.onError?.call(details);
    if (!mounted) return;
    setState(() => _error = details);
  }
}

class _DefaultFallback extends StatelessWidget {
  const _DefaultFallback({required this.error, required this.onRetry});

  final FlutterErrorDetails error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 64, color: AppColors.goldBright),
            const SizedBox(height: 16),
            const Text(
              'حدث خطأ غير متوقع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يرجى المحاولة مرة أخرى. إذا استمرت المشكلة، تواصل مع الدعم.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
