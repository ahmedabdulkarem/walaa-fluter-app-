import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/permission_constants.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../shared/models/user_schema.dart';

class AdminEditPage extends ConsumerStatefulWidget {
  final String adminId;
  const AdminEditPage({super.key, required this.adminId});

  @override
  ConsumerState<AdminEditPage> createState() => _AdminEditPageState();
}

class _AdminEditPageState extends ConsumerState<AdminEditPage> {
  List<String> _selectedPermissions = [];
  bool _isLoading = true;
  bool _isSaving = false;
  UserSchema? _admin;

  @override
  void initState() {
    super.initState();
    _loadAdmin();
  }

  Future<void> _loadAdmin() async {
    final user = await AuthService.getCurrentUser();
    if (!mounted) return;
    if (user != null && user.uid == widget.adminId) {
      setState(() {
        _admin = user;
        _selectedPermissions = List<String>.from(user.permissions);
        _isLoading = false;
      });
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(widget.adminId)
        .get();
    if (!mounted) return;
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _admin = UserSchema()
          ..uid = doc.id
          ..displayName = data['name'] ?? ''
          ..email = data['username'] ?? ''
          ..username = data['username']
          ..role = 'sub_admin'
          ..isSuperAdmin = false
          ..permissions = List<String>.from(data['permissions'] ?? [])
          ..isActive = data['isActive'] ?? true;
        _selectedPermissions =
            List<String>.from(data['permissions'] ?? []);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(widget.adminId)
          .update({'permissions': _selectedPermissions});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الصلاحيات بنجاح')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الحفظ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppAppBar(
        context: context,
        title: 'تعديل الصلاحيات',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _admin == null
              ? Center(
                  child: Text(
                    'لم يتم العثور على المدير',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.marginMobile),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _admin!.displayName.isNotEmpty
                                          ? _admin!.displayName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 20,
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSizes.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _admin!.displayName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _admin!.email,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'Cairo',
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                      if (_admin!.username != null)
                                        Text(
                                          _admin!.username!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Cairo',
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      Text(
                        'الصلاحيات',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: AppColors.onBackground),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      ...PermissionConstants.allPermissions.map(
                        (perm) => CheckboxListTile(
                          title: Text(
                            perm['labelAr']!,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                            ),
                          ),
                          value: _selectedPermissions.contains(perm['key']),
                          activeColor: AppColors.primary,
                          controlAffinity: ListTileControlAffinity.trailing,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedPermissions.add(perm['key']!);
                              } else {
                                _selectedPermissions.remove(perm['key']!);
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            disabledBackgroundColor: AppColors.primaryContainer,
                            disabledForegroundColor: AppColors.onPrimaryContainer,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusMd),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.onPrimary,
                                  ),
                                )
                              : const Text(
                                  'حفظ التغييرات',
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
    );
  }
}
