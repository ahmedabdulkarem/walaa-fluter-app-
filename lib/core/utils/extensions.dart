// lib/core/utils/extensions.dart
// WHY: Convenience extensions on BuildContext, String, DateTime used throughout the app.

import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  void showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

extension StringX on String {
  bool get isBlank => trim().isEmpty;
  bool get isNotBlank => !isBlank;
  String get capitalize => isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}

extension DateTimeX on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isPast => isBefore(DateTime.now());
  bool get isFuture => isAfter(DateTime.now());

  DateTime get dateOnly => DateTime(year, month, day);
}