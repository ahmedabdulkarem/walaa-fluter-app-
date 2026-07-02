import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/models/team_info_section_schema.dart';
import '../../../../shared/models/team_member_schema.dart';
import '../../../../shared/repositories/team_info_repository.dart';

class TeamPage extends ConsumerStatefulWidget {
  const TeamPage({super.key});

  @override
  ConsumerState<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends ConsumerState<TeamPage> {
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';
    final repo = ref.watch(teamInfoRepositoryProvider);
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    final canManage = currentUser?.isSuperAdmin == true ||
        currentUser?.can('manage_team') == true;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: buildAppAppBar(context: context, title: 'الفريق'),
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
                padding: const EdgeInsets.all(4),
                labelStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
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
                  Tab(text: 'عن الفريق'),
                  Tab(text: 'الأعضاء'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSectionsTab(context, ref, repo, isArabic),
                  _buildMembersTab(context, ref, repo, isArabic, canManage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionsTab(
    BuildContext context,
    WidgetRef ref,
    TeamInfoRepository repo,
    bool isArabic,
  ) {
    return StreamBuilder<List<TeamInfoSectionSchema>>(
      stream: repo.streamSections(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final sections = snapshot.data ?? [];
        if (sections.isEmpty) {
          return _buildEmptyState('لا توجد أقسام بعد');
        }
        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSizes.marginMobile),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? section.titleAr : section.titleEn,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo',
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        isArabic ? section.bodyAr : section.bodyEn,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Cairo',
                          color: AppColors.onSurfaceVariant,
                          height: 1.6,
                        ),
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

  Widget _buildMembersTab(
    BuildContext context,
    WidgetRef ref,
    TeamInfoRepository repo,
    bool isArabic,
    bool canManage,
  ) {
    return StreamBuilder<List<TeamMemberSchema>>(
      stream: repo.streamMembers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final members = snapshot.data ?? [];
        return Stack(
          children: [
            if (members.isEmpty)
              _buildEmptyState('لا يوجد أعضاء بعد')
            else
              RefreshIndicator(
                onRefresh: () async {},
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.marginMobile,
                    AppSizes.marginMobile,
                    AppSizes.marginMobile,
                    canManage ? 80 : AppSizes.marginMobile,
                  ),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: AppCard(
                        padding: const EdgeInsets.all(AppSizes.sm),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primarySurface,
                              child: Text(
                                member.fullName.isNotEmpty
                                    ? member.fullName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Cairo',
                                  color: AppColors.primary,
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
                                          member.fullName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Cairo',
                                            color: AppColors.onSurface,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (member.isLeadership)
                                        const Padding(
                                          padding: EdgeInsetsDirectional.only(
                                            start: 4,
                                          ),
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
                                    member.role,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Cairo',
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (member.department != null &&
                                      member.department!.isNotEmpty) ...[
                                    const SizedBox(height: 1),
                                    Text(
                                      member.department!,
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
                            if (canManage) ...[
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                color: AppColors.primary,
                                onPressed: () =>
                                    _showMemberDialog(repo, member, members),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                color: AppColors.danger,
                                onPressed: () =>
                                    _confirmDelete(repo, member),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (canManage)
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  onPressed: () =>
                      _showMemberDialog(repo, null, members),
                  backgroundColor: AppColors.primary,
                  child: const Icon(
                    Icons.person_add,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.onSurfaceVariant,
          fontSize: 14,
        ),
      ),
    );
  }

  Future<void> _showMemberDialog(
    TeamInfoRepository repo,
    TeamMemberSchema? existing,
    List<TeamMemberSchema> members,
  ) async {
    final isEditing = existing != null;
    final fullNameController =
        TextEditingController(text: existing?.fullName ?? '');
    final departmentController =
        TextEditingController(text: existing?.department ?? '');
    final roleInTeamController =
        TextEditingController(text: existing?.role ?? '');
    final phoneController =
        TextEditingController(text: existing?.phone ?? '');
    var isLeadership = existing?.isLeadership ?? false;
    final nextSortOrder = existing?.sortOrder ??
        (members.isEmpty
            ? 0
            : members
                    .map((m) => m.sortOrder)
                    .reduce((a, b) => a > b ? a : b) +
                1);

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
                          activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
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
      member.phone =
          phoneController.text.trim().isEmpty ? null : phoneController.text.trim();
      member.photoUrl = existing?.photoUrl;
      member.isLeadership = isLeadership;
      member.sortOrder = existing?.sortOrder ?? nextSortOrder;

      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) return;
      await repo.upsertMember(member, user);
    }
  }

  Future<void> _confirmDelete(
    TeamInfoRepository repo,
    TeamMemberSchema member,
  ) async {
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
}
