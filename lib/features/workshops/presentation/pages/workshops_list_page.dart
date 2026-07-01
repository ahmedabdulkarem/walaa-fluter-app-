import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../app.dart';

class WorkshopsListPage extends ConsumerWidget {
  const WorkshopsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';
    final workshopsStream =
        ref.watch(workshopRepositoryProvider).streamWorkshops();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppAppBar(context: context, title: 'الورش'),
      body: StreamBuilder(
        stream: workshopsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final workshops = snapshot.data ?? [];
          if (workshops.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'لا توجد ورش',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'يمكنك إضافة ورشة جديدة من الزر أدناه',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.marginMobile),
            itemCount: workshops.length,
            itemBuilder: (context, index) {
              final w = workshops[index];
              final status = WorkshopStatus.fromString(w.status);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: AppCard(
                  onTap: () =>
                      context.push(RouteNames.workshopDetailsPath(w.uid)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              w.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          _StatusBadge(status: status),
                        ],
                      ),
                      if (w.instructorName.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.xs),
                        Row(
                          children: [
                            const Icon(Icons.person_outline,
                                size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                w.instructorName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.onSurfaceVariant),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (w.dateTime != null) ...[
                        const SizedBox(height: AppSizes.xs),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                DateFormatters.formatDateTime(w.dateTime!,
                                    isArabic: isArabic),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.onSurfaceVariant),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSizes.xs),
                      Row(
                        children: [
                          const Icon(Icons.people_outline,
                              size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'السعة: ${w.capacity}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.onSurfaceVariant),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSizes.md),
                          const Icon(Icons.attach_money,
                              size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${w.subscriptionFee.toStringAsFixed(0)} د.ل',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.onSurfaceVariant),
                              overflow: TextOverflow.ellipsis,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        onPressed: () => context.push(RouteNames.workshopForm),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final WorkshopStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (status) {
      WorkshopStatus.upcoming => (const Color(0xFFDBEAFE), const Color(0xFF1E40AF), 'قادمة'),
      WorkshopStatus.active => (const Color(0xFFDCFCE7), const Color(0xFF166534), 'نشطة'),
      WorkshopStatus.completed => (const Color(0xFFF3F4F6), const Color(0xFF4B5563), 'منتهية'),
      WorkshopStatus.cancelled => (const Color(0xFFFEE2E2), const Color(0xFF991B1B), 'ملغاة'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}
