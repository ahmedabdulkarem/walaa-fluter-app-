import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../shared/models/user_schema.dart';
import '../../../../shared/models/workshop_schema.dart';
import '../../../../features/detachment/models/detachment_day_model.dart';
import '../../../../app.dart';

final _activeDeploymentsProvider = StreamProvider<List<DetachmentDayModel>>((ref) {
  return ref.watch(detachmentNewRepoProvider).watchDays();
});

final _upcomingWorkshopsProvider = StreamProvider<List<WorkshopSchema>>((ref) {
  return ref.watch(workshopRepositoryProvider).streamWorkshops();
});

final _totalMembersProvider = StreamProvider<int>((ref) {
  return ref.watch(teamInfoRepositoryProvider).streamMembers().map((l) => l.length);
});

final _subAdminsProvider = StreamProvider<List<UserSchema>>((ref) {
  return AuthService.streamSubAdmins();
});

class HomeDashboardPage extends ConsumerWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;
    final isAdmin = user?.isSuperAdmin == true || (user?.can('manage') ?? false);

    final allDeployments = ref.watch(_activeDeploymentsProvider);
    final allWorkshops = ref.watch(_upcomingWorkshopsProvider);
    final totalMembers = ref.watch(_totalMembersProvider);
    final subAdmins = ref.watch(_subAdminsProvider);

    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'الرئيسية',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.md)),

          // Welcome card
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginMobile),
            sliver: SliverToBoxAdapter(child: _WelcomeCard(user: userAsync)),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.lg)),

          // Summary stats
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginMobile),
            sliver: const SliverToBoxAdapter(
              child: _SectionTitle(title: 'نظرة عامة'),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.sm)),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginMobile),
            sliver: SliverGrid(
              delegate: SliverChildListDelegate([
                _StatCard(
                  icon: Icons.emergency,
                  label: 'المفارز النشطة',
                  accentColor: AppColors.adminPurple,
                  value: allDeployments.when(
                    data: (days) => AsyncData(days.where((d) => d.isActive).length),
                    loading: () => const AsyncLoading(),
                    error: (e, st) => AsyncError(e, st),
                  ),
                ),
                _StatCard(
                  icon: Icons.school,
                  label: 'الورش القادمة',
                  accentColor: AppColors.success,
                  value: allWorkshops.when(
                    data: (ws) => AsyncData(ws.where((w) => w.status == 'upcoming').length),
                    loading: () => const AsyncLoading(),
                    error: (e, st) => AsyncError(e, st),
                  ),
                ),
                _StatCard(
                  icon: Icons.groups,
                  label: 'الأعضاء',
                  accentColor: AppColors.primary,
                  value: totalMembers,
                ),
                _StatCard(
                  icon: Icons.admin_panel_settings,
                  label: 'المديرين',
                  accentColor: AppColors.goldBright,
                  value: subAdmins.when(
                    data: (list) => AsyncData(list.length),
                    loading: () => const AsyncLoading(),
                    error: (e, st) => AsyncError(e, st),
                  ),
                ),
              ]),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.4,
                crossAxisSpacing: AppSizes.sm,
                mainAxisSpacing: AppSizes.sm,
              ),
            ),
          ),

          // Active deployments detail
          if (isAdmin) ...[
            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.lg)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginMobile),
              sliver: const SliverToBoxAdapter(
                child: _SectionTitle(title: 'المفارز النشطة'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.sm)),
            allDeployments.when(
              data: (days) {
                final active = days.where((d) => d.isActive).toList();
                if (active.isEmpty) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginMobile),
                    sliver: SliverToBoxAdapter(
                      child: _EmptyState(message: 'لا توجد مفارز نشطة حالياً'),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginMobile),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _DeploymentCard(day: active[index]),
                      childCount: active.length > 3 ? 3 : active.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const SliverToBoxAdapter(child: SizedBox()),
            ),
          ],

          // Upcoming workshops detail
          if (isAdmin) ...[
            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.lg)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginMobile),
              sliver: const SliverToBoxAdapter(
                child: _SectionTitle(title: 'الورش القادمة'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.sm)),
            allWorkshops.when(
              data: (ws) {
                final upcoming = ws.where((w) =>
                    w.dateTime != null && w.dateTime!.isAfter(now)).toList();
                if (upcoming.isEmpty) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginMobile),
                    sliver: SliverToBoxAdapter(
                      child: _EmptyState(message: 'لا توجد ورش قادمة'),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.marginMobile),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _WorkshopCard(workshop: upcoming[index]),
                      childCount: upcoming.length > 3 ? 3 : upcoming.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const SliverToBoxAdapter(child: SizedBox()),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final AsyncValue<UserSchema?> user;
  const _WelcomeCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F6D28D9),
            blurRadius: AppSizes.shadowBlur,
            offset: Offset(0, 2),
          ),
        ],
        border: Border(
          top: BorderSide(color: AppColors.border),
          left: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أهلاً بعودتك',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: AppColors.onSurface),
                  ),
                  Text(
                    'فريق الولاء الطبي',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          if (user.valueOrNull?.isSuperAdmin == true) ...[
            const SizedBox(height: AppSizes.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.goldLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                border: Border.all(color: AppColors.goldBright),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.admin_panel_settings_outlined, size: 14, color: AppColors.goldDark),
                  SizedBox(width: 4),
                  Text(
                    'المشرف العام',
                    style: TextStyle(
                      color: AppColors.goldDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(color: AppColors.onBackground),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final AsyncValue<int> value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
        border: Border(
          top: BorderSide(color: accentColor, width: 3),
          left: const BorderSide(color: AppColors.border),
          bottom: const BorderSide(color: AppColors.border),
          right: const BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.06),
            blurRadius: AppSizes.shadowBlur,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: accentColor, size: 28),
          const SizedBox(height: 8),
          value.when(
            data: (v) => TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: v),
              duration: const Duration(milliseconds: 800),
              builder: (_, val, _) => Text(
                '$val',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Cairo',
                  color: AppColors.onSurface,
                ),
              ),
            ),
            loading: () => const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
            error: (_, _) => const Text(
              '-',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontFamily: 'Cairo',
                color: AppColors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Cairo',
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _DeploymentCard extends StatelessWidget {
  final DetachmentDayModel day;
  const _DeploymentCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.adminPurple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.emergency, color: AppColors.adminPurple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.dayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    '${day.memberIds.length} أعضاء',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Cairo',
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: const Text(
                'نشط',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Cairo',
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkshopCard extends StatelessWidget {
  final WorkshopSchema workshop;
  const _WorkshopCard({required this.workshop});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school, color: AppColors.success, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workshop.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (workshop.instructorName.isNotEmpty)
                    Text(
                      workshop.instructorName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Cairo',
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              '\$${workshop.subscriptionFee.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.onSurfaceVariant,
          fontSize: 13,
        ),
      ),
    );
  }
}
