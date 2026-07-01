import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../models/detachment_member_model.dart';
import '../../controllers/detachment_controller.dart';
import '../../../../app.dart';

class ShiftMembersPage extends ConsumerStatefulWidget {
  const ShiftMembersPage({super.key});

  @override
  ConsumerState<ShiftMembersPage> createState() =>
      _ShiftMembersPageState();
}

class _ShiftMembersPageState extends ConsumerState<ShiftMembersPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is List<String>) {
        ref
            .read(detachmentMemberSelectionProvider.notifier)
            .initSelection(extra);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref
          .read(detachmentMemberSelectionProvider.notifier)
          .setSearchQuery(query);
    });
  }

  Future<void> _save(String shiftId) async {
    final result = await ref
        .read(detachmentMemberSelectionProvider.notifier)
        .saveShiftMembers(shiftId);
    if (!mounted) return;
    if (result) {
      context.showSnackBar('تم حفظ أعضاء الشفت بنجاح');
      if (mounted) context.pop();
    } else {
      final error =
          ref.read(detachmentMemberSelectionProvider).errorMessage;
      context.showSnackBar(error ?? 'فشل الحفظ',
          backgroundColor: AppColors.error);
    }
  }

  void _showAddMemberBottomSheet() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRole = 'volunteer';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusLg)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: AppSizes.md,
                left: AppSizes.marginMobile,
                right: AppSizes.marginMobile,
                bottom: MediaQuery.of(ctx).viewInsets.bottom +
                    AppSizes.marginMobile,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(
                            AppSizes.radiusFull),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  const Text(
                    'إضافة عضو',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo',
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  TextField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'الاسم *',
                      labelStyle:
                          const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppSizes.radiusDefault)),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: AppSizes.md),
                  DropdownButtonFormField<String>(
                    hint: const Text('الدور',
                        style: TextStyle(fontFamily: 'Cairo')),
                    items: const [
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('مشرف',
                            style: TextStyle(fontFamily: 'Cairo')),
                      ),
                      DropdownMenuItem(
                        value: 'volunteer',
                        child: Text('متطوع',
                            style: TextStyle(fontFamily: 'Cairo')),
                      ),
                      DropdownMenuItem(
                        value: 'representative',
                        child: Text('ممثل',
                            style: TextStyle(fontFamily: 'Cairo')),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setSheetState(
                            () => selectedRole = value);
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppSizes.radiusDefault)),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  TextField(
                    controller: phoneController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف (اختياري)',
                      labelStyle:
                          const TextStyle(fontFamily: 'Cairo'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppSizes.radiusDefault)),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSaving ||
                              nameController.text.trim().isEmpty
                          ? null
                          : () async {
                              setSheetState(
                                  () => isSaving = true);

                              final member =
                                  DetachmentMemberModel(
                                uid: '',
                                name:
                                    nameController.text.trim(),
                                role: selectedRole,
                                phone: phoneController
                                        .text
                                        .trim()
                                        .isEmpty
                                    ? null
                                    : phoneController.text
                                        .trim(),
                                isActive: true,
                                createdAt: DateTime.now(),
                              );

                              final result = await ref
                                  .read(
                                      detachmentNewRepoProvider)
                                  .addMember(member);

                              if (!ctx.mounted) return;
                              setSheetState(
                                  () => isSaving = false);

                              result.fold(
                                (failure) {
                                  if (!mounted) return;
                                  context.showSnackBar(
                                    'فشل: ${failure.message}',
                                    backgroundColor:
                                        AppColors.error,
                                  );
                                },
                                (_) {
                                  Navigator.of(ctx).pop();
                                  if (!mounted) return;
                                  context.showSnackBar(
                                      'تم إضافة العضو بنجاح');
                                },
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppSizes.radiusDefault),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onPrimary),
                            )
                          : const Text(
                              'حفظ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Cairo',
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayId =
        GoRouterState.of(context).pathParameters['dayId'] ?? '';
    final shiftId =
        GoRouterState.of(context).pathParameters['shiftId'] ?? '';
    final repo = ref.watch(detachmentNewRepoProvider);
    final selection = ref.watch(detachmentMemberSelectionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: StreamBuilder(
          stream: repo.watchShiftsForDay(dayId),
          builder: (context, snapshot) {
            final shifts = snapshot.data ?? [];
            final shift =
                shifts.where((s) => s.uid == shiftId).firstOrNull;
            return Text(
              shift?.shiftName ?? 'أعضاء الشفت',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              ),
            );
          },
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: selection.isSaving ? null : () => _save(shiftId),
            child: selection.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary),
                  )
                : const Text(
                    'حفظ',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.marginMobile),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'بحث عن عضو...',
                hintStyle: const TextStyle(fontFamily: 'Cairo'),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.onSurfaceVariant),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppColors.onSurfaceVariant),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(
                                  detachmentMemberSelectionProvider
                                      .notifier)
                              .setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusDefault),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm),
              ),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<DetachmentMemberModel>>(
              stream: repo.watchMembers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: AppColors.error),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          'حدث خطأ: ${snapshot.error}',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.md),
                        OutlinedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('إعادة المحاولة',
                              style:
                                  TextStyle(fontFamily: 'Cairo')),
                        ),
                      ],
                    ),
                  );
                }

                final allMembers = snapshot.data ?? [];

                if (allMembers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.group_off,
                            size: 64,
                            color: AppColors.onSurfaceVariant),
                        const SizedBox(height: AppSizes.md),
                        const Text(
                          'لا يوجد أعضاء مضافون',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 16,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        ElevatedButton.icon(
                          onPressed: _showAddMemberBottomSheet,
                          icon: const Icon(Icons.person_add,
                              color: AppColors.onPrimary),
                          label: const Text('إضافة أعضاء للمفرزة',
                              style:
                                  TextStyle(fontFamily: 'Cairo')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final filteredMembers =
                    selection.filterMembers(allMembers);

                if (filteredMembers.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد نتائج للبحث',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 16,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  );
                }

                final sorted = List<DetachmentMemberModel>.from(
                    filteredMembers)
                  ..sort((a, b) {
                    final aChecked =
                        selection.selectedMemberIds.contains(a.uid);
                    final bChecked =
                        selection.selectedMemberIds.contains(b.uid);
                    if (aChecked != bChecked) {
                      return aChecked ? -1 : 1;
                    }
                    return a.name.compareTo(b.name);
                  });

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    left: AppSizes.marginMobile,
                    right: AppSizes.marginMobile,
                    bottom: 80,
                  ),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    final member = sorted[index];
                    final isChecked = selection.selectedMemberIds
                        .contains(member.uid);

                    return Card(
                      color: isChecked
                          ? AppColors.primarySurface
                          : AppColors.surface,
                      elevation: 0,
                      margin:
                          const EdgeInsets.only(bottom: AppSizes.xs),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd),
                        side: BorderSide(
                          color: isChecked
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd),
                        onTap: () => ref
                            .read(
                                detachmentMemberSelectionProvider
                                    .notifier)
                            .toggleMember(member.uid),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.md,
                              vertical: AppSizes.sm),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    isChecked
                                        ? AppColors.primary
                                        : AppColors
                                            .onSurfaceVariant
                                            .withValues(alpha: 0.2),
                                radius: 20,
                                child: Text(
                                  member.name.isNotEmpty
                                      ? member.name[0]
                                      : '?',
                                  style: TextStyle(
                                    color: isChecked
                                        ? AppColors.onPrimary
                                        : AppColors
                                            .onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSizes.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight.w700,
                                        fontFamily: 'Cairo',
                                        color:
                                            AppColors.onSurface,
                                      ),
                                      overflow:
                                          TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      member.role == 'admin'
                                          ? 'مشرف'
                                          : member.role ==
                                                  'representative'
                                              ? 'ممثل'
                                              : 'متطوع',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Cairo',
                                        color: member.role ==
                                                'admin'
                                            ? AppColors
                                                .adminPurple
                                            : member.role ==
                                                    'representative'
                                                ? AppColors
                                                    .goldBright
                                                : AppColors
                                                    .volunteerBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Checkbox(
                                value: isChecked,
                                activeColor: AppColors.primary,
                                onChanged: (_) => ref
                                    .read(
                                        detachmentMemberSelectionProvider
                                            .notifier)
                                    .toggleMember(member.uid),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSizes.marginMobile),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
              top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Text(
              'تم اختيار ${selection.selectedMemberIds.length} عضو',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: selection.isSaving
                  ? null
                  : () => _save(shiftId),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      AppSizes.radiusDefault),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.lg,
                    vertical: AppSizes.sm),
              ),
              child: selection.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary),
                    )
                  : const Text(
                      'حفظ الشفت',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
