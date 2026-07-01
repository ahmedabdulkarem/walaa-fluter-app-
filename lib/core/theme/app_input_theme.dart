// lib/core/theme/app_input_theme.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppInputTheme {
  AppInputTheme._();

  static InputDecorationTheme buildTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md, vertical: AppSizes.sm),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      hintStyle: const TextStyle(color: AppColors.outline, fontSize: 14),
      labelStyle: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
    );
  }
}
