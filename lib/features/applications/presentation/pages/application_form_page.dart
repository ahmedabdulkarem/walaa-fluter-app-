import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/models/pending_application_schema.dart';
import '../../../../app.dart';

class ApplicationFormPage extends ConsumerStatefulWidget {
  const ApplicationFormPage({super.key});

  @override
  ConsumerState<ApplicationFormPage> createState() => _ApplicationFormPageState();
}

class _ApplicationFormPageState extends ConsumerState<ApplicationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  String _applicationType = 'تطوع';
  bool _isSubmitting = false;

  static const _types = [
    'تطوع',
    'عضوية',
    'استفسار',
    'أخرى',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final now = DateTime.now();

    final application = PendingApplicationSchema()
      ..uid = 'app_${now.millisecondsSinceEpoch}'
      ..fullName = _fullNameController.text.trim()
      ..email = _emailController.text.trim()
      ..phone = _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim()
      ..applicationType = _applicationType
      ..message = _messageController.text.trim()
      ..status = 'pending'
      ..createdAt = now;

    final result = await ref.read(applicationRepositoryProvider).submit(application);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الإرسال: ${failure.message}')),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال طلبك بنجاح، سنتواصل معك قريباً')),
        );
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
        title: const Text(
          'سجل معنا',
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
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'الاسم مطلوب';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'البريد الإلكتروني مطلوب';
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(v.trim())) return 'البريد الإلكتروني غير صحيح';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف (اختياري)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSizes.md),
              DropdownButtonFormField<String>(
                initialValue: _applicationType,
                decoration: const InputDecoration(
                  labelText: 'نوع الطلب',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _types.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type, style: const TextStyle(fontFamily: 'Cairo')),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _applicationType = v);
                },
              ),
              const SizedBox(height: AppSizes.md),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'الرسالة',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'الرسالة مطلوبة';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.lg),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    disabledBackgroundColor: AppColors.primaryContainer,
                    disabledForegroundColor: AppColors.onPrimaryContainer,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Text(
                          'إرسال',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
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
