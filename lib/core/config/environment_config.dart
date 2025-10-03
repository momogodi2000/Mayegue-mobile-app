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

  // Stripe Payment Gateway (International)
  static String get stripePublishableKey =>
      dotenv.get('STRIPE_PUBLISHABLE_KEY', fallback: '');
  static String get stripeSecretKey =>
      dotenv.get('STRIPE_SECRET_KEY', fallback: '');
  static String get stripeWebhookSecret =>
      dotenv.get('STRIPE_WEBHOOK_SECRET', fallback: '');

  // Base URL
  static String get baseUrl =>
      dotenv.get('BASE_URL', fallback: 'https://mayegue.app');

  // App Configuration
  static String get appEnv => dotenv.get('APP_ENV', fallback: 'development');
  static String get appName => dotenv.get('APP_NAME', fallback: 'Mayegue');
  static String get appVersion => dotenv.get('APP_VERSION', fallback: '1.0.0');

  // Default Admin Configuration
  static String get defaultAdminEmail =>
      dotenv.get('DEFAULT_ADMIN_EMAIL', fallback: 'admin@mayegue.app');
  static String get defaultAdminPassword =>
      dotenv.get('DEFAULT_ADMIN_PASSWORD', fallback: '');
  static String get defaultAdminName =>
      dotenv.get('DEFAULT_ADMIN_NAME', fallback: 'Administrateur');

  // Security
  static String get jwtSecret => dotenv.get('JWT_SECRET', fallback: '');
  static String get encryptionKey => dotenv.get('ENCRYPTION_KEY', fallback: '');

  // Feature Flags
  static bool get enable2FA =>
      dotenv.get('ENABLE_2FA', fallback: 'true').toLowerCase() == 'true';
  static bool get enableGoogleAuth =>
      dotenv.get('ENABLE_GOOGLE_AUTH', fallback: 'true').toLowerCase() ==
      'true';
  static bool get enableFacebookAuth =>
      dotenv.get('ENABLE_FACEBOOK_AUTH', fallback: 'true').toLowerCase() ==
      'true';
  static bool get enablePhoneAuth =>
      dotenv.get('ENABLE_PHONE_AUTH', fallback: 'true').toLowerCase() == 'true';
  static bool get enableAiAssistant =>
      dotenv.get('ENABLE_AI_ASSISTANT', fallback: 'true').toLowerCase() ==
      'true';
  static bool get enableOfflineMode =>
      dotenv.get('ENABLE_OFFLINE_MODE', fallback: 'true').toLowerCase() ==
      'true';

  // Newsletter & Marketing
  static String get emailServiceApiKey =>
      dotenv.get('EMAIL_SERVICE_API_KEY', fallback: '');
  static String get newsletterListId =>
      dotenv.get('NEWSLETTER_LIST_ID', fallback: '');

  // Validation
  static bool get isProduction => appEnv == 'production';
  static bool get isDevelopment => appEnv == 'development';

  static bool get hasValidPaymentConfig =>
      (campayApiKey.isNotEmpty && campaySecret.isNotEmpty) ||
      noupaiApiKey.isNotEmpty ||
      stripePublishableKey.isNotEmpty;

  static bool get hasStripeConfig =>
      stripePublishableKey.isNotEmpty && stripeSecretKey.isNotEmpty;

  static bool get hasCampayConfig =>
      campayApiKey.isNotEmpty && campaySecret.isNotEmpty;

  static bool get hasNoupaiConfig => noupaiApiKey.isNotEmpty;
}
