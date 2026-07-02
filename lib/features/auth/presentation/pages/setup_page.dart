// lib/features/auth/presentation/pages/setup_page.dart
// WHY: First-run setup — creates the initial super admin when no admins exist in Firestore.
// Replaces the old "first device = super admin" insecure mechanism.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/auth_service.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;
  String? _error;
  bool _done = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _setup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;
      final salt = AuthService.generateSalt();
      final hashed = AuthService.hashPasswordWithSalt(password, salt);

      final docRef =
          FirebaseFirestore.instance.collection('admins').doc();
      await docRef.set({
        'uid': docRef.id,
        'name': 'Super Admin',
        'username': username,
        'passwordHash': hashed,
        'passwordSalt': salt,
        'permissions': [],
        'isSuperAdmin': true,
        'isActive': true,
        'sessionExpiresAt':
            Timestamp.fromDate(DateTime(2099, 12, 31)),
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _done = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'فشل إنشاء الحساب: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: _done ? _buildDone() : _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildDone() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle,
            size: 80, color: AppColors.success),
        const SizedBox(height: AppSizes.lg),
        const Text(
          'تم إنشاء حساب المشرف العام بنجاح',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        const Text(
          'الرجاء إعادة تشغيل التطبيق لتسجيل الدخول',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Cairo',
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSizes.xl),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: const StadiumBorder(),
            ),
            child: const Text(
              'تم',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          const Text(
            'إعداد أولي',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          const Text(
            'إنشاء حساب المشرف العام الأول',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Cairo',
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'اسم المستخدم',
              prefixIcon: Icon(Icons.person_outline),
            ),
            textInputAction: TextInputAction.next,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
          ),
          const SizedBox(height: AppSizes.md),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(_obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: () =>
                    setState(() => _obscure = !_obscure),
              ),
            ),
            obscureText: _obscure,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                (v == null || v.length < 6) ? '٦ أحرف على الأقل' : null,
          ),
          const SizedBox(height: AppSizes.md),
          TextFormField(
            controller: _confirmController,
            decoration: const InputDecoration(
              labelText: 'تأكيد كلمة المرور',
              prefixIcon: Icon(Icons.lock_outlined),
            ),
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            validator: (v) => (v != _passwordController.text)
                ? 'كلمة المرور غير متطابقة'
                : null,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSizes.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(
                    AppSizes.radiusDefault),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 18, color: AppColors.danger),
                  const SizedBox(width: AppSizes.xs),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: AppColors.danger,
                        fontFamily: 'Cairo',
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _setup,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                disabledBackgroundColor: AppColors.primaryContainer,
                disabledForegroundColor: AppColors.onPrimaryContainer,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : const Text(
                      'إنشاء الحساب',
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
    );
  }
}
