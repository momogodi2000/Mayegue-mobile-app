import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mayegue/shared/providers/locale_provider.dart';

void main() {
  late LocaleProvider localeProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    localeProvider = LocaleProvider();
    await localeProvider.initialize();
  });

  group('LocaleProvider', () {
    test('defaults to French locale', () {
      expect(localeProvider.locale.languageCode, 'fr');
    });

    test('setLocale changes locale', () async {
      await localeProvider.setLocale(const Locale('en'));
      expect(localeProvider.locale.languageCode, 'en');
    });

    test('toggleLocale switches between French and English', () async {
      expect(localeProvider.locale.languageCode, 'fr');
      await localeProvider.toggleLocale();
      expect(localeProvider.locale.languageCode, 'en');
      await localeProvider.toggleLocale();
      expect(localeProvider.locale.languageCode, 'fr');
    });

    test('locale persists after restart', () async {
      await localeProvider.setLocale(const Locale('en'));

      // Create new instance to simulate app restart
      final newProvider = LocaleProvider();
      await newProvider.initialize();

      expect(newProvider.locale.languageCode, 'en');
    });

    test('notifies listeners on locale change', () async {
      var notified = false;
      localeProvider.addListener(() => notified = true);

      await localeProvider.setLocale(const Locale('en'));
      expect(notified, true);
    });
  });
}
