import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/detachment_stats_schema.dart';
import '../../../../app.dart';

class DetachmentStatsPage extends ConsumerStatefulWidget {
  const DetachmentStatsPage({super.key});

  @override
  ConsumerState<DetachmentStatsPage> createState() => _DetachmentStatsPageState();
}

class _DetachmentStatsPageState extends ConsumerState<DetachmentStatsPage> {
  final _formKey = GlobalKey<FormState>();
  final _totalPatientsController = TextEditingController();
  final _notesController = TextEditingController();
  final _categoryLabels = <TextEditingController>[];
  final _categoryCounts = <TextEditingController>[];
  bool _isSubmitting = false;
  bool _initialized = false;
  String? _existingUid;

  @override
  void dispose() {
    _totalPatientsController.dispose();
    _notesController.dispose();
    for (final c in _categoryLabels) {
      c.dispose();
    }
    for (final c in _categoryCounts) {
      c.dispose();
    }
    super.dispose();
  }

  String? _dayId(BuildContext context) {
    return GoRouterState.of(context).pathParameters['dayId'];
  }

  void _initFromStats(DetachmentStatsSchema stats) {
    if (_initialized) return;
    _initialized = true;
    _existingUid = stats.uid;
    _totalPatientsController.text = stats.totalPatients.toString();
    _notesController.text = stats.notes ?? '';
    for (final cat in stats.categories) {
      _categoryLabels.add(TextEditingController(text: cat.label));
      _categoryCounts.add(TextEditingController(text: cat.count.toString()));
    }
    setState(() {});
  }

  void _addCategory() {
    setState(() {
      _categoryLabels.add(TextEditingController());
      _categoryCounts.add(TextEditingController());
    });
  }

  void _removeCategory(int index) {
    setState(() {
      _categoryLabels[index].dispose();
      _categoryCounts[index].dispose();
      _categoryLabels.removeAt(index);
      _categoryCounts.removeAt(index);
    });
  }

  Future<void> _submit(String dayId) async {
    if (!_formKey.currentState!.validate()) return;

    final totalText = _totalPatientsController.text.trim();
    final totalPatients = int.tryParse(totalText) ?? 0;

    final categories = <PatientCategory>[];
    for (var i = 0; i < _categoryLabels.length; i++) {
      final label = _categoryLabels[i].text.trim();
      final countText = _categoryCounts[i].text.trim();
      if (label.isEmpty) continue;
      categories.add(
        PatientCategory()
          ..label = label
          ..count = int.tryParse(countText) ?? 0,
      );
    }

    setState(() => _isSubmitting = true);

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) {
      if (mounted) context.showSnackBar('يرجى تسجيل الدخول أولاً', backgroundColor: AppColors.error);
      setState(() => _isSubmitting = false);
      return;
    }

    final stats = DetachmentStatsSchema()
      ..uid = _existingUid ?? DateTime.now().millisecondsSinceEpoch.toString()
      ..totalPatients = totalPatients
      ..categories = categories
      ..notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim()
      ..recordedBy = user.uid
      ..recordedByName = user.displayName
      ..recordedAt = _existingUid == null ? DateTime.now() : null
      ..updatedAt = DateTime.now();

    final result = await ref.read(detachmentRepositoryProvider).upsertStats(dayId, stats, user);

    if (!mounted) return;

    result.fold(
      (failure) {
        context.showSnackBar('فشل في حفظ الإحصائيات: ${failure.message}', backgroundColor: AppColors.error);
        setState(() => _isSubmitting = false);
      },
      (_) {
        context.showSnackBar('تم حفظ الإحصائيات بنجاح');
        context.pop();
      },
    );
  }

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
          title: const Text(
            'إحصائيات',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(child: Text('لم يتم العثور على المفرزة', style: TextStyle(fontFamily: 'Cairo'))),
      );
    }

    final repo = ref.watch(detachmentRepositoryProvider);

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
        title: const Text(
          'إحصائيات',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<DetachmentStatsSchema>>(
        stream: repo.streamStats(dayId),
        builder: (context, snapshot) {
          final statsList = snapshot.data ?? [];
          if (statsList.isNotEmpty && !_initialized) {
            _initFromStats(statsList.first);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.marginMobile),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _totalPatientsController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'يرجى إدخال عدد المرضى';
                      if (int.tryParse(value.trim()) == null) return 'يرجى إدخال رقم صحيح';
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'إجمالي المرضى',
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Row(
                    children: [
                      const Text(
                        'التصنيفات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Cairo',
                          color: AppColors.onSurface,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _addCategory,
                        icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
                        label: const Text(
                          'إضافة تصنيف',
                          style: TextStyle(fontFamily: 'Cairo', color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  if (_categoryLabels.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
                      ),
                      child: const Center(
                        child: Text(
                          'لم يتم إضافة تصنيفات بعد',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                  ...List.generate(_categoryLabels.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _categoryLabels[index],
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'التصنيف ${index + 1}',
                                labelStyle: const TextStyle(fontFamily: 'Cairo'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
                                  borderSide: const BorderSide(color: AppColors.primary),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _categoryCounts[index],
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'العدد',
                                labelStyle: const TextStyle(fontFamily: 'Cairo'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
                                  borderSide: const BorderSide(color: AppColors.primary),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: AppSizes.xs),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
                            onPressed: () => _removeCategory(index),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: AppSizes.lg),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      labelText: 'ملاحظات (اختياري)',
                      labelStyle: const TextStyle(fontFamily: 'Cairo'),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _submit(dayId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                            )
                          : const Text(
                              'حفظ',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Cairo'),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
