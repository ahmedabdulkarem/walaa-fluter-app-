// lib/features/posts/presentation/pages/posts_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_card.dart';
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

class PostsListPage extends ConsumerWidget {
  const PostsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postStream = ref.read(postRepositoryProvider).streamPosts();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'البوستات',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/posts/form'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
      body: StreamBuilder<List<PostSchema>>(
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
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
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
                    'لا توجد بوستات بعد',
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
          return RefreshIndicator(
            onRefresh: () => Future.delayed(const Duration(milliseconds: 300)),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSizes.marginMobile),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: AppCard(
                    onTap: () => context.push('/posts/${post.uid}'),
                    isPinned: post.isPinned,
                    isUrgent: post.isUrgent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                              ),
                              child: Text(
                                _categoryArabicName(post.category),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (post.createdAt != null)
                              Text(
                                DateFormatters.timeAgo(post.createdAt!, isArabic: true),
                                style: const TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 11,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          post.title,
                          style: const TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 15,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          post.body,
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 13,
                            fontFamily: 'Cairo',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          post.authorName,
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
