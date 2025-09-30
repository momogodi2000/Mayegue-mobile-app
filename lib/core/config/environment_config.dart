import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

/// Environment configuration class
class EnvironmentConfig {
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      await dotenv.load(fileName: '.env');
      _isInitialized = true;
      if (kDebugMode) {
        print('Environment configuration loaded successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print(
          'Warning: .env file not found or could not be loaded. Using default values.',
        );
        print('Error: $e');
      }
      // Initialize with empty values to prevent crashes
      _isInitialized = true;
    }
  }

  // Firebase Configuration
  static String get firebaseApiKey =>
      dotenv.get('FIREBASE_API_KEY', fallback: '');
  static String get firebaseAuthDomain =>
      dotenv.get('FIREBASE_AUTH_DOMAIN', fallback: '');
  static String get firebaseProjectId =>
      dotenv.get('FIREBASE_PROJECT_ID', fallback: '');
  static String get firebaseStorageBucket =>
      dotenv.get('FIREBASE_STORAGE_BUCKET', fallback: '');
  static String get firebaseMessagingSenderId =>
      dotenv.get('FIREBASE_MESSAGING_SENDER_ID', fallback: '');
  static String get firebaseAppId =>
      dotenv.get('FIREBASE_APP_ID', fallback: '');

  // Gemini AI Configuration
  static String get geminiApiKey => dotenv.get('GEMINI_API_KEY', fallback: '');

  // CamPay Payment Gateway
  static String get campayBaseUrl =>
      dotenv.get('CAMPAY_BASE_URL', fallback: 'https://api.campay.net');
  static String get campayApiKey => dotenv.get('CAMPAY_API_KEY', fallback: '');
  static String get campaySecret => dotenv.get('CAMPAY_SECRET', fallback: '');
  static String get campayWebhookSecret =>
      dotenv.get('CAMPAY_WEBHOOK_SECRET', fallback: '');

  // NouPai Payment Gateway
  static String get noupaiBaseUrl =>
      dotenv.get('NOUPAI_BASE_URL', fallback: 'https://api.noupai.com');
  static String get noupaiApiKey => dotenv.get('NOUPAI_API_KEY', fallback: '');
  static String get noupaiWebhookSecret =>
      dotenv.get('NOUPAI_WEBHOOK_SECRET', fallback: '');

  // Base URL
  static String get baseUrl =>
      dotenv.get('BASE_URL', fallback: 'https://mayegue.app');

  // App Configuration
  static String get appEnv => dotenv.get('APP_ENV', fallback: 'development');
  static String get appName => dotenv.get('APP_NAME', fallback: 'Mayegue');
  static String get appVersion => dotenv.get('APP_VERSION', fallback: '1.0.0');

  // Validation
  static bool get isProduction => appEnv == 'production';
  static bool get isDevelopment => appEnv == 'development';

  static bool get hasValidPaymentConfig =>
      campayApiKey.isNotEmpty && campaySecret.isNotEmpty ||
      noupaiApiKey.isNotEmpty;
}
