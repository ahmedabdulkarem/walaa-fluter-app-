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

class DetachmentListPage extends ConsumerStatefulWidget {
  const DetachmentListPage({super.key});

  @override
  ConsumerState<DetachmentListPage> createState() => _DetachmentListPageState();
}

class _DetachmentListPageState extends ConsumerState<DetachmentListPage> {
  Future<void> _deleteDay(DetachmentDaySchema day) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المفرزة', style: TextStyle(fontFamily: 'Cairo')),
        content: Text(
          'هل أنت متأكد من حذف "${day.title}"؟\nسيتم حذف جميع الورديات والفرق المرتبطة بها.',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: AppColors.onPrimary)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    final result = await ref.read(detachmentRepositoryProvider).deleteDay(day.uid, user);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الحذف: ${failure.message}'), backgroundColor: AppColors.error),
      ),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المفرزة'), backgroundColor: AppColors.success),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(detachmentRepositoryProvider);
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';
    final user = ref.watch(currentUserProvider).valueOrNull;
    final canManage = user?.can('manage_detachment') == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppAppBar(context: context, title: 'المفرزات'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/detachment/form'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
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
          final days = snapshot.data ?? [];
          if (days.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emergency_outlined, size: 64, color: AppColors.onSurfaceVariant),
                  SizedBox(height: AppSizes.md),
                  Text(
                    'لا توجد مفرزات بعد',
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

          final sortedDays = List<DetachmentDaySchema>.from(days)
            ..sort((a, b) {
              if (a.isActive != b.isActive) {
                return a.isActive ? -1 : 1;
              }
              final aTime = a.date?.millisecondsSinceEpoch ?? 0;
              final bTime = b.date?.millisecondsSinceEpoch ?? 0;
              return bTime.compareTo(aTime);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.marginMobile),
            itemCount: sortedDays.length + 1,
            itemBuilder: (context, index) {
              if (index == sortedDays.length) {
                return const SizedBox(height: 80);
              }
              final day = sortedDays[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: AppCard(
                  onTap: () => context.push('/detachment/${day.uid}'),
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: day.isActive ? AppColors.successLight : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                            ),
                            child: Text(
                              day.isActive ? 'نشط' : 'منتهي',
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w500,
                                color: day.isActive ? AppColors.success : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          if (canManage) ...[
                            const SizedBox(width: 4),
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _deleteDay(day),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                              ),
                            ),
                          ],
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
                              Flexible(
                                child: Text(
                                  DateFormatters.formatDateLong(day.date!, isArabic: isArabic),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Cairo',
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
    );
  }
}
