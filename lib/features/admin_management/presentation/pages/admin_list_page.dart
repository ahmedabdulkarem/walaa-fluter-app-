import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/permission_constants.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/admin_generator_service.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../shared/models/user_schema.dart';
import '../../../admin/presentation/widgets/credentials_bottom_sheet.dart';

class AdminListPage extends ConsumerStatefulWidget {
  const AdminListPage({super.key});

  @override
  ConsumerState<AdminListPage> createState() => _AdminListPageState();
}

class _AdminListPageState extends ConsumerState<AdminListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppAppBar(
        context: context,
        title: 'إدارة المديرين',
      ),
      body: StreamBuilder<List<UserSchema>>(
        stream: AuthService.streamSubAdmins(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final admins = snapshot.data ?? [];
          if (admins.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.admin_panel_settings_outlined,
                      size: 64,
                      color: AppColors.onSurfaceVariant.withAlpha(100)),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'لا يوجد مديرون',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.marginMobile),
            itemCount: admins.length,
            itemBuilder: (context, index) {
              final admin = admins[index];
              final permissions = List<String>.from(admin.permissions);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: AppCard(
                  onTap: () =>
                      context.push(RouteNames.memberEditPath(admin.uid)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusMd),
                            ),
                            child: Center(
                              child: Text(
                                admin.displayName.isNotEmpty
                                    ? admin.displayName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 18,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  admin.displayName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  admin.username ?? admin.email,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Cairo',
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: admin.isActive,
                            activeThumbColor: AppColors.success,
                            onChanged: (value) {
                              FirebaseFirestore.instance
                                  .collection('admins')
                                  .doc(admin.uid)
                                  .update({'isActive': value});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: admin.isActive
                                  ? AppColors.successLight
                                  : AppColors.dangerLight,
                              borderRadius: BorderRadius.circular(
                                  AppSizes.radiusFull),
                            ),
                            child: Text(
                              admin.isActive ? 'نشط' : 'غير نشط',
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Cairo',
                                color: admin.isActive
                                    ? AppColors.success
                                    : AppColors.danger,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Text(
                            '${permissions.length} ${permissions.length == 1 ? 'صلاحية' : 'صلاحيات'}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Cairo',
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          if (admin.sessionDurationHours != null) ...[
                            const Spacer(),
                            Icon(Icons.access_time,
                                size: 14,
                                color: AppColors.onSurfaceVariant
                                    .withAlpha(150)),
                            const SizedBox(width: 4),
                            Text(
                              DateFormatters.sessionDurationLabel(
                                  admin.sessionDurationHours!),
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Cairo',
                                color: AppColors.onSurfaceVariant
                                    .withAlpha(150),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final durationController = TextEditingController(text: '8');
    final selectedPermissions = <String>{};
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: const Text(
                  'إضافة مدير جديد',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'الاسم',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'الاسم مطلوب'
                              : null,
                        ),
                        const SizedBox(height: AppSizes.md),
                        const Text(
                          'الصلاحيات',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        ...PermissionConstants.allPermissions.map(
                          (perm) => CheckboxListTile(
                            title: Text(
                              perm['labelAr']!,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                              ),
                            ),
                            value:
                                selectedPermissions.contains(perm['key']),
                            dense: true,
                            controlAffinity:
                                ListTileControlAffinity.trailing,
                            onChanged: (checked) {
                              setDialogState(() {
                                if (checked == true) {
                                  selectedPermissions.add(perm['key']!);
                                } else {
                                  selectedPermissions
                                      .remove(perm['key']!);
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        TextFormField(
                          controller: durationController,
                          decoration: const InputDecoration(
                            labelText: 'مدة الجلسة (ساعات)',
                            prefixIcon: Icon(Icons.timer_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'مطلوب';
                            final hours = int.tryParse(v);
                            if (hours == null || hours < 1 || hours > 24) {
                              return 'مدخل غير صالح (1-24)';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      if (selectedPermissions.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'يجب اختيار صلاحية واحدة على الأقل'),
                          ),
                        );
                        return;
                      }
                      _createAdmin(
                        ctx,
                        nameController.text.trim(),
                        selectedPermissions.toList(),
                        int.parse(durationController.text.trim()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                    ),
                    child: const Text(
                      'إنشاء',
                      style: TextStyle(fontFamily: 'Cairo'),
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

  Future<void> _createAdmin(
    BuildContext dialogContext,
    String name,
    List<String> permissions,
    int sessionHours,
  ) async {
    final expiresAt =
        DateTime.now().add(Duration(hours: sessionHours));

    final creds = await AdminGeneratorService.createSubAdmin(
      name: name,
      permissions: permissions,
      sessionExpiresAt: expiresAt,
    );

    if (!dialogContext.mounted) return;
    Navigator.of(dialogContext).pop();

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CredentialsBottomSheet(
        name: creds['name']!,
        username: creds['username']!,
        password: creds['password']!,
      ),
    );
  }
}
