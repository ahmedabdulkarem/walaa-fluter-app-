import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/detachment_day_schema.dart';
import '../../../../app.dart';

class DetachmentFormPage extends ConsumerStatefulWidget {
  const DetachmentFormPage({super.key});

  @override
  ConsumerState<DetachmentFormPage> createState() => _DetachmentFormPageState();
}

class _DetachmentFormPageState extends ConsumerState<DetachmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  bool _isActive = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) {
      if (mounted) context.showSnackBar('يرجى تسجيل الدخول أولاً', backgroundColor: AppColors.error);
      setState(() => _isSubmitting = false);
      return;
    }

    final day = DetachmentDaySchema()
      ..uid = DateTime.now().millisecondsSinceEpoch.toString()
      ..title = _titleController.text.trim()
      ..date = _selectedDate
      ..location = _locationController.text.trim()
      ..description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim()
      ..isActive = _isActive
      ..createdBy = user.uid
      ..createdAt = DateTime.now();

    final result = await ref.read(detachmentRepositoryProvider).createDay(day, user);

    if (!mounted) return;

    result.fold(
      (failure) {
        context.showSnackBar('فشل في إنشاء المفرزة: ${failure.message}', backgroundColor: AppColors.error);
        setState(() => _isSubmitting = false);
      },
      (_) {
        context.showSnackBar('تم إنشاء المفرزة بنجاح');
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'مفرزة جديدة',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.marginMobile),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                validator: (value) => (value == null || value.trim().isEmpty) ? 'يرجى إدخال عنوان المفرزة' : null,
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  labelStyle: const TextStyle(fontFamily: 'Cairo'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              const SizedBox(height: AppSizes.md),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'التاريخ',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                    suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.year}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.day.toString().padLeft(2, '0')}'
                        : 'اختر التاريخ',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: _selectedDate != null ? AppColors.onSurface : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              TextFormField(
                controller: _locationController,
                textInputAction: TextInputAction.next,
                validator: (value) => (value == null || value.trim().isEmpty) ? 'يرجى إدخال المكان' : null,
                decoration: InputDecoration(
                  labelText: 'المكان',
                  labelStyle: const TextStyle(fontFamily: 'Cairo'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.radiusDefault)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              const SizedBox(height: AppSizes.md),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  labelText: 'الوصف (اختياري)',
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
              const SizedBox(height: AppSizes.md),
              SwitchListTile(
                title: const Text(
                  'مفرزة نشطة',
                  style: TextStyle(fontFamily: 'Cairo', color: AppColors.onSurface),
                ),
                value: _isActive,
                activeThumbColor: AppColors.primary,
                onChanged: (value) => setState(() => _isActive = value),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppSizes.lg),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
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
      ),
    );
  }
}
