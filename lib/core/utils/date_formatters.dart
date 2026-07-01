// lib/core/utils/date_formatters.dart
// WHY: Centralized date formatting for both Arabic and English locales.

import 'package:intl/intl.dart';

class DateFormatters {
  DateFormatters._();

  static String formatDate(DateTime date, {bool isArabic = true}) {
    final pattern = isArabic ? 'yyyy/MM/dd' : 'MM/dd/yyyy';
    return DateFormat(pattern, isArabic ? 'ar' : 'en').format(date);
  }

  static String formatDateLong(DateTime date, {bool isArabic = true}) {
    final pattern = isArabic ? 'dd MMMM yyyy' : 'MMMM dd, yyyy';
    return DateFormat(pattern, isArabic ? 'ar' : 'en').format(date);
  }

  static String formatDateTime(DateTime date, {bool isArabic = true}) {
    final pattern = isArabic ? 'yyyy/MM/dd hh:mm a' : 'MM/dd/yyyy hh:mm a';
    return DateFormat(pattern, isArabic ? 'ar' : 'en').format(date);
  }

  static String formatTime(DateTime date, {bool isArabic = true}) {
    return DateFormat('hh:mm a', isArabic ? 'ar' : 'en').format(date);
  }

  static String timeAgo(DateTime date, {bool isArabic = true}) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return isArabic ? 'الآن' : 'Just now';
    } else if (diff.inMinutes < 60) {
      final mins = diff.inMinutes;
      return isArabic ? 'منذ $mins دقيقة' : '$mins min ago';
    } else if (diff.inHours < 24) {
      final hours = diff.inHours;
      return isArabic ? 'منذ $hours ساعة' : '$hours hr ago';
    } else if (diff.inDays < 7) {
      final days = diff.inDays;
      return isArabic ? 'منذ $days يوم' : '$days d ago';
    } else {
      return formatDate(date, isArabic: isArabic);
    }
  }

  static String sessionDurationLabel(int hours, {bool isArabic = true}) {
    return isArabic ? '$hours ساعات' : '$hours hours';
  }
}