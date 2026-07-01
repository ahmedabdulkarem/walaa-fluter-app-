// lib/features/language/presentation/pages/language_selection_page.dart
// WHY: Language selection on first launch — chooses AR or EN before login.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/routing/route_names.dart';

class LanguageSelectionPage extends ConsumerWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.translate, size: 64, color: Color(0xFF6D28D9)),
              const SizedBox(height: 24),
              Text(
                'اختر اللغة',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Text('Choose Language'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(localeProvider.notifier).setLocale(const Locale('ar'));
                    context.go(RouteNames.splash);
                  },
                  child: const Text('العربية (Arabic)'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                    context.go(RouteNames.splash);
                  },
                  child: const Text('English'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}