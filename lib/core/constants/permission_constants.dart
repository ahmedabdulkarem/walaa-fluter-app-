// lib/core/constants/permission_constants.dart
// WHY: String constants for every permission key used in permission checks and Firestore documents.

class PermissionConstants {
  PermissionConstants._();

  // Post permissions
  static const String publishPosts = 'publish_posts';
  static const String editDeletePosts = 'edit_delete_posts';

  // Detachment permissions
  static const String manageDetachment = 'manage_detachment';
  static const String recordDetachmentShifts = 'record_detachment_shifts';
  static const String addPatientStats = 'add_patient_stats';

  // Workshop permissions
  static const String manageWorkshops = 'manage_workshops';
  static const String addWorkshopAttendees = 'add_workshop_attendees';
  static const String confirmPayment = 'confirm_payment';
  static const String recordWorkshopAttendance = 'record_workshop_attendance';

  // General
  static const String viewGeneralStats = 'view_general_stats';

  // All permissions list (for admin creation checklist UI)
  static const List<Map<String, String>> allPermissions = [
    {
      'key': publishPosts,
      'labelAr': 'نشر بوستات',
      'labelEn': 'Publish Posts',
    },
    {
      'key': editDeletePosts,
      'labelAr': 'تعديل/حذف البوستات',
      'labelEn': 'Edit/Delete Posts',
    },
    {
      'key': manageDetachment,
      'labelAr': 'إدارة المفرزة',
      'labelEn': 'Manage Detachment',
    },
    {
      'key': recordDetachmentShifts,
      'labelAr': 'تسجيل حضور المفرزة',
      'labelEn': 'Record Detachment Shifts',
    },
    {
      'key': addPatientStats,
      'labelAr': 'إضافة إحصائيات المرضى',
      'labelEn': 'Add Patient Stats',
    },
    {
      'key': manageWorkshops,
      'labelAr': 'إدارة الورش',
      'labelEn': 'Manage Workshops',
    },
    {
      'key': addWorkshopAttendees,
      'labelAr': 'إضافة المشتركين للورش',
      'labelEn': 'Add Workshop Attendees',
    },
    {
      'key': confirmPayment,
      'labelAr': 'تأكيد دفع الاشتراك',
      'labelEn': 'Confirm Subscription Payment',
    },
    {
      'key': recordWorkshopAttendance,
      'labelAr': 'تسجيل حضور الورشة',
      'labelEn': 'Record Workshop Attendance',
    },
    {
      'key': viewGeneralStats,
      'labelAr': 'مشاهدة إحصائيات عامة',
      'labelEn': 'View General Stats',
    },
  ];
}