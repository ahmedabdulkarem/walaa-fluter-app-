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
import '../../features/detachment/presentation/pages/detachment_form_page.dart';
import '../../features/detachment/presentation/pages/detachment_history_page.dart';
import '../../features/detachment/presentation/pages/detachment_day_detail_page.dart';
import '../../features/detachment/presentation/pages/detachment_stats_page.dart';
import '../../features/detachment/presentation/pages/detachment_days_page.dart';
import '../../features/detachment/presentation/pages/day_shifts_page.dart';
import '../../features/workshops/presentation/pages/workshops_list_page.dart';
import '../../features/workshops/presentation/pages/workshop_form_page.dart';
import '../../features/workshops/presentation/pages/workshop_detail_page.dart';
import '../../features/team/presentation/pages/team_members_page.dart';
import '../../features/admin_management/presentation/pages/admin_edit_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/profile_edit_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/about_page.dart';
import '../../features/support/presentation/pages/support_list_page.dart';
import '../../features/support/presentation/pages/support_form_page.dart';
import '../../features/support/presentation/pages/support_detail_page.dart';
import '../../features/applications/presentation/pages/application_form_page.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

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

        // ── 4-Branch Shell ─────────────────────────────────────
        StatefulShellRoute.indexedStack(
          builder: (_, _, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            // 1. Dashboard
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.dashboard,
                  builder: (_, _) => const HomeDashboardPage(),
                ),
              ],
            ),

            // 2. Deployments (مفارز)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.deployments,
                  builder: (_, _) => const DetachmentDaysPage(),
                  routes: [
                    GoRoute(
                      path: 'form',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (_, _) =>
                          const DetachmentFormPage(),
                    ),
                    GoRoute(
                      path: 'history',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (_, _) =>
                          const DetachmentHistoryPage(),
                    ),
                    GoRoute(
                      path: ':dayId',
                      builder: (_, state) =>
                          DetachmentDayDetailPage(
                        dayId: state.pathParameters['dayId'] ?? '',
                      ),
                      routes: [
                        GoRoute(
                          path: 'day-shifts/:weekDay',
                          builder: (_, state) =>
                              DayShiftsPage(
                            detachmentId:
                                state.pathParameters['dayId'] ?? '',
                            weekDayKey:
                                state.pathParameters['weekDay'] ?? '',
                          ),
                        ),
                        GoRoute(
                          path: 'stats',
                          parentNavigatorKey: _rootNavigatorKey,
                          pageBuilder: (_, state) =>
                              NoTransitionPage(
                            child:
                                const DetachmentStatsPage(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // 3. Workshops (ورشات)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.workshops,
                  builder: (_, _) => const WorkshopsListPage(),
                  routes: [
                    GoRoute(
                      path: 'form',
                      parentNavigatorKey: _rootNavigatorKey,
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

            // 4. Members & Permissions (الأعضاء والصلاحيات)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: RouteNames.members,
                  builder: (_, _) => const TeamMembersPage(),
                  routes: [
                    GoRoute(
                      path: ':id/edit',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (_, state) => AdminEditPage(
                        adminId:
                            state.pathParameters['id'] ?? '',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // ── Standalone routes ──────────────────────────────────
        GoRoute(
          path: RouteNames.profile,
          builder: (_, _) => const ProfilePage(),
        ),
        GoRoute(
          path: RouteNames.profileEdit,
          builder: (_, _) => const ProfileEditPage(),
        ),
        GoRoute(
          path: RouteNames.settings,
          builder: (_, _) => const SettingsPage(),
        ),
        GoRoute(
          path: RouteNames.about,
          builder: (_, _) => const AboutPage(),
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
      ],
    );
  }
}

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
              top: BorderSide(color: AppColors.divider)),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) =>
              navigationShell.goBranch(index,
                  initialLocation: index == navigationShell.currentIndex),
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
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emergency_outlined),
              activeIcon: Icon(Icons.emergency),
              label: 'مفارز',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school),
              label: 'ورشات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'الأعضاء',
            ),
          ],
        ),
      ),
    );
  }
}
