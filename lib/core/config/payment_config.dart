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
    if (EnvironmentConfig.hasCampayConfig) {
      methods.add('campay');
    }
    if (EnvironmentConfig.hasNoupaiConfig) {
      methods.add('noupai');
    }
    if (EnvironmentConfig.hasStripeConfig) {
      methods.add('stripe');
    }
    return methods;
  }

  static bool get supportsCamPay => EnvironmentConfig.hasCampayConfig;
  static bool get supportsNouPai => EnvironmentConfig.hasNoupaiConfig;
  static bool get supportsStripe => EnvironmentConfig.hasStripeConfig;

  static String get primaryPaymentMethod {
    if (supportsCamPay) return 'campay';
    if (supportsNouPai) return 'noupai';
    if (supportsStripe) return 'stripe';
    return 'none';
  }

  static String get fallbackPaymentMethod {
    if (supportsNouPai) return 'noupai';
    if (supportsStripe) return 'stripe';
    return 'none';
  }

  static Map<String, String> get paymentMethodNames => {
    'campay': 'CamPay (Mobile Money)',
    'noupai': 'NouPai (Mobile Money)',
    'stripe': 'Carte Bancaire (Stripe)',
  };

  static Map<String, String> get paymentMethodDescriptions => {
    'campay': 'MTN Mobile Money, Orange Money',
    'noupai': 'Mobile Money alternatif',
    'stripe': 'Visa, Mastercard, American Express',
  };

  static String getPaymentMethodDisplayName(String method) {
    return paymentMethodNames[method] ?? method;
  }

  static String getPaymentMethodDescription(String method) {
    return paymentMethodDescriptions[method] ?? '';
  }

  /// Determine which payment method to use based on amount and availability
  static String selectPaymentMethod({
    required double amount,
    String? preferredMethod,
  }) {
    // If preferred method is available, use it
    if (preferredMethod != null &&
        availablePaymentMethods.contains(preferredMethod)) {
      return preferredMethod;
    }

    // For international payments or large amounts, prefer Stripe
    if (supportsStripe && amount > 100000) {
      return 'stripe';
    }

    // Otherwise use primary method
    return primaryPaymentMethod;
  }
}
