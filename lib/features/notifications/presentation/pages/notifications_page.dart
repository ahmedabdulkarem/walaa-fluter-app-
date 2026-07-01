import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../shared/models/notification_schema.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../app.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = AuthService.currentUid;
    final notifRepo = ref.watch(notificationRepositoryProvider);
    final stream = notifRepo.streamNotifications();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppAppBar(
        context: context,
        title: '\u0627\u0644\u0625\u0634\u0639\u0627\u0631\u0627\u062A',
        showNotificationBadge: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_outlined, color: AppColors.primary),
            tooltip: '\u062A\u0639\u064A\u064A\u0646 \u0627\u0644\u0643\u0644 \u0645\u0642\u0631\u0648\u0621',
            onPressed: uid == null
                ? null
                : () {
                    final notifRepoLocal = ref.read(notificationRepositoryProvider);
                    notifRepoLocal.streamNotifications().first.then((notifs) {
                      final ids = notifs.map((n) => n.id).toList();
                      notifRepoLocal.markAllAsRead(uid, ids);
                    });
                  },
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationSchema>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifs = snapshot.data ?? [];
          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    '\u0644\u0627 \u062A\u0648\u062C\u062F \u0625\u0634\u0639\u0627\u0631\u0627\u062A',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.marginMobile),
            itemCount: notifs.length,
            itemBuilder: (context, index) {
              final notif = notifs[index];
              final isRead = uid != null && notif.readByUids.contains(uid);
              final type = NotificationType.fromString(notif.type);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: AppCard(
                  onTap: uid == null
                      ? null
                      : () {
                          if (!isRead) {
                            ref.read(notificationRepositoryProvider).markAsRead(notif.id, uid);
                          }
                        },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isRead
                                  ? AppColors.surfaceContainerHighest
                                  : AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(AppSizes.radiusDefault),
                            ),
                            child: Icon(
                              _iconForType(type),
                              size: 18,
                              color: isRead
                                  ? AppColors.onSurfaceVariant
                                  : AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notif.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Cairo',
                                    fontWeight: isRead ? FontWeight.w400 : FontWeight.w700,
                                    color: isRead
                                        ? AppColors.onSurfaceVariant
                                        : AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  notif.body,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Cairo',
                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        DateFormatters.timeAgo(notif.createdAt ?? DateTime.now()),
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Cairo',
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
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

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.post:
        return Icons.feed_outlined;
      case NotificationType.workshop:
        return Icons.school_outlined;
      case NotificationType.detachment:
        return Icons.emergency_outlined;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }
}
