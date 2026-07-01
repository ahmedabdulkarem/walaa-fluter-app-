import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../shared/models/support_ticket_schema.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../app.dart';

class SupportListPage extends ConsumerWidget {
  const SupportListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;
    final isSuperAdmin = user?.isSuperAdmin ?? false;
    final uid = AuthService.currentUid ?? '';
    final repository = ref.watch(supportRepositoryProvider);

    final Stream<List<SupportTicketSchema>> stream =
        isSuperAdmin ? repository.streamAllTickets() : repository.streamUserTickets(uid);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppAppBar(
        context: context,
        title: '\u0627\u0644\u062F\u0639\u0645 \u0627\u0644\u0641\u0646\u064A',
      ),
      body: StreamBuilder<List<SupportTicketSchema>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tickets = snapshot.data ?? [];
          if (tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.headset_mic_outlined,
                      size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    '\u0644\u0627 \u062A\u0648\u062C\u062F \u062A\u0630\u0627\u0643\u0631',
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
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final status = TicketStatus.fromString(ticket.status);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: AppCard(
                  onTap: () => context.push(RouteNames.supportDetailsPath(ticket.uid)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ticket.subject,
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
                          _statusBadge(status),
                        ],
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Row(
                        children: [
                          Icon(Icons.category_outlined,
                              size: 14, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Text(
                            ticket.category,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Cairo',
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.schedule,
                              size: 14, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Text(
                            DateFormatters.timeAgo(ticket.createdAt ?? DateTime.now()),
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'Cairo',
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        onPressed: () => context.push(RouteNames.supportNew),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _statusBadge(TicketStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case TicketStatus.open:
        bgColor = AppColors.primarySurface;
        textColor = AppColors.primary;
        label = '\u0645\u0641\u062A\u0648\u062D';
      case TicketStatus.inProgress:
        bgColor = AppColors.goldLight;
        textColor = AppColors.goldDark;
        label = '\u0642\u064A\u062F \u0627\u0644\u0645\u0639\u0627\u0644\u062C\u0629';
      case TicketStatus.resolved:
        bgColor = AppColors.successLight;
        textColor = AppColors.success;
        label = '\u062A\u0645 \u0627\u0644\u062D\u0644';
      case TicketStatus.closed:
        bgColor = AppColors.surfaceContainerHighest;
        textColor = AppColors.onSurfaceVariant;
        label = '\u0645\u063A\u0644\u0642';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'Cairo',
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
