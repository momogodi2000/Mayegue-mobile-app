import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _prefsKey = 'app_locale_code';

  Locale _locale = const Locale('fr');
  bool _initialized = false;

  Locale get locale => _locale;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefsKey);
      if (code != null && code.isNotEmpty) {
        _locale = Locale(code);
      }
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> toggleLocale() async {
    await setLocale(
      _locale.languageCode == 'fr' ? const Locale('en') : const Locale('fr'),
    );
  }
}
