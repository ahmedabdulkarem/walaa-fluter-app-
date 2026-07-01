// lib/core/widgets/app_card.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool isPinned;
  final bool isUrgent;
  final VoidCallback? onTap;

  const AppCard({
    required this.child,
    this.padding,
    this.isPinned = false,
    this.isUrgent = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border(
            top: const BorderSide(color: AppColors.border),
            left: const BorderSide(color: AppColors.border),
            bottom: const BorderSide(color: AppColors.border),
            right: BorderSide(
              color: isPinned
                  ? AppColors.goldBright
                  : isUrgent
                      ? AppColors.danger
                      : AppColors.border,
              width: (isPinned || isUrgent) ? AppSizes.goldBorderWidth : 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.06),
              blurRadius: AppSizes.shadowBlur,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSizes.md),
          child: child,
        ),
      ),
    );
  }
}
