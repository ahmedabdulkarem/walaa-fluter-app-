import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_app_bar.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppAppBar(
        context: context,
        title: '\u0639\u0646 \u0627\u0644\u062A\u0637\u0628\u064A\u0642',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.marginMobile),
        child: Column(
          children: [
            const SizedBox(height: AppSizes.xl),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            const Text(
              '\u0641\u0631\u064A\u0642 \u0627\u0644\u0648\u0644\u0627\u0621 \u0627\u0644\u0637\u0628\u064A',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              '\u0627\u0644\u0625\u0635\u062F\u0627\u0631 1.0.0',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Cairo',
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '\u0639\u0646 \u0627\u0644\u062A\u0637\u0628\u064A\u0642',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  const Text(
                    '\u062A\u0637\u0628\u064A\u0642 \u0641\u0631\u064A\u0642 \u0627\u0644\u0648\u0644\u0627\u0621 \u0627\u0644\u0637\u0628\u064A \u0647\u0648 \u0645\u0646\u0635\u0629 \u0645\u062A\u0643\u0627\u0645\u0644\u0629 \u0644\u0625\u062F\u0627\u0631\u0629 \u0627\u0644\u0641\u0631\u064A\u0642 \u0627\u0644\u0637\u0628\u064A \u0627\u0644\u062A\u0637\u0648\u0639\u064A\u060C \u062A\u0648\u0641\u0631 \u0623\u062F\u0648\u0627\u062A \u0644\u0625\u062F\u0627\u0631\u0629 \u0627\u0644\u0645\u0641\u0631\u0632\u0627\u062A \u0648\u0627\u0644\u0648\u0631\u0634 \u0648\u0627\u0644\u0628\u0648\u0633\u062A\u0627\u062A \u0648\u062A\u0646\u0638\u064A\u0645 \u0627\u0644\u0641\u0631\u064A\u0642 \u0628\u0643\u0641\u0627\u0621\u0629.',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Cairo',
                      color: AppColors.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '\u0645\u0639\u0644\u0648\u0645\u0627\u062A \u0627\u0644\u062A\u0637\u0648\u064A\u0631',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  _devInfo('\u0627\u0644\u0645\u0637\u0648\u0631', '\u0641\u0631\u064A\u0642 \u0627\u0644\u0648\u0644\u0627\u0621 \u0627\u0644\u0637\u0628\u064A'),
                  const SizedBox(height: AppSizes.xs),
                  _devInfo('\u0627\u0644\u0625\u0635\u062F\u0627\u0631', '1.0.0'),
                  const SizedBox(height: AppSizes.xs),
                  _devInfo('\u0627\u0644\u0646\u0638\u0627\u0645', 'Flutter \u00B7 Android \u00B7 iOS \u00B7 Web \u00B7 Desktop'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _devInfo(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
