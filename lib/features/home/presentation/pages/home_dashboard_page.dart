import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../shared/models/cms_section_schema.dart';
import '../../../../app.dart';

final _teamCountProvider = StreamProvider<int>((ref) {
  return ref
      .watch(teamInfoRepositoryProvider)
      .streamMembers()
      .map((l) => l.length);
});

final _detachmentCountProvider = StreamProvider<int>((ref) {
  return ref
      .watch(detachmentRepositoryProvider)
      .streamDays()
      .map((l) => l.length);
});

final _workshopCountProvider = StreamProvider<int>((ref) {
  return ref
      .watch(workshopRepositoryProvider)
      .streamWorkshops()
      .map((l) => l.length);
});

final _supportCountProvider = StreamProvider<int>((ref) {
  return ref
      .watch(supportRepositoryProvider)
      .streamAllTickets()
      .map((l) => l.length);
});

final _cmsAboutProvider = StreamProvider<List<CmsSectionSchema>>((ref) {
  return ref.watch(cmsRepositoryProvider).streamPublishedByType('about');
});

class HomeDashboardPage extends ConsumerWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    final teamCount = ref.watch(_teamCountProvider);
    final detCount = ref.watch(_detachmentCountProvider);
    final workshopCount = ref.watch(_workshopCountProvider);
    final supportCount = ref.watch(_supportCountProvider);

    final aboutSections = ref.watch(_cmsAboutProvider).valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '\u0627\u0644\u0631\u0626\u064A\u0633\u064A\u0629',
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

          SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.marginMobile),
            sliver: SliverToBoxAdapter(
              child: _WelcomeCard(user: user),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.lg)),

          SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.marginMobile),
            sliver: const SliverToBoxAdapter(
              child: _SectionTitle(
                  title:
                      '\u0627\u0644\u0641\u0631\u064A\u0642 \u0628\u0627\u0644\u0623\u0631\u0642\u0627\u0645'),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.sm)),

          SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.marginMobile),
            sliver: SliverGrid(
              delegate: SliverChildListDelegate([
                _StatCard(
                  icon: Icons.groups,
                  label: '\u0627\u0644\u0623\u0639\u0636\u0627\u0621',
                  accentColor: AppColors.primary,
                  value: teamCount,
                ),
                _StatCard(
                  icon: Icons.emergency,
                  label: '\u0627\u0644\u0645\u0641\u0631\u0632\u0627\u062A',
                  accentColor: AppColors.adminPurple,
                  value: detCount,
                ),
                _StatCard(
                  icon: Icons.school,
                  label: '\u0627\u0644\u0648\u0631\u0634',
                  accentColor: AppColors.success,
                  value: workshopCount,
                ),
                _StatCard(
                  icon: Icons.headset_mic,
                  label: '\u0627\u0644\u062F\u0639\u0645',
                  accentColor: AppColors.goldBright,
                  value: supportCount,
                ),
              ]),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.4,
                crossAxisSpacing: AppSizes.sm,
                mainAxisSpacing: AppSizes.sm,
              ),
            ),
          ),

          if (aboutSections.isNotEmpty) ...[
            const SliverToBoxAdapter(
                child: SizedBox(height: AppSizes.lg)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.marginMobile),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final sec = aboutSections[index];
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSizes.sm),
                      child: _CmsSectionCard(section: sec),
                    );
                  },
                  childCount: aboutSections.length,
                ),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.lg)),

          SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.marginMobile),
            sliver: const SliverToBoxAdapter(
              child: _SectionTitle(
                  title:
                      '\u0625\u062C\u0631\u0627\u0621\u0627\u062A \u0633\u0631\u064A\u0639\u0629'),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.sm)),

          SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.marginMobile),
            sliver: SliverGrid(
              delegate: SliverChildListDelegate([
                _QuickActionCard(
                  icon: Icons.feed_outlined,
                  label: '\u0627\u0644\u0628\u0648\u0633\u062A\u0627\u062A',
                  onTap: () => context.go(RouteNames.posts),
                ),
                _QuickActionCard(
                  icon: Icons.groups_outlined,
                  label: '\u0627\u0644\u0641\u0631\u064A\u0642',
                  onTap: () => context.go(RouteNames.team),
                ),
                _QuickActionCard(
                  icon: Icons.emergency_outlined,
                  label: '\u0627\u0644\u0645\u0641\u0631\u0632\u0629',
                  onTap: () => context.go(RouteNames.detachment),
                ),
                _QuickActionCard(
                  icon: Icons.school_outlined,
                  label: '\u0627\u0644\u0648\u0631\u0634',
                  onTap: () => context.go(RouteNames.workshops),
                ),
                _QuickActionCard(
                  icon: Icons.admin_panel_settings_outlined,
                  label:
                      '\u0627\u0644\u0645\u062F\u064A\u0631\u064A\u0646',
                  onTap: () =>
                      context.push(RouteNames.adminManagement),
                ),
                _QuickActionCard(
                  icon: Icons.headset_mic_outlined,
                  label: '\u0627\u0644\u062F\u0639\u0645',
                  onTap: () => context.push(RouteNames.support),
                ),
                if (user.valueOrNull?.isSuperAdmin == true) ...[
                  _QuickActionCard(
                    icon: Icons.article_outlined,
                    label:
                        '\u0627\u0644\u0645\u062D\u062A\u0648\u0649',
                    onTap: () => context.push(RouteNames.cms),
                  ),
                  _QuickActionCard(
                    icon: Icons.person_add_alt_1_outlined,
                    label:
                        '\u0627\u0644\u0637\u0644\u0628\u0627\u062A',
                    onTap: () =>
                        context.push(RouteNames.applications),
                  ),
                  _QuickActionCard(
                    icon: Icons.dynamic_feed_outlined,
                    label:
                        '\u062D\u0642\u0648\u0644 \u062F\u064A\u0646\u0627\u0645\u064A\u0643\u064A\u0629',
                    onTap: () =>
                        context.push(RouteNames.dynamicFields),
                  ),
                ],
              ]),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.95,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final AsyncValue<dynamic> user;
  const _WelcomeCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(
            Radius.circular(AppSizes.radiusMd)),
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
                    '\u0623\u0647\u0644\u0627\u064B \u0628\u0639\u0648\u062F\u062A\u0643',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: AppColors.onSurface),
                  ),
                  Text(
                    '\u0641\u0631\u064A\u0642 \u0627\u0644\u0648\u0644\u0627\u0621 \u0627\u0644\u0637\u0628\u064A',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                            color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          if (user.valueOrNull?.isSuperAdmin == true) ...[
            const SizedBox(height: AppSizes.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.goldLight,
                borderRadius: BorderRadius.circular(
                    AppSizes.radiusFull),
                border: Border.all(color: AppColors.goldBright),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.admin_panel_settings_outlined,
                      size: 14, color: AppColors.goldDark),
                  SizedBox(width: 4),
                  Text(
                    '\u0627\u0644\u0645\u0634\u0631\u0641 \u0627\u0644\u0639\u0627\u0645',
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
        borderRadius: const BorderRadius.all(
            Radius.circular(AppSizes.radiusMd)),
        border: Border(
          top: BorderSide(color: accentColor, width: 3),
          left: const BorderSide(color: AppColors.border),
          bottom: const BorderSide(color: AppColors.border),
          right: const BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer
                .withValues(alpha: 0.06),
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
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
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

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.all(
              Radius.circular(AppSizes.radiusMd)),
          border: Border(
            top: BorderSide(color: AppColors.border),
            left: BorderSide(color: AppColors.border),
            bottom: BorderSide(color: AppColors.border),
            right: BorderSide(color: AppColors.border),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0F6D28D9),
              blurRadius: AppSizes.shadowBlur,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.sm, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(height: AppSizes.xs),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Cairo',
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CmsSectionCard extends StatelessWidget {
  final CmsSectionSchema section;
  const _CmsSectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(
            Radius.circular(AppSizes.radiusMd)),
        border: Border(
          top: BorderSide(color: AppColors.border),
          left: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F6D28D9),
            blurRadius: AppSizes.shadowBlur,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (section.iconName != null &&
                  section.iconName!.isNotEmpty)
                const Icon(Icons.info_outline,
                    size: 20, color: AppColors.primary),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  section.titleAr,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (section.bodyAr.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              section.bodyAr,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.6,
                  ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
