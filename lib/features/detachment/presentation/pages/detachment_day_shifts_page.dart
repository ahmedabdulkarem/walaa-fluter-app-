import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../models/detachment_day_model.dart';
import '../../models/detachment_shift_model.dart';
import '../../../../app.dart';
import 'shift_form_page.dart';

class DetachmentDayShiftsPage extends ConsumerStatefulWidget {
  const DetachmentDayShiftsPage({super.key});

  @override
  ConsumerState<DetachmentDayShiftsPage> createState() =>
      _DetachmentDayShiftsPageState();
}

class _DetachmentDayShiftsPageState
    extends ConsumerState<DetachmentDayShiftsPage> {
  @override
  Widget build(BuildContext context) {
    final dayId =
        GoRouterState.of(context).pathParameters['dayId'] ?? '';
    final repo = ref.watch(detachmentNewRepoProvider);
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';
    final user = ref.watch(currentUserProvider).valueOrNull;
    final canManage = user?.can('manage_detachment') == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: StreamBuilder<List<DetachmentDayModel>>(
          stream: repo.watchDays(),
          builder: (context, snapshot) {
            final days = snapshot.data ?? [];
            final day =
                days.where((d) => d.uid == dayId).firstOrNull;
            return Text(
              day != null
                  ? '${day.dayName} - ${DateFormatters.formatDate(day.dayDate, isArabic: isArabic)}'
                  : 'تفاصيل اليوم',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              ),
            );
          },
        ),
        centerTitle: true,
      ),
      floatingActionButton: canManage
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                      builder: (_) => const ShiftFormPage()),
                );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add,
                  color: AppColors.onPrimary),
            )
          : null,
      body: StreamBuilder<List<DetachmentShiftModel>>(
        stream: repo.watchShiftsForDay(dayId),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'حدث خطأ: ${snapshot.error}',
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.error),
                  ),
                ],
              ),
            );
          }

          final shifts = snapshot.data ?? [];

          if (shifts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule_outlined,
                      size: 64,
                      color: AppColors.onSurfaceVariant),
                  SizedBox(height: AppSizes.md),
                  Text(
                    'لا توجد شفتات لهذا اليوم',
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
            padding:
                const EdgeInsets.all(AppSizes.marginMobile),
            itemCount: shifts.length + 1,
            itemBuilder: (context, index) {
              if (index == shifts.length) {
                return const SizedBox(height: 80);
              }
              final shift = shifts[index];
              return Padding(
                padding:
                    const EdgeInsets.only(bottom: AppSizes.sm),
                child: GestureDetector(
                  onTap: () => context.push(
                    '/detachment/manage/$dayId/shifts/${shift.uid}',
                    extra: shift.memberIds,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                          AppSizes.radiusMd),
                      border: Border.all(
                          color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryContainer
                              .withValues(alpha: 0.06),
                          blurRadius: AppSizes.shadowBlur,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                shift.shiftName.isNotEmpty
                                    ? shift.shiftName
                                    : 'شفت',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Cairo',
                                  color: AppColors.onSurface,
                                ),
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primarySurface,
                                borderRadius: BorderRadius
                                    .circular(
                                        AppSizes.radiusFull),
                              ),
                              child: Text(
                                '${shift.memberCount} أعضاء',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            if (canManage) ...[
                              const SizedBox(width: 4),
                              InkWell(
                                borderRadius:
                                    BorderRadius.circular(
                                        20),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ShiftFormPage(
                                              initialShift:
                                                  shift),
                                    ),
                                  );
                                },
                                child: const Padding(
                                  padding:
                                      EdgeInsets.all(4),
                                  child: Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color:
                                          AppColors.primary),
                                ),
                              ),
                              InkWell(
                                borderRadius:
                                    BorderRadius.circular(
                                        20),
                                onTap: () =>
                                    _deleteShift(shift),
                                child: const Padding(
                                  padding:
                                      EdgeInsets.all(4),
                                  child: Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color:
                                          AppColors.error),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(
                            height: AppSizes.xs),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 14,
                                color: AppColors
                                    .onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(
                              '${shift.startTime} - ${shift.endTime}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'Cairo',
                                color: AppColors
                                    .onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(
                                width: AppSizes.md),
                            if (shift.leaderId.isNotEmpty) ...[
                              const Icon(
                                  Icons.admin_panel_settings,
                                  size: 14,
                                  color: AppColors.goldBright),
                              const SizedBox(width: 4),
                              const Text('له مسؤول',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Cairo',
                                    color: AppColors.goldBright,
                                  )),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteShift(DetachmentShiftModel shift) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الشفت',
            style: TextStyle(fontFamily: 'Cairo')),
        content: Text(
          'هل أنت متأكد من حذف "${shift.shiftName.isNotEmpty ? shift.shiftName : "الشفت"}"؟',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء',
                style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('حذف',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.onPrimary)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await ref
        .read(detachmentNewRepoProvider)
        .deleteShift(shift.uid);
    if (!mounted) return;
    result.fold(
      (failure) => context.showSnackBar(
          'فشل الحذف: ${failure.message}',
          backgroundColor: AppColors.error),
      (_) => context.showSnackBar('تم حذف الشفت'),
    );
  }
}
