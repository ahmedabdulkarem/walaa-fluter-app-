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

class DetachmentDayShiftsPage extends ConsumerStatefulWidget {
  const DetachmentDayShiftsPage({super.key});

  @override
  ConsumerState<DetachmentDayShiftsPage> createState() =>
      _DetachmentDayShiftsPageState();
}

class _DetachmentDayShiftsPageState
    extends ConsumerState<DetachmentDayShiftsPage> {
  TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

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
            final day = days.where((d) => d.uid == dayId).firstOrNull;
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
              onPressed: () => _showAddShiftBottomSheet(
                  dayId, user!.uid),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: AppColors.onPrimary),
            )
          : null,
      body: StreamBuilder<List<DetachmentShiftModel>>(
        stream: repo.watchShiftsForDay(dayId),
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
            padding: const EdgeInsets.all(AppSizes.marginMobile),
            itemCount: shifts.length + 1,
            itemBuilder: (context, index) {
              if (index == shifts.length) {
                return const SizedBox(height: 80);
              }
              final shift = shifts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: GestureDetector(
                  onTap: () => context.push(
                    '/detachment/manage/$dayId/shifts/${shift.uid}',
                    extra: shift.memberIds,
                  ),
                  onLongPress:
                      canManage ? () => _deleteShift(shift, dayId) : null,
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
                        children: [
                          Expanded(
                            child: Text(
                              shift.shiftName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Cairo',
                                color: AppColors.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(
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
                                  BorderRadius.circular(20),
                              onTap: () =>
                                  _showEditShiftDialog(shift, dayId, user!.uid),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.edit_outlined,
                                    size: 18,
                                    color: AppColors.primary),
                              ),
                            ),
                            InkWell(
                              borderRadius:
                                  BorderRadius.circular(20),
                              onTap: () =>
                                  _deleteShift(shift, dayId),
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
                          const Icon(Icons.access_time,
                              size: 14,
                              color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text(
                            '${shift.startTime} ← ${shift.endTime}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'Cairo',
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: AppSizes.md),
                          const Icon(Icons.hourglass_bottom,
                              size: 14,
                              color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text(
                            '${shift.durationHours.toStringAsFixed(1)} ساعة',
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'Cairo',
                              color: AppColors.onSurfaceVariant,
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

  void _showAddShiftBottomSheet(String dayId, String createdBy) {
    final shiftNameController = TextEditingController();
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    bool isSaving = false;

    final startText = ValueNotifier<String>('');
    final endText = ValueNotifier<String>('');
    final durationText = ValueNotifier<String>('0.0 ساعة');

    void updateDuration() {
      if (startTime != null && endTime != null) {
        final startMinutes =
            startTime!.hour * 60 + startTime!.minute;
        final endMinutes = endTime!.hour * 60 + endTime!.minute;
        final diffMinutes = endMinutes > startMinutes
            ? endMinutes - startMinutes
            : (24 * 60 - startMinutes) + endMinutes;
        final hours = diffMinutes / 60.0;
        durationText.value = '${hours.toStringAsFixed(1)} ساعة';
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusLg)),
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
                        borderRadius: BorderRadius.circular(
                            AppSizes.radiusFull),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  const Text(
                    'إضافة شفت جديد',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo',
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  TextField(
                    controller: shiftNameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'اسم الشفت',
                      labelStyle:
                          const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppSizes.radiusDefault)),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<String>(
                          valueListenable: startText,
                          builder: (_, value, _) => TextField(
                            readOnly: true,
                            controller:
                                TextEditingController(text: value),
                            decoration: InputDecoration(
                              labelText: 'وقت البداية',
                              labelStyle: const TextStyle(
                                  fontFamily: 'Cairo'),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          AppSizes
                                              .radiusDefault)),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                    Icons.access_time),
                                onPressed: () async {
                                  final picked =
                                      await showTimePicker(
                                    context: ctx,
                                    initialTime: const TimeOfDay(
                                        hour: 8, minute: 0),
                                    builder: (context, child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(
                                                context)
                                            .copyWith(
                                                alwaysUse24HourFormat:
                                                    true),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setSheetState(() {
                                      startTime = picked;
                                      startText.value =
                                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                    });
                                    updateDuration();
                                  }
                                },
                              ),
                            ),
                            style: const TextStyle(
                                fontFamily: 'Cairo'),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: ValueListenableBuilder<String>(
                          valueListenable: endText,
                          builder: (_, value, _) => TextField(
                            readOnly: true,
                            controller:
                                TextEditingController(text: value),
                            decoration: InputDecoration(
                              labelText: 'وقت النهاية',
                              labelStyle: const TextStyle(
                                  fontFamily: 'Cairo'),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          AppSizes
                                              .radiusDefault)),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                    Icons.access_time),
                                onPressed: () async {
                                  final picked =
                                      await showTimePicker(
                                    context: ctx,
                                    initialTime: const TimeOfDay(
                                        hour: 14, minute: 0),
                                    builder: (context, child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(
                                                context)
                                            .copyWith(
                                                alwaysUse24HourFormat:
                                                    true),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setSheetState(() {
                                      endTime = picked;
                                      endText.value =
                                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                    });
                                    updateDuration();
                                  }
                                },
                              ),
                            ),
                            style: const TextStyle(
                                fontFamily: 'Cairo'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                  ValueListenableBuilder<String>(
                    valueListenable: durationText,
                    builder: (_, value, _) => InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'المدة (تلقائي)',
                        labelStyle:
                            const TextStyle(fontFamily: 'Cairo'),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppSizes.radiusDefault)),
                      ),
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSaving ||
                              shiftNameController.text
                                  .trim()
                                  .isEmpty ||
                              startTime == null ||
                              endTime == null
                          ? null
                          : () async {
                              setSheetState(() => isSaving = true);
                              final startMinutes =
                                  startTime!.hour * 60 +
                                      startTime!.minute;
                              final endMinutes =
                                  endTime!.hour * 60 +
                                      endTime!.minute;
                              final diffMinutes =
                                  endMinutes > startMinutes
                                      ? endMinutes - startMinutes
                                      : (24 * 60 - startMinutes) +
                                          endMinutes;
                              final durationHours =
                                  diffMinutes / 60.0;

                              final shift = DetachmentShiftModel(
                                uid: '',
                                dayId: dayId,
                                shiftName: shiftNameController.text
                                    .trim(),
                                startTime: startText.value,
                                endTime: endText.value,
                                durationHours: durationHours,
                                memberIds: const [],
                                memberCount: 0,
                                createdAt: DateTime.now(),
                                createdBy: createdBy,
                              );

                              final result = await ref
                                  .read(detachmentNewRepoProvider)
                                  .createShift(shift);

                              if (!ctx.mounted) return;
                              setSheetState(
                                  () => isSaving = false);

                              result.fold(
                                (failure) {
                                  if (!mounted) return;
                                  context.showSnackBar(
                                    'فشل: ${failure.message}',
                                    backgroundColor:
                                        AppColors.error,
                                  );
                                },
                                (_) {
                                  Navigator.of(ctx).pop();
                                  if (!mounted) return;
                                  context.showSnackBar(
                                      'تم إنشاء الشفت بنجاح');
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

  void _showEditShiftDialog(
      DetachmentShiftModel shift, String dayId, String createdBy) {
    final shiftNameController =
        TextEditingController(text: shift.shiftName);
    TimeOfDay startTime = _parseTimeOfDay(shift.startTime);
    TimeOfDay endTime = _parseTimeOfDay(shift.endTime);
    bool isSaving = false;

    final startText = ValueNotifier<String>(shift.startTime);
    final endText = ValueNotifier<String>(shift.endTime);
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final diff =
        endMinutes > startMinutes ? endMinutes - startMinutes : 0;
    final durationText =
        ValueNotifier<String>('${(diff / 60.0).toStringAsFixed(1)} ساعة');

    void updateDuration() {
      final sm = startTime.hour * 60 + startTime.minute;
      final em = endTime.hour * 60 + endTime.minute;
      final dm = em > sm ? em - sm : (24 * 60 - sm) + em;
      final hours = dm / 60.0;
      durationText.value = '${hours.toStringAsFixed(1)} ساعة';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusLg)),
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
                        borderRadius: BorderRadius.circular(
                            AppSizes.radiusFull),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  const Text(
                    'تعديل الشفت',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo',
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  TextField(
                    controller: shiftNameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'اسم الشفت',
                      labelStyle:
                          const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppSizes.radiusDefault)),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<String>(
                          valueListenable: startText,
                          builder: (_, value, _) => TextField(
                            readOnly: true,
                            controller:
                                TextEditingController(text: value),
                            decoration: InputDecoration(
                              labelText: 'وقت البداية',
                              labelStyle: const TextStyle(
                                  fontFamily: 'Cairo'),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          AppSizes
                                              .radiusDefault)),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                    Icons.access_time),
                                onPressed: () async {
                                  final picked =
                                      await showTimePicker(
                                    context: ctx,
                                    initialTime: startTime,
                                    builder: (context, child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(
                                                context)
                                            .copyWith(
                                                alwaysUse24HourFormat:
                                                    true),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setSheetState(() {
                                      startTime = picked;
                                      startText.value =
                                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                    });
                                    updateDuration();
                                  }
                                },
                              ),
                            ),
                            style: const TextStyle(
                                fontFamily: 'Cairo'),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: ValueListenableBuilder<String>(
                          valueListenable: endText,
                          builder: (_, value, _) => TextField(
                            readOnly: true,
                            controller:
                                TextEditingController(text: value),
                            decoration: InputDecoration(
                              labelText: 'وقت النهاية',
                              labelStyle: const TextStyle(
                                  fontFamily: 'Cairo'),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          AppSizes
                                              .radiusDefault)),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                    Icons.access_time),
                                onPressed: () async {
                                  final picked =
                                      await showTimePicker(
                                    context: ctx,
                                    initialTime: endTime,
                                    builder: (context, child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(
                                                context)
                                            .copyWith(
                                                alwaysUse24HourFormat:
                                                    true),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setSheetState(() {
                                      endTime = picked;
                                      endText.value =
                                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                    });
                                    updateDuration();
                                  }
                                },
                              ),
                            ),
                            style: const TextStyle(
                                fontFamily: 'Cairo'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                  ValueListenableBuilder<String>(
                    valueListenable: durationText,
                    builder: (_, value, _) => InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'المدة (تلقائي)',
                        labelStyle:
                            const TextStyle(fontFamily: 'Cairo'),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppSizes.radiusDefault)),
                      ),
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSaving ||
                              shiftNameController.text
                                  .trim()
                                  .isEmpty
                          ? null
                          : () async {
                              setSheetState(() => isSaving = true);
                              final sm = startTime.hour * 60 +
                                  startTime.minute;
                              final em = endTime.hour * 60 +
                                  endTime.minute;
                              final dm = em > sm
                                  ? em - sm
                                  : (24 * 60 - sm) + em;
                              final durationHours = dm / 60.0;

                              final updated = DetachmentShiftModel(
                                uid: shift.uid,
                                dayId: shift.dayId,
                                shiftName: shiftNameController.text
                                    .trim(),
                                startTime: startText.value,
                                endTime: endText.value,
                                durationHours: durationHours,
                                memberIds: shift.memberIds,
                                memberCount: shift.memberCount,
                                createdAt: shift.createdAt,
                                createdBy: shift.createdBy,
                              );

                              final result = await ref
                                  .read(detachmentNewRepoProvider)
                                  .updateShift(updated);

                              if (!ctx.mounted) return;
                              setSheetState(
                                  () => isSaving = false);

                              result.fold(
                                (failure) {
                                  if (!mounted) return;
                                  context.showSnackBar(
                                    'فشل: ${failure.message}',
                                    backgroundColor:
                                        AppColors.error,
                                  );
                                },
                                (_) {
                                  Navigator.of(ctx).pop();
                                  if (!mounted) return;
                                  context.showSnackBar(
                                      'تم تعديل الشفت بنجاح');
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

  Future<void> _deleteShift(DetachmentShiftModel shift, String dayId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الشفت',
            style: TextStyle(fontFamily: 'Cairo')),
        content: Text(
          'هل أنت متأكد من حذف "${shift.shiftName}"؟',
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

    final result =
        await ref.read(detachmentNewRepoProvider).deleteShift(shift.uid);
    if (!mounted) return;
    result.fold(
      (failure) => context.showSnackBar('فشل الحذف: ${failure.message}',
          backgroundColor: AppColors.error),
      (_) => context.showSnackBar('تم حذف الشفت'),
    );
  }
}
