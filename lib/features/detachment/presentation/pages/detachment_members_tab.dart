import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../app.dart';
import '../../models/detachment_member_model.dart';
import '../../providers/detachment_detail_provider.dart';
import '../../providers/detachment_tag_provider.dart';
import '../../widgets/autocomplete_field.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class DetachmentMembersTab extends ConsumerWidget {
  final String detachmentId;

  const DetachmentMembersTab({super.key, required this.detachmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(detachmentMembersProvider(detachmentId));

    return membersAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(
        child: Text('خطأ: $e',
            style: const TextStyle(fontFamily: 'Cairo', color: AppColors.error)),
      ),
      data: (members) {
    final leaders = members.where((m) => m.isLeader).length;

        if (members.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.person_add_outlined,
            title: 'لا يوجد أعضاء بعد',
            subtitle: 'أضف أعضاء وقادة لهذه المفرزة',
            actionLabel: 'إضافة عضو',
            onAction: () => _showMemberForm(context, ref, null),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(children: [
                Text('${members.length} أعضاء',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Cairo')),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.adminPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.shield, size: 14,
                        color: AppColors.adminPurple),
                    const SizedBox(width: 4),
                    Text('$leaders قادة',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Cairo',
                            color: AppColors.adminPurple)),
                  ]),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: () => _showMemberForm(context, ref, null),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('إضافة',
                      style: TextStyle(fontFamily: 'Cairo')),
                ),
              ]),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: members.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final m = members[i];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: m.isLeader
                                ? AppColors.adminPurple.withValues(alpha: 0.12)
                                : AppColors.primary.withValues(alpha: 0.1),
                            child: Icon(
                                m.isLeader
                                    ? Icons.shield_outlined
                                    : Icons.person_outline,
                                color: m.isLeader
                                    ? AppColors.adminPurple
                                    : AppColors.primary,
                                size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        fontFamily: 'Cairo')),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: m.isLeader
                                        ? AppColors.goldLight
                                        : AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    m.role,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Cairo',
                                      color: m.isLeader
                                          ? AppColors.goldDark
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!m.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.error
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('غير نشط',
                                  style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Cairo')),
                            ),
                          const SizedBox(width: 4),
                          PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit') {
                                _showMemberForm(context, ref, m);
                              } else if (v == 'delete') {
                                _confirmDeleteMember(context, ref, m);
                              } else if (v == 'toggle') {
                                ref
                                    .read(detachmentNewRepoProvider)
                                    .updateMember(
                                        m.copyWith(isActive: !m.isActive));
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(children: [
                                  Icon(Icons.edit_outlined, size: 16),
                                  SizedBox(width: 8),
                                  Text('تعديل',
                                      style: TextStyle(fontFamily: 'Cairo')),
                                ]),
                              ),
                              PopupMenuItem(
                                value: 'toggle',
                                child: Row(children: [
                                  Icon(
                                    m.isActive
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(m.isActive ? 'تعطيل' : 'تفعيل',
                                      style: const TextStyle(
                                          fontFamily: 'Cairo')),
                                ]),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(children: [
                                  Icon(Icons.delete_outlined,
                                      size: 16, color: AppColors.error),
                                  SizedBox(width: 8),
                                  Text('حذف',
                                      style: TextStyle(
                                          fontFamily: 'Cairo',
                                          color: AppColors.error)),
                                ]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMemberForm(
      BuildContext ctx, WidgetRef ref, DetachmentMemberModel? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    String roleVal = existing?.role ?? 'عضو';
    String specialtyVal = existing?.specialty ?? '';
    bool active = existing?.isActive ?? true;

    const roles = ['مسؤول', 'عضو', 'دعم', 'تنظيم', 'اداري', 'متابعة'];

    final specialtiesAsync = ref.watch(specialtiesProvider);
    final specialties = specialtiesAsync.valueOrNull ?? [];

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (ctx2) => StatefulBuilder(
        builder: (_, setSt) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx2).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  existing == null ? 'إضافة عضو' : 'تعديل عضو',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل *',
                    labelStyle: TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    labelStyle: TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 12),
                AutocompleteField(
                  label: 'التخصص',
                  initialValue: specialtyVal,
                  suggestions: specialties,
                  onChanged: (v) => setSt(() => specialtyVal = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: roles.contains(roleVal) ? roleVal : 'عضو',
                  decoration: const InputDecoration(
                    labelText: 'الدور في المفرزة',
                    labelStyle: TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(),
                  ),
                  items: roles
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r,
                                style: const TextStyle(fontFamily: 'Cairo')),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setSt(() => roleVal = v);
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('نشط',
                      style: TextStyle(fontFamily: 'Cairo')),
                  value: active,
                  onChanged: (v) => setSt(() => active = v),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final repo = ref.read(detachmentNewRepoProvider);
                    final tagRepo = ref.read(detachmentTagRepoProvider);
                    if (existing == null) {
                      final member = DetachmentMemberModel(
                        uid: '',
                        detachmentId: detachmentId,
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim().isEmpty
                            ? null
                            : phoneCtrl.text.trim(),
                        specialty: specialtyVal.trim().isEmpty
                            ? null
                            : specialtyVal.trim(),
                        role: roleVal,
                        isActive: active,
                        createdAt: DateTime.now(),
                      );
                      await repo.addMember(member);
                      await tagRepo.saveTags(
                        specialties: specialtyVal.trim().isNotEmpty
                            ? [specialtyVal.trim()]
                            : [],
                        roles: [roleVal],
                      );
                    } else {
                      await repo.updateMember(existing.copyWith(
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim().isEmpty
                            ? null
                            : phoneCtrl.text.trim(),
                        specialty: specialtyVal.trim().isEmpty
                            ? null
                            : specialtyVal.trim(),
                        role: roleVal,
                        isActive: active,
                      ));
                      await tagRepo.saveTags(
                        specialties: specialtyVal.trim().isNotEmpty
                            ? [specialtyVal.trim()]
                            : [],
                        roles: [roleVal],
                      );
                    }
                    if (ctx2.mounted) Navigator.pop(ctx2);
                  },
                  child: Text(existing == null ? 'إضافة عضو' : 'حفظ التغييرات',
                      style: const TextStyle(fontFamily: 'Cairo')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteMember(
      BuildContext ctx, WidgetRef ref, DetachmentMemberModel m) {
    showDialog(
      context: ctx,
      builder: (ctx2) => AlertDialog(
        title: const Text('حذف عضو',
            style: TextStyle(fontFamily: 'Cairo')),
        content: Text('هل أنت متأكد من حذف "${m.name}" من هذه المفرزة؟',
            style: const TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx2),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await ref.read(detachmentNewRepoProvider).deleteMember(m.uid);
              if (ctx2.mounted) Navigator.pop(ctx2);
            },
            child: const Text('حذف',
                style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}
