import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/models/cms_section_schema.dart';
import '../../../../app.dart';

class CmsFormPage extends ConsumerStatefulWidget {
  final String? sectionKey;
  const CmsFormPage({super.key, this.sectionKey});

  @override
  ConsumerState<CmsFormPage> createState() => _CmsFormPageState();
}

class _CmsFormPageState extends ConsumerState<CmsFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleArController = TextEditingController();
  final _titleEnController = TextEditingController();
  final _bodyArController = TextEditingController();
  final _bodyEnController = TextEditingController();
  final _sortOrderController = TextEditingController(text: '0');
  final _iconNameController = TextEditingController();
  bool _isPublished = true;
  String _type = 'من نحن';
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _existingKey;

  bool get _isEditing => _existingKey != null;

  static const _types = [
    'من نحن',
    'الأهداف',
    'الإنجازات',
    'الطموحات',
  ];

  @override
  void initState() {
    super.initState();
    _loadSection();
  }

  Future<void> _loadSection() async {
    final key = widget.sectionKey;
    if (key == null) {
      setState(() => _isLoading = false);
      return;
    }

    final section = await ref.read(cmsRepositoryProvider).getByKey(key);
    if (!mounted) return;

    if (section != null) {
      setState(() {
        _existingKey = section.key;
        _type = section.type;
        _titleArController.text = section.titleAr;
        _titleEnController.text = section.titleEn;
        _bodyArController.text = section.bodyAr;
        _bodyEnController.text = section.bodyEn;
        _sortOrderController.text = section.sortOrder.toString();
        _isPublished = section.isPublished;
        _iconNameController.text = section.iconName ?? '';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleArController.dispose();
    _titleEnController.dispose();
    _bodyArController.dispose();
    _bodyEnController.dispose();
    _sortOrderController.dispose();
    _iconNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final user = ref.read(currentUserProvider).valueOrNull;

    final key = _existingKey ?? '${_type}_${DateTime.now().millisecondsSinceEpoch}';
    final section = CmsSectionSchema(
      id: key,
      key: key,
      type: _type,
      titleAr: _titleArController.text.trim(),
      titleEn: _titleEnController.text.trim(),
      bodyAr: _bodyArController.text.trim(),
      bodyEn: _bodyEnController.text.trim(),
      sortOrder: int.tryParse(_sortOrderController.text.trim()) ?? 0,
      isPublished: _isPublished,
      iconName: _iconNameController.text.trim().isEmpty
          ? null
          : _iconNameController.text.trim(),
      updatedAt: DateTime.now(),
      updatedBy: user?.uid,
    );

    await ref.read(cmsRepositoryProvider).upsert(section);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'تم تحديث القسم بنجاح' : 'تم إنشاء القسم بنجاح'),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          _isEditing ? 'تعديل القسم' : 'قسم جديد',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.marginMobile),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: const InputDecoration(
                        labelText: 'النوع',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _types.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type, style: const TextStyle(fontFamily: 'Cairo')),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _type = v);
                      },
                    ),
                    const SizedBox(height: AppSizes.md),
                    TextFormField(
                      controller: _titleArController,
                      decoration: const InputDecoration(
                        labelText: 'العنوان (عربي)',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'العنوان العربي مطلوب';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.md),
                    TextFormField(
                      controller: _titleEnController,
                      decoration: const InputDecoration(
                        labelText: 'العنوان (إنجليزي)',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'العنوان الإنجليزي مطلوب';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.md),
                    TextFormField(
                      controller: _bodyArController,
                      decoration: const InputDecoration(
                        labelText: 'المحتوى (عربي)',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'المحتوى العربي مطلوب';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.md),
                    TextFormField(
                      controller: _bodyEnController,
                      decoration: const InputDecoration(
                        labelText: 'المحتوى (إنجليزي)',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'المحتوى الإنجليزي مطلوب';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.md),
                    TextFormField(
                      controller: _sortOrderController,
                      decoration: const InputDecoration(
                        labelText: 'ترتيب العرض',
                        prefixIcon: Icon(Icons.sort),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSizes.md),
                    TextFormField(
                      controller: _iconNameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الأيقونة (اختياري)',
                        prefixIcon: Icon(Icons.emoji_symbols_outlined),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    SwitchListTile(
                      title: const Text(
                        'منشور',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      subtitle: const Text(
                        'ظهور القسم للجمهور',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                      ),
                      value: _isPublished,
                      onChanged: (v) => setState(() => _isPublished = v),
                      activeThumbColor: AppColors.success,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          disabledBackgroundColor: AppColors.primaryContainer,
                          disabledForegroundColor: AppColors.onPrimaryContainer,
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onPrimary,
                                ),
                              )
                            : Text(
                                _isEditing ? 'تحديث' : 'إنشاء',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
