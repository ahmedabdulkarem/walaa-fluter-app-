import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../models/detachment_day_model.dart';
import '../../../../app.dart';

class DetachmentDaysPage extends ConsumerStatefulWidget {
  const DetachmentDaysPage({super.key});

  @override
  ConsumerState<DetachmentDaysPage> createState() => _DetachmentDaysPageState();
}

class _DetachmentDaysPageState extends ConsumerState<DetachmentDaysPage> {
  static const _dayNames = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  Future<void> _deleteDay(DetachmentDayModel day) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'حذف اليوم',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        content: Text(
          'هل أنت متأكد من حذف يوم "${day.dayName}"؟\nسيتم حذف جميع الشفتات المرتبطة به.',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child:
                const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف',
                style: TextStyle(
                    fontFamily: 'Cairo', color: AppColors.onPrimary)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result =
        await ref.read(detachmentNewRepoProvider).deleteDay(day.uid);
    if (!mounted) return;
    result.fold(
      (failure) => context.showSnackBar('فشل الحذف: ${failure.message}',
          backgroundColor: AppColors.error),
      (_) => context.showSnackBar('تم حذف اليوم'),
    );
  }

  void _showAddDayBottomSheet() {
    String? selectedDayName;
    DateTime? selectedDate;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: AppSizes.md,
                left: AppSizes.marginMobile,
                right: AppSizes.marginMobile,
                bottom: MediaQuery.of(ctx).viewInsets.bottom +
                    AppSizes.marginMobile,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusFull),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  const Text(
                    'إضافة يوم جديد',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo',
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  DropdownButtonFormField<String>(
                    hint: const Text(
                      'اختر اسم اليوم',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                    items: _dayNames
                        .map((name) => DropdownMenuItem(
                              value: name,
                              child: Text(name,
                                  style:
                                      const TextStyle(fontFamily: 'Cairo')),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setSheetState(() => selectedDayName = value);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppSizes.radiusDefault)),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setSheetState(() => selectedDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'التاريخ',
                        labelStyle:
                            const TextStyle(fontFamily: 'Cairo'),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppSizes.radiusDefault)),
                        suffixIcon: const Icon(Icons.calendar_today,
                            color: AppColors.primary),
                      ),
                      child: Text(
                        selectedDate != null
                            ? DateFormatters.formatDateLong(
                                selectedDate!,
                                isArabic: true)
                            : 'اختر التاريخ',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: selectedDate != null
                              ? AppColors.onSurface
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSaving || selectedDayName == null
                          ? null
                          : () async {
                              setSheetState(() => isSaving = true);
                              final dayDate = selectedDate ?? DateTime.now();
                              final weekDay = dayDate.weekday;
                              final user = ref
                                  .read(currentUserProvider)
                                  .valueOrNull;

                              final day = DetachmentDayModel(
                                uid: '',
                                dayName: selectedDayName!,
                                dayDate: dayDate,
                                weekDay: weekDay,
                                isActive: true,
                                createdAt: DateTime.now(),
                                createdBy: user?.uid ?? '',
                              );

                              final result = await ref
                                  .read(detachmentNewRepoProvider)
                                  .createDay(day);

                              if (!ctx.mounted) return;
                              setSheetState(() => isSaving = false);

                              result.fold(
                                (failure) {
                                  if (!mounted) return;
                                  context.showSnackBar(
                                    'فشل: ${failure.message}',
                                    backgroundColor: AppColors.error,
                                  );
                                },
                                (_) {
                                  Navigator.of(ctx).pop();
                                  if (!mounted) return;
                                  context.showSnackBar(
                                      'تم إنشاء اليوم بنجاح');
                                },
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppSizes.radiusDefault),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onPrimary),
                            )
                          : const Text(
                              'حفظ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Cairo',
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(detachmentNewRepoProvider);
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';
    final user = ref.watch(currentUserProvider).valueOrNull;
    final canManage = user?.can('manage_detachment') == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppAppBar(context: context, title: 'المفرزة'),
      floatingActionButton: canManage
          ? FloatingActionButton(
              onPressed: _showAddDayBottomSheet,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: AppColors.onPrimary),
            )
          : null,
      body: StreamBuilder<List<DetachmentDayModel>>(
        stream: repo.watchDays(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary),
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
                        fontFamily: 'Cairo', color: AppColors.error),
                  ),
                  const SizedBox(height: AppSizes.md),
                  OutlinedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('إعادة المحاولة',
                        style: TextStyle(fontFamily: 'Cairo')),
                  ),
                ],
              ),
            );
          }

          final days = snapshot.data ?? [];

          if (days.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emergency_outlined,
                      size: 64, color: AppColors.onSurfaceVariant),
                  const SizedBox(height: AppSizes.md),
                  const Text(
                    'لا توجد أيام مضافة بعد',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 16,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  if (canManage)
                    ElevatedButton.icon(
                      onPressed: _showAddDayBottomSheet,
                      icon: const Icon(Icons.add,
                          color: AppColors.onPrimary),
                      label: const Text('إضافة يوم',
                          style: TextStyle(fontFamily: 'Cairo')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                      ),
                    ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.marginMobile),
            itemCount: days.length + 1,
            itemBuilder: (context, index) {
              if (index == days.length) {
                return const SizedBox(height: 80);
              }
              final day = days[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: GestureDetector(
                  onTap: () =>
                      context.push('/detachment/manage/${day.uid}'),
                  onLongPress:
                      canManage ? () => _deleteDay(day) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryContainer
                              .withValues(alpha: 0.06),
                          blurRadius: AppSizes.shadowBlur,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                day.dayName,
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: day.isActive
                                    ? AppColors.successLight
                                    : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(
                                    AppSizes.radiusFull),
                              ),
                              child: Text(
                                day.isActive ? 'نشط' : 'غير نشط',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w500,
                                  color: day.isActive
                                      ? AppColors.success
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            if (canManage) ...[
                              const SizedBox(width: 4),
                              InkWell(
                                borderRadius:
                                    BorderRadius.circular(20),
                                onTap: () => _deleteDay(day),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.delete_outline,
                                      size: 18,
                                      color: AppColors.error),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 14,
                                color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                DateFormatters.formatDateLong(
                                    day.dayDate,
                                    isArabic: isArabic),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
