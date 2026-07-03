import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../app.dart';
import '../../models/detachment_shift_model.dart';
import '../../models/detachment_member_model.dart';
import '../../models/week_day.dart';

final detachmentMembersProvider =
    StreamProvider<List<DetachmentMemberModel>>((ref) {
  return ref.read(detachmentNewRepoProvider).watchMembers();
});

class ShiftFormPage extends ConsumerStatefulWidget {
  final DetachmentShiftModel? initialShift;
  const ShiftFormPage({super.key, this.initialShift});

  bool get isEditing => initialShift != null;

  @override
  ConsumerState<ShiftFormPage> createState() => _ShiftFormPageState();
}

class _ShiftFormPageState extends ConsumerState<ShiftFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();

  WeekDay _selectedDay = WeekDay.saturday;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final Set<String> _selectedMemberIds = {};
  String? _leaderId;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialShift;
    if (initial != null) {
      _nameController.text = initial.shiftName;
      _selectedDay = initial.weekDay;
      _startTime = _parseTimeOfDay(initial.startTime);
      _endTime = _parseTimeOfDay(initial.endTime);
      _selectedMemberIds.addAll(initial.memberIds);
      _leaderId = initial.leaderId.isNotEmpty ? initial.leaderId : null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTimeOfDay(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0,
        minute: int.tryParse(parts[1]) ?? 0);
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  double _calcDuration() {
    if (_startTime == null || _endTime == null) return 0;
    final sm = _startTime!.hour * 60 + _startTime!.minute;
    final em = _endTime!.hour * 60 + _endTime!.minute;
    final diff = em >= sm ? em - sm : (24 * 60 - sm) + em;
    return diff / 60.0;
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 8, minute: 0),
      builder: (ctx, child) {
        return MediaQuery(
          data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 14, minute: 0),
      builder: (ctx, child) {
        return MediaQuery(
          data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  void _toggleMember(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedMemberIds.add(id);
      } else {
        _selectedMemberIds.remove(id);
        if (_leaderId == id) _leaderId = null;
      }
    });
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMessage = null);

    if (_startTime == null || _endTime == null) {
      setState(() => _errorMessage = 'حدد وقت البداية والنهاية');
      return;
    }
    if (_selectedMemberIds.isEmpty) {
      setState(() => _errorMessage = 'اختر عضوًا واحدًا على الأقل');
      return;
    }
    if (_leaderId == null || !_selectedMemberIds.contains(_leaderId)) {
      setState(() => _errorMessage = 'حدد مسؤول الشفت من ضمن الأعضاء المختارين');
      return;
    }

    setState(() => _isSaving = true);

    final user = ref.read(currentUserProvider).valueOrNull;
    final startTime = _fmt(_startTime!);
    final endTime = _fmt(_endTime!);
    final duration = _calcDuration();
    final repo = ref.read(detachmentNewRepoProvider);

    final shift = DetachmentShiftModel(
      uid: widget.initialShift?.uid ?? '',
      detachmentId: widget.initialShift?.detachmentId ?? '',
      weekDay: _selectedDay,
      shiftName: _nameController.text.trim(),
      startTime: startTime,
      endTime: endTime,
      durationHours: duration,
      memberIds: _selectedMemberIds.toList(),
      memberCount: _selectedMemberIds.length,
      leaderId: _leaderId!,
      createdAt: widget.initialShift?.createdAt ?? DateTime.now(),
      createdBy: widget.initialShift?.createdBy ?? (user?.uid ?? ''),
    );

    final result = widget.isEditing
        ? await repo.updateShift(shift)
        : await repo.createShift(shift);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isSaving = false;
          _errorMessage = failure.message;
        });
      },
      (_) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(detachmentMembersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isEditing ? 'تعديل الشفت' : 'إضافة شفت',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.marginMobile),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'اسم الشفت (اختياري)',
                labelStyle: const TextStyle(fontFamily: 'Cairo'),
                hintText: 'مثال: شفت الصباح',
                hintStyle: const TextStyle(fontFamily: 'Cairo'),
                border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusDefault)),
              ),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            const SizedBox(height: AppSizes.md),
            const Text('اليوم',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface)),
            const SizedBox(height: AppSizes.xs),
            DropdownButtonFormField<WeekDay>(
              items: WeekDay.values
                  .map((d) => DropdownMenuItem(
                      value: d,
                      child: Text(d.arabicLabel,
                          style: const TextStyle(fontFamily: 'Cairo'))))
                  .toList(),
              onChanged: (d) {
                if (d != null) setState(() => _selectedDay = d);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusDefault)),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            const Text('الوقت',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface)),
            const SizedBox(height: AppSizes.xs),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickStartTime,
                    icon: const Icon(Icons.access_time,
                        color: AppColors.primary),
                    label: Text(
                      _startTime == null ? 'وقت البداية' : _fmt(_startTime!),
                      style:
                          const TextStyle(fontFamily: 'Cairo'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurface,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppSizes.radiusDefault)),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickEndTime,
                    icon: const Icon(Icons.access_time_filled,
                        color: AppColors.primary),
                    label: Text(
                      _endTime == null ? 'وقت النهاية' : _fmt(_endTime!),
                      style:
                          const TextStyle(fontFamily: 'Cairo'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurface,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppSizes.radiusDefault)),
                    ),
                  ),
                ),
              ],
            ),
            if (_startTime != null && _endTime != null) ...[
              const SizedBox(height: AppSizes.xs),
              Text(
                'المدة: ${_calcDuration().toStringAsFixed(1)} ساعة',
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.primary),
              ),
            ],
            const SizedBox(height: AppSizes.md),
            const Text('الأعضاء',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface)),
            const SizedBox(height: AppSizes.xs),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'ابحث عن عضو...',
                hintStyle: const TextStyle(fontFamily: 'Cairo'),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.onSurfaceVariant),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusDefault),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            const SizedBox(height: AppSizes.sm),
            membersAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primary)),
              error: (e, _) => Text('تعذر تحميل الأعضاء: $e',
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: AppColors.error)),
              data: (allMembers) {
                final query = _searchController.text.trim();
                final filtered = query.isEmpty
                    ? allMembers
                    : allMembers
                        .where((m) =>
                            m.name.toLowerCase().contains(
                                query.toLowerCase()))
                        .toList();
                if (filtered.isEmpty) {
                  return const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 16),
                    child: Text('لا يوجد أعضاء مطابقين',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            color:
                                AppColors.onSurfaceVariant)),
                  );
                }
                return Column(
                  children: filtered.map((m) {
                    final selected =
                        _selectedMemberIds.contains(m.uid);
                    return Card(
                      color: selected
                          ? AppColors.primarySurface
                          : AppColors.surface,
                      elevation: 0,
                      margin: const EdgeInsets.only(
                          bottom: AppSizes.xs),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd),
                        side: BorderSide(
                          color: selected
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                      ),
                      child: CheckboxListTile(
                        value: selected,
                        activeColor: AppColors.primary,
                        title: Text(m.name,
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface)),
                        subtitle: Text(
                          m.role == 'admin'
                              ? 'مشرف'
                              : m.role == 'representative'
                                  ? 'ممثل'
                                  : 'متطوع',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: m.role == 'admin'
                                ? AppColors.adminPurple
                                : m.role == 'representative'
                                    ? AppColors.goldBright
                                    : AppColors.volunteerBlue,
                          ),
                        ),
                        onChanged: (v) =>
                            _toggleMember(m.uid, v ?? false),
                        contentPadding:
                            const EdgeInsets.symmetric(
                                horizontal: AppSizes.md),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: AppSizes.md),
            const Text('مسؤول الشفت',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface)),
            const SizedBox(height: AppSizes.xs),
            membersAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (allMembers) {
                final selectedMembers = allMembers
                    .where((m) => _selectedMemberIds.contains(m.uid))
                    .toList();
                if (selectedMembers.isEmpty) {
                  return const Text(
                    'اختر الأعضاء أولًا حتى تقدر تحدد مسؤول الشفت',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13),
                  );
                }
                return DropdownButtonFormField<String>(
                  hint: const Text('اختر المسؤول',
                      style: TextStyle(fontFamily: 'Cairo')),
                  items: selectedMembers
                      .map((m) => DropdownMenuItem(
                          value: m.uid,
                          child: Text(m.name,
                              style: const TextStyle(
                                  fontFamily: 'Cairo'))))
                      .toList(),
                  onChanged: (id) =>
                      setState(() => _leaderId = id),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            AppSizes.radiusDefault)),
                  ),
                );
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSizes.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(
                      AppSizes.radiusDefault),
                ),
                child: Text(_errorMessage!,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.danger)),
              ),
            ],
            const SizedBox(height: AppSizes.lg),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppSizes.radiusDefault)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary),
                      )
                    : Text(
                        widget.isEditing ? 'حفظ التعديلات' : 'إضافة الشفت',
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
