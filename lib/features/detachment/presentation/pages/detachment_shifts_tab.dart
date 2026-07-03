import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/week_day.dart';
import '../../providers/detachment_detail_provider.dart';

class DetachmentShiftsTab extends ConsumerWidget {
  final String detachmentId;

  const DetachmentShiftsTab({super.key, required this.detachmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftsAsync = ref.watch(detachmentShiftsProvider(detachmentId));

    return shiftsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => Center(
        child: Text('خطأ: $e',
            style: const TextStyle(
                fontFamily: 'Cairo', color: AppColors.error)),
      ),
      data: (shifts) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(children: [
                const Text('الشفتات الأسبوعية',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                        fontSize: 16)),
                const Spacer(),
                Text('${shifts.length} إجمالي',
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        fontFamily: 'Cairo')),
              ]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: WeekDay.values.length,
                  itemBuilder: (_, i) {
                    final day = WeekDay.values[i];
                    final dayShifts = shifts
                        .where((s) => s.weekDay == day)
                        .toList();
                    final count = dayShifts.length;

                    return _DayCard(
                      day: day,
                      shiftCount: count,
                      onTap: () => context.push(
                        '/deployments/$detachmentId/day-shifts/${day.storageKey}',
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DayCard extends StatelessWidget {
  final WeekDay day;
  final int shiftCount;
  final VoidCallback onTap;

  const _DayCard({
    required this.day,
    required this.shiftCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasShifts = shiftCount > 0;
    final color = hasShifts ? AppColors.primary : AppColors.onSurfaceVariant;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: hasShifts
                      ? AppColors.primarySurface
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                day.arabicLabel,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  shiftCount > 0
                      ? '$shiftCount شفت'
                      : 'فارغ',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
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
