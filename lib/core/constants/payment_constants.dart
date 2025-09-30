import '../config/environment_config.dart';

/// Payment and subscription constants
class PaymentConstants {
  // CamPay Configuration
  static const String campayBaseUrl = 'https://api.campay.net/api';
  static String get campayApiKey => EnvironmentConfig.campayApiKey;
  static String get campayWebhookSecret => EnvironmentConfig.campayWebhookSecret;
  static String get campayRedirectUrl => '${EnvironmentConfig.baseUrl}/payment/callback';
  static String get campayWebhookUrl => '${EnvironmentConfig.baseUrl}/webhook/campay';

  // NouPai Configuration (Fallback)
  static const String noupaiBaseUrl = 'https://api.noupai.com/v1';
  static String get noupaiApiKey => EnvironmentConfig.noupaiApiKey;
  static String get noupaiWebhookSecret => EnvironmentConfig.noupaiWebhookSecret;
  static String get noupaiRedirectUrl => '${EnvironmentConfig.baseUrl}/payment/noupai/callback';
  static String get noupaiWebhookUrl => '${EnvironmentConfig.baseUrl}/webhook/noupai';

  // Subscription Plans
  static const Map<String, dynamic> freemiumPlan = {
    'id': 'freemium',
    'name': 'Freemium',
    'price': 0.0,
    'currency': 'FCFA',
    'features': [
      '5 lessons per month',
      'Basic games',
      'Community access',
    ],
  };

  static const Map<String, dynamic> premiumMonthlyPlan = {
    'id': 'premium_monthly',
    'name': 'Premium Mensuel',
    'price': 1500.0,
    'currency': 'FCFA',
    'features': [
      'Unlimited lessons',
      'AI Assistant',
      'All games',
      'Advanced community',
      'Certificates',
    ],
  };

  static const Map<String, dynamic> premiumAnnualPlan = {
    'id': 'premium_annual',
    'name': 'Premium Annuel',
    'price': 11000.0,
    'currency': 'FCFA',
    'originalPrice': 18000.0, // 12 * 1500
    'savings': 7000.0, // 39% discount
    'features': [
      'All monthly features',
      '7 months free (39% discount)',
      'Priority support',
      'Offline content download',
    ],
  };

  static const Map<String, dynamic> teacherPlan = {
    'id': 'teacher',
    'name': 'Enseignant',
    'price': 18000.0, // Updated to family price
    'currency': 'FCFA',
    'features': [
      'All premium features',
      'Create lessons',
      'Student management',
      'Analytics dashboard',
      'Up to 6 teacher accounts',
    ],
  };

  // Family Plan (same as teacher for now)
  static const Map<String, dynamic> familyPlan = {
    'id': 'family',
    'name': 'Famille',
    'price': 18000.0,
    'currency': 'FCFA',
    'features': [
      'All premium features',
      'Up to 6 family accounts',
      'Parental controls',
      'Family progress tracking',
      'Shared achievements',
    ],
  };

  // Payment Status
  static const String paymentPending = 'pending';
  static const String paymentCompleted = 'completed';
  static const String paymentFailed = 'failed';
  static const String paymentCancelled = 'cancelled';
}
