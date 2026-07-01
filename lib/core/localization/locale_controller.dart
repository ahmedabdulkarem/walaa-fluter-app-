// lib/core/localization/locale_controller.dart
// WHY: Riverpod notifier for locale state — persists to SharedPreferences.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_strings.dart';

final localeProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController();
});

class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('ar')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(AppStrings.prefLocale) ?? 'ar';
    state = Locale(lang);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStrings.prefLocale, locale.languageCode);
  }

  bool get isArabic => state.languageCode == 'ar';
}
