import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../shared/models/support_ticket_schema.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../app.dart';

class SupportFormPage extends ConsumerStatefulWidget {
  const SupportFormPage({super.key});

  @override
  ConsumerState<SupportFormPage> createState() => _SupportFormPageState();
}

class _SupportFormPageState extends ConsumerState<SupportFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = '\u0645\u0634\u0643\u0644\u0629 \u062A\u0642\u0646\u064A\u0629';
  bool _isSaving = false;

  static const List<String> _categories = [
    '\u0645\u0634\u0643\u0644\u0629 \u062A\u0642\u0646\u064A\u0629',
    '\u0627\u0633\u062A\u0641\u0633\u0627\u0631',
    '\u0627\u0642\u062A\u0631\u0627\u062D',
    '\u0634\u0643\u0648\u0649',
    '\u0637\u0644\u0628',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final uid = AuthService.currentUid;
    if (uid == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('\u064A\u062C\u0628 \u062A\u0633\u062C\u064A\u0644 \u0627\u0644\u062F\u062E\u0648\u0644 \u0623\u0648\u0644\u0627\u064B')),
      );
      return;
    }

    final user = await AuthService.getUserByUid(uid);
    final now = DateTime.now();
    final ticketUid = 'ticket_${now.millisecondsSinceEpoch}';

    final ticket = SupportTicketSchema()
      ..uid = ticketUid
      ..subject = _subjectController.text.trim()
      ..message = _messageController.text.trim()
      ..category = _selectedCategory
      ..createdBy = uid
      ..createdByName = user?.displayName ?? ''
      ..status = 'open'
      ..createdAt = now
      ..updatedAt = now;

    final result = await ref.read(supportRepositoryProvider).createTicket(ticket);

    if (!mounted) return;
    setState(() => _isSaving = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('\u0641\u0634\u0644 \u0625\u0646\u0634\u0627\u0621 \u0627\u0644\u062A\u0630\u0643\u0631\u0629: ${failure.message}')),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('\u062A\u0645 \u0625\u0646\u0634\u0627\u0621 \u0627\u0644\u062A\u0630\u0643\u0631\u0629 \u0628\u0646\u062C\u0627\u062D')),
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
        title: '\u062A\u0630\u0643\u0631\u0629 \u062C\u062F\u064A\u062F\u0629',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.marginMobile),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: '\u0627\u0644\u0645\u0648\u0636\u0648\u0639',
                  prefixIcon: Icon(Icons.title_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '\u0627\u0644\u0645\u0648\u0636\u0648\u0639 \u0645\u0637\u0644\u0648\u0628' : null,
              ),
              const SizedBox(height: AppSizes.md),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: '\u0627\u0644\u062A\u0635\u0646\u064A\u0641',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontFamily: 'Cairo')));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: AppSizes.md),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: '\u0627\u0644\u0631\u0633\u0627\u0644\u0629',
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '\u0627\u0644\u0631\u0633\u0627\u0644\u0629 \u0645\u0637\u0644\u0648\u0628\u0629' : null,
              ),
              const SizedBox(height: AppSizes.lg),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
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
                          '\u0625\u0631\u0633\u0627\u0644',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
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
