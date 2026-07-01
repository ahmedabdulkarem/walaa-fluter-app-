import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../shared/models/pending_application_schema.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../app.dart';

class ApplicationListPage extends ConsumerStatefulWidget {
  const ApplicationListPage({super.key});

  @override
  ConsumerState<ApplicationListPage> createState() => _ApplicationListPageState();
}

class _ApplicationListPageState extends ConsumerState<ApplicationListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSuperAdmin = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkAccess();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkAccess() async {
    final uid = AuthService.currentUid;
    if (uid == null) return;
    final user = await AuthService.getUserByUid(uid);
    if (!mounted) return;
    setState(() {
      _isSuperAdmin = user?.isSuperAdmin ?? false;
    });
  }

  String _appTypeLabel(String type) {
    switch (type) {
      case 'تطوع':
        return 'تطوع';
      case 'عضوية':
        return 'عضوية';
      case 'استفسار':
        return 'استفسار';
      case 'أخرى':
        return 'أخرى';
      default:
        return type;
    }
  }

  Future<void> _reviewApplication(
    PendingApplicationSchema app,
    String newStatus,
  ) async {
    final notesController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            newStatus == 'accepted' ? 'قبول الطلب' : 'رفض الطلب',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${app.fullName} - ${app.applicationType}',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات المراجعة (اختياري)',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: newStatus == 'accepted'
                    ? AppColors.success
                    : AppColors.danger,
                foregroundColor: AppColors.onPrimary,
              ),
              child: Text(
                newStatus == 'accepted' ? 'قبول' : 'رفض',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    final reviewerUid = AuthService.currentUid;

    final result = await ref.read(applicationRepositoryProvider).review(
      app.id,
      newStatus,
      reviewerUid,
      notesController.text.trim().isEmpty ? null : notesController.text.trim(),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل العملية: ${failure.message}')),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'accepted' ? 'تم قبول الطلب' : 'تم رفض الطلب',
            ),
          ),
        );
      },
    );
  }

  void _showDetailDialog(PendingApplicationSchema app) {
    final notesController = TextEditingController(text: app.reviewNotes ?? '');
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'تفاصيل الطلب',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('الاسم', app.fullName),
                _detailRow('البريد', app.email),
                if (app.phone != null) _detailRow('الهاتف', app.phone!),
                _detailRow('النوع', app.applicationType),
                _detailRow('الحالة', _statusLabel(app.status)),
                _detailRow('الرسالة', app.message),
                if (app.createdAt != null)
                  _detailRow(
                    'تاريخ التقديم',
                    DateFormatters.formatDateTime(app.createdAt!),
                  ),
                if (app.reviewedBy != null) _detailRow('تمت المراجعة بواسطة', app.reviewedBy!),
                if (app.reviewedAt != null)
                  _detailRow(
                    'تاريخ المراجعة',
                    DateFormatters.formatDateTime(app.reviewedAt!),
                  ),
                if (app.status == 'pending') ...[
                  const SizedBox(height: AppSizes.md),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات المراجعة',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),
                ] else if (app.reviewNotes != null && app.reviewNotes!.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.sm),
                  _detailRow('ملاحظات المراجعة', app.reviewNotes!),
                ],
              ],
            ),
          ),
          actions: [
            if (app.status == 'pending') ...[
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _reviewApplication(app, 'rejected');
                },
                child: const Text(
                  'رفض',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.danger,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _reviewApplication(app, 'accepted');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.onPrimary,
                ),
                child: const Text('قبول', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
                child: const Text('إغلاق', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'accepted':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSuperAdmin) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: buildAppAppBar(
          context: context,
          title: 'طلبات التسجيل',
        ),
        body: const Center(
          child: Text(
            'ليس لديك صلاحية الوصول',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontFamily: 'Cairo',
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: buildAppAppBar(
          context: context,
          title: 'طلبات التسجيل',
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSizes.marginMobile,
                vertical: AppSizes.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: TabBar(
                controller: _tabController,
                padding: const EdgeInsets.all(4),
                labelStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                labelColor: AppColors.onPrimary,
                unselectedLabelColor: AppColors.onSurfaceVariant,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'جديدة'),
                  Tab(text: 'مقبولة'),
                  Tab(text: 'مرفوضة'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStatusTab('pending'),
                  _buildStatusTab('accepted'),
                  _buildStatusTab('rejected'),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildStatusTab(String status) {
    final stream = ref.watch(applicationRepositoryProvider).streamByStatus(status);

    return StreamBuilder<List<PendingApplicationSchema>>(
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
        final apps = snapshot.data ?? [];
        if (apps.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 64,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                ),
                const SizedBox(height: AppSizes.md),
                const Text(
                  'لا توجد طلبات',
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
          itemCount: apps.length,
          itemBuilder: (context, index) {
            final app = apps[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: AppCard(
                onTap: () => _showDetailDialog(app),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            app.fullName,
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                          ),
                          child: Text(
                            _appTypeLabel(app.applicationType),
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'Cairo',
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            app.email,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Cairo',
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (app.phone != null && app.phone!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 14,
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            app.phone!,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Cairo',
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      app.message,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'Cairo',
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          app.createdAt != null
                              ? DateFormatters.timeAgo(app.createdAt!)
                              : '',
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'Cairo',
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                        const Spacer(),
                        if (app.status == 'pending') ...[
                          SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              onPressed: () => _reviewApplication(app, 'accepted'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: AppColors.onPrimary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                                ),
                              ),
                              child: const Text(
                                'قبول',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.xs),
                          SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              onPressed: () => _reviewApplication(app, 'rejected'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.danger,
                                foregroundColor: AppColors.onPrimary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                                ),
                              ),
                              child: const Text(
                                'رفض',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
