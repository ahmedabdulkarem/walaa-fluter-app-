import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../shared/models/workshop_schema.dart';
import '../../../../app.dart';

class WorkshopFormPage extends ConsumerStatefulWidget {
  final WorkshopSchema? workshop;

  const WorkshopFormPage({super.key, this.workshop});

  @override
  ConsumerState<WorkshopFormPage> createState() => _WorkshopFormPageState();
}

class _WorkshopFormPageState extends ConsumerState<WorkshopFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _instructorNameController;
  late final TextEditingController _locationController;
  late final TextEditingController _meetingLinkController;
  late final TextEditingController _capacityController;
  late final TextEditingController _subscriptionFeeController;
  DateTime? _dateTime;
  DateTime? _endDateTime;
  bool _isOnline = false;
  WorkshopStatus _status = WorkshopStatus.upcoming;
  bool _isLoading = false;

  bool get _isEditing => widget.workshop != null;

  @override
  void initState() {
    super.initState();
    final w = widget.workshop;
    _titleController = TextEditingController(text: w?.title ?? '');
    _descriptionController = TextEditingController(text: w?.description ?? '');
    _instructorNameController =
        TextEditingController(text: w?.instructorName ?? '');
    _locationController = TextEditingController(text: w?.location ?? '');
    _meetingLinkController = TextEditingController(text: w?.meetingLink ?? '');
    _capacityController =
        TextEditingController(text: w != null ? w.capacity.toString() : '');
    _subscriptionFeeController = TextEditingController(
        text: w != null ? w.subscriptionFee.toString() : '');
    _dateTime = w?.dateTime;
    _endDateTime = w?.endDateTime;
    _isOnline = w?.isOnline ?? false;
    _status = w != null ? WorkshopStatus.fromString(w.status) : WorkshopStatus.upcoming;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructorNameController.dispose();
    _locationController.dispose();
    _meetingLinkController.dispose();
    _capacityController.dispose();
    _subscriptionFeeController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isEnd}) async {
    final initial = isEnd ? _endDateTime : _dateTime;
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: ref.watch(localeProvider),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(initial ?? DateTime.now()),
    );
    if (time == null || !mounted) return;
    final combined =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isEnd) {
        _endDateTime = combined;
      } else {
        _dateTime = combined;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isLoading = true);

    final w = WorkshopSchema()
      ..uid = _isEditing
          ? widget.workshop!.uid
          : DateTime.now().millisecondsSinceEpoch.toString()
      ..title = _titleController.text.trim()
      ..description = _descriptionController.text.trim()
      ..instructorName = _instructorNameController.text.trim()
      ..dateTime = _dateTime
      ..endDateTime = _endDateTime
      ..location = _locationController.text.trim()
      ..isOnline = _isOnline
      ..meetingLink =
          _isOnline ? _meetingLinkController.text.trim() : null
      ..capacity = int.tryParse(_capacityController.text.trim()) ?? 0
      ..subscriptionFee =
          double.tryParse(_subscriptionFeeController.text.trim()) ?? 0
      ..status = _status.toFirestore
      ..createdBy = user.uid
      ..createdAt = _isEditing ? widget.workshop!.createdAt : DateTime.now()
      ..updatedAt = DateTime.now();

    final repo = ref.read(workshopRepositoryProvider);
    final result = _isEditing
        ? await repo.updateWorkshop(w, user)
        : await repo.createWorkshop(w, user);

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: AppColors.error),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'تم تحديث الورشة' : 'تم إنشاء الورشة'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppAppBar(
        context: context,
        title: _isEditing ? 'تعديل الورشة' : 'ورشة جديدة',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.marginMobile),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'العنوان'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'الرجاء إدخال العنوان' : null,
              ),
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'الوصف'),
                maxLines: 4,
              ),
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: _instructorNameController,
                decoration: const InputDecoration(labelText: 'اسم المدرب'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'الرجاء إدخال اسم المدرب' : null,
              ),
              const SizedBox(height: AppSizes.sm),
              InkWell(
                onTap: () => _pickDateTime(isEnd: false),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'تاريخ ووقت البداية'),
                  child: Text(
                    _dateTime != null
                        ? '${_dateTime!.year}/${_dateTime!.month}/${_dateTime!.day} - ${_dateTime!.hour.toString().padLeft(2, '0')}:${_dateTime!.minute.toString().padLeft(2, '0')}'
                        : 'اختر التاريخ والوقت',
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              InkWell(
                onTap: () => _pickDateTime(isEnd: true),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'تاريخ ووقت النهاية'),
                  child: Text(
                    _endDateTime != null
                        ? '${_endDateTime!.year}/${_endDateTime!.month}/${_endDateTime!.day} - ${_endDateTime!.hour.toString().padLeft(2, '0')}:${_endDateTime!.minute.toString().padLeft(2, '0')}'
                        : 'اختياري',
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'الموقع'),
              ),
              const SizedBox(height: AppSizes.sm),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('أونلاين'),
                value: _isOnline,
                onChanged: (v) => setState(() => _isOnline = v),
              ),
              if (_isOnline) ...[
                const SizedBox(height: AppSizes.sm),
                TextFormField(
                  controller: _meetingLinkController,
                  decoration: const InputDecoration(labelText: 'رابط الاجتماع'),
                ),
              ],
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: 'السعة'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'الرجاء إدخال السعة';
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return 'الرجاء إدخال رقم صحيح';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: _subscriptionFeeController,
                decoration: const InputDecoration(labelText: 'رسوم الاشتراك (د.ل)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'الرجاء إدخال الرسوم';
                  final n = double.tryParse(v.trim());
                  if (n == null || n < 0) return 'الرجاء إدخال رقم صحيح';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.sm),
              DropdownButtonFormField<WorkshopStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'الحالة'),
                items: WorkshopStatus.values.map((s) {
                  final label = switch (s) {
                    WorkshopStatus.upcoming => 'قادمة',
                    WorkshopStatus.active => 'نشطة',
                    WorkshopStatus.completed => 'منتهية',
                    WorkshopStatus.cancelled => 'ملغاة',
                  };
                  return DropdownMenuItem(value: s, child: Text(label));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _status = v);
                },
              ),
              const SizedBox(height: AppSizes.lg),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Text(_isEditing ? 'تحديث' : 'إنشاء'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
