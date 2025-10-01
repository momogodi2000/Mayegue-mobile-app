import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mayegue/shared/providers/theme_provider.dart';

void main() {
  late ThemeProvider themeProvider;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    themeProvider = ThemeProvider();
    await themeProvider.initialize();
  });

  group('ThemeProvider', () {
    test('defaults to light theme', () {
      expect(themeProvider.isDarkMode, isFalse);
      expect(themeProvider.themeMode, equals(ThemeMode.light));
    });

    test('persists theme mode change', () async {
      await themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.isDarkMode, isTrue);
      expect(themeProvider.themeMode, equals(ThemeMode.dark));
      expect(prefs.getBool('is_dark_mode'), isTrue);
    });

    test('loads persisted theme mode on initialization', () async {
      await prefs.setBool('is_dark_mode', true);
      await themeProvider.initialize();
      expect(themeProvider.isDarkMode, isTrue);
      expect(themeProvider.themeMode, equals(ThemeMode.dark));
    });

    test('toggles between light and dark mode', () async {
      expect(themeProvider.isDarkMode, isFalse);
      expect(themeProvider.themeMode, equals(ThemeMode.light));

      await themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.isDarkMode, isTrue);
      expect(themeProvider.themeMode, equals(ThemeMode.dark));

      await themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.isDarkMode, isFalse);
      expect(themeProvider.themeMode, equals(ThemeMode.light));
    });

    test('notifies listeners on theme change', () async {
      var notified = false;
      themeProvider.addListener(() => notified = true);
      await themeProvider.setThemeMode(ThemeMode.dark);
      expect(notified, isTrue);
    });
  });

  group('Theme Data', () {
    testWidgets('applies light theme correctly', (tester) async {
      themeProvider.setThemeMode(ThemeMode.light);

      await tester.pumpWidget(
        MaterialApp(
          theme: themeProvider.currentTheme,
          themeMode: themeProvider.themeMode,
          home: const Scaffold(
            body: Text('Test'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(Colors.white));
    });

    testWidgets('applies dark theme correctly', (tester) async {
      themeProvider.setThemeMode(ThemeMode.dark);

      await tester.pumpWidget(
        MaterialApp(
          theme: themeProvider.currentTheme,
          themeMode: themeProvider.themeMode,
          home: const Scaffold(
            body: Text('Test'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(Colors.black));
    });

    testWidgets('updates UI when theme changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: themeProvider.currentTheme,
          themeMode: themeProvider.themeMode,
          home: const Scaffold(
            body: Text('Test'),
          ),
        ),
      );

      final initialScaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(initialScaffold.backgroundColor, equals(Colors.white));

      await themeProvider.setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();

      final updatedScaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(updatedScaffold.backgroundColor, equals(Colors.black));
    });

    testWidgets('handles theme data customization', (tester) async {
      final customLightTheme = themeProvider.currentTheme.copyWith(
        primaryColor: Colors.blue,
        colorScheme: const ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: customLightTheme,
          themeMode: themeProvider.themeMode,
          home: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return Text(
                'Test',
                style: TextStyle(color: theme.primaryColor),
              );
            },
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Test'));
      expect(text.style?.color, equals(Colors.blue));

      await themeProvider.setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();

      final updatedText = tester.widget<Text>(find.text('Test'));
      expect(updatedText.style?.color, equals(Colors.blue));
    });
  });
}