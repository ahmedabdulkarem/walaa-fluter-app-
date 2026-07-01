import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/localization/locale_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppAppBar(
        context: context,
        title: '\u0627\u0644\u0625\u0639\u062F\u0627\u062F\u0627\u062A',
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.marginMobile),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language_outlined, color: AppColors.primary),
                  title: const Text(
                    '\u0627\u0644\u0644\u063A\u0629',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    isArabic ? '\u0627\u0644\u0639\u0631\u0628\u064A\u0629' : 'English',
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  trailing: Switch(
                    value: isArabic,
                    activeThumbColor: AppColors.primary,
                    onChanged: (value) {
                      ref.read(localeProvider.notifier).setLocale(
                        value ? const Locale('ar') : const Locale('en'),
                      );
                    },
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.primary),
                  title: const Text(
                    '\u0639\u0646 \u0627\u0644\u062A\u0637\u0628\u064A\u0642',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_left, color: AppColors.onSurfaceVariant),
                  onTap: () => context.push(RouteNames.about),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Center(
            child: Text(
              '\u0627\u0644\u0625\u0635\u062F\u0627\u0631 1.0.0',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
