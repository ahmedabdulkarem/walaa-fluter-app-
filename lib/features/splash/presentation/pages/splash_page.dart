// lib/features/splash/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';

class SplashPage extends StatefulWidget {
  final String initialAccess;

  const SplashPage({super.key, required this.initialAccess});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigate());
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    if (widget.initialAccess == 'super_admin' ||
        widget.initialAccess == 'sub_admin') {
      GoRouter.of(context).go(RouteNames.dashboard);
    } else {
      GoRouter.of(context).go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.medical_services,
                size: 80, color: Color(0xFF6D28D9)),
            const SizedBox(height: 24),
            const Text(
              'فريق الولاء الطبي',
              style: TextStyle(
                color: Color(0xFF6D28D9),
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Al-Walaa Medical Team',
                style: TextStyle(fontFamily: 'Cairo')),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Color(0xFF6D28D9)),
          ],
        ),
      ),
    );
  }
}
