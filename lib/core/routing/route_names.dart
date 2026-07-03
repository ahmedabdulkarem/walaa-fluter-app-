class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String language = '/language';
  static const String login = '/login';
  static const String setup = '/setup';
  static const String sessionExpired = '/session-expired';

  // === 3 Nav Branches ===
  static const String dashboard = '/dashboard';
  static const String deployments = '/deployments';
  static const String workshops = '/workshops';

  // Deployments sub-routes
  static const String deploymentDayDetails = '/deployments/:dayId';
  static const String deploymentForm = '/deployments/form';
  static const String deploymentHistory = '/deployments/history';

  // Workshops sub-routes
  static const String workshopDetails = '/workshops/:id';
  static const String workshopForm = '/workshops/form';

  // Standalone routes (outside shell)
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String settings = '/settings';
  static const String about = '/settings/about';

  // Application form (public, outside shell)
  static const String applicationForm = '/apply';

  // Support (standalone)
  static const String support = '/support';
  static const String supportNew = '/support/new';
  static const String supportDetails = '/support/:id';

  // Helpers
  static String deploymentDayPath(String dayId) => '/deployments/$dayId';
  static String workshopDetailsPath(String id) => '/workshops/$id';
  static String supportDetailsPath(String id) => '/support/$id';
}
