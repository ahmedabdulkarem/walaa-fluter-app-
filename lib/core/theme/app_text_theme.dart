// lib/core/theme/app_text_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextTheme {
  static TextTheme buildTextTheme(bool isArabic) {
    final baseTheme = isArabic
        ? GoogleFonts.cairoTextTheme()
        : GoogleFonts.interTextTheme();

    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      headlineMedium: baseTheme.headlineMedium?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.27,
      ),
      titleLarge: baseTheme.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.33,
      ),
      bodyLarge: baseTheme.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: baseTheme.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
      ),
      labelSmall: baseTheme.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
    );
  }

  static TextStyle displayLgMobile(bool isArabic) => TextStyle(
    fontFamily: isArabic ? 'Cairo' : 'Inter',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.29,
  );
}
