import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/utils/extensions.dart';
import '../../models/detachment_day_model.dart';

class DetachmentDaysPage extends ConsumerStatefulWidget {
  const DetachmentDaysPage({super.key});

  @override
  ConsumerState<DetachmentDaysPage> createState() => _DetachmentDaysPageState();
}

class _DetachmentDaysPageState extends ConsumerState<DetachmentDaysPage> {
  void _showAddDetachmentSheet() {
    final nameCtrl = TextEditingController();
    final leaderCtrl = TextEditingController();
    final placeCtrl = TextEditingController();
    final daysCtrl = TextEditingController(text: '1');
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
              child: SingleChildScrollView(
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
                      'إضافة مفرزة جديدة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    TextField(
                      controller: nameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'اسم المفرزة *',
                        prefixIcon: Icon(Icons.emergency_outlined),
                        labelStyle: TextStyle(fontFamily: 'Cairo'),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextField(
                      controller: leaderCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'القائد',
                        prefixIcon: Icon(Icons.person_outline),
                        labelStyle: TextStyle(fontFamily: 'Cairo'),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextField(
                      controller: placeCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'المكان',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        labelStyle: TextStyle(fontFamily: 'Cairo'),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextField(
                      controller: daysCtrl,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'عدد الأيام',
                        prefixIcon: Icon(Icons.date_range_outlined),
                        labelStyle: TextStyle(fontFamily: 'Cairo'),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSaving || nameCtrl.text.trim().isEmpty
                            ? null
                            : () async {
                                setSheetState(() => isSaving = true);
                                final user = ref
                                    .read(currentUserProvider)
                                    .valueOrNull;
                                final now = DateTime.now();

                                final day = DetachmentDayModel(
                                  uid: '',
                                  dayName: nameCtrl.text.trim(),
                                  leaderName: leaderCtrl.text.trim().isEmpty
                                      ? null
                                      : leaderCtrl.text.trim(),
                                  location: placeCtrl.text.trim(),
                                  durationDays: int.tryParse(
                                          daysCtrl.text.trim()) ??
                                      1,
                                  dayDate: now,
                                  weekDay: now.weekday,
                                  isActive: true,
                                  createdAt: now,
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
                                        'تم إنشاء المفرزة بنجاح');
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
    final user = ref.watch(currentUserProvider).valueOrNull;
    final canManage = user?.can('manage_detachment') == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppAppBar(context: context, title: 'المفرزة'),
      floatingActionButton: canManage
          ? FloatingActionButton(
              onPressed: _showAddDetachmentSheet,
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
                    'لا توجد مفارز بعد',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 16,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  if (canManage)
                    ElevatedButton.icon(
                      onPressed: _showAddDetachmentSheet,
                      icon: const Icon(Icons.add,
                          color: AppColors.onPrimary),
                      label: const Text('إضافة مفرزة',
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
                      context.push('/deployments/${day.uid}'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F6D28D9),
                          blurRadius: 4,
                          offset: Offset(0, 2),
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
                          ],
                        ),
                        const SizedBox(height: AppSizes.xs),
                        if (day.leaderName != null &&
                            day.leaderName!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.person_outline,
                                    size: 14,
                                    color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 6),
                                Text(
                                  day.leaderName!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Cairo',
                                    color: AppColors.goldBright,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (day.location.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 14,
                                    color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 6),
                                Flexible(
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
                          ),
                        Row(
                          children: [
                            const Icon(Icons.date_range_outlined,
                                size: 14,
                                color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(
                              '${day.durationDays} ${day.durationDays == 1 ? 'يوم' : 'أيام'}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'Cairo',
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
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
