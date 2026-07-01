import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/constants/permission_constants.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/utils/clipboard_utils.dart';
import '../../../../shared/models/workshop_schema.dart';
import '../../../../shared/models/workshop_staff_schema.dart';
import '../../../../shared/models/workshop_attendee_schema.dart';
import '../../../../shared/models/user_schema.dart';
import '../../../../core/localization/locale_controller.dart';

enum _ViewMode { list, table, grid }

enum _Filter { all, paid, unpaid, present, absent }

class WorkshopDetailPage extends ConsumerStatefulWidget {
  final String id;

  const WorkshopDetailPage({super.key, required this.id});

  @override
  ConsumerState<WorkshopDetailPage> createState() =>
      _WorkshopDetailPageState();
}

class _WorkshopDetailPageState extends ConsumerState<WorkshopDetailPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  WorkshopSchema? _workshop;
  bool _loadingWorkshop = true;
  _ViewMode _staffViewMode = _ViewMode.list;
  _ViewMode _attendeeViewMode = _ViewMode.list;
  _Filter _staffFilter = _Filter.all;
  _Filter _attendeeFilter = _Filter.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadWorkshop();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkshop() async {
    final repo = ref.read(workshopRepositoryProvider);
    final w = await repo.getWorkshop(widget.id);
    if (mounted) {
      setState(() {
        _workshop = w;
        _loadingWorkshop = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isArabic = locale.languageCode == 'ar';
    final user = ref.read(currentUserProvider).valueOrNull;

    if (_loadingWorkshop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            'الورشة',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_workshop == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            'الورشة',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: AppSizes.md),
              Text(
                'الورشة غير موجودة',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: AppColors.error),
              ),
            ],
          ),
        ),
      );
    }

    final w = _workshop!;
    final canEdit =
        user?.can(PermissionConstants.manageWorkshops) ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider),
        ),
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          onSelected: (value) {
            switch (value) {
              case 'add_staff':
                _showAddStaffDialog(w);
              case 'add_attendee':
                _showAddAttendeeDialog(w);
              case 'edit_workshop':
                context.push('/workshops/form', extra: w);
              case 'delete_workshop':
                _confirmDeleteWorkshop(context, w);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'add_staff',
              child: Row(
                children: [
                  Icon(Icons.person_add_alt_1_outlined, size: 18, color: AppColors.primary),
                  SizedBox(width: AppSizes.sm),
                  Text('إضافة عضو طاقم', style: TextStyle(fontFamily: 'Cairo', fontSize: 14)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'add_attendee',
              child: Row(
                children: [
                  Icon(Icons.group_add_outlined, size: 18, color: AppColors.primary),
                  SizedBox(width: AppSizes.sm),
                  Text('إضافة طالب / ضيف', style: TextStyle(fontFamily: 'Cairo', fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        title: Text(
          w.title,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () => context.push('/notifications'),
          ),
          if (canEdit) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              onPressed: () {
                context.push('/workshops/form', extra: w);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever, color: AppColors.error),
              onPressed: () => _confirmDeleteWorkshop(context, w),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          _buildHeader(w, isArabic),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            indicatorColor: AppColors.primary,
            labelStyle: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'الطاقم'),
              Tab(text: 'الطلبة والضيوف'),
              Tab(text: 'الإحصائيات'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStaffTab(w, user),
                _buildAttendeesTab(w, user),
                _buildStatsTab(w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteWorkshop(BuildContext context, WorkshopSchema w) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الورشة', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('هل أنت متأكد من حذف هذه الورشة؟ سيتم حذف جميع البيانات المرتبطة بها.', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: AppColors.onPrimary)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    final result = await ref.read(workshopRepositoryProvider).deleteWorkshop(w.uid, user);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message), backgroundColor: AppColors.error),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الورشة'), backgroundColor: AppColors.success),
        );
        context.pop();
      },
    );
  }

  Widget _buildHeader(WorkshopSchema w, bool isArabic) {
    final status = WorkshopStatus.fromString(w.status);
    final (Color bg, Color fg, String label) = switch (status) {
      WorkshopStatus.upcoming => (
        const Color(0xFFDBEAFE),
        const Color(0xFF1E40AF),
        'قادمة'
      ),
      WorkshopStatus.active => (
        const Color(0xFFDCFCE7),
        const Color(0xFF166534),
        'نشطة'
      ),
      WorkshopStatus.completed => (
        const Color(0xFFF3F4F6),
        const Color(0xFF4B5563),
        'منتهية'
      ),
      WorkshopStatus.cancelled => (
        const Color(0xFFFEE2E2),
        const Color(0xFF991B1B),
        'ملغاة'
      ),
    };

    final formattedDate = w.dateTime != null
        ? DateFormatters.formatDateTime(w.dateTime!, isArabic: isArabic)
        : '';
    final formattedEnd = w.endDateTime != null
        ? DateFormatters.formatDateTime(w.endDateTime!, isArabic: isArabic)
        : '';

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.marginMobile, AppSizes.sm, AppSizes.marginMobile, 0),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    w.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: fg,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: AppSizes.md,
              runSpacing: AppSizes.xs,
              children: [
                _infoChip(Icons.person_outline, w.instructorName),
                if (formattedDate.isNotEmpty)
                  _infoChip(Icons.access_time, formattedDate),
                if (formattedEnd.isNotEmpty)
                  _infoChip(Icons.event, formattedEnd),
                _infoChip(Icons.location_on_outlined, w.location),
                _infoChip(
                    Icons.people_outline, 'السعة: ${w.capacity}'),
                _infoChip(
                  Icons.attach_money,
                  'رسوم: ${w.subscriptionFee.toStringAsFixed(0)} د.ل',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontFamily: 'Cairo',
              ),
        ),
      ],
    );
  }

  Widget _buildStaffTab(WorkshopSchema w, UserSchema? user) {
    final repo = ref.read(workshopRepositoryProvider);
    final canManage =
        user?.can(PermissionConstants.manageWorkshops) ?? false;
    final canConfirmPay =
        user?.can(PermissionConstants.confirmPayment) ?? false;
    final canRecordAtt =
        user?.can(PermissionConstants.recordWorkshopAttendance) ?? false;

    return Stack(
      children: [
        StreamBuilder<List<WorkshopStaffSchema>>(
          stream: repo.streamStaff(w.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final allStaff = snapshot.data ?? [];
            final filtered = _applyStaffFilter(allStaff);

            return Column(
              children: [
                _buildStaffTopBar(filtered, canManage),
                Expanded(child: _buildStaffContent(filtered, canManage,
                    canConfirmPay, canRecordAtt, w)),
              ],
            );
          },
        ),
        if (canManage)
          Positioned(
            bottom: AppSizes.marginMobile,
            right: AppSizes.marginMobile,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              onPressed: () => _showAddStaffDialog(w),
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }

  Widget _buildAttendeesTab(WorkshopSchema w, UserSchema? user) {
    final repo = ref.read(workshopRepositoryProvider);
    final canManage =
        user?.can(PermissionConstants.addWorkshopAttendees) ?? false;
    final canConfirmPay =
        user?.can(PermissionConstants.confirmPayment) ?? false;
    final canRecordAtt =
        user?.can(PermissionConstants.recordWorkshopAttendance) ?? false;

    return Stack(
      children: [
        StreamBuilder<List<WorkshopAttendeeSchema>>(
          stream: repo.streamAttendees(w.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = snapshot.data ?? [];
            final filtered = _applyAttendeeFilter(all);

            return Column(
              children: [
                _buildAttendeeTopBar(filtered, canManage),
                Expanded(
                    child: _buildAttendeeContent(filtered, canManage,
                        canConfirmPay, canRecordAtt, w)),
              ],
            );
          },
        ),
        if (canManage)
          Positioned(
            bottom: AppSizes.marginMobile,
            right: AppSizes.marginMobile,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              onPressed: () => _showAddAttendeeDialog(w),
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }

  Widget _buildStaffTopBar(
      List<WorkshopStaffSchema> filtered, bool canManage) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.marginMobile, AppSizes.sm, AppSizes.marginMobile, 0),
      child: Column(
        children: [
          Row(
            children: [
              if (canManage) ...[
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: 'نسخ الكل',
                  color: AppColors.primary,
                  onPressed: () => _copyStaffList(filtered),
                ),
                IconButton(
                  icon: const Icon(Icons.file_download_outlined, size: 20),
                  tooltip: 'تحميل كملف CSV',
                  color: AppColors.primary,
                  onPressed: () => _exportStaffCsv(filtered),
                ),
              ],
              const Spacer(),
              _viewModeToggle(
                current: _staffViewMode,
                onChanged: (v) => setState(() => _staffViewMode = v),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          _filterChips(
            current: _staffFilter,
            onChanged: (v) => setState(() => _staffFilter = v),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeeTopBar(
      List<WorkshopAttendeeSchema> filtered, bool canManage) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSizes.marginMobile, AppSizes.sm, AppSizes.marginMobile, 0),
      child: Column(
        children: [
          Row(
            children: [
              if (canManage) ...[
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: 'نسخ الكل',
                  color: AppColors.primary,
                  onPressed: () => _copyAttendeeList(filtered),
                ),
                IconButton(
                  icon: const Icon(Icons.file_download_outlined, size: 20),
                  tooltip: 'تحميل كملف CSV',
                  color: AppColors.primary,
                  onPressed: () => _exportAttendeeCsv(filtered),
                ),
              ],
              const Spacer(),
              _viewModeToggle(
                current: _attendeeViewMode,
                onChanged: (v) => setState(() => _attendeeViewMode = v),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          _filterChips(
            current: _attendeeFilter,
            onChanged: (v) => setState(() => _attendeeFilter = v),
          ),
        ],
      ),
    );
  }

  Widget _viewModeToggle({
    required _ViewMode current,
    required ValueChanged<_ViewMode> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _ViewMode.values.map((mode) {
        final isActive = current == mode;
        final icon = switch (mode) {
          _ViewMode.list => Icons.view_list,
          _ViewMode.table => Icons.table_chart_outlined,
          _ViewMode.grid => Icons.grid_view_outlined,
        };
        return IconButton(
          icon: Icon(icon, size: 20),
          color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
          onPressed: () => onChanged(mode),
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }

  Widget _filterChips({
    required _Filter current,
    required ValueChanged<_Filter> onChanged,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _Filter.values.map((f) {
          final sel = current == f;
          final label = switch (f) {
            _Filter.all => 'الكل',
            _Filter.paid => 'دافعين',
            _Filter.unpaid => 'غير دافعين',
            _Filter.present => 'حاضرين',
            _Filter.absent => 'غائبين',
          };
          return Padding(
            padding: const EdgeInsets.only(left: AppSizes.xs),
            child: ChoiceChip(
              label: Text(label,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Cairo',
                    color: sel ? AppColors.onPrimary : AppColors.onSurface,
                  )),
              selected: sel,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: sel ? AppColors.primary : AppColors.outlineVariant,
              ),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onSelected: (_) => onChanged(f),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<WorkshopStaffSchema> _applyStaffFilter(List<WorkshopStaffSchema> list) {
    switch (_staffFilter) {
      case _Filter.all:
        return list;
      case _Filter.paid:
        return list.where((s) => s.hasPaidSubscription).toList();
      case _Filter.unpaid:
        return list.where((s) => !s.hasPaidSubscription).toList();
      case _Filter.present:
        return list.where((s) => s.attendanceStatus == 'present').toList();
      case _Filter.absent:
        return list.where((s) => s.attendanceStatus == 'absent').toList();
    }
  }

  List<WorkshopAttendeeSchema> _applyAttendeeFilter(
      List<WorkshopAttendeeSchema> list) {
    switch (_attendeeFilter) {
      case _Filter.all:
        return list;
      case _Filter.paid:
        return list.where((s) => s.hasPaidSubscription).toList();
      case _Filter.unpaid:
        return list.where((s) => !s.hasPaidSubscription).toList();
      case _Filter.present:
        return list.where((s) => s.attendanceStatus == 'present').toList();
      case _Filter.absent:
        return list.where((s) => s.attendanceStatus == 'absent').toList();
    }
  }

  Widget _buildStaffContent(
    List<WorkshopStaffSchema> list,
    bool canManage,
    bool canConfirmPay,
    bool canRecordAtt,
    WorkshopSchema w,
  ) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد طاقم',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: AppColors.onSurfaceVariant),
        ),
      );
    }

    switch (_staffViewMode) {
      case _ViewMode.list:
        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.marginMobile),
          itemCount: list.length,
          itemBuilder: (_, i) => _buildStaffListItem(
              list[i], canManage, canConfirmPay, canRecordAtt, w),
        );
      case _ViewMode.table:
        return _buildStaffTableView(
            list, canManage, canConfirmPay, canRecordAtt, w);
      case _ViewMode.grid:
        return _buildStaffGridView(
            list, canManage, canConfirmPay, canRecordAtt, w);
    }
  }

  Widget _buildAttendeeContent(
    List<WorkshopAttendeeSchema> list,
    bool canManage,
    bool canConfirmPay,
    bool canRecordAtt,
    WorkshopSchema w,
  ) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد طلبة أو ضيوف',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: AppColors.onSurfaceVariant),
        ),
      );
    }

    switch (_attendeeViewMode) {
      case _ViewMode.list:
        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.marginMobile),
          itemCount: list.length,
          itemBuilder: (_, i) => _buildAttendeeListItem(
              list[i], canManage, canConfirmPay, canRecordAtt, w),
        );
      case _ViewMode.table:
        return _buildAttendeeTableView(
            list, canManage, canConfirmPay, canRecordAtt, w);
      case _ViewMode.grid:
        return _buildAttendeeGridView(
            list, canManage, canConfirmPay, canRecordAtt, w);
    }
  }

  Widget _buildStaffListItem(
    WorkshopStaffSchema s,
    bool canManage,
    bool canConfirmPay,
    bool canRecordAtt,
    WorkshopSchema w,
  ) {
    final attStatus = AttendanceStatus.fromString(s.attendanceStatus);
    final attLabel = switch (attStatus) {
      AttendanceStatus.notRecorded => 'لم يسجل',
      AttendanceStatus.present => 'حاضر',
      AttendanceStatus.absent => 'غائب',
    };
    final attColor = switch (attStatus) {
      AttendanceStatus.notRecorded => AppColors.onSurfaceVariant,
      AttendanceStatus.present => AppColors.success,
      AttendanceStatus.absent => AppColors.danger,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.fullName,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: AppColors.onSurface),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (s.role != null && s.role!.isNotEmpty)
                        Text(
                          s.role!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: AppColors.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (canConfirmPay)
                  GestureDetector(
                    onTap: () => _toggleStaffPayment(w, s),
                    child: _paymentBadge(s.hasPaidSubscription),
                  ),
                const SizedBox(width: AppSizes.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: attColor.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    attLabel,
                    style: TextStyle(
                      color: attColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                if (canManage)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        size: 18, color: AppColors.onSurfaceVariant),
                    onSelected: (v) {
                      if (v == 'edit') _showEditStaffDialog(s);
                      if (v == 'delete') _showDeleteStaffDialog(s);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'edit', child: Text('تعديل')),
                      const PopupMenuItem(
                          value: 'delete', child: Text('حذف')),
                    ],
                  ),
              ],
            ),
            if (canRecordAtt)
              Padding(
                padding: const EdgeInsets.only(top: AppSizes.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: s.attendanceStatus == 'present'
                          ? null
                          : () => _markStaffAttendance(
                              w, s, 'present'),
                      icon: const Icon(Icons.check_circle_outline,
                          size: 16, color: AppColors.success),
                      label: const Text(
                        'حضور',
                        style: TextStyle(
                          color: AppColors.success,
                          fontFamily: 'Cairo',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.xs),
                    TextButton.icon(
                      onPressed: s.attendanceStatus == 'absent'
                          ? null
                          : () =>
                              _markStaffAttendance(w, s, 'absent'),
                      icon: const Icon(Icons.cancel_outlined,
                          size: 16, color: AppColors.danger),
                      label: const Text(
                        'غياب',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontFamily: 'Cairo',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendeeListItem(
    WorkshopAttendeeSchema a,
    bool canManage,
    bool canConfirmPay,
    bool canRecordAtt,
    WorkshopSchema w,
  ) {
    final attStatus = AttendanceStatus.fromString(a.attendanceStatus);
    final attLabel = switch (attStatus) {
      AttendanceStatus.notRecorded => 'لم يسجل',
      AttendanceStatus.present => 'حاضر',
      AttendanceStatus.absent => 'غائب',
    };
    final attColor = switch (attStatus) {
      AttendanceStatus.notRecorded => AppColors.onSurfaceVariant,
      AttendanceStatus.present => AppColors.success,
      AttendanceStatus.absent => AppColors.danger,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    a.fullName,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: AppColors.onSurface),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (canConfirmPay)
                  GestureDetector(
                    onTap: () => _toggleAttendeePayment(w, a),
                    child: _paymentBadge(a.hasPaidSubscription),
                  ),
                const SizedBox(width: AppSizes.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: attColor.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    attLabel,
                    style: TextStyle(
                      color: attColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                if (canManage)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        size: 18, color: AppColors.onSurfaceVariant),
                    onSelected: (v) {
                      if (v == 'edit') _showEditAttendeeDialog(a);
                      if (v == 'delete') _showDeleteAttendeeDialog(a);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'edit', child: Text('تعديل')),
                      const PopupMenuItem(
                          value: 'delete', child: Text('حذف')),
                    ],
                  ),
              ],
            ),
            if (canRecordAtt)
              Padding(
                padding: const EdgeInsets.only(top: AppSizes.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: a.attendanceStatus == 'present'
                          ? null
                          : () => _markAttendeeAttendance(
                              w, a, 'present'),
                      icon: const Icon(Icons.check_circle_outline,
                          size: 16, color: AppColors.success),
                      label: const Text(
                        'حضور',
                        style: TextStyle(
                          color: AppColors.success,
                          fontFamily: 'Cairo',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.xs),
                    TextButton.icon(
                      onPressed: a.attendanceStatus == 'absent'
                          ? null
                          : () =>
                              _markAttendeeAttendance(w, a, 'absent'),
                      icon: const Icon(Icons.cancel_outlined,
                          size: 16, color: AppColors.danger),
                      label: const Text(
                        'غياب',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontFamily: 'Cairo',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _paymentBadge(bool hasPaid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hasPaid
            ? AppColors.successLight
            : AppColors.dangerLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Text(
        hasPaid ? 'مدفوع' : 'غير مدفوع',
        style: TextStyle(
          color: hasPaid ? AppColors.success : AppColors.danger,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildStaffTableView(
    List<WorkshopStaffSchema> list,
    bool canManage,
    bool canConfirmPay,
    bool canRecordAtt,
    WorkshopSchema w,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.marginMobile),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('الاسم', style: TextStyle(fontFamily: 'Cairo'))),
            DataColumn(label: Text('الدور', style: TextStyle(fontFamily: 'Cairo'))),
            DataColumn(label: Text('الدفع', style: TextStyle(fontFamily: 'Cairo'))),
            DataColumn(label: Text('الحالة', style: TextStyle(fontFamily: 'Cairo'))),
            DataColumn(label: Text('', style: TextStyle(fontFamily: 'Cairo'))),
          ],
          rows: list.map((s) {
            final attStatus = AttendanceStatus.fromString(s.attendanceStatus);
            final attLabel = switch (attStatus) {
              AttendanceStatus.notRecorded => 'لم يسجل',
              AttendanceStatus.present => 'حاضر',
              AttendanceStatus.absent => 'غائب',
            };
            return DataRow(cells: [
              DataCell(Text(s.fullName)),
              DataCell(Text(s.role ?? '')),
              DataCell(
                canConfirmPay
                    ? GestureDetector(
                        onTap: () => _toggleStaffPayment(w, s),
                        child: _paymentBadge(s.hasPaidSubscription),
                      )
                    : _paymentBadge(s.hasPaidSubscription),
              ),
              DataCell(Text(attLabel)),
              DataCell(
                canManage
                    ? PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 16),
                        onSelected: (v) {
                          if (v == 'edit') _showEditStaffDialog(s);
                          if (v == 'delete') _showDeleteStaffDialog(s);
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                              value: 'edit', child: Text('تعديل')),
                          const PopupMenuItem(
                              value: 'delete', child: Text('حذف')),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStaffGridView(
    List<WorkshopStaffSchema> list,
    bool canManage,
    bool canConfirmPay,
    bool canRecordAtt,
    WorkshopSchema w,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSizes.marginMobile),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.sm,
        mainAxisSpacing: AppSizes.sm,
        childAspectRatio: 1.4,
      ),
      itemCount: list.length,
      itemBuilder: (_, i) => _buildStaffGridItem(
          list[i], canManage, canConfirmPay, canRecordAtt, w),
    );
  }

  Widget _buildStaffGridItem(
    WorkshopStaffSchema s,
    bool canManage,
    bool canConfirmPay,
    bool canRecordAtt,
    WorkshopSchema w,
  ) {
    final attStatus = AttendanceStatus.fromString(s.attendanceStatus);
    final attLabel = switch (attStatus) {
      AttendanceStatus.notRecorded => 'لم يسجل',
      AttendanceStatus.present => 'حاضر',
      AttendanceStatus.absent => 'غائب',
    };
    final attColor = switch (attStatus) {
      AttendanceStatus.notRecorded => AppColors.onSurfaceVariant,
      AttendanceStatus.present => AppColors.success,
      AttendanceStatus.absent => AppColors.danger,
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  s.fullName,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (canManage)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      size: 14, color: AppColors.onSurfaceVariant),
                  onSelected: (v) {
                    if (v == 'edit') _showEditStaffDialog(s);
                    if (v == 'delete') _showDeleteStaffDialog(s);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'edit', child: Text('تعديل')),
                    const PopupMenuItem(
                        value: 'delete', child: Text('حذف')),
                  ],
                ),
            ],
          ),
          if (s.role != null && s.role!.isNotEmpty)
            Text(s.role!,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.onSurfaceVariant),
                overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSizes.xs),
          Row(
            children: [
              if (canConfirmPay)
                GestureDetector(
                  onTap: () => _toggleStaffPayment(w, s),
                  child: _paymentBadge(s.hasPaidSubscription),
                ),
              const SizedBox(width: AppSizes.xs),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: attColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Text(
                  attLabel,
                  style: TextStyle(
                    color: attColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeeTableView(
    List<WorkshopAttendeeSchema> list,
    bool canManage,
    bool canConfirmPay,
    bool canRecordAtt,
    WorkshopSchema w,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.marginMobile),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('الاسم', style: TextStyle(fontFamily: 'Cairo'))),
            DataColumn(label: Text('الدفع', style: TextStyle(fontFamily: 'Cairo'))),
            DataColumn(label: Text('الحالة', style: TextStyle(fontFamily: 'Cairo'))),
            DataColumn(label: Text('', style: TextStyle(fontFamily: 'Cairo'))),
          ],
          rows: list.map((a) {
            final attStatus = AttendanceStatus.fromString(a.attendanceStatus);
            final attLabel = switch (attStatus) {
              AttendanceStatus.notRecorded => 'لم يسجل',
              AttendanceStatus.present => 'حاضر',
              AttendanceStatus.absent => 'غائب',
            };
            return DataRow(cells: [
              DataCell(Text(a.fullName)),
              DataCell(
                canConfirmPay
                    ? GestureDetector(
                        onTap: () => _toggleAttendeePayment(w, a),
                        child: _paymentBadge(a.hasPaidSubscription),
                      )
                    : _paymentBadge(a.hasPaidSubscription),
              ),
              DataCell(Text(attLabel)),
              DataCell(
                canManage
                    ? PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 16),
                        onSelected: (v) {
                          if (v == 'edit') _showEditAttendeeDialog(a);
                          if (v == 'delete') _showDeleteAttendeeDialog(a);
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                              value: 'edit', child: Text('تعديل')),
                          const PopupMenuItem(
                              value: 'delete', child: Text('حذف')),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAttendeeGridView(
    List<WorkshopAttendeeSchema> list,
    bool canManage,
    bool canConfirmPay,
    bool canRecordAtt,
    WorkshopSchema w,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSizes.marginMobile),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.sm,
        mainAxisSpacing: AppSizes.sm,
        childAspectRatio: 1.4,
      ),
      itemCount: list.length,
      itemBuilder: (_, i) => _buildAttendeeGridItem(
          list[i], canManage, canConfirmPay, canRecordAtt, w),
    );
  }

  Widget _buildAttendeeGridItem(
    WorkshopAttendeeSchema a,
    bool canManage,
    bool canConfirmPay,
    bool canRecordAtt,
    WorkshopSchema w,
  ) {
    final attStatus = AttendanceStatus.fromString(a.attendanceStatus);
    final attLabel = switch (attStatus) {
      AttendanceStatus.notRecorded => 'لم يسجل',
      AttendanceStatus.present => 'حاضر',
      AttendanceStatus.absent => 'غائب',
    };
    final attColor = switch (attStatus) {
      AttendanceStatus.notRecorded => AppColors.onSurfaceVariant,
      AttendanceStatus.present => AppColors.success,
      AttendanceStatus.absent => AppColors.danger,
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  a.fullName,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (canManage)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      size: 14, color: AppColors.onSurfaceVariant),
                  onSelected: (v) {
                    if (v == 'edit') _showEditAttendeeDialog(a);
                    if (v == 'delete') _showDeleteAttendeeDialog(a);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'edit', child: Text('تعديل')),
                    const PopupMenuItem(
                        value: 'delete', child: Text('حذف')),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            children: [
              if (canConfirmPay)
                GestureDetector(
                  onTap: () => _toggleAttendeePayment(w, a),
                  child: _paymentBadge(a.hasPaidSubscription),
                ),
              const SizedBox(width: AppSizes.xs),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: attColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Text(
                  attLabel,
                  style: TextStyle(
                    color: attColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(WorkshopSchema w) {
    final repo = ref.read(workshopRepositoryProvider);
    final staffStream = repo.streamStaff(w.uid);
    final attendeesStream = repo.streamAttendees(w.uid);

    return StreamBuilder<List<WorkshopStaffSchema>>(
      stream: staffStream,
      builder: (context, staffSnap) {
        final staff = staffSnap.data ?? [];
        return StreamBuilder<List<WorkshopAttendeeSchema>>(
          stream: attendeesStream,
          builder: (context, attSnap) {
            final attendees = attSnap.data ?? [];
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.marginMobile),
              child: Column(
                children: [
                  _buildStatsCard(
                    title: 'إحصائيات الطاقم',
                    icon: Icons.group_outlined,
                    children: [
                      _statRow('إجمالي الطاقم', '${staff.length}'),
                      _statRow(
                        'مدفوع',
                        '${staff.where((s) => s.hasPaidSubscription).length}',
                        valueColor: AppColors.success,
                      ),
                      _statRow(
                        'غير مدفوع',
                        '${staff.where((s) => !s.hasPaidSubscription).length}',
                        valueColor: AppColors.danger,
                      ),
                      _statRow(
                        'حاضر',
                        '${staff.where((s) => s.attendanceStatus == 'present').length}',
                        valueColor: AppColors.success,
                      ),
                      _statRow(
                        'غائب',
                        '${staff.where((s) => s.attendanceStatus == 'absent').length}',
                        valueColor: AppColors.danger,
                      ),
                      _statRow(
                        'نسبة الحضور',
                        staff.isEmpty
                            ? '0%'
                            : '${((staff.where((s) => s.attendanceStatus == 'present').length / staff.length) * 100).toStringAsFixed(0)}%',
                        valueColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildStatsCard(
                    title: 'إحصائيات الطلبة والضيوف',
                    icon: Icons.people_outlined,
                    children: [
                      _statRow('الإجمالي', '${attendees.length}'),
                      _statRow(
                        'مدفوع',
                        '${attendees.where((s) => s.hasPaidSubscription).length}',
                        valueColor: AppColors.success,
                      ),
                      _statRow(
                        'غير مدفوع',
                        '${attendees.where((s) => !s.hasPaidSubscription).length}',
                        valueColor: AppColors.danger,
                      ),
                      _statRow(
                        'حاضر',
                        '${attendees.where((s) => s.attendanceStatus == 'present').length}',
                        valueColor: AppColors.success,
                      ),
                      _statRow(
                        'غائب',
                        '${attendees.where((s) => s.attendanceStatus == 'absent').length}',
                        valueColor: AppColors.danger,
                      ),
                      _statRow(
                        'لم يسجل',
                        '${attendees.where((s) => s.attendanceStatus == 'not_recorded').length}',
                        valueColor: AppColors.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildStatsCard(
                    title: 'الإحصائيات المالية',
                    icon: Icons.account_balance_wallet_outlined,
                    children: [
                      _statRow(
                        'رسوم الاشتراك',
                        '${w.subscriptionFee.toStringAsFixed(0)} د.ل',
                      ),
                      _statRow(
                        'المدفوعات الإجمالية',
                        _formatCurrency(
                          ((staff.where((s) => s.hasPaidSubscription)
                                      .length +
                                  attendees
                                      .where((s) => s.hasPaidSubscription)
                                      .length) *
                              w.subscriptionFee),
                        ),
                        valueColor: AppColors.success,
                        isLarge: true,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatsCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSizes.xs),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const Divider(height: AppSizes.lg),
          ...children,
        ],
      ),
    );
  }

  Widget _statRow(
    String label,
    String value, {
    Color? valueColor,
    bool isLarge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            value,
            style: (isLarge
                    ? Theme.of(context).textTheme.titleLarge
                    : Theme.of(context).textTheme.bodyLarge)
                ?.copyWith(
              color: valueColor ?? AppColors.onSurface,
              fontWeight: isLarge ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} د.ل';
  }

  Future<void> _showAddStaffDialog(WorkshopSchema w) async {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة عضو طاقم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'الاسم', hintText: 'الاسم الكامل'),
              autofocus: true,
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: roleCtrl,
              decoration: const InputDecoration(
                  labelText: 'الدور (اختياري)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    if (result != true || nameCtrl.text.trim().isEmpty) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final staff = WorkshopStaffSchema()
      ..uid = DateTime.now().millisecondsSinceEpoch.toString()
      ..fullName = nameCtrl.text.trim()
      ..role = roleCtrl.text.trim().isEmpty ? null : roleCtrl.text.trim()
      ..hasPaidSubscription = false
      ..attendanceStatus = 'not_recorded'
      ..addedBy = user.uid
      ..addedAt = DateTime.now();

    final repo = ref.read(workshopRepositoryProvider);
    final addResult = await repo.addStaff(w.uid, staff, user);
    if (!mounted) return;
    addResult.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error),
      ),
      (_) {},
    );
  }

  Future<void> _showEditStaffDialog(WorkshopStaffSchema staff) async {
    final nameCtrl = TextEditingController(text: staff.fullName);
    final roleCtrl = TextEditingController(text: staff.role ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعديل عضو طاقم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'الاسم'),
              autofocus: true,
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: roleCtrl,
              decoration: const InputDecoration(
                  labelText: 'الدور (اختياري)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (result != true || nameCtrl.text.trim().isEmpty) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    staff.fullName = nameCtrl.text.trim();
    staff.role = roleCtrl.text.trim().isEmpty ? null : roleCtrl.text.trim();

    final repo = ref.read(workshopRepositoryProvider);
    final updResult = await repo.updateStaff(staff, user);
    if (!mounted) return;
    updResult.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error),
      ),
      (_) {},
    );
  }

  Future<void> _showDeleteStaffDialog(WorkshopStaffSchema staff) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف عضو طاقم'),
        content: Text('هل أنت متأكد من حذف "${staff.fullName}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final repo = ref.read(workshopRepositoryProvider);
    final delResult = await repo.deleteStaff(widget.id, staff.uid, user);
    if (!mounted) return;
    delResult.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error),
      ),
      (_) {},
    );
  }

  Future<void> _showAddAttendeeDialog(WorkshopSchema w) async {
    final nameCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة طالب أو ضيف'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'الاسم'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );

    if (result != true || nameCtrl.text.trim().isEmpty) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final attendee = WorkshopAttendeeSchema()
      ..uid = DateTime.now().millisecondsSinceEpoch.toString()
      ..fullName = nameCtrl.text.trim()
      ..hasPaidSubscription = false
      ..attendanceStatus = 'not_recorded'
      ..addedBy = user.uid
      ..addedAt = DateTime.now();

    final repo = ref.read(workshopRepositoryProvider);
    final addResult = await repo.addAttendee(w.uid, attendee, user);
    if (!mounted) return;
    addResult.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error),
      ),
      (_) {},
    );
  }

  Future<void> _showEditAttendeeDialog(WorkshopAttendeeSchema attendee) async {
    final nameCtrl = TextEditingController(text: attendee.fullName);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعديل طالب أو ضيف'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'الاسم'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (result != true || nameCtrl.text.trim().isEmpty) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    attendee.fullName = nameCtrl.text.trim();

    final repo = ref.read(workshopRepositoryProvider);
    final updResult = await repo.updateAttendee(attendee, user);
    if (!mounted) return;
    updResult.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error),
      ),
      (_) {},
    );
  }

  Future<void> _showDeleteAttendeeDialog(
      WorkshopAttendeeSchema attendee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف طالب أو ضيف'),
        content: Text('هل أنت متأكد من حذف "${attendee.fullName}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final repo = ref.read(workshopRepositoryProvider);
    final delResult = await repo.deleteAttendee(widget.id, attendee.uid, user);
    if (!mounted) return;
    delResult.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error),
      ),
      (_) {},
    );
  }

  Future<void> _toggleStaffPayment(
      WorkshopSchema w, WorkshopStaffSchema staff) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    final repo = ref.read(workshopRepositoryProvider);
    final result = await repo.toggleStaffPayment(
        w.uid, staff.id, !staff.hasPaidSubscription, user);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error),
      ),
      (_) {},
    );
  }

  Future<void> _toggleAttendeePayment(
      WorkshopSchema w, WorkshopAttendeeSchema attendee) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    final repo = ref.read(workshopRepositoryProvider);
    final result = await repo.toggleAttendeePayment(
        w.uid, attendee.id, !attendee.hasPaidSubscription, user);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error),
      ),
      (_) {},
    );
  }

  Future<void> _markStaffAttendance(
      WorkshopSchema w, WorkshopStaffSchema staff, String status) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    final repo = ref.read(workshopRepositoryProvider);
    final result =
        await repo.markStaffAttendance(w.uid, staff.id, status, user);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error),
      ),
      (_) {},
    );
  }

  Future<void> _markAttendeeAttendance(
      WorkshopSchema w, WorkshopAttendeeSchema attendee, String status) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    final repo = ref.read(workshopRepositoryProvider);
    final result =
        await repo.markAttendance(w.uid, attendee.id, status, user);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error),
      ),
      (_) {},
    );
  }

  String _formatStaffLine(WorkshopStaffSchema s) {
    final role = s.role ?? '';
    final pay = s.hasPaidSubscription ? 'مدفوع' : 'غير مدفوع';
    final att = AttendanceStatus.fromString(s.attendanceStatus);
    final attLabel = switch (att) {
      AttendanceStatus.notRecorded => 'لم يسجل',
      AttendanceStatus.present => 'حاضر',
      AttendanceStatus.absent => 'غائب',
    };
    final parts = [s.fullName, role, pay, attLabel]
        .where((x) => x.isNotEmpty)
        .join(' - ');
    return parts;
  }

  void _copyStaffList(List<WorkshopStaffSchema> list) {
    final lines = list.map(_formatStaffLine).toList();
    final text = ClipboardUtils.formatNamesForCopy(lines);
    ClipboardUtils.copy(context, text);
  }

  void _exportStaffCsv(List<WorkshopStaffSchema> list) {
    final buffer = StringBuffer('\uFEFF');
    buffer.writeln('الاسم,الدور,الدفع,الحالة');
    for (final s in list) {
      final att = AttendanceStatus.fromString(s.attendanceStatus);
      final attLabel = switch (att) {
        AttendanceStatus.notRecorded => 'لم يسجل',
        AttendanceStatus.present => 'حاضر',
        AttendanceStatus.absent => 'غائب',
      };
      buffer.writeln(
          '${s.fullName},${s.role ?? ''},${s.hasPaidSubscription ? 'مدفوع' : 'غير مدفوع'},$attLabel');
    }
    ClipboardUtils.copy(context, buffer.toString(), label: 'تم نسخ CSV');
  }

  String _formatAttendeeLine(WorkshopAttendeeSchema a) {
    final pay = a.hasPaidSubscription ? 'مدفوع' : 'غير مدفوع';
    final att = AttendanceStatus.fromString(a.attendanceStatus);
    final attLabel = switch (att) {
      AttendanceStatus.notRecorded => 'لم يسجل',
      AttendanceStatus.present => 'حاضر',
      AttendanceStatus.absent => 'غائب',
    };
    return [a.fullName, pay, attLabel].join(' - ');
  }

  void _copyAttendeeList(List<WorkshopAttendeeSchema> list) {
    final lines = list.map(_formatAttendeeLine).toList();
    final text = ClipboardUtils.formatNamesForCopy(lines);
    ClipboardUtils.copy(context, text);
  }

  void _exportAttendeeCsv(List<WorkshopAttendeeSchema> list) {
    final buffer = StringBuffer('\uFEFF');
    buffer.writeln('الاسم,الدفع,الحالة');
    for (final a in list) {
      final att = AttendanceStatus.fromString(a.attendanceStatus);
      final attLabel = switch (att) {
        AttendanceStatus.notRecorded => 'لم يسجل',
        AttendanceStatus.present => 'حاضر',
        AttendanceStatus.absent => 'غائب',
      };
      buffer.writeln(
          '${a.fullName},${a.hasPaidSubscription ? 'مدفوع' : 'غير مدفوع'},$attLabel');
    }
    ClipboardUtils.copy(context, buffer.toString(), label: 'تم نسخ CSV');
  }
}
