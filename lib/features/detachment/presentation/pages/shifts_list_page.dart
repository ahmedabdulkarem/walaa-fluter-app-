import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../app.dart';
import '../../models/detachment_shift_model.dart';
import '../../models/week_day.dart';
import 'shift_form_page.dart';

final allShiftsProvider = StreamProvider<List<DetachmentShiftModel>>((ref) {
  return ref.read(detachmentNewRepoProvider).watchAllShifts();
});

class ShiftsListPage extends ConsumerWidget {
  const ShiftsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftsAsync = ref.watch(allShiftsProvider);
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'الشفتات',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: canManage
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ShiftFormPage()),
                  ),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add,
                  color: AppColors.onPrimary),
            )
          : null,
      body: shiftsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(
                color: AppColors.primary)),
        error: (e, _) => Center(
          child: Text('تعذر تحميل الشفتات: $e',
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.error)),
        ),
        data: (shifts) {
          if (shifts.isEmpty) {
            return const Center(
              child: Text('لا توجد شفتات بعد',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      color: AppColors.onSurfaceVariant)),
            );
          }

          final grouped = <WeekDay, List<DetachmentShiftModel>>{};
          for (final day in WeekDay.values) {
            grouped[day] = shifts
                .where((s) => s.weekDay == day)
                .toList()
              ..sort((a, b) => a.startTime.compareTo(b.startTime));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.marginMobile),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              for (final day in WeekDay.values)
                if (grouped[day]!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 12, bottom: 8),
                    child: Text(
                      day.arabicLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  for (final shift in grouped[day]!)
                    _ShiftCard(
                      shift: shift,
                      canManage: canManage,
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ShiftCard extends ConsumerWidget {
  final DetachmentShiftModel shift;
  final bool canManage;
  const _ShiftCard({required this.shift, required this.canManage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSizes.xs),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        onTap: canManage
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ShiftFormPage(initialShift: shift),
                  ),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      shift.shiftName.isNotEmpty
                          ? shift.shiftName
                          : 'شفت',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                        color: AppColors.onSurface,
                      ),
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
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _deleteShift(
                          context, ref, shift),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.delete_outline,
                            size: 18, color: AppColors.error),
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
                    '${shift.startTime} - ${shift.endTime}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'Cairo',
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  if (shift.leaderId.isNotEmpty) ...[
                    const SizedBox(width: AppSizes.md),
                    const Icon(Icons.admin_panel_settings,
                        size: 14, color: AppColors.goldBright),
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
  }

  Future<void> _deleteShift(BuildContext context, WidgetRef ref,
      DetachmentShiftModel shift) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الشفت',
            style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('هل أنت متأكد من حذف هذا الشفت؟',
            style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء',
                style: TextStyle(fontFamily: 'Cairo')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('حذف',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await ref
        .read(detachmentNewRepoProvider)
        .deleteShift(shift.uid);
    if (!context.mounted) return;
    result.fold(
      (failure) => context.showSnackBar(
          'فشل الحذف: ${failure.message}',
          backgroundColor: AppColors.error),
      (_) => context.showSnackBar('تم حذف الشفت'),
    );
  }
}
