import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../app.dart';
import '../../models/detachment_member_model.dart';
import '../../models/detachment_shift_model.dart';
import '../../models/week_day.dart';
import '../../providers/detachment_detail_provider.dart';

class DayShiftsPage extends ConsumerWidget {
  final String detachmentId;
  final String weekDayKey;

  const DayShiftsPage({
    super.key,
    required this.detachmentId,
    required this.weekDayKey,
  });

  WeekDay get _day => WeekDay.fromStorageKey(weekDayKey);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftsAsync = ref.watch(detachmentShiftsProvider(detachmentId));
    final membersAsync = ref.watch(detachmentMembersProvider(detachmentId));

    final allMembers = membersAsync.valueOrNull ?? [];
    final activeMembers = allMembers.where((m) => m.isActive).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        title: Text(
          _day.arabicLabel,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: activeMembers.isNotEmpty
          ? FloatingActionButton(
              onPressed: () =>
                  _showShiftForm(context, ref, activeMembers, null),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: AppColors.onPrimary),
            )
          : null,
      body: shiftsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Text('خطأ: $e',
              style: const TextStyle(
                  fontFamily: 'Cairo', color: AppColors.error)),
        ),
        data: (List<DetachmentShiftModel> allShifts) {
          final dayShifts =
              allShifts.where((s) => s.weekDay == _day).toList();

          if (dayShifts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 64,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text(
                    'لا يوجد شفتات ليوم ${_day.arabicLabel}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (activeMembers.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => _showShiftForm(
                          context, ref, activeMembers, null),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('إضافة شفت',
                          style: TextStyle(fontFamily: 'Cairo')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                      ),
                    ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dayShifts.length,
            itemBuilder: (_, i) {
              final shift = dayShifts[i];
              final leader = membersAsync.valueOrNull
                  ?.where((m) => m.uid == shift.leaderId)
                  .firstOrNull;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.schedule, size: 16,
                            color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            shift.shiftName.isNotEmpty
                                ? shift.shiftName
                                : 'شفت',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                fontFamily: 'Cairo'),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${shift.startTime} – ${shift.endTime}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                fontFamily: 'Cairo'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(shift.durationLabel,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                                fontFamily: 'Cairo')),
                      ]),
                      if (leader != null) ...[
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.star, size: 14,
                              color: AppColors.goldBright),
                          const SizedBox(width: 4),
                          Text('القائد: ${leader.name}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Cairo',
                                  color: AppColors.goldDark)),
                        ]),
                      ],
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.check_circle, size: 16,
                            color: AppColors.success),
                        const SizedBox(width: 4),
                        Text('${shift.presentCount}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                                fontFamily: 'Cairo')),
                        const SizedBox(width: 12),
                        const Icon(Icons.cancel, size: 16,
                            color: AppColors.error),
                        const SizedBox(width: 4),
                        Text('${shift.absentCount}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                                fontFamily: 'Cairo')),
                        const Spacer(),
                        Text('${shift.memberIds.length} معين',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                                fontFamily: 'Cairo')),
                      ]),
                      const SizedBox(height: 8),
                      ...shift.memberIds.map((mid) {
                        final member = membersAsync.valueOrNull
                            ?.where((m) => m.uid == mid)
                            .firstOrNull;
                        final isPresent =
                            shift.attendance[mid] ?? false;
                        if (member == null) return const SizedBox.shrink();
                        return InkWell(
                          onTap: () => ref
                              .read(detachmentNewRepoProvider)
                              .toggleAttendance(
                                  shift.uid, mid, !isPresent),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 8),
                            child: Row(children: [
                              AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isPresent
                                      ? AppColors.success
                                      : AppColors.error
                                          .withValues(alpha: 0.15),
                                ),
                                child: Center(
                                  child: Icon(
                                    isPresent
                                        ? Icons.check
                                        : Icons.close,
                                    size: 18,
                                    color: isPresent
                                        ? Colors.white
                                        : AppColors.error,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(member.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Cairo',
                                      fontWeight: isPresent
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      decoration: isPresent
                                          ? TextDecoration.none
                                          : TextDecoration.lineThrough,
                                      color: isPresent
                                          ? AppColors.onSurface
                                          : AppColors.onSurfaceVariant,
                                    )),
                              ),
                              if (member.uid == shift.leaderId)
                                const Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(Icons.star, size: 14,
                                      color: AppColors.goldBright),
                                ),
                            ]),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _showShiftForm(context,
                                  ref, activeMembers, shift),
                              icon: const Icon(Icons.edit_outlined,
                                  size: 16),
                              label: const Text('تعديل',
                                  style:
                                      TextStyle(fontFamily: 'Cairo')),
                              style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary),
                            ),
                            TextButton.icon(
                              onPressed: () => _confirmDelete(
                                  context, ref, shift),
                              icon: const Icon(Icons.delete_outlined,
                                  size: 16),
                              label: const Text('حذف',
                                  style:
                                      TextStyle(fontFamily: 'Cairo')),
                              style: TextButton.styleFrom(
                                  foregroundColor: AppColors.error),
                            ),
                          ]),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showShiftForm(BuildContext ctx, WidgetRef ref,
      List<DetachmentMemberModel> activeMembers,
      DetachmentShiftModel? existing) {
    final nameCtrl =
        TextEditingController(text: existing?.shiftName ?? '');
    final selectedMembers = <String>{...?existing?.memberIds};
    String? leaderId = existing?.leaderId;
    String startTime = existing?.startTime ?? '08:00';
    String endTime = existing?.endTime ?? '16:00';

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
                  existing == null
                      ? 'إضافة شفت — ${_day.arabicLabel}'
                      : 'تعديل الشفت',
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
                const SizedBox(height: 16),
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
                const SizedBox(height: 20),
                const Text('الأعضاء',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        fontFamily: 'Cairo')),
                const SizedBox(height: 8),
                if (activeMembers.isEmpty)
                  const Text('لا يوجد أعضاء نشطون. أضف أعضاء أولاً.',
                      style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontFamily: 'Cairo'))
                else
                  ...activeMembers.map((m) {
                    final selected = selectedMembers.contains(m.uid);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
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
                        subtitle: m.phone != null
                            ? Text(m.phone!,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color:
                                        AppColors.onSurfaceVariant,
                                    fontFamily: 'Cairo'))
                            : null,
                        onChanged: (v) {
                          setSt(() {
                            if (v == true) {
                              selectedMembers.add(m.uid);
                            } else {
                              selectedMembers.remove(m.uid);
                              if (leaderId == m.uid) {
                                leaderId = null;
                              }
                            }
                          });
                        },
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4),
                      ),
                    );
                  }),
                if (selectedMembers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('قائد الشفت (مطلوب)',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          fontFamily: 'Cairo')),
                  const SizedBox(height: 8),
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
                const SizedBox(height: 24),
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

                          if (existing == null) {
                            final shift = DetachmentShiftModel(
                              uid: '',
                              detachmentId: detachmentId,
                              weekDay: _day,
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
                          } else {
                            await repo.updateShift(existing.copyWith(
                              shiftName: nameCtrl.text.trim(),
                              startTime: startTime,
                              endTime: endTime,
                              durationHours: diff / 60.0,
                              memberIds: selectedMembers.toList(),
                              memberCount: selectedMembers.length,
                              leaderId: leaderId!,
                            ));
                          }
                          if (ctx2.mounted) Navigator.pop(ctx2);
                        },
                  child: Text(
                      existing == null
                          ? 'إنشاء الشفت'
                          : 'حفظ التغييرات',
                      style: const TextStyle(fontFamily: 'Cairo')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, WidgetRef ref,
      DetachmentShiftModel shift) {
    showDialog(
      context: ctx,
      builder: (ctx2) => AlertDialog(
        title: const Text('حذف الشفت',
            style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('هل أنت متأكد من حذف هذا الشفت؟',
            style: TextStyle(fontFamily: 'Cairo')),
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
                  .deleteShift(shift.uid);
              if (ctx2.mounted) Navigator.pop(ctx2);
            },
            child: const Text('حذف',
                style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
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
