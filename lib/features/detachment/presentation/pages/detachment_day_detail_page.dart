import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../shared/models/detachment_day_schema.dart';
import '../../../../shared/models/detachment_shift_schema.dart';
import '../../../../shared/models/detachment_stats_schema.dart';
import '../../../../shared/models/detachment_crew_schema.dart';
import '../../../../shared/models/user_schema.dart';
import '../../../../shared/repositories/detachment_repository.dart';
import '../../../../app.dart';

class DetachmentDayDetailPage extends ConsumerStatefulWidget {
  const DetachmentDayDetailPage({super.key});

  @override
  ConsumerState<DetachmentDayDetailPage> createState() => _DetachmentDayDetailPageState();
}

class _DetachmentDayDetailPageState extends ConsumerState<DetachmentDayDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String? _dayId(BuildContext context) {
    return GoRouterState.of(context).pathParameters['dayId'];
  }

  // ── Time picker helper ──────────────────────────────────────

  Future<String?> _pickTime(BuildContext context, {String? initial}) async {
    TimeOfDay initialTime;
    if (initial != null) {
      final parts = initial.split(':');
      initialTime = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 8,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    } else {
      initialTime = const TimeOfDay(hour: 8, minute: 0);
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked == null) return null;
    return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
  }

  // ── Shift dialogs ───────────────────────────────────────────

  void _showAddShiftDialog(String dayId, UserSchema user) {
    final labelController = TextEditingController();
    String? startTime;
    String? endTime;
    final startTimeText = ValueNotifier<String>('');
    final endTimeText = ValueNotifier<String>('');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'إضافة وردية',
            style: TextStyle(fontFamily: 'Cairo', color: AppColors.primary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'اسم الوردية',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: AppSizes.sm),
                ValueListenableBuilder<String>(
                  valueListenable: startTimeText,
                  builder: (_, value, _) => TextField(
                    readOnly: true,
                    controller: TextEditingController(text: value),
                    decoration: InputDecoration(
                      labelText: 'وقت البداية',
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          final t = await _pickTime(context);
                          if (t != null) {
                            startTime = t;
                            startTimeText.value = t;
                          }
                        },
                      ),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                ValueListenableBuilder<String>(
                  valueListenable: endTimeText,
                  builder: (_, value, _) => TextField(
                    readOnly: true,
                    controller: TextEditingController(text: value),
                    decoration: InputDecoration(
                      labelText: 'وقت النهاية',
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          final t = await _pickTime(context);
                          if (t != null) {
                            endTime = t;
                            endTimeText.value = t;
                          }
                        },
                      ),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (labelController.text.trim().isEmpty || startTime == null || endTime == null) {
                  return;
                }
                final shift = DetachmentShiftSchema()
                  ..uid = DateTime.now().millisecondsSinceEpoch.toString()
                  ..dayId = dayId
                  ..label = labelController.text.trim()
                  ..startTime = startTime!
                  ..endTime = endTime!
                  ..assignedAdminUids = []
                  ..checkedInUids = []
                  ..checkIns = []
                  ..createdAt = DateTime.now();

                final result = await ref.read(detachmentRepositoryProvider).addShift(dayId, shift, user);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                if (result.isSuccess) {
                  context.showSnackBar('تمت إضافة الوردية بنجاح');
                } else {
                  context.showSnackBar('فشل في إضافة الوردية', backgroundColor: AppColors.error);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('إضافة', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        );
      },
    );
  }

  void _showEditShiftDialog(DetachmentShiftSchema shift, UserSchema user) {
    final labelController = TextEditingController(text: shift.label);
    String? startTime = shift.startTime;
    String? endTime = shift.endTime;
    final startTimeText = ValueNotifier<String>(shift.startTime);
    final endTimeText = ValueNotifier<String>(shift.endTime);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'تعديل الوردية',
            style: TextStyle(fontFamily: 'Cairo', color: AppColors.primary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'اسم الوردية',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: AppSizes.sm),
                ValueListenableBuilder<String>(
                  valueListenable: startTimeText,
                  builder: (_, value, _) => TextField(
                    readOnly: true,
                    controller: TextEditingController(text: value),
                    decoration: InputDecoration(
                      labelText: 'وقت البداية',
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          final t = await _pickTime(context, initial: startTime);
                          if (t != null) {
                            startTime = t;
                            startTimeText.value = t;
                          }
                        },
                      ),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                ValueListenableBuilder<String>(
                  valueListenable: endTimeText,
                  builder: (_, value, _) => TextField(
                    readOnly: true,
                    controller: TextEditingController(text: value),
                    decoration: InputDecoration(
                      labelText: 'وقت النهاية',
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          final t = await _pickTime(context, initial: endTime);
                          if (t != null) {
                            endTime = t;
                            endTimeText.value = t;
                          }
                        },
                      ),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (labelController.text.trim().isEmpty || startTime == null || endTime == null) {
                  return;
                }
                shift
                  ..label = labelController.text.trim()
                  ..startTime = startTime!
                  ..endTime = endTime!;

                final result = await ref.read(detachmentRepositoryProvider).updateShift(shift, user);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                if (result.isSuccess) {
                  context.showSnackBar('تم تعديل الوردية بنجاح');
                } else {
                  context.showSnackBar('فشل في تعديل الوردية', backgroundColor: AppColors.error);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteShift(DetachmentShiftSchema shift, UserSchema user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الوردية', style: TextStyle(fontFamily: 'Cairo', color: AppColors.error)),
        content: Text(
          'هل أنت متأكد من حذف الوردية "${shift.label}"؟',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.onError),
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await ref.read(detachmentRepositoryProvider).deleteShift(shift.dayId, shift.uid, user);
    if (!mounted) return;
    if (result.isSuccess) {
      context.showSnackBar('تم حذف الوردية بنجاح');
    } else {
      context.showSnackBar('فشل في حذف الوردية', backgroundColor: AppColors.error);
    }
  }

  // ── Crew dialogs ────────────────────────────────────────────

  void _showAddCrewDialog(String dayId, UserSchema user) {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'إضافة فرد',
            style: TextStyle(fontFamily: 'Cairo', color: AppColors.primary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'الاسم الكامل *',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: AppSizes.sm),
                TextField(
                  controller: roleController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'المهام / الدور *',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: AppSizes.sm),
                TextField(
                  controller: phoneController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف (اختياري)',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final role = roleController.text.trim();
                if (name.isEmpty || role.isEmpty) return;
                final phone = phoneController.text.trim();

                final crew = DetachmentCrewSchema()
                  ..uid = DateTime.now().millisecondsSinceEpoch.toString()
                  ..dayId = dayId
                  ..fullName = name
                  ..role = role
                  ..phone = phone.isNotEmpty ? phone : null
                  ..addedBy = user.uid
                  ..addedAt = DateTime.now();

                final result = await ref.read(detachmentRepositoryProvider).addCrew(crew, user);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                if (result.isSuccess) {
                  context.showSnackBar('تمت إضافة الفرد بنجاح');
                } else {
                  context.showSnackBar('فشل في إضافة الفرد', backgroundColor: AppColors.error);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('إضافة', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        );
      },
    );
  }

  void _showEditCrewDialog(DetachmentCrewSchema crew, UserSchema user) {
    final nameController = TextEditingController(text: crew.fullName);
    final roleController = TextEditingController(text: crew.role);
    final phoneController = TextEditingController(text: crew.phone ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'تعديل بيانات الفرد',
            style: TextStyle(fontFamily: 'Cairo', color: AppColors.primary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'الاسم الكامل *',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: AppSizes.sm),
                TextField(
                  controller: roleController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'المهام / الدور *',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: AppSizes.sm),
                TextField(
                  controller: phoneController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف (اختياري)',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final role = roleController.text.trim();
                if (name.isEmpty || role.isEmpty) return;
                final phone = phoneController.text.trim();

                crew
                  ..fullName = name
                  ..role = role
                  ..phone = phone.isNotEmpty ? phone : null;

                final result = await ref.read(detachmentRepositoryProvider).updateCrew(crew, user);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                if (result.isSuccess) {
                  context.showSnackBar('تم تعديل بيانات الفرد بنجاح');
                } else {
                  context.showSnackBar('فشل في تعديل بيانات الفرد', backgroundColor: AppColors.error);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCrew(DetachmentCrewSchema crew, UserSchema user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الفرد', style: TextStyle(fontFamily: 'Cairo', color: AppColors.error)),
        content: Text(
          'هل أنت متأكد من حذف "${crew.fullName}"؟',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.onError),
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await ref.read(detachmentRepositoryProvider).deleteCrew(crew.dayId, crew.uid, user);
    if (!mounted) return;
    if (result.isSuccess) {
      context.showSnackBar('تم حذف الفرد بنجاح');
    } else {
      context.showSnackBar('فشل في حذف الفرد', backgroundColor: AppColors.error);
    }
  }

  // ── Day edit / delete dialogs ───────────────────────────────

  void _showEditDayDialog(DetachmentDaySchema day, UserSchema user) {
    final titleController = TextEditingController(text: day.title);
    final locationController = TextEditingController(text: day.location);
    final descriptionController = TextEditingController(text: day.description ?? '');
    DateTime? selectedDate = day.date;
    bool isActive = day.isActive;
    final dateText = ValueNotifier<String>(
      selectedDate != null ? DateFormatters.formatDateLong(selectedDate, isArabic: true) : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'تعديل المفرزة',
            style: TextStyle(fontFamily: 'Cairo', color: AppColors.primary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'العنوان *',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: AppSizes.sm),
                ValueListenableBuilder<String>(
                  valueListenable: dateText,
                  builder: (_, value, _) => TextField(
                    readOnly: true,
                    controller: TextEditingController(text: value),
                    decoration: InputDecoration(
                      labelText: 'التاريخ',
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            selectedDate = picked;
                            dateText.value = DateFormatters.formatDateLong(picked, isArabic: true);
                          }
                        },
                      ),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                TextField(
                  controller: locationController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'الموقع *',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: AppSizes.sm),
                TextField(
                  controller: descriptionController,
                  textInputAction: TextInputAction.newline,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'الوصف (اختياري)',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: AppSizes.sm),
                StatefulBuilder(
                  builder: (_, setLocalState) => Row(
                    children: [
                      const Text('نشط', style: TextStyle(fontFamily: 'Cairo')),
                      const Spacer(),
                        Switch(
                          value: isActive,
                          activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                          activeThumbColor: AppColors.primary,
                        onChanged: (v) {
                          setLocalState(() => isActive = v);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final location = locationController.text.trim();
                if (title.isEmpty || location.isEmpty) return;

                day
                  ..title = title
                  ..date = selectedDate
                  ..location = location
                  ..description = descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim()
                  ..isActive = isActive;

                final result = await ref.read(detachmentRepositoryProvider).updateDay(day, user);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                if (result.isSuccess) {
                  context.showSnackBar('تم تعديل المفرزة بنجاح');
                } else {
                  context.showSnackBar('فشل في تعديل المفرزة', backgroundColor: AppColors.error);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('حفظ', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteDay(String dayId, UserSchema user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المفرزة', style: TextStyle(fontFamily: 'Cairo', color: AppColors.error)),
        content: const Text(
          'هل أنت متأكد من حذف هذه المفرزة؟ سيتم حذف جميع الورديات والإحصائيات والفرق المرتبطة بها.',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.onError),
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await ref.read(detachmentRepositoryProvider).deleteDay(dayId, user);
    if (!mounted) return;
    if (result.isSuccess) {
      context.showSnackBar('تم حذف المفرزة بنجاح');
      context.pop();
    } else {
      context.showSnackBar('فشل في حذف المفرزة', backgroundColor: AppColors.error);
    }
  }

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dayId = _dayId(context);
    if (dayId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('لم يتم العثور على المفرزة', style: TextStyle(fontFamily: 'Cairo'))),
      );
    }

    final repo = ref.watch(detachmentRepositoryProvider);
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';
    final user = ref.watch(currentUserProvider).valueOrNull;

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
        title: StreamBuilder<List<DetachmentDaySchema>>(
          stream: repo.streamDays(),
          builder: (context, snapshot) {
            final days = snapshot.data ?? [];
            final day = days.where((d) => d.uid == dayId).firstOrNull;
            return Text(
              day?.title ?? 'تفاصيل المفرزة',
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
        actions: [
          if (user != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.primary),
              onSelected: (value) {
                if (value == 'edit') {
                  ref.read(detachmentRepositoryProvider).streamDays().first.then((daysList) {
                    final d = daysList.where((d) => d.uid == dayId).firstOrNull;
                    if (d != null && mounted) {
                      _showEditDayDialog(d, user);
                    }
                  });
                } else if (value == 'delete') {
                  _deleteDay(dayId, user);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('تعديل', style: TextStyle(fontFamily: 'Cairo')),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo'),
          tabs: const [
            Tab(text: 'الفريق'),
            Tab(text: 'الورديات'),
            Tab(text: 'الإحصائيات'),
          ],
        ),
      ),
      body: StreamBuilder<List<DetachmentDaySchema>>(
        stream: repo.streamDays(),
        builder: (context, snapshot) {
          final days = snapshot.data ?? [];
          final day = days.where((d) => d.uid == dayId).firstOrNull;

          return Column(
            children: [
              if (day != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.md),
                  color: AppColors.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo',
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      if (day.date != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
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
                          const Spacer(),
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
                        ],
                      ),
                      if (day.description != null && day.description!.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          day.description!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Cairo',
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCrewTab(repo, dayId, user),
                    _buildShiftsTab(repo, dayId, user),
                    _buildStatsTab(repo, dayId, user),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Crew tab ────────────────────────────────────────────────

  Widget _buildCrewTab(DetachmentRepository repo, String dayId, UserSchema? user) {
    return StreamBuilder<List<DetachmentCrewSchema>>(
      stream: repo.streamCrew(dayId),
      builder: (context, snapshot) {
        final crewList = snapshot.data ?? [];

        return Stack(
          children: [
            if (crewList.isEmpty)
              const Center(
                child: Text(
                  'لا يوجد أفراد في الفريق بعد',
                  style: TextStyle(fontFamily: 'Cairo', color: AppColors.onSurfaceVariant),
                ),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.all(AppSizes.marginMobile),
                itemCount: crewList.length,
                itemBuilder: (context, index) {
                  final crew = crewList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: AppCard(
                      onTap: user != null ? () => _showEditCrewDialog(crew, user) : null,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.md),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    crew.fullName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Cairo',
                                      color: AppColors.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    crew.role,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Cairo',
                                      color: AppColors.primary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (crew.phone != null && crew.phone!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone, size: 12, color: AppColors.onSurfaceVariant),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            crew.phone!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Cairo',
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (user != null)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                onPressed: () => _deleteCrew(crew, user),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            if (user != null)
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  mini: true,
                  heroTag: 'add_crew',
                  onPressed: () => _showAddCrewDialog(dayId, user),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.person_add, color: AppColors.onPrimary),
                ),
              ),
          ],
        );
      },
    );
  }

  // ── Shifts tab ──────────────────────────────────────────────

  Widget _buildShiftsTab(DetachmentRepository repo, String dayId, UserSchema? user) {
    return StreamBuilder<List<DetachmentShiftSchema>>(
      stream: repo.streamShifts(dayId),
      builder: (context, snapshot) {
        final shifts = snapshot.data ?? [];

        return Stack(
          children: [
            if (shifts.isEmpty)
              const Center(
                child: Text(
                  'لا توجد ورديات بعد',
                  style: TextStyle(fontFamily: 'Cairo', color: AppColors.onSurfaceVariant),
                ),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.all(AppSizes.marginMobile),
                itemCount: shifts.length,
                itemBuilder: (context, index) {
                  final shift = shifts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: AppCard(
                      onTap: user != null ? () => _showEditShiftDialog(shift, user) : null,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    shift.label,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Cairo',
                                      color: AppColors.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                                  ),
                                  child: Text(
                                    '${shift.checkIns.length} تسجيل',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'Cairo',
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                if (user != null) ...[
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                    onPressed: () => _deleteShift(shift, user),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: AppSizes.xs),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 14, color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '${shift.startTime} - ${shift.endTime}',
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
              ),
            if (user != null)
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  mini: true,
                  heroTag: 'add_shift',
                  onPressed: () => _showAddShiftDialog(dayId, user),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.add, color: AppColors.onPrimary),
                ),
              ),
          ],
        );
      },
    );
  }

  // ── Stats tab ───────────────────────────────────────────────

  Widget _buildStatsTab(DetachmentRepository repo, String dayId, UserSchema? user) {
    return StreamBuilder<List<DetachmentStatsSchema>>(
      stream: repo.streamStats(dayId),
      builder: (context, snapshot) {
        final statsList = snapshot.data ?? [];
        final stats = statsList.isNotEmpty ? statsList.first : null;

        return Stack(
          children: [
            if (stats == null)
              const Center(
                child: Text(
                  'لا توجد إحصائيات بعد',
                  style: TextStyle(fontFamily: 'Cairo', color: AppColors.onSurfaceVariant),
                ),
              )
            else
              ListView(
                padding: const EdgeInsets.all(AppSizes.marginMobile),
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'إجمالي المرضى',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Cairo',
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          '${stats.totalPatients}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Cairo',
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (stats.categories.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.sm),
                    AppCard(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'التصنيفات',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Cairo',
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          ...stats.categories.map(
                            (cat) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSizes.xs),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      cat.label,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontFamily: 'Cairo',
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${cat.count}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Cairo',
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (stats.notes != null && stats.notes!.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.sm),
                    AppCard(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ملاحظات',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Cairo',
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSizes.xs),
                          Text(
                            stats.notes!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'Cairo',
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            if (user != null)
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  mini: true,
                  heroTag: 'edit_stats',
                  onPressed: () => context.push('/detachment/$dayId/stats'),
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    stats == null ? Icons.add : Icons.edit,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
