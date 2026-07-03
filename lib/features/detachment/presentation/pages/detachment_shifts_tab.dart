import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/detachment_member_model.dart';
import '../../models/detachment_shift_model.dart';
import '../../models/week_day.dart';
import '../../providers/detachment_detail_provider.dart';
import '../../../../app.dart';

class DetachmentShiftsTab extends ConsumerWidget {
  final String detachmentId;

  const DetachmentShiftsTab({super.key, required this.detachmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftsAsync = ref.watch(detachmentShiftsProvider(detachmentId));
    final membersAsync = ref.watch(detachmentMembersProvider(detachmentId));

    final allMembers = membersAsync.valueOrNull ?? [];
    final activeMembers = allMembers.where((m) => m.isActive).toList();

    return shiftsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(
        child: Text('خطأ: $e',
            style: const TextStyle(
                fontFamily: 'Cairo', color: AppColors.error)),
      ),
      data: (shifts) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(children: [
                const Text('الشفتات الأسبوعية',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                        fontSize: 16)),
                const Spacer(),
                Text('${shifts.length} إجمالي',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                        fontFamily: 'Cairo')),
              ]),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  mainAxisExtent: 126,
                ),
                itemCount: WeekDay.values.length,
                itemBuilder: (_, i) {
                  final day = WeekDay.values[i];
                  final dayShifts =
                      shifts.where((s) => s.weekDay == day).toList();
                  final count = dayShifts.length;

                  return _DayCard(
                    day: day,
                    shiftCount: count,
                    hasMembers: activeMembers.isNotEmpty,
                    onTap: () => context.push(
                      '/deployments/$detachmentId/day-shifts/${day.storageKey}',
                    ),
                    onAddShift: activeMembers.isEmpty
                        ? null
                        : () => _quickAddShift(
                            context, ref, activeMembers, day),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _quickAddShift(BuildContext ctx, WidgetRef ref,
      List<DetachmentMemberModel> activeMembers, WeekDay weekDay) {
    final nameCtrl = TextEditingController();
    final selectedMembers = <String>{};
    String? leaderId;
    String startTime = '08:00';
    String endTime = '16:00';

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (ctx2) => StatefulBuilder(
        builder: (_, setSt) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollCtrl) => SingleChildScrollView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'إضافة شفت — ${weekDay.arabicLabel}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'اسم الشفت (اختياري)',
                    hintText: 'مثال: شفت الصباح',
                    labelStyle: TextStyle(fontFamily: 'Cairo'),
                    hintStyle: TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: ctx2,
                          initialTime: _parseTime(startTime),
                        );
                        if (time != null) {
                          setSt(() => startTime = _fmtTime(time));
                        }
                      },
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(startTime,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Cairo')),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('إلى',
                        style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: ctx2,
                          initialTime: _parseTime(endTime),
                        );
                        if (time != null) {
                          setSt(() => endTime = _fmtTime(time));
                        }
                      },
                      icon: const Icon(Icons.access_time_filled,
                          size: 18),
                      label: Text(endTime,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Cairo')),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                const Text('الأعضاء',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        fontFamily: 'Cairo')),
                const SizedBox(height: 4),
                ...activeMembers.map((m) {
                  final selected = selectedMembers.contains(m.uid);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: CheckboxListTile(
                      value: selected,
                      title: Row(children: [
                        if (m.isLeader)
                          const Icon(Icons.shield_outlined,
                              size: 14,
                              color: AppColors.adminPurple),
                        if (m.isLeader) const SizedBox(width: 4),
                        Text(m.name,
                            style: TextStyle(
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontFamily: 'Cairo')),
                      ]),
                      onChanged: (v) {
                        setSt(() {
                          if (v == true) {
                            selectedMembers.add(m.uid);
                          } else {
                            selectedMembers.remove(m.uid);
                            if (leaderId == m.uid) leaderId = null;
                          }
                        });
                      },
                      dense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  );
                }),
                if (selectedMembers.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('قائد الشفت (مطلوب)',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          fontFamily: 'Cairo')),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue:
                        selectedMembers.contains(leaderId)
                            ? leaderId
                            : null,
                    decoration: const InputDecoration(
                      hintText: 'اختر القائد',
                      hintStyle: TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(),
                    ),
                    items: activeMembers
                        .where((m) =>
                            selectedMembers.contains(m.uid))
                        .map((m) => DropdownMenuItem(
                            value: m.uid,
                            child: Row(children: [
                              const Icon(Icons.star,
                                  size: 14,
                                  color: AppColors.goldBright),
                              const SizedBox(width: 6),
                              Text(m.name,
                                  style: const TextStyle(
                                      fontFamily: 'Cairo')),
                            ])))
                        .toList(),
                    onChanged: (v) => setSt(() => leaderId = v),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: (selectedMembers.isEmpty ||
                          leaderId == null ||
                          !selectedMembers.contains(leaderId))
                      ? null
                      : () async {
                          final repo =
                              ref.read(detachmentNewRepoProvider);
                          final startParts = startTime.split(':');
                          final endParts = endTime.split(':');
                          final startMin =
                              int.parse(startParts[0]) * 60 +
                                  int.parse(startParts[1]);
                          final endMin =
                              int.parse(endParts[0]) * 60 +
                                  int.parse(endParts[1]);
                          final diff = endMin >= startMin
                              ? endMin - startMin
                              : (24 * 60 - startMin) + endMin;

                          final shift = DetachmentShiftModel(
                            uid: '',
                            detachmentId: detachmentId,
                            weekDay: weekDay,
                            shiftName: nameCtrl.text.trim(),
                            startTime: startTime,
                            endTime: endTime,
                            durationHours: diff / 60.0,
                            memberIds: selectedMembers.toList(),
                            memberCount: selectedMembers.length,
                            leaderId: leaderId!,
                            attendance: {},
                            createdAt: DateTime.now(),
                            createdBy: '',
                          );
                          await repo.createShift(shift);
                          if (ctx2.mounted) Navigator.pop(ctx2);
                        },
                  child: const Text('إنشاء الشفت',
                      style: TextStyle(fontFamily: 'Cairo')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TimeOfDay _parseTime(String t) {
    final p = t.split(':');
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _DayCard extends StatelessWidget {
  final WeekDay day;
  final int shiftCount;
  final bool hasMembers;
  final VoidCallback onTap;
  final VoidCallback? onAddShift;

  const _DayCard({
    required this.day,
    required this.shiftCount,
    required this.hasMembers,
    required this.onTap,
    this.onAddShift,
  });

  @override
  Widget build(BuildContext context) {
    final hasShifts = shiftCount > 0;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: hasShifts
                      ? AppColors.primarySurface
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: hasShifts
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                day.arabicLabel,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: hasShifts
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: hasShifts
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hasShifts ? '$shiftCount شفت' : 'فارغ',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: hasShifts
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (onAddShift != null) ...[
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: onAddShift,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add,
                            size: 16, color: AppColors.primary),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
