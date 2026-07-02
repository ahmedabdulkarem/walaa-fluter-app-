// lib/core/routing/route_names.dart
// WHY: Typed route name constants — prevents hardcoding paths throughout the app.

class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String language = '/language';
  static const String login = '/login';
  static const String setup = '/setup';
  static const String sessionExpired = '/session-expired';
  static const String home = '/home';
  static const String notifications = '/notifications';

  // Posts
  static const String posts = '/posts';
  static const String postDetails = '/posts/:id';
  static const String postForm = '/posts/form';

  // Team
  static const String team = '/team';
  static const String teamLeadership = '/team/leadership';

  // Detachment
  static const String detachment = '/detachment';
  static const String detachmentDayDetails = '/detachment/:dayId';
  static const String detachmentForm = '/detachment/form';
  static const String detachmentStats = '/detachment/:dayId/stats';
  static const String detachmentHistory = '/detachment/history';
  static const String detachmentManage = '/detachment/manage';
  static const String detachmentManageDay = '/detachment/manage/:dayId';
  static const String detachmentManageShift = '/detachment/manage/:dayId/shifts/:shiftId';

  // Workshops
  static const String workshops = '/workshops';
  static const String workshopDetails = '/workshops/:id';
  static const String workshopForm = '/workshops/form';

  // Admin Management
  static const String adminManagement = '/management/admins';
  static const String adminEdit = '/management/admins/:id/edit';

  // Support
  static const String support = '/support';
  static const String supportNew = '/support/new';
  static const String supportDetails = '/support/:id';

  // CMS
  static const String cms = '/cms';
  static const String cmsForm = '/cms/form';

  // Applications
  static const String applications = '/applications';
  static const String applicationForm = '/apply';

  // Dynamic Fields
  static const String dynamicFields = '/dynamic-fields';

  // Profile & Settings
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String settings = '/settings';
  static const String about = '/settings/about';

  // Helpers
  static String postDetailsPath(String id) => '/posts/$id';
  static String detachmentDayPath(String dayId) => '/detachment/$dayId';
  static String detachmentStatsPath(String dayId) => '/detachment/$dayId/stats';
  static String detachmentManageDayPath(String dayId) => '/detachment/manage/$dayId';
  static String detachmentManageShiftPath(String dayId, String shiftId) => '/detachment/manage/$dayId/shifts/$shiftId';
  static String workshopDetailsPath(String id) => '/workshops/$id';
  static String adminEditPath(String id) => '/management/admins/$id/edit';
  static String supportDetailsPath(String id) => '/support/$id';
}