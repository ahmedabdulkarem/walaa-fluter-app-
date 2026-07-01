// lib/core/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import 'route_names.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/language/presentation/pages/language_selection_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/widgets/session_expired_screen.dart';
import '../../features/home/presentation/pages/home_dashboard_page.dart';
import '../../features/posts/presentation/pages/posts_list_page.dart';
import '../../features/posts/presentation/pages/post_form_page.dart';
import '../../features/posts/presentation/pages/post_detail_page.dart';
import '../../features/team/presentation/pages/team_page.dart';
import '../../features/team/presentation/pages/team_leadership_page.dart';
import '../../features/detachment/presentation/pages/detachment_list_page.dart';
import '../../features/detachment/presentation/pages/detachment_form_page.dart';
import '../../features/detachment/presentation/pages/detachment_history_page.dart';
import '../../features/detachment/presentation/pages/detachment_day_detail_page.dart';
import '../../features/detachment/presentation/pages/detachment_stats_page.dart';
import '../../features/detachment/presentation/pages/detachment_days_page.dart';
import '../../features/detachment/presentation/pages/detachment_day_shifts_page.dart';
import '../../features/detachment/presentation/pages/shift_members_page.dart';
import '../../features/workshops/presentation/pages/workshops_list_page.dart';
import '../../features/workshops/presentation/pages/workshop_form_page.dart';
import '../../features/workshops/presentation/pages/workshop_detail_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/admin_management/presentation/pages/admin_list_page.dart';
import '../../features/admin_management/presentation/pages/admin_edit_page.dart';
import '../../features/support/presentation/pages/support_list_page.dart';
import '../../features/support/presentation/pages/support_form_page.dart';
import '../../features/support/presentation/pages/support_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/profile_edit_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/about_page.dart';
import '../../features/cms/presentation/pages/cms_list_page.dart';
import '../../features/cms/presentation/pages/cms_form_page.dart';
import '../../features/applications/presentation/pages/application_list_page.dart';
import '../../features/applications/presentation/pages/application_form_page.dart';
import '../../features/cms/presentation/pages/dynamic_fields_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter create({required String initialAccess}) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: RouteNames.splash,
      redirect: (context, state) {
        final isOnSplash = state.uri.path == RouteNames.splash;
        final isOnLanguage = state.uri.path == RouteNames.language;
        final isOnLogin = state.uri.path == RouteNames.login;
        final isOnSessionExpired =
            state.uri.path == RouteNames.sessionExpired;
        final isOnApply = state.uri.path == RouteNames.applicationForm;

        if (isOnSplash || isOnLanguage || isOnLogin ||
            isOnSessionExpired || isOnApply) {
          return null;
        }

        if (!AuthService.isLoggedIn) return RouteNames.login;

        return null;
      },
      routes: [
        GoRoute(
          path: RouteNames.splash,
          builder: (_, _) =>
              SplashPage(initialAccess: initialAccess),
        ),
        GoRoute(
          path: RouteNames.language,
          builder: (_, _) => const LanguageSelectionPage(),
        ),
        GoRoute(
          path: RouteNames.login,
          builder: (_, _) => const LoginPage(),
        ),
        GoRoute(
          path: RouteNames.sessionExpired,
          builder: (_, _) => const SessionExpiredScreen(),
        ),
        GoRoute(
          path: RouteNames.applicationForm,
          builder: (_, _) => const ApplicationFormPage(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (_, _, child) =>
              HomeDashboardShell(child: child),
          routes: [
            GoRoute(
              path: RouteNames.home,
              builder: (_, _) => const HomeDashboardPage(),
            ),
            GoRoute(
              path: RouteNames.posts,
              builder: (_, _) => const PostsListPage(),
              routes: [
                GoRoute(
                  path: 'form',
                  builder: (_, state) => PostFormPage(
                    post: state.extra as dynamic,
                  ),
                ),
                GoRoute(
                  path: ':id',
                  builder: (_, state) => const PostDetailPage(),
                ),
              ],
            ),
            GoRoute(
              path: RouteNames.team,
              builder: (_, _) => const TeamPage(),
              routes: [
                GoRoute(
                  path: 'leadership',
                  builder: (_, _) =>
                      const TeamLeadershipPage(),
                ),
              ],
            ),
            GoRoute(
              path: RouteNames.detachment,
              builder: (_, _) => const DetachmentListPage(),
              routes: [
                GoRoute(
                  path: 'form',
                  builder: (_, _) =>
                      const DetachmentFormPage(),
                ),
                GoRoute(
                  path: 'history',
                  builder: (_, _) =>
                      const DetachmentHistoryPage(),
                ),
                GoRoute(
                  path: ':dayId',
                  builder: (_, state) =>
                      const DetachmentDayDetailPage(),
                  routes: [
                    GoRoute(
                      path: 'stats',
                      builder: (_, state) =>
                          const DetachmentStatsPage(),
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: RouteNames.workshops,
              builder: (_, _) =>
                  const WorkshopsListPage(),
              routes: [
                GoRoute(
                  path: 'form',
                  builder: (_, state) => WorkshopFormPage(
                    workshop: state.extra as dynamic,
                  ),
                ),
                GoRoute(
                  path: ':id',
                  builder: (_, state) => WorkshopDetailPage(
                    id: state.pathParameters['id'] ?? '',
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.notifications,
          builder: (_, _) => const NotificationsPage(),
        ),
        GoRoute(
          path: RouteNames.detachmentManage,
          builder: (_, _) => const DetachmentDaysPage(),
          routes: [
            GoRoute(
              path: ':dayId',
              builder: (_, state) =>
                  const DetachmentDayShiftsPage(),
              routes: [
                GoRoute(
                  path: 'shifts/:shiftId',
                  builder: (_, state) =>
                      const ShiftMembersPage(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.adminManagement,
          builder: (_, _) => const AdminListPage(),
          routes: [
            GoRoute(
              path: ':id/edit',
              builder: (_, state) => AdminEditPage(
                adminId: state.pathParameters['id'] ?? '',
              ),
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.support,
          builder: (_, _) => const SupportListPage(),
          routes: [
            GoRoute(
              path: 'new',
              builder: (_, _) => const SupportFormPage(),
            ),
            GoRoute(
              path: ':id',
              builder: (_, state) => SupportDetailPage(
                ticketId: state.pathParameters['id'] ?? '',
              ),
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.profile,
          builder: (_, _) => const ProfilePage(),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (_, _) => const ProfileEditPage(),
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.settings,
          builder: (_, _) => const SettingsPage(),
          routes: [
            GoRoute(
              path: 'about',
              builder: (_, _) => const AboutPage(),
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.cms,
          builder: (_, _) => const CmsListPage(),
          routes: [
            GoRoute(
              path: 'form',
              builder: (_, state) => CmsFormPage(
                sectionKey: state.extra as String?,
              ),
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.applications,
          builder: (_, _) => const ApplicationListPage(),
        ),
        GoRoute(
          path: RouteNames.dynamicFields,
          builder: (_, _) => const DynamicFieldsPage(),
        ),
      ],
    );
  }
}

class HomeDashboardShell extends StatelessWidget {
  final Widget child;
  const HomeDashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
              top: BorderSide(color: AppColors.divider)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex(context),
          onTap: (index) => _onTap(context, index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.onSurfaceVariant,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.feed_outlined),
              activeIcon: Icon(Icons.feed),
              label: 'البوستات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              activeIcon: Icon(Icons.groups),
              label: 'الفريق',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emergency_outlined),
              activeIcon: Icon(Icons.emergency),
              label: 'المفرزة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school),
              label: 'الورش',
            ),
          ],
        ),
      ),
    );
  }

  int _currentIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path.startsWith('/posts')) return 1;
    if (path.startsWith('/team')) return 2;
    if (path.startsWith('/detachment')) return 3;
    if (path.startsWith('/workshops')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.posts);
        break;
      case 2:
        context.go(RouteNames.team);
        break;
      case 3:
        context.go(RouteNames.detachment);
        break;
      case 4:
        context.go(RouteNames.workshops);
        break;
    }
  }
}
