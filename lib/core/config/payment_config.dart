import '../config/environment_config.dart';

/// Payment configuration validation and setup
class PaymentConfig {
  static bool get isConfigured => EnvironmentConfig.hasValidPaymentConfig;

  static String? get configurationError {
    if (!isConfigured) {
      return 'Payment configuration is incomplete. Please check your .env file for CamPay or NouPai API keys.';
    }
    return null;
  }

  static List<String> get availablePaymentMethods {
    final methods = <String>[];
    if (EnvironmentConfig.campayApiKey.isNotEmpty && EnvironmentConfig.campaySecret.isNotEmpty) {
      methods.add('campay');
    }
    if (EnvironmentConfig.noupaiApiKey.isNotEmpty) {
      methods.add('noupai');
    }
    return methods;
  }

  static bool get supportsCamPay => EnvironmentConfig.campayApiKey.isNotEmpty && EnvironmentConfig.campaySecret.isNotEmpty;
  static bool get supportsNouPai => EnvironmentConfig.noupaiApiKey.isNotEmpty;

  static String get primaryPaymentMethod {
    if (supportsCamPay) return 'campay';
    if (supportsNouPai) return 'noupai';
    return 'none';
  }

  static Map<String, String> get paymentMethodNames => {
    'campay': 'CamPay',
    'noupai': 'NouPai',
  };

  static String getPaymentMethodDisplayName(String method) {
    return paymentMethodNames[method] ?? method;
  }
}