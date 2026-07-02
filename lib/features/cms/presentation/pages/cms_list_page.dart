import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../shared/models/cms_section_schema.dart';
import '../../../../app.dart';

class CmsListPage extends ConsumerStatefulWidget {
  const CmsListPage({super.key});

  @override
  ConsumerState<CmsListPage> createState() => _CmsListPageState();
}

class _CmsListPageState extends ConsumerState<CmsListPage> {
  String? _selectedType;

  static const _typeFilters = [
    'من نحن',
    'الأهداف',
    'الإنجازات',
    'الطموحات',
  ];

  Color _typeColor(String type) {
    switch (type) {
      case 'من نحن':
        return AppColors.primary;
      case 'الأهداف':
        return AppColors.success;
      case 'الإنجازات':
        return AppColors.goldBright;
      case 'الطموحات':
        return AppColors.volunteerBlue;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  Color _typeBgColor(String type) {
    switch (type) {
      case 'من نحن':
        return AppColors.primarySurface;
      case 'الأهداف':
        return AppColors.successLight;
      case 'الإنجازات':
        return AppColors.goldLight;
      case 'الطموحات':
        return AppColors.surfaceContainerHighest;
      default:
        return AppColors.surfaceContainerHighest;
    }
  }

  Future<void> _confirmDelete(CmsSectionSchema section) async {
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
            'هل أنت متأكد من حذف "${section.titleAr}"؟',
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
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) return;
      await ref.read(cmsRepositoryProvider).delete(section.id, user);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الحذف بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sectionsAsync = ref.watch(cmsRepositoryProvider).streamSections();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppAppBar(
        context: context,
        title: 'إدارة المحتوى',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/cms/form'),
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
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: AppSizes.xs),
                  child: FilterChip(
                    label: Text(
                      'الكل',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: _selectedType == null
                            ? AppColors.onPrimary
                            : AppColors.onSurface,
                      ),
                    ),
                    selected: _selectedType == null,
                    selectedColor: AppColors.primary,
                    checkmarkColor: AppColors.onPrimary,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    onSelected: (_) => setState(() => _selectedType = null),
                  ),
                ),
                ..._typeFilters.map((type) => Padding(
                  padding: const EdgeInsets.only(left: AppSizes.xs),
                  child: FilterChip(
                    label: Text(
                      type,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: _selectedType == type
                            ? AppColors.onPrimary
                            : AppColors.onSurface,
                      ),
                    ),
                    selected: _selectedType == type,
                    selectedColor: _typeColor(type),
                    checkmarkColor: AppColors.onPrimary,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    onSelected: (_) => setState(() => _selectedType = type),
                  ),
                )),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<CmsSectionSchema>>(
              stream: sectionsAsync,
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
                final sections = snapshot.data ?? [];
                final filtered = _selectedType == null
                    ? sections
                    : sections.where((s) => s.type == _selectedType).toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: AppSizes.md),
                        const Text(
                          'لا توجد أقسام',
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
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final section = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: Dismissible(
                        key: ValueKey(section.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: AppSizes.md),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: AppColors.onPrimary,
                            size: 28,
                          ),
                        ),
                        confirmDismiss: (_) async {
                          _confirmDelete(section);
                          return false;
                        },
                        child: AppCard(
                          onTap: () => context.push('/cms/form', extra: section.key.toString()),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _typeBgColor(section.type),
                                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                                ),
                                child: Text(
                                  section.type,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Cairo',
                                    color: _typeColor(section.type),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSizes.sm),
                              Expanded(
                                child: Text(
                                  section.titleAr,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSizes.xs),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                                ),
                                child: Text(
                                  '${section.sortOrder}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Cairo',
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSizes.xs),
                              Icon(
                                section.isPublished
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 20,
                                color: section.isPublished
                                    ? AppColors.success
                                    : AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_left,
                                color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                              ),
                            ],
                          ),
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
