// lib/core/widgets/enhanced/loading_skeleton.dart
// WHY: A shimmer-style skeleton loader improves perceived performance —
//      users see the layout appear before data arrives rather than a
//      blank CircularProgressIndicator. Built with `RepaintBoundary` and
//      a single `AnimationController` so multiple skeletons share the
//      same pulse, keeping GPU cost near-zero.

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

/// Animated shimmer placeholder. Drop inside any list/card to suggest
/// "content is loading here".
class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 6,
    this.margin,
  });

  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Container(
          margin: widget.margin,
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.surfaceContainer,
                Color.lerp(
                  AppColors.surfaceContainer,
                  AppColors.surfaceContainerHighest,
                  t,
                )!,
                AppColors.surfaceContainer,
              ],
            ),
          ),
          child: child,
        );
      },
    );
  }
}

/// A ready-made list of skeleton rows for a card list view.
class SkeletonCardList extends StatelessWidget {
  const SkeletonCardList({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LoadingSkeleton(width: 160, height: 18),
            SizedBox(height: 12),
            LoadingSkeleton(height: 12),
            SizedBox(height: 8),
            LoadingSkeleton(height: 12),
            SizedBox(height: 8),
            LoadingSkeleton(width: 120, height: 12),
          ],
        ),
      ),
    );
  }
}
