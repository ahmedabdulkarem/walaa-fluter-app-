import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/models/team_member_schema.dart';

class TeamLeadershipPage extends ConsumerWidget {
  const TeamLeadershipPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(teamInfoRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppAppBar(context: context, title: 'القادة'),
      body: StreamBuilder<List<TeamMemberSchema>>(
        stream: repo.streamMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final members = snapshot.data ?? [];
          final leaders = members.where((m) => m.isLeadership).toList();
          if (leaders.isEmpty) {
            return const Center(
              child: Text(
                'لا يوجد قادة بعد',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {},
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSizes.marginMobile),
              itemCount: leaders.length,
              itemBuilder: (context, index) {
                final member = leaders[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.md),
                  child: AppCard(
                    isPinned: true,
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.goldLight,
                          child: Text(
                            _initials(member.fullName),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Cairo',
                              color: AppColors.goldDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          member.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Cairo',
                            color: AppColors.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusFull,
                            ),
                          ),
                          child: Text(
                            member.role,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Cairo',
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (member.department != null &&
                            member.department!.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.sm),
                          _infoRow(Icons.business_outlined, member.department!),
                        ],
                        if (member.phone != null &&
                            member.phone!.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.xs),
                          _infoRow(Icons.phone_outlined, member.phone!),
                        ],
                        if (member.email != null &&
                            member.email!.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.xs),
                          _infoRow(Icons.email_outlined, member.email!),
                        ],
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

  Widget _infoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: AppColors.outline),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'Cairo',
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return '?';
  }
}
