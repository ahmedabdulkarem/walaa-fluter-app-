import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../app.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppAppBar(
        context: context,
        title: '\u0627\u0644\u0645\u0644\u0641 \u0627\u0644\u0634\u062E\u0635\u064A',
      ),
      body: user == null
          ? Center(
              child: Text(
                '\u064A\u0631\u062C\u0649 \u062A\u0633\u062C\u064A\u0644 \u0627\u0644\u062F\u062E\u0648\u0644',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.onSurfaceVariant),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.marginMobile),
              child: Column(
                children: [
                  AppCard(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSizes.md),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                          ),
                          child: Center(
                            child: Text(
                              user.displayName.isNotEmpty
                                  ? user.displayName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 32,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          user.displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Cairo',
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        _roleBadge(user.role),
                        const SizedBox(height: AppSizes.md),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoItem(Icons.badge_outlined,
                            '\u0627\u0644\u0642\u0633\u0645', user.department ?? '\u2014'),
                        const Divider(height: 24, color: AppColors.divider),
                        _infoItem(Icons.phone_outlined,
                            '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062A\u0641', user.phone ?? '\u2014'),
                        const Divider(height: 24, color: AppColors.divider),
                        _infoItem(Icons.language_outlined,
                            '\u0627\u0644\u0644\u063A\u0629', user.language == 'ar' ? '\u0627\u0644\u0639\u0631\u0628\u064A\u0629' : 'English'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(RouteNames.profileEdit),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text(
                        '\u062A\u0639\u062F\u064A\u0644 \u0627\u0644\u0645\u0644\u0641',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _showSignOutDialog(context, ref),
                      icon: const Icon(Icons.logout_outlined, color: AppColors.danger),
                      label: const Text(
                        '\u062A\u0633\u062C\u064A\u0644 \u0627\u0644\u062E\u0631\u0648\u062C',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _roleBadge(String role) {
    Color bgColor;
    Color textColor;
    String label;

    switch (role) {
      case 'super_admin':
        bgColor = AppColors.goldLight;
        textColor = AppColors.goldDark;
        label = '\u0627\u0644\u0645\u0634\u0631\u0641 \u0627\u0644\u0639\u0627\u0645';
      case 'sub_admin':
        bgColor = AppColors.primarySurface;
        textColor = AppColors.primary;
        label = '\u0645\u062F\u064A\u0631';
      case 'volunteer':
        bgColor = AppColors.surfaceContainerHighest;
        textColor = AppColors.volunteerBlue;
        label = '\u0645\u062A\u0637\u0648\u0639';
      default:
        bgColor = AppColors.surfaceContainerHighest;
        textColor = AppColors.onSurfaceVariant;
        label = '\u0636\u064A\u0641';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontFamily: 'Cairo',
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
        const SizedBox(width: AppSizes.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Cairo',
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              '\u062A\u0633\u062C\u064A\u0644 \u0627\u0644\u062E\u0631\u0648\u062C',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
            ),
            content: const Text(
              '\u0647\u0644 \u0623\u0646\u062A \u0645\u062A\u0623\u0643\u062F \u0645\u0646 \u062A\u0633\u062C\u064A\u0644 \u0627\u0644\u062E\u0631\u0648\u062C\u061F',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  '\u0625\u0644\u063A\u0627\u0621',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  AuthService.logout();
                  context.go(RouteNames.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: AppColors.onError,
                ),
                child: const Text(
                  '\u062A\u0633\u062C\u064A\u0644 \u0627\u0644\u062E\u0631\u0648\u062C',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
