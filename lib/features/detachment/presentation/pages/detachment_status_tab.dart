import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/clipboard_utils.dart';
import '../../../../app.dart';
import '../../models/detachment_patient_model.dart';
import '../../providers/detachment_detail_provider.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class DetachmentStatusTab extends ConsumerWidget {
  final String detachmentId;

  const DetachmentStatusTab({super.key, required this.detachmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(detachmentPatientsProvider(detachmentId));

    return patientsAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(
        child: Text('خطأ: $e',
            style:
                const TextStyle(fontFamily: 'Cairo', color: AppColors.error)),
      ),
      data: (List<DetachmentPatientModel> patients) {
        final statusCounts = <String, int>{};
        for (final p in patients) {
          statusCounts[p.status] = (statusCounts[p.status] ?? 0) + 1;
        }
        final avgAge = patients.isNotEmpty
            ? (patients.fold<double>(0, (s, p) => s + p.age) /
                    patients.length)
                .round()
            : 0;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(children: [
              Expanded(
                child: _PatientStatCard(
                  title: 'الإجمالي',
                  value: '${patients.length}',
                  icon: Icons.people,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PatientStatCard(
                  title: 'متوسط العمر',
                  value: '$avgAge',
                  icon: Icons.cake,
                  color: AppColors.volunteerBlue,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            if (statusCounts.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('توزيع الحالات',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              fontFamily: 'Cairo')),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: statusCounts.entries.map((e) {
                          final color = Color(
                              DetachmentPatientModel.statusColors[e.key] ??
                                  0xFF94A3B8);
                          final label =
                              DetachmentPatientModel.statusLabels[e.key] ??
                                  e.key;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text('$label: ${e.value}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                        fontFamily: 'Cairo')),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Card(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.adminPurple,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.assessment,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('إجمالي المرضى',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w500)),
                      Text('${patients.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const Spacer(),
                  if (statusCounts['critical'] != null)
                    Column(children: [
                      const Text('حرج',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontFamily: 'Cairo')),
                      Text('${statusCounts['critical']}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w800)),
                    ]),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Text('المرضى',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo')),
              const Spacer(),
              if (patients.isNotEmpty) ...[
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: 'نسخ الكل',
                  color: AppColors.primary,
                  onPressed: () => _copyPatients(context, patients),
                ),
                IconButton(
                  icon: const Icon(Icons.file_download_outlined, size: 20),
                  tooltip: 'تحميل كملف CSV',
                  color: AppColors.primary,
                  onPressed: () => _exportPatientsCsv(context, patients),
                ),
                const SizedBox(width: 4),
              ],
              FilledButton.tonalIcon(
                onPressed: () =>
                    _showPatientForm(context, ref, null),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة مريض',
                    style: TextStyle(fontFamily: 'Cairo')),
              ),
            ]),
            const SizedBox(height: 8),
            if (patients.isEmpty)
              const EmptyStateWidget(
                icon: Icons.local_hospital_outlined,
                title: 'لا يوجد مرضى مسجلين',
                subtitle: 'تتبع حالة المرضى والعمر والتشخيص هنا',
              )
            else
              ...patients.map((p) => _PatientCard(
                    detachmentId: detachmentId,
                    patient: p,
                  )),
          ],
        );
      },
    );
  }

  void _showPatientForm(
      BuildContext ctx, WidgetRef ref, DetachmentPatientModel? existing) {
    final nameCtrl =
        TextEditingController(text: existing?.name ?? '');
    final ageCtrl =
        TextEditingController(text: existing?.age.toString() ?? '');
    final illnessCtrl =
        TextEditingController(text: existing?.illness ?? '');
    final notesCtrl =
        TextEditingController(text: existing?.notes ?? '');
    String status = existing?.status ?? 'stable';

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (ctx2) => StatefulBuilder(
        builder: (_, setSt) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  existing == null ? 'إضافة مريض' : 'تعديل مريض',
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
                    labelText: 'اسم المريض *',
                    labelStyle: TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'العمر *',
                        labelStyle: TextStyle(fontFamily: 'Cairo'),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(
                        labelText: 'الحالة',
                        labelStyle: TextStyle(fontFamily: 'Cairo'),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'stable', child: Text('مستقر')),
                        DropdownMenuItem(
                            value: 'moderate', child: Text('متوسط')),
                        DropdownMenuItem(
                            value: 'critical', child: Text('حرج')),
                        DropdownMenuItem(
                            value: 'recovered',
                            child: Text('متعافي')),
                        DropdownMenuItem(
                            value: 'transferred',
                            child: Text('محول')),
                      ],
                      onChanged: (v) {
                        if (v != null) setSt(() => status = v);
                      },
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                TextField(
                  controller: illnessCtrl,
                  decoration: const InputDecoration(
                    labelText: 'التشخيص / الحالة المرضية *',
                    labelStyle: TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات',
                    labelStyle: TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty ||
                        ageCtrl.text.isEmpty ||
                        illnessCtrl.text.trim().isEmpty) {
                      return;
                    }
                    final repo = ref.read(detachmentNewRepoProvider);
                    if (existing == null) {
                      final patient = DetachmentPatientModel(
                        uid: '',
                        detachmentId: detachmentId,
                        name: nameCtrl.text.trim(),
                        age: int.tryParse(ageCtrl.text) ?? 0,
                        illness: illnessCtrl.text.trim(),
                        status: status,
                        notes: notesCtrl.text.trim().isEmpty
                            ? null
                            : notesCtrl.text.trim(),
                        createdAt: DateTime.now(),
                        createdBy: '',
                      );
                      await repo.addPatient(patient);
                    } else {
                      await repo.updatePatient(existing.copyWith(
                        name: nameCtrl.text.trim(),
                        age: int.tryParse(ageCtrl.text) ?? 0,
                        illness: illnessCtrl.text.trim(),
                        status: status,
                        notes: notesCtrl.text.trim().isEmpty
                            ? null
                            : notesCtrl.text.trim(),
                      ));
                    }
                    if (ctx2.mounted) Navigator.pop(ctx2);
                  },
                  child: Text(
                      existing == null ? 'إضافة مريض' : 'حفظ التغييرات',
                      style: const TextStyle(fontFamily: 'Cairo')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _copyPatients(
      BuildContext context, List<DetachmentPatientModel> patients) {
    final lines = <String>[];
    for (var i = 0; i < patients.length; i++) {
      final p = patients[i];
      lines.add('${p.uid} - ${p.name} - ${p.age} سنة - ${p.illness}');
    }
    final text = ClipboardUtils.formatNamesForCopy(lines);
    ClipboardUtils.copy(context, text);
  }

  void _exportPatientsCsv(
      BuildContext context, List<DetachmentPatientModel> patients) {
    final buffer = StringBuffer('\uFEFF');
    buffer.writeln('المعرف,الاسم,العمر,التشخيص');
    for (final p in patients) {
      buffer.writeln('${p.uid},${p.name},${p.age},${p.illness}');
    }
    ClipboardUtils.copy(context, buffer.toString(), label: 'تم نسخ CSV');
  }
}

class _PatientStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _PatientStatCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                    fontFamily: 'Cairo')),
            Text(title,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    fontFamily: 'Cairo')),
          ]),
        ]),
      ),
    );
  }
}

class _PatientCard extends ConsumerWidget {
  final String detachmentId;
  final DetachmentPatientModel patient;
  const _PatientCard(
      {required this.detachmentId, required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(
        DetachmentPatientModel.statusColors[patient.status] ??
            0xFF94A3B8);
    final label =
        DetachmentPatientModel.statusLabels[patient.status] ??
            patient.status;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 10,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(patient.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            fontFamily: 'Cairo')),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(label,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: color,
                              fontFamily: 'Cairo')),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                      '${patient.age} سنة  •  ${patient.illness}',
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                          fontFamily: 'Cairo')),
                  if (patient.notes != null &&
                      patient.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(patient.notes!,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                            fontFamily: 'Cairo')),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') {
                  _showEditForm(context, ref, patient);
                } else if (v == 'delete') {
                  _confirmDelete(context, ref, patient);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_outlined, size: 16),
                    SizedBox(width: 8),
                    Text('تعديل', style: TextStyle(fontFamily: 'Cairo')),
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
  }

  void _showEditForm(
      BuildContext ctx, WidgetRef ref, DetachmentPatientModel patient) {
    final nameCtrl = TextEditingController(text: patient.name);
    final ageCtrl =
        TextEditingController(text: patient.age.toString());
    final illnessCtrl =
        TextEditingController(text: patient.illness);
    final notesCtrl =
        TextEditingController(text: patient.notes ?? '');
    String status = patient.status;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (ctx2) => StatefulBuilder(
        builder: (_, setSt) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('تعديل مريض',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo')),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'اسم المريض *',
                    labelStyle: TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'العمر *',
                        labelStyle: TextStyle(fontFamily: 'Cairo'),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(
                        labelText: 'الحالة',
                        labelStyle: TextStyle(fontFamily: 'Cairo'),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'stable', child: Text('مستقر')),
                        DropdownMenuItem(
                            value: 'moderate', child: Text('متوسط')),
                        DropdownMenuItem(
                            value: 'critical', child: Text('حرج')),
                        DropdownMenuItem(
                            value: 'recovered',
                            child: Text('متعافي')),
                        DropdownMenuItem(
                            value: 'transferred',
                            child: Text('محول')),
                      ],
                      onChanged: (v) {
                        if (v != null) setSt(() => status = v);
                      },
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                TextField(
                  controller: illnessCtrl,
                  decoration: const InputDecoration(
                    labelText: 'التشخيص / الحالة المرضية *',
                    labelStyle: TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات',
                    labelStyle: TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty ||
                        ageCtrl.text.isEmpty ||
                        illnessCtrl.text.trim().isEmpty) {
                      return;
                    }
                    await ref
                        .read(detachmentNewRepoProvider)
                        .updatePatient(patient.copyWith(
                          name: nameCtrl.text.trim(),
                          age: int.tryParse(ageCtrl.text) ?? 0,
                          illness: illnessCtrl.text.trim(),
                          status: status,
                          notes: notesCtrl.text.trim().isEmpty
                              ? null
                              : notesCtrl.text.trim(),
                        ));
                    if (ctx2.mounted) Navigator.pop(ctx2);
                  },
                  child: const Text('حفظ التغييرات',
                      style: TextStyle(fontFamily: 'Cairo')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext ctx, WidgetRef ref, DetachmentPatientModel patient) {
    showDialog(
      context: ctx,
      builder: (ctx2) => AlertDialog(
        title: const Text('حذف مريض',
            style: TextStyle(fontFamily: 'Cairo')),
        content: Text('هل أنت متأكد من حذف "${patient.name}"؟',
            style: const TextStyle(fontFamily: 'Cairo')),
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
                  .deletePatient(patient.uid);
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
