import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/permission_constants.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/services/admin_generator_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/models/team_member_schema.dart';
import '../../../../shared/models/user_schema.dart';
import '../../../admin/presentation/widgets/credentials_bottom_sheet.dart';

class TeamMembersPage extends ConsumerStatefulWidget {
  const TeamMembersPage({super.key});

  @override
  ConsumerState<TeamMembersPage> createState() => _TeamMembersPageState();
}

class _TeamMembersPageState extends ConsumerState<TeamMembersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final canManageTeam = user?.isSuperAdmin == true ||
        user?.can('manage_team') == true;
    final currentTab = _tabController.index;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppAppBar(context: context, title: 'الأعضاء والصلاحيات'),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSizes.marginMobile,
              vertical: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: TabBar(
              controller: _tabController,
              padding: const EdgeInsets.all(4),
              labelStyle: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              labelColor: AppColors.onPrimary,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'أعضاء الفريق والقادة'),
                Tab(text: 'مديري التطبيق والصلاحيات'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _MembersTab(canManageTeam: canManageTeam),
                _AdminsTab(
                  canManage: user?.isSuperAdmin == true ||
                      user?.can('manage_team') == true,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: currentTab == 0 && canManageTeam
          ? FloatingActionButton(
              heroTag: 'add_member',
              onPressed: () => _showMemberDialog(null),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person_add, color: AppColors.onPrimary),
            )
          : currentTab == 1 && canManageTeam
              ? FloatingActionButton(
                  heroTag: 'add_admin',
                  onPressed: () => _showCreateAdminDialog(context),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.admin_panel_settings,
                      color: AppColors.onPrimary),
                )
              : null,
    );
  }

  Future<void> _showMemberDialog(TeamMemberSchema? existing) async {
    final repo = ref.read(teamInfoRepositoryProvider);
    final isEditing = existing != null;
    final fullNameController =
        TextEditingController(text: existing?.fullName ?? '');
    final departmentController =
        TextEditingController(text: existing?.department ?? '');
    final roleInTeamController =
        TextEditingController(text: existing?.role ?? '');
    final phoneController =
        TextEditingController(text: existing?.phone ?? '');
    final emailController =
        TextEditingController(text: existing?.email ?? '');
    var isLeadership = existing?.isLeadership ?? false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing ? 'تعديل عضو' : 'إضافة عضو',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: fullNameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'الاسم الكامل *',
                        labelStyle: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextField(
                      controller: departmentController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'القسم *',
                        labelStyle: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextField(
                      controller: roleInTeamController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'الدور في الفريق',
                        labelStyle: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextField(
                      controller: phoneController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف',
                        labelStyle: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextField(
                      controller: emailController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        labelStyle: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Row(
                      children: [
                        const Text(
                          'قيادي',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                          ),
                        ),
                        Switch(
                          value: isLeadership,
                          onChanged: (v) =>
                              setDialogState(() => isLeadership = v),
                          activeTrackColor:
                              AppColors.primary.withValues(alpha: 0.3),
                          activeThumbColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (fullNameController.text.trim().isEmpty ||
                        departmentController.text.trim().isEmpty) {
                      return;
                    }
                    Navigator.of(ctx).pop(true);
                  },
                  child: Text(
                    isEditing ? 'حفظ' : 'إضافة',
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      final member = TeamMemberSchema();
      if (existing != null) {
        member.id = existing.id;
        member.uid = existing.uid;
      } else {
        member.uid = DateTime.now().microsecondsSinceEpoch.toString();
      }
      member.fullName = fullNameController.text.trim();
      member.department = departmentController.text.trim();
      member.role = roleInTeamController.text.trim();
      member.phone = phoneController.text.trim().isEmpty
          ? null
          : phoneController.text.trim();
      member.email = emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim();
      member.photoUrl = existing?.photoUrl;
      member.isLeadership = isLeadership;
      member.sortOrder = existing?.sortOrder ?? 0;

      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) return;
      await repo.upsertMember(member, user);
    }
  }

  Future<void> _confirmDelete(TeamMemberSchema member) async {
    final repo = ref.read(teamInfoRepositoryProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'تأكيد الحذف',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف "${member.fullName}"؟',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'حذف',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) return;
      await repo.deleteMember(member.uid, user);
    }
  }

  void _showCreateAdminDialog(BuildContext context) {
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
                            value: selectedPermissions.contains(perm['key']),
                            dense: true,
                            controlAffinity:
                                ListTileControlAffinity.trailing,
                            onChanged: (checked) {
                              setDialogState(() {
                                if (checked == true) {
                                  selectedPermissions.add(perm['key']!);
                                } else {
                                  selectedPermissions.remove(perm['key']!);
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
                            content: Text('يجب اختيار صلاحية واحدة على الأقل'),
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
    final expiresAt = DateTime.now().add(Duration(hours: sessionHours));

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

// ── Members Tab ───────────────────────────────────────────────

class _MembersTab extends ConsumerWidget {
  final bool canManageTeam;

  const _MembersTab({required this.canManageTeam});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(teamInfoRepositoryProvider);

    return StreamBuilder<List<TeamMemberSchema>>(
      stream: repo.streamMembers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final members = snapshot.data ?? [];
        if (members.isEmpty) {
          return const Center(
            child: Text(
              'لا يوجد أعضاء بعد',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
              AppSizes.marginMobile,
              AppSizes.marginMobile,
              AppSizes.marginMobile,
              canManageTeam ? 80 : AppSizes.marginMobile,
            ),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              final mm = member;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSizes.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: mm.isLeadership
                                ? AppColors.goldLight
                                : AppColors.primarySurface,
                            child: Text(
                              mm.fullName.isNotEmpty
                                  ? mm.fullName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Cairo',
                                color: mm.isLeadership
                                    ? AppColors.goldDark
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        mm.fullName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Cairo',
                                          color: AppColors.onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (mm.isLeadership)
                                      const Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: 4),
                                        child: Icon(
                                          Icons.star,
                                          color: AppColors.goldBright,
                                          size: 16,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  mm.role.isNotEmpty
                                      ? mm.role
                                      : 'عضو',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Cairo',
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (mm.department != null &&
                                    mm.department!.isNotEmpty) ...[
                                  const SizedBox(height: 1),
                                  Text(
                                    mm.department!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Cairo',
                                      color: AppColors.outline,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (canManageTeam) ...[
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              color: AppColors.primary,
                              onPressed: () {
                                final page = context
                                    .findAncestorStateOfType<
                                        _TeamMembersPageState>();
                                page?._showMemberDialog(mm);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              color: AppColors.danger,
                              onPressed: () {
                                final page = context
                                    .findAncestorStateOfType<
                                        _TeamMembersPageState>();
                                page?._confirmDelete(mm);
                              },
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ── Admins Tab ────────────────────────────────────────────────

class _AdminsTab extends ConsumerWidget {
  final bool canManage;

  const _AdminsTab({required this.canManage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<UserSchema>>(
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
          padding: EdgeInsets.fromLTRB(
            AppSizes.marginMobile,
            AppSizes.marginMobile,
            AppSizes.marginMobile,
            canManage ? 80 : AppSizes.marginMobile,
          ),
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
                        if (canManage)
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
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusFull),
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
    );
  }
}
