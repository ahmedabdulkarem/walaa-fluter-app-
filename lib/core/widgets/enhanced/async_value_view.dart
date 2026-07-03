// lib/core/widgets/enhanced/async_value_view.dart
// WHY: The app is full of `asyncValue.when(data:..., loading:..., error:...)`
//      blocks duplicated dozens of times. This widget centralizes the
/// pattern so call-sites shrink to a single line and we get consistent
/// loading skeletons + error UIs everywhere by default.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_colors.dart';
import 'loading_skeleton.dart';

/// Renders an [AsyncValue] with sensible defaults for loading and error.
/// Pass [data] for the success branch; the other two are optional.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.skeletonCount = 4,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final WidgetBuilder? loading;
  final Widget Function(Object error, StackTrace? stack)? error;
  final int skeletonCount;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => loading?.call(context) ?? SkeletonCardList(itemCount: skeletonCount),
      error: (e, st) => error?.call(e, st) ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48, color: AppColors.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text(
                    'تعذّر تحميل البيانات',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
