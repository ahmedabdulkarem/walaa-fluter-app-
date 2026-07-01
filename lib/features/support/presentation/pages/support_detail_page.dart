import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../shared/models/support_ticket_schema.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../app.dart';

class SupportDetailPage extends ConsumerStatefulWidget {
  final String ticketId;
  const SupportDetailPage({super.key, required this.ticketId});

  @override
  ConsumerState<SupportDetailPage> createState() => _SupportDetailPageState();
}

class _SupportDetailPageState extends ConsumerState<SupportDetailPage> {
  SupportTicketSchema? _ticket;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSuperAdmin = false;

  late TextEditingController _responseController;
  late TextEditingController _assignController;
  String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    _responseController = TextEditingController();
    _assignController = TextEditingController();
    _loadTicket();
  }

  @override
  void dispose() {
    _responseController.dispose();
    _assignController.dispose();
    super.dispose();
  }

  Future<void> _loadTicket() async {
    final uid = AuthService.currentUid;
    if (uid == null) return;

    final user = await AuthService.getUserByUid(uid);
    if (!mounted) return;

    setState(() {
      _isSuperAdmin = user?.isSuperAdmin ?? false;
    });

    final stream = ref.read(supportRepositoryProvider).streamAllTickets();
    stream.first.then((tickets) {
      if (!mounted) return;
      final ticket = tickets.cast<SupportTicketSchema?>().firstWhere(
        (t) => t!.uid == widget.ticketId,
        orElse: () => null,
      );
      setState(() {
        _ticket = ticket;
        _selectedStatus = ticket?.status ?? 'open';
        _responseController.text = ticket?.response ?? '';
        _assignController.text = ticket?.assignedTo ?? '';
        _isLoading = false;
      });
    });
  }

  Future<void> _save() async {
    if (_ticket == null) return;
    setState(() => _isSaving = true);

    final updates = <String, dynamic>{};
    if (_selectedStatus != _ticket!.status) {
      updates['status'] = _selectedStatus;
    }
    if (_responseController.text.trim() != (_ticket!.response ?? '')) {
      updates['response'] = _responseController.text.trim();
    }
    if (_assignController.text.trim() != (_ticket!.assignedTo ?? '')) {
      updates['assignedTo'] = _assignController.text.trim();
    }

    if (updates.isEmpty) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('\u0644\u0627 \u062A\u0648\u062C\u062F \u062A\u063A\u064A\u064A\u0631\u0627\u062A')),
      );
      return;
    }

    final result = await ref
        .read(supportRepositoryProvider)
        .updateTicket(_ticket!.id, updates);

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('\u0641\u0634\u0644 \u0627\u0644\u062D\u0641\u0638: ${failure.message}')),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('\u062A\u0645 \u0627\u0644\u062D\u0641\u0638 \u0628\u0646\u062C\u0627\u062D')),
        );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppAppBar(
        context: context,
        title: '\u062A\u0641\u0627\u0635\u064A\u0644 \u0627\u0644\u062A\u0630\u0643\u0631\u0629',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ticket == null
              ? Center(
                  child: Text(
                    '\u0644\u0645 \u064A\u062A\u0645 \u0627\u0644\u0639\u062B\u0648\u0631 \u0639\u0644\u0649 \u0627\u0644\u062A\u0630\u0643\u0631\u0629',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.marginMobile),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _ticket!.subject,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ),
                                _statusBadge(TicketStatus.fromString(_ticket!.status)),
                              ],
                            ),
                            const SizedBox(height: AppSizes.sm),
                            _infoRow(Icons.person_outline, _ticket!.createdByName),
                            const SizedBox(height: 4),
                            _infoRow(Icons.category_outlined, _ticket!.category),
                            const SizedBox(height: 4),
                            _infoRow(Icons.schedule, DateFormatters.formatDateTime(
                                _ticket!.createdAt ?? DateTime.now())),
                            if (_ticket!.assignedTo != null && _ticket!.assignedTo!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              _infoRow(Icons.person_pin_outlined, _ticket!.assignedTo!),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '\u0627\u0644\u0631\u0633\u0627\u0644\u0629',
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSizes.sm),
                            Text(
                              _ticket!.message,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: 'Cairo',
                                color: AppColors.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_ticket!.response != null && _ticket!.response!.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.md),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.reply_outlined,
                                      size: 18, color: AppColors.success),
                                  const SizedBox(width: 6),
                                  const Text(
                                    '\u0627\u0644\u0631\u062F',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.sm),
                              Text(
                                _ticket!.response!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Cairo',
                                  color: AppColors.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_isSuperAdmin) ...[
                        const SizedBox(height: AppSizes.md),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '\u0625\u062F\u0627\u0631\u0629 \u0627\u0644\u062A\u0630\u0643\u0631\u0629',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: AppSizes.md),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedStatus,
                                decoration: const InputDecoration(
                                  labelText: '\u0627\u0644\u062D\u0627\u0644\u0629',
                                ),
                                items: TicketStatus.values.map((status) {
                                  String label;
                                  switch (status) {
                                    case TicketStatus.open:
                                      label = '\u0645\u0641\u062A\u0648\u062D';
                                    case TicketStatus.inProgress:
                                      label = '\u0642\u064A\u062F \u0627\u0644\u0645\u0639\u0627\u0644\u062C\u0629';
                                    case TicketStatus.resolved:
                                      label = '\u062A\u0645 \u0627\u0644\u062D\u0644';
                                    case TicketStatus.closed:
                                      label = '\u0645\u063A\u0644\u0642';
                                  }
                                  return DropdownMenuItem(
                                    value: status.toFirestore,
                                    child: Text(label, style: const TextStyle(fontFamily: 'Cairo')),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) setState(() => _selectedStatus = value);
                                },
                              ),
                              const SizedBox(height: AppSizes.md),
                              TextFormField(
                                controller: _assignController,
                                decoration: const InputDecoration(
                                  labelText: '\u062A\u0639\u064A\u064A\u0646 \u0644\u0640',
                                  prefixIcon: Icon(Icons.person_pin_outlined),
                                ),
                              ),
                              const SizedBox(height: AppSizes.md),
                              TextFormField(
                                controller: _responseController,
                                decoration: const InputDecoration(
                                  labelText: '\u0627\u0644\u0631\u062F',
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSizes.lg),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              disabledBackgroundColor: AppColors.primaryContainer,
                              disabledForegroundColor: AppColors.onPrimaryContainer,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.onPrimary,
                                    ),
                                  )
                                : const Text(
                                    '\u062D\u0641\u0638 \u0627\u0644\u062A\u063A\u064A\u064A\u0631\u0627\u062A',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Cairo',
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'Cairo',
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
