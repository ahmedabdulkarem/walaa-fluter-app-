import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_app_bar.dart';

class DetachmentHistoryPage extends ConsumerWidget {
  const DetachmentHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppAppBar(context: context, title: 'سجل المفارز'),
      body: const Center(
        child: Text(
          'قريباً',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
