// lib/core/auth/session_watcher.dart
// WHY: Background timer that checks sub-admin session expiry every 15 minutes.
// Auto-signs out the user with a dialog when session expires while app is open.

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';

class SessionWatcher {
  Timer? _timer;
  final BuildContext context;
  final VoidCallback onSessionExpired;

  SessionWatcher({required this.context, required this.onSessionExpired});

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 15), (_) => _checkSession());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkSession() async {
    final uid = AuthService.currentUid;
    if (uid == null) return;
    if (uid == 'super_admin') return;

    try {
      final doc =
          await FirebaseFirestore.instance.collection('admins').doc(uid).get();

      if (!doc.exists) {
        onSessionExpired();
        return;
      }

      final data = doc.data()!;
      final isActive = data['isActive'] as bool? ?? true;
      final expiresAt =
          (data['sessionExpiresAt'] as Timestamp?)?.toDate();

      if (!isActive) {
        onSessionExpired();
        return;
      }

      if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
        onSessionExpired();
      }
    } catch (_) {
      // Silently fail — retry in 15 minutes
    }
  }

  static void showSessionExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('انتهت الجلسة'),
        content: const Text('انتهت صلاحية جلستك. ستحتاج إلى تسجيل الدخول مجدداً.'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await AuthService.logout();
            },
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}
