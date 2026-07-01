import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../shared/models/detachment_day_schema.dart';
import '../../../../app.dart';

class DetachmentHistoryPage extends ConsumerWidget {
  const DetachmentHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(detachmentRepositoryProvider);
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppAppBar(context: context, title: 'سجل المفرزات'),
      body: StreamBuilder<List<DetachmentDaySchema>>(
        stream: repo.streamDays(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'حدث خطأ: ${snapshot.error}',
                style: const TextStyle(fontFamily: 'Cairo', color: AppColors.error),
              ),
            );
          }
          final inactiveDays = (snapshot.data ?? [])
              .where((d) => !d.isActive)
              .toList()
            ..sort((a, b) {
              final aTime = a.date?.millisecondsSinceEpoch ?? 0;
              final bTime = b.date?.millisecondsSinceEpoch ?? 0;
              return bTime.compareTo(aTime);
            });

          if (inactiveDays.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: AppColors.onSurfaceVariant),
                  SizedBox(height: AppSizes.md),
                  Text(
                    'لا توجد مفرزات سابقة',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 16,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.marginMobile),
            itemCount: inactiveDays.length,
            itemBuilder: (context, index) {
              final day = inactiveDays[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: AppCard(
                  onTap: () => context.push('/detachment/${day.uid}'),
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              day.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Cairo',
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                            ),
                            child: const Text(
                              'منتهي',
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.xs),
                      if (day.date != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.xs),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 6),
                              Text(
                                DateFormatters.formatDateLong(day.date!, isArabic: isArabic),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Cairo',
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              day.location,
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'Cairo',
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
