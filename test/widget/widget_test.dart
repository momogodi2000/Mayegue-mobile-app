// Widget tests for the Mayegue app
//
// This test suite covers the main app widget and core UI components.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mayegue/main.dart';
import 'package:mayegue/shared/providers/app_providers.dart';
import 'package:mayegue/core/config/environment_config.dart';

void main() {
  setUpAll(() async {
    // Initialize environment config for tests
    await EnvironmentConfig.init();
  });

  testWidgets('MyApp builds and shows initial screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: getProviders(),
        child: const MyApp(),
      ),
    );

    // Wait for initialization
    await tester.pumpAndSettle();

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);

    // Check for common UI elements that should be present
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('MyApp supports localization', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: getProviders(),
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify localization is set up
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.localizationsDelegates, isNotNull);
    expect(materialApp.supportedLocales, isNotEmpty);
    expect(materialApp.supportedLocales, contains(const Locale('en')));
    expect(materialApp.supportedLocales, contains(const Locale('fr')));
  });

  testWidgets('MyApp has proper theme configuration', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: getProviders(),
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify theme is configured
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme, isNotNull);
    expect(materialApp.darkTheme, isNotNull);
    expect(materialApp.themeMode, isNotNull);
  });

  testWidgets('MyApp has router configuration', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: getProviders(),
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify router is configured
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.routerConfig, isNotNull);
  });

  testWidgets('MyApp handles debug banner correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: getProviders(),
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // In debug mode, banner should be hidden
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.debugShowCheckedModeBanner, isFalse);
  });
}
