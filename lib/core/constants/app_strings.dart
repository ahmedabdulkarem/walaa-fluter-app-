// lib/core/constants/app_strings.dart
// WHY: Non-localized constants — Firestore collection names, shared prefs keys, env keys.

class AppStrings {
  AppStrings._();

  // ── Environment Keys ──────────────────────────────────
  static const String envSuperAdminEmail = 'SUPER_ADMIN_EMAIL';

  // ── SharedPreferences Keys ────────────────────────────
  static const String prefLocale = 'app_locale';
  static const String prefThemeMode = 'app_theme_mode';
  static const String prefOnboardingDone = 'onboarding_done';

  // ── Firestore Collection Names ────────────────────────
  static const String colUsers = 'users';
  static const String colPosts = 'posts';
  static const String colTeamInfoSections = 'team_info_sections';
  static const String colTeamMembers = 'team_members';
  static const String colDetachmentDays = 'detachment_days';
  static const String colDetachmentShifts = 'shifts';
  static const String colDetachmentStats = 'stats';
  static const String colWorkshops = 'workshops';
  static const String colWorkshopStaff = 'staff';
  static const String colWorkshopAttendees = 'attendees';
  static const String colSupportTickets = 'support_tickets';
  static const String colNotifications = 'notifications';
  static const String colAppSettings = 'app_settings';
  static const String colDetachmentMembers = 'detachment_members';
  static const String colDetachmentDaysNew = 'detachment_days';
  static const String colDetachmentShiftsNew = 'detachment_shifts';

  // ── Storage Paths ─────────────────────────────────────
  static const String storagePostImages = 'post_images';
  static const String storageProfilePhotos = 'profile_photos';
  static const String storageMemberPhotos = 'member_photos';
}