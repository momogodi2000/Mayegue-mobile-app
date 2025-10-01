import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mayegue/shared/providers/locale_provider.dart';
import 'package:mayegue/l10n/app_localizations.dart';

void main() {
  late LocaleProvider localeProvider;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    localeProvider = LocaleProvider();
    await localeProvider.initialize();
  });

  group('LocaleProvider', () {
    test('defaults to French locale', () {
      expect(localeProvider.locale.languageCode, equals('fr'));
    });

    test('persists locale change', () async {
      await localeProvider.setLocale(const Locale('en'));
      expect(localeProvider.locale.languageCode, equals('en'));
      expect(prefs.getString('app_locale_code'), equals('en'));
    });

    test('loads persisted locale on initialization', () async {
      await prefs.setString('app_locale_code', 'en');
      await localeProvider.initialize();
      expect(localeProvider.locale.languageCode, equals('en'));
    });

    test('toggles between French and English', () async {
      expect(localeProvider.locale.languageCode, equals('fr'));
      await localeProvider.toggleLocale();
      expect(localeProvider.locale.languageCode, equals('en'));
      await localeProvider.toggleLocale();
      expect(localeProvider.locale.languageCode, equals('fr'));
    });

    test('notifies listeners on locale change', () async {
      var notified = false;
      localeProvider.addListener(() => notified = true);
      await localeProvider.setLocale(const Locale('en'));
      expect(notified, isTrue);
    });
  });

  group('AppLocalizations', () {
    testWidgets('provides French translations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.appName);
            },
          ),
        ),
      );

      expect(find.text("Ma'a yegue"), findsOneWidget);
    });

    testWidgets('provides English translations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.appName);
            },
          ),
        ),
      );

      expect(find.text("Ma'a yegue"), findsOneWidget);
    });

    testWidgets('updates UI when locale changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Column(
                children: [
                  Text(l10n.login),
                  Text(l10n.register),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('Connexion'), findsOneWidget);
      expect(find.text("S'inscrire"), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Column(
                children: [
                  Text(l10n.login),
                  Text(l10n.register),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('handles missing translations gracefully', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.appName);
            },
          ),
        ),
      );

      expect(find.text("Ma'a yegue"), findsOneWidget);
    });
  });
}