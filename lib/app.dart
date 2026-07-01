// lib/app.dart
// WHY: Root MaterialApp — sets up theme, localization, GoRouter, and providers.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/localization/locale_controller.dart';
import 'shared/repositories/post_repository.dart';
import 'shared/repositories/team_info_repository.dart';
import 'shared/repositories/detachment_repository.dart';
import 'features/detachment/repositories/detachment_repository.dart' as new_repo;
import 'shared/repositories/workshop_repository.dart';
import 'shared/repositories/support_repository.dart';
import 'shared/repositories/notification_repository.dart';
import 'shared/repositories/cms_repository.dart';
import 'shared/repositories/application_repository.dart';
import 'shared/repositories/dynamic_field_repository.dart';
import 'core/services/auth_service.dart';
import 'shared/models/user_schema.dart';
import 'l10n/app_localizations.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository();
});

final teamInfoRepositoryProvider = Provider<TeamInfoRepository>((ref) {
  return TeamInfoRepository();
});

final detachmentRepositoryProvider = Provider<DetachmentRepository>((ref) {
  return DetachmentRepository();
});

final workshopRepositoryProvider = Provider<WorkshopRepository>((ref) {
  return WorkshopRepository();
});

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepository();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final cmsRepositoryProvider = Provider<CmsRepository>((ref) {
  return CmsRepository();
});

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository();
});

final dynamicFieldRepositoryProvider = Provider<DynamicFieldRepository>((ref) {
  return DynamicFieldRepository();
});

final detachmentNewRepoProvider = Provider<new_repo.DetachmentRepository>((ref) {
  return new_repo.DetachmentRepository();
});

final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserSchema?>>((ref) {
  return CurrentUserNotifier();
});

class CurrentUserNotifier extends StateNotifier<AsyncValue<UserSchema?>> {
  CurrentUserNotifier() : super(const AsyncLoading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    state = AsyncData(user);
  }

  Future<void> refresh() async {
    final user = await AuthService.getCurrentUser();
    state = AsyncData(user);
  }

  void setUser(UserSchema? user) {
    state = AsyncData(user);
  }
}

class AlWallaApp extends ConsumerWidget {
  final String initialAccess;

  const AlWallaApp({super.key, required this.initialAccess});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider(initialAccess));

    final isArabic = locale.languageCode == 'ar';
    return MaterialApp.router(
      title: 'فريق الولاء الطبي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(isArabic: isArabic),
      locale: locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return const Locale('ar');
        for (final supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) {
            return supported;
          }
        }
        return const Locale('ar');
      },
      routerConfig: router,
    );
  }
}

final appRouterProvider = Provider.family<GoRouter, String>((ref, initialAccess) {
  return AppRouter.create(initialAccess: initialAccess);
});
