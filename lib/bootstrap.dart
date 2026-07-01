// lib/bootstrap.dart
// WHY: Checks device access level, then launches app with correct route.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/auth_service.dart';

Future<void> bootstrap() async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  ErrorWidget.builder = (details) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error: ${details.exception}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  };

  final access = await AuthService.checkAccess();

  runApp(
    ProviderScope(
      child: AlWallaApp(initialAccess: access),
    ),
  );
}
