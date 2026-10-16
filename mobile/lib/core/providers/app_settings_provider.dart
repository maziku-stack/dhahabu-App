import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider extends ChangeNotifier {
  static const _languageKey = 'app_language';
  static const _themeKey = 'app_dark_mode';

  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.dark;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get isSwahili => _locale.languageCode == 'sw';
  bool get isDark => _themeMode == ThemeMode.dark;

  AppSettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    _locale = Locale(preferences.getString(_languageKey) ?? 'en');
    _themeMode = (preferences.getBool(_themeKey) ?? true)
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageKey, languageCode);
  }

  Future<void> toggleTheme() async {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_themeKey, isDark);
  }
}
