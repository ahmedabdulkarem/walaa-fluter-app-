// lib/features/posts/presentation/pages/post_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/permission_constants.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../app.dart';
import '../../../../shared/models/post_schema.dart';

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

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = GoRouterState.of(context).pathParameters['id'] ?? '';
    final postStream = Stream.fromFuture(
      ref.read(postRepositoryProvider).getPost(uid),
    );
    final user = ref.watch(currentUserProvider).valueOrNull;
    final canEdit = user?.can(PermissionConstants.publishPosts) ?? false;
    final canDelete = user?.can(PermissionConstants.editDeletePosts) ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'تفاصيل البوست',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<PostSchema?>(
        stream: postStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('حدث خطأ: ${snapshot.error}'),
            );
          }
          final post = snapshot.data;
          if (post == null) {
            return const Center(
              child: Text(
                'البوست غير موجود',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontFamily: 'Cairo',
                  fontSize: 16,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.marginMobile),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Text(
                        _categoryArabicName(post.category),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.xs),
                    if (post.isPinned)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.goldLight,
                          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.push_pin, size: 12, color: AppColors.goldDark),
                            SizedBox(width: 2),
                            Text(
                              'مثبت',
                              style: TextStyle(
                                color: AppColors.goldDark,
                                fontSize: 11,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (post.isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.dangerLight,
                          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.danger),
                            SizedBox(width: 2),
                            Text(
                              'عاجل',
                              style: TextStyle(
                                color: AppColors.danger,
                                fontSize: 11,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    if (canEdit || canDelete)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            context.push('/posts/form', extra: post);
                          } else if (value == 'delete') {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text(
                                  'حذف البوست',
                                  style: TextStyle(fontFamily: 'Cairo'),
                                ),
                                content: const Text(
                                  'هل أنت متأكد من حذف هذا البوست؟',
                                  style: TextStyle(fontFamily: 'Cairo'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                    child: const Text(
                                      'إلغاء',
                                      style: TextStyle(fontFamily: 'Cairo'),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: const Text(
                                      'حذف',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true && context.mounted) {
                              final repo = ref.read(postRepositoryProvider);
                              final result = await repo.deletePost(post.id, user!);
                              if (context.mounted) {
                                result.fold(
                                  (failure) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('فشل الحذف: ${failure.message}')),
                                    );
                                  },
                                  (_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تم حذف البوست')),
                                    );
                                    context.pop();
                                  },
                                );
                              }
                            }
                          }
                        },
                        itemBuilder: (ctx) => [
                          if (canEdit)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                  SizedBox(width: 8),
                                  Text('تعديل', style: TextStyle(fontFamily: 'Cairo')),
                                ],
                              ),
                            ),
                          if (canDelete)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                  SizedBox(width: 8),
                                  Text('حذف', style: TextStyle(fontFamily: 'Cairo')),
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  post.title,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 20,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      post.authorName,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    const Icon(Icons.access_time, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      post.createdAt != null
                          ? DateFormatters.formatDateTime(post.createdAt!, isArabic: true)
                          : '',
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
                const Divider(color: AppColors.divider),
                const SizedBox(height: AppSizes.md),
                Text(
                  post.body,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 15,
                    fontFamily: 'Cairo',
                    height: 1.6,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
