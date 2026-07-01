import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../shared/models/dynamic_field_schema.dart';
import '../../../../app.dart';

class DynamicFieldsPage extends ConsumerStatefulWidget {
  const DynamicFieldsPage({super.key});

  @override
  ConsumerState<DynamicFieldsPage> createState() => _DynamicFieldsPageState();
}

class _DynamicFieldsPageState extends ConsumerState<DynamicFieldsPage> {
  String _selectedCategory = 'أدوار الفريق';

  static const _categories = [
    'أدوار الفريق',
    'أقسام',
    'تخصصات',
  ];

  String _categoryKey(String label) {
    switch (label) {
      case 'أدوار الفريق':
        return 'roles';
      case 'أقسام':
        return 'departments';
      case 'تخصصات':
        return 'specializations';
      default:
        return label;
    }
  }

  Future<void> _toggleActive(DynamicFieldSchema field) async {
    field.isActive = !field.isActive;
    await ref.read(dynamicFieldRepositoryProvider).upsert(field);
  }

  Future<void> _confirmDelete(DynamicFieldSchema field) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'تأكيد الحذف',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          ),
          content: Text(
            'هل أنت متأكد من حذف "${field.labelAr}"؟',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await ref.read(dynamicFieldRepositoryProvider).delete(field.id);
    }
  }

  void _showAddDialog() {
    final formKey = GlobalKey<FormState>();
    final keyController = TextEditingController();
    final labelArController = TextEditingController();
    final labelEnController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'إضافة حقل جديد',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: keyController,
                    decoration: const InputDecoration(
                      labelText: 'المفتاح',
                      prefixIcon: Icon(Icons.vpn_key_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'المفتاح مطلوب';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                  TextFormField(
                    controller: labelArController,
                    decoration: const InputDecoration(
                      labelText: 'التسمية (عربي)',
                      prefixIcon: Icon(Icons.text_fields),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'التسمية العربية مطلوبة';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                  TextFormField(
                    controller: labelEnController,
                    decoration: const InputDecoration(
                      labelText: 'التسمية (إنجليزي)',
                      prefixIcon: Icon(Icons.text_fields),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'التسمية الإنجليزية مطلوبة';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final category = _categoryKey(_selectedCategory);
                final maxSort = 0;
                final field = DynamicFieldSchema()
                  ..key = keyController.text.trim()
                  ..category = category
                  ..labelAr = labelArController.text.trim()
                  ..labelEn = labelEnController.text.trim()
                  ..sortOrder = maxSort
                  ..isActive = true;

                await ref.read(dynamicFieldRepositoryProvider).upsert(field);
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('إضافة', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = ref
        .read(dynamicFieldRepositoryProvider)
        .streamByCategory(_categoryKey(_selectedCategory));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppAppBar(
        context: context,
        title: 'الحقول المفتوحة',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.marginMobile,
                vertical: AppSizes.xs,
              ),
              children: _categories.map((cat) {
                final selected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(left: AppSizes.xs),
                  child: FilterChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: selected
                            ? AppColors.onPrimary
                            : AppColors.onSurface,
                      ),
                    ),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    checkmarkColor: AppColors.onPrimary,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<DynamicFieldSchema>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'حدث خطأ: ${snapshot.error}',
                      style: const TextStyle(fontFamily: 'Cairo', color: AppColors.error),
                    ),
                  );
                }
                final fields = snapshot.data ?? [];
                if (fields.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.list_alt_outlined,
                          size: 64,
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: AppSizes.md),
                        const Text(
                          'لا توجد حقول',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontFamily: 'Cairo',
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.marginMobile),
                  itemCount: fields.length,
                  itemBuilder: (context, index) {
                    final field = fields[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: AppCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    field.labelAr,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    field.labelEn,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontFamily: 'Cairo',
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    field.key,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'Cairo',
                                      color: AppColors.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: field.isActive,
                              activeThumbColor: AppColors.success,
                              onChanged: (_) => _toggleActive(field),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.danger,
                              ),
                              onPressed: () => _confirmDelete(field),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
