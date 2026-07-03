import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../app.dart';
import '../../models/detachment_day_model.dart';
import '../../providers/detachment_detail_provider.dart';
import 'detachment_members_tab.dart';
import 'detachment_shifts_tab.dart';
import 'detachment_status_tab.dart';

class DetachmentDayDetailPage extends ConsumerStatefulWidget {
  final String dayId;

  const DetachmentDayDetailPage({super.key, required this.dayId});

  @override
  ConsumerState<DetachmentDayDetailPage> createState() =>
      _DetachmentDayDetailPageState();
}

class _DetachmentDayDetailPageState
    extends ConsumerState<DetachmentDayDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dayAsync =
        ref.watch(detachmentDetailProvider(widget.dayId));

    return dayAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
            child:
                CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('خطأ',
              style: TextStyle(fontFamily: 'Cairo')),
        ),
        body: Center(
          child: Text(
            'حدث خطأ',
            style: const TextStyle(
                fontFamily: 'Cairo', color: AppColors.error),
          ),
        ),
      ),
      data: (DetachmentDayModel? day) {
        if (day == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text('المفرزة غير موجودة',
                  style: TextStyle(
                      fontFamily: 'Cairo', color: AppColors.error)),
            ),
          );
        }

        final membersAsync =
            ref.watch(detachmentMembersProvider(day.uid));
        final shiftsAsync =
            ref.watch(detachmentShiftsProvider(day.uid));
        final patientsAsync =
            ref.watch(detachmentPatientsProvider(day.uid));

        final members = membersAsync.valueOrNull ?? [];
        final shifts = shiftsAsync.valueOrNull ?? [];
        final patients = patientsAsync.valueOrNull ?? [];

        final memberCount = members.length;
        final activeMembers =
            members.where((m) => m.isActive).length;
        final leaderCount =
            members.where((m) => m.isLeader).length;
        final shiftCount = shifts.length;
        final patientCount = patients.length;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            centerTitle: true,
            title: Text(
              day.dayName,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') _showEditDialog(day);
                  if (v == 'delete') _confirmDelete(day);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('تعديل',
                            style: TextStyle(fontFamily: 'Cairo')),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outlined,
                            size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('حذف',
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                color: AppColors.primarySurface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _QuickStat(
                      icon: Icons.people,
                      label: 'الأعضاء',
                      value: '$activeMembers/$memberCount',
                      color: AppColors.primary,
                    ),
                    _QuickStat(
                      icon: Icons.shield,
                      label: 'القادة',
                      value: '$leaderCount',
                      color: AppColors.adminPurple,
                    ),
                    _QuickStat(
                      icon: Icons.schedule,
                      label: 'الشفتات',
                      value: '$shiftCount',
                      color: AppColors.goldBright,
                    ),
                    _QuickStat(
                      icon: Icons.local_hospital,
                      label: 'المرضى',
                      value: '$patientCount',
                      color: AppColors.error,
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabCtrl,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.onSurfaceVariant,
                indicatorColor: AppColors.primary,
                labelStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: 'الشفتات'),
                  Tab(text: 'الأعضاء'),
                  Tab(text: 'المرضى'),
                  Tab(text: 'نظرة عامة'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    DetachmentShiftsTab(
                        detachmentId: day.uid),
                    DetachmentMembersTab(
                        detachmentId: day.uid),
                    DetachmentStatusTab(
                        detachmentId: day.uid),
                    _OverviewTab(day: day),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(DetachmentDayModel day) {
    final nameCtrl = TextEditingController(text: day.dayName);
    final leaderCtrl =
        TextEditingController(text: day.leaderName ?? '');
    final placeCtrl = TextEditingController(text: day.location);
    final daysCtrl =
        TextEditingController(text: day.durationDays.toString());
    final descCtrl =
        TextEditingController(text: day.description ?? '');
    final rulesCtrl =
        TextEditingController(text: day.rules ?? '');
    String status = day.status;
    bool isActive = day.isActive;

    showDialog(
      context: context,
      builder: (ctx2) => StatefulBuilder(
        builder: (_, setSt) => AlertDialog(
          title: const Text('تعديل المفرزة',
              style: TextStyle(fontFamily: 'Cairo')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'اسم المفرزة *',
                    labelStyle: TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: leaderCtrl,
                  decoration: const InputDecoration(
                    labelText: 'القائد',
                    labelStyle: TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: placeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'المكان',
                    labelStyle: TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: daysCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'عدد الأيام',
                    labelStyle: TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(
                    labelText: 'الحالة',
                    labelStyle: TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'active', child: Text('نشط')),
                    DropdownMenuItem(
                        value: 'standby', child: Text('استعداد')),
                    DropdownMenuItem(
                        value: 'deployed', child: Text('منتشر')),
                    DropdownMenuItem(
                        value: 'inactive', child: Text('غير نشط')),
                  ],
                  onChanged: (v) {
                    if (v != null) setSt(() => status = v);
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('نشط',
                      style: TextStyle(fontFamily: 'Cairo')),
                  value: isActive,
                  onChanged: (v) => setSt(() => isActive = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'الوصف',
                    labelStyle: TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: rulesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'القواعد والملاحظات',
                    labelStyle: TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx2),
              child: const Text('إلغاء',
                  style: TextStyle(fontFamily: 'Cairo')),
            ),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final updated = day.copyWith(
                  dayName: nameCtrl.text.trim(),
                  leaderName: leaderCtrl.text.trim().isEmpty
                      ? null
                      : leaderCtrl.text.trim(),
                  location: placeCtrl.text.trim(),
                  durationDays:
                      int.tryParse(daysCtrl.text.trim()) ?? 1,
                  isActive: isActive,
                  status: status,
                  description: descCtrl.text.trim().isEmpty
                      ? null
                      : descCtrl.text.trim(),
                  rules: rulesCtrl.text.trim().isEmpty
                      ? null
                      : rulesCtrl.text.trim(),
                );
                await ref
                    .read(detachmentNewRepoProvider)
                    .updateDay(updated);
                if (ctx2.mounted) Navigator.pop(ctx2);
              },
              child: const Text('حفظ',
                  style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(DetachmentDayModel day) {
    showDialog(
      context: context,
      builder: (ctx2) => AlertDialog(
        title: const Text('حذف المفرزة',
            style: TextStyle(fontFamily: 'Cairo')),
        content: Text(
          'هل أنت متأكد من حذف "${day.dayName}" وجميع بياناتها؟ لا يمكن التراجع.',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx2),
            child: const Text('إلغاء',
                style: TextStyle(fontFamily: 'Cairo')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () async {
              await ref
                  .read(detachmentNewRepoProvider)
                  .deleteDay(day.uid);
              if (mounted) context.pop();
            },
            child: const Text('حذف',
                style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _QuickStat(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 6),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
                fontFamily: 'Cairo')),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
                fontFamily: 'Cairo')),
      ]),
    ]);
  }
}

class _OverviewTab extends StatelessWidget {
  final DetachmentDayModel day;
  const _OverviewTab({required this.day});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.speed,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text('معلومات المفرزة',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(day.status)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _statusLabel(day.status),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _statusColor(day.status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow(
                    label: 'الحالة',
                    value: _statusLabel(day.status)),
                _InfoRow(
                    label: 'القائد',
                    value: day.leaderName ?? '-'),
                _InfoRow(label: 'المكان', value: day.location),
                _InfoRow(
                    label: 'المدة',
                    value:
                        '${day.durationDays} ${day.durationDays == 1 ? 'يوم' : 'أيام'}'),
                _InfoRow(
                    label: 'عدد الأعضاء',
                    value: '${day.memberIds.length}'),
              ],
            ),
          ),
        ),
        if (day.description != null &&
            day.description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الوصف',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  const SizedBox(height: 8),
                  Text(day.description!,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                          fontFamily: 'Cairo',
                          height: 1.6)),
                ],
              ),
            ),
          ),
        ],
        if (day.rules != null && day.rules!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('القواعد والملاحظات',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  const SizedBox(height: 8),
                  Text(day.rules!,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                          fontFamily: 'Cairo',
                          height: 1.6)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'standby':
        return AppColors.goldBright;
      case 'deployed':
        return AppColors.volunteerBlue;
      case 'inactive':
        return AppColors.error;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'نشط';
      case 'standby':
        return 'استعداد';
      case 'deployed':
        return 'منتشر';
      case 'inactive':
        return 'غير نشط';
      default:
        return status;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w500))),
        Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo'))),
      ]),
    );
  }
}
