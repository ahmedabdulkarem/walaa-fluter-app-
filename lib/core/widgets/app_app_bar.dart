// lib/core/widgets/app_app_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';

PreferredSizeWidget buildAppAppBar({
  required BuildContext context,
  String? title,
  List<Widget>? actions,
  bool showNotificationBadge = true,
}) {
  return AppBar(
    backgroundColor: AppColors.background,
    elevation: 0,
    scrolledUnderElevation: 0,
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, color: AppColors.divider),
    ),
    leading: IconButton(
      icon: const Icon(Icons.menu, color: AppColors.primary),
      onPressed: () => Scaffold.of(context).openDrawer(),
    ),
    title: Text(
      title ?? '\u0641\u0631\u064A\u0642 \u0627\u0644\u0648\u0644\u0627\u0621 \u0627\u0644\u0637\u0628\u064A',
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: 'Cairo',
      ),
    ),
    centerTitle: true,
    actions: [
      Stack(children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
          onPressed: () => context.push('/notifications'),
        ),
        if (showNotificationBadge)
          const Positioned(
            top: 12,
            right: 12,
            child: CircleAvatar(
              radius: 4,
              backgroundColor: AppColors.goldBright,
            ),
          ),
      ]),
      ...?actions,
    ],
  );
}
