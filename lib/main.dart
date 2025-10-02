import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/router.dart';
import 'core/config/environment_config.dart';
import 'core/database/database_initialization_service.dart';
import 'core/database/data_seeding_service.dart';
import 'shared/providers/app_providers.dart';
import 'shared/themes/app_theme.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/providers/locale_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  try {
    await EnvironmentConfig.init();
  } catch (e) {
    debugPrint('Error initializing environment config: $e');
    // Continue without environment config - app should still work
  }

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Initialize Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
    // Continue without Firebase - app should work in offline mode
  }

  // Initialize databases and seed data with improved error handling
  bool databasesInitialized = false;
  try {
    // Initialize the pre-built Cameroon languages database
    await DatabaseInitializationService.database;

    // Seed the main app database with initial data
    await DataSeedingService.seedDatabase();

    databasesInitialized = true;
    debugPrint('Databases initialized successfully');
  } catch (e) {
    // Log error but don't crash the app
    debugPrint('Error initializing databases: $e');
    // App will continue with limited functionality
  }

  runApp(MyApp(databasesInitialized: databasesInitialized));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.databasesInitialized = false});

  final bool databasesInitialized;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders,
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return FutureBuilder<void>(
            future: Future.wait([
              themeProvider.isInitialized
                  ? Future.value()
                  : themeProvider.initialize(),
              localeProvider.isInitialized
                  ? Future.value()
                  : localeProvider.initialize(),
            ]),
            builder: (context, snapshot) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Ma\'a yegue',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                routerConfig: AppRouter.createRouter(),
                locale: localeProvider.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('en'), Locale('fr')],
              );
            },
          );
        },
      ),
    );
  }
}
