// lib/features/auth/presentation/widgets/session_expired_screen.dart
// WHY: Shown when a sub-admin's session expires while the app is open.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/routing/route_names.dart';

class SessionExpiredScreen extends StatelessWidget {
  const SessionExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_off, size: 80, color: Color(0xFFDC2626)),
              const SizedBox(height: 24),
              Text(
                'انتهت الجلسة',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'انتهت صلاحية جلستك. يرجى تسجيل الدخول مجدداً.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    await AuthService.logout();
                    if (context.mounted) {
                      context.go(RouteNames.login);
                    }
                  },
                  child: const Text('تسجيل الدخول'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}