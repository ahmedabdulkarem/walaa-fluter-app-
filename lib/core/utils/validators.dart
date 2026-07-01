// lib/core/utils/validators.dart
// WHY: Centralized form validation functions — used across all form widgets.

class Validators {
  Validators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الاسم مطلوب';
    }
    if (value.trim().length < 3) {
      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'بريد إلكتروني غير صالح';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرمز مطلوب';
    }
    if (value.length < 8) {
      return 'الرمز يجب أن يكون 8 أحرف على الأقل';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // phone is optional
    final phoneRegex = RegExp(r'^[+]?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'رقم هاتف غير صالح';
    }
    return null;
  }

  static String? number(String? value, {int? min, int? max}) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    final n = int.tryParse(value.trim());
    if (n == null) return 'يجب إدخال رقم';
    if (min != null && n < min) return 'القيمة يجب أن تكون $min على الأقل';
    if (max != null && n > max) return 'القيمة يجب أن تكون $max على الأكثر';
    return null;
  }

  static String? time(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الوقت مطلوب';
    }
    final timeRegex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    if (!timeRegex.hasMatch(value.trim())) {
      return 'صيغة الوقت غير صالحة (HH:MM)';
    }
    return null;
  }
}