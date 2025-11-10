import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app's locale (language) setting
///
/// This provider:
/// - Loads saved language preference on startup
/// - Allows user to change language
/// - Saves preference for next time
/// - If no preference saved, uses system language
class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  static const String _localeKey = 'app_locale';

  /// Current locale, null means "use system language"
  Locale? get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  /// Load saved language preference from storage
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);

    if (localeCode != null && localeCode.isNotEmpty) {
      _locale = Locale(localeCode);
      notifyListeners();
    }
    // If null, system locale will be used automatically by Flutter
  }

  /// Change the app language
  /// Pass null to use system language
  Future<void> setLocale(Locale? locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners(); // This rebuilds the app with new language

    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      // Remove preference to use system locale
      await prefs.remove(_localeKey);
    } else {
      // Save language code (e.g., "en", "fr", "es")
      await prefs.setString(_localeKey, locale.languageCode);
    }
  }

  /// Reset to system language
  void clearLocale() {
    setLocale(null);
  }
}
