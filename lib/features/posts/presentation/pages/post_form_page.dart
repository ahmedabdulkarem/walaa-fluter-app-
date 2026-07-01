// lib/features/posts/presentation/pages/post_form_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/constants/permission_constants.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app.dart';
import '../../../../shared/models/post_schema.dart';

final _allRoles = [
  'super_admin',
  'sub_admin',
  'volunteer',
  'guest',
];

String _categoryArabicName(String category) {
  switch (category) {
    case 'medical':
      return 'طبي';
    case 'urgent':
      return 'عاجل';
    case 'event':
      return 'فعالية';
    case 'workshop_notice':
      return 'إشعار ورشة';
    default:
      return 'عام';
  }
}

String _roleArabicName(String role) {
  switch (role) {
    case 'super_admin':
      return 'المشرف العام';
    case 'sub_admin':
      return 'مدير';
    case 'volunteer':
      return 'متطوع';
    case 'guest':
      return 'ضيف';
    default:
      return role;
  }
}

class PostFormPage extends ConsumerStatefulWidget {
  final PostSchema? post;
  const PostFormPage({super.key, this.post});

  @override
  ConsumerState<PostFormPage> createState() => _PostFormPageState();
}

class _PostFormPageState extends ConsumerState<PostFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isPinned = false;
  bool _isUrgent = false;
  String _category = 'general';
  late List<String> _visibilityRoles;
  bool _isSubmitting = false;

  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    final post = widget.post;
    if (post != null) {
      _titleController.text = post.title;
      _bodyController.text = post.body;
      _isPinned = post.isPinned;
      _isUrgent = post.isUrgent;
      _category = post.category;
      _visibilityRoles = List.from(post.visibilityRoles);
    } else {
      _visibilityRoles = [];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول أولاً')),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final repo = ref.read(postRepositoryProvider);

    if (_isEditing) {
      final existing = widget.post!;
      existing.title = _titleController.text.trim();
      existing.body = _bodyController.text.trim();
      existing.category = _category;
      existing.isPinned = _isPinned;
      existing.isUrgent = _isUrgent;
      existing.visibilityRoles = _visibilityRoles;
      existing.updatedAt = DateTime.now();

      final result = await repo.updatePost(existing, user);
      if (!mounted) return;
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل التحديث: ${failure.message}')),
          );
          setState(() => _isSubmitting = false);
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث البوست بنجاح')),
          );
          context.pop();
        },
      );
    } else {
      final post = PostSchema()
        ..uid = DateTime.now().millisecondsSinceEpoch.toString()
        ..title = _titleController.text.trim()
        ..body = _bodyController.text.trim()
        ..category = _category
        ..authorUid = user.uid
        ..authorName = user.displayName
        ..isPinned = _isPinned
        ..isUrgent = _isUrgent
        ..visibilityRoles = _visibilityRoles
        ..createdAt = DateTime.now();

      final result = await repo.createPost(post, user);
      if (!mounted) return;
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل النشر: ${failure.message}')),
          );
          setState(() => _isSubmitting = false);
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم نشر البوست بنجاح')),
          );
          context.pop();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final canPublish = user?.can(PermissionConstants.publishPosts) ?? false;

    if (!canPublish) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.primary,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            _isEditing ? 'تعديل البوست' : 'بوست جديد',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'ليس لديك صلاحية نشر البوستات',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontFamily: 'Cairo',
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          _isEditing ? 'تعديل البوست' : 'بوست جديد',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
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
                decoration: const InputDecoration(
                  labelText: 'العنوان',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'العنوان مطلوب';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'المحتوى',
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                minLines: 3,
              ),
              const SizedBox(height: AppSizes.md),
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: PostCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat.toFirestore,
                    child: Text(_categoryArabicName(cat.toFirestore)),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _category = v);
                },
                decoration: const InputDecoration(
                  labelText: 'التصنيف',
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              AppCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'مثبت',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      subtitle: const Text(
                        'سيظهر البوست في أعلى القائمة',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                      ),
                      value: _isPinned,
                      onChanged: (v) => setState(() => _isPinned = v),
                      activeThumbColor: AppColors.goldBright,
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    SwitchListTile(
                      title: const Text(
                        'عاجل',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      subtitle: const Text(
                        'سيتم تمييز البوست باللون الأحمر',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                      ),
                      value: _isUrgent,
                      onChanged: (v) => setState(() => _isUrgent = v),
                      activeThumbColor: AppColors.danger,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'الرؤية المسموحة',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: AppSizes.xs),
              Wrap(
                spacing: AppSizes.xs,
                runSpacing: AppSizes.xs,
                children: _allRoles.map((role) {
                  final selected = _visibilityRoles.contains(role);
                  return FilterChip(
                    label: Text(
                      _roleArabicName(role),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: selected ? AppColors.onPrimary : AppColors.onSurface,
                      ),
                    ),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    checkmarkColor: AppColors.onPrimary,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _visibilityRoles.add(role);
                        } else {
                          _visibilityRoles.remove(role);
                        }
                      });
                    },
                  );
                }).toList(),
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
                          _isEditing ? 'تحديث' : 'نشر',
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
