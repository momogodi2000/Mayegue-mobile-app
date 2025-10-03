import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/config/environment_config.dart';
import 'campay_datasource.dart';

/// Stripe implementation for international credit card payments
class StripeDataSourceImpl implements PaymentDataSource {
  final DioClient dioClient;
  static const String baseUrl = 'https://api.stripe.com/v1';

  StripeDataSourceImpl(this.dioClient);

  @override
  Future<Map<String, dynamic>> initiatePayment({
    required String phoneNumber,
    required double amount,
    required String description,
    required String externalReference,
    String? currency = 'XAF',
  }) async {
    try {
      // Validate inputs
      if (amount <= 0) {
        throw Exception('Amount must be greater than 0');
      }

      // Stripe requires amount in smallest currency unit (cents for USD, centimes for XAF)
      final int amountInCents = (amount * 100).round();

      // Create a payment intent
      final response = await dioClient.dio.post(
        '$baseUrl/payment_intents',
        data: {
          'amount': amountInCents,
          'currency': currency?.toLowerCase() ?? 'xaf',
          'description': description,
          'metadata': {'external_reference': externalReference},
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${EnvironmentConfig.stripeSecretKey}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (kDebugMode) {
        print('Stripe payment initiated successfully');
      }

      return {
        'status': 'pending',
        'transaction_id': response.data['id'],
        'reference': externalReference,
        'client_secret': response.data['client_secret'],
        'amount': amount,
        'currency': currency,
        'provider': 'stripe',
        'payment_url': null, // Stripe uses client-side SDK
        'expires_at': DateTime.now()
            .add(const Duration(hours: 1))
            .toIso8601String(),
      };
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Stripe payment initiation failed: ${e.message}');
        print('Response: ${e.response?.data}');
      }

      if (e.response?.statusCode == 401) {
        throw Exception('Invalid Stripe API credentials');
      } else if (e.response?.statusCode == 400) {
        throw Exception(
          'Invalid payment parameters: ${e.response?.data?['error']?['message'] ?? 'Unknown error'}',
        );
      }

      throw Exception('Stripe payment failed: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during Stripe payment: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> checkPaymentStatus(String transactionId) async {
    try {
      final response = await dioClient.dio.get(
        '$baseUrl/payment_intents/$transactionId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${EnvironmentConfig.stripeSecretKey}',
          },
        ),
      );

      final status = response.data['status'];
      String normalizedStatus;

      switch (status) {
        case 'succeeded':
          normalizedStatus = 'successful';
          break;
        case 'processing':
          normalizedStatus = 'pending';
          break;
        case 'requires_payment_method':
        case 'requires_confirmation':
        case 'requires_action':
          normalizedStatus = 'pending';
          break;
        case 'canceled':
          normalizedStatus = 'cancelled';
          break;
        default:
          normalizedStatus = 'failed';
      }

      return {
        'status': normalizedStatus,
        'transaction_id': transactionId,
        'amount': (response.data['amount'] as int) / 100,
        'currency': response.data['currency'].toString().toUpperCase(),
        'provider': 'stripe',
        'payment_method': response.data['payment_method'],
        'created_at': DateTime.fromMillisecondsSinceEpoch(
          response.data['created'] * 1000,
        ).toIso8601String(),
      };
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Stripe status check failed: ${e.message}');
      }
      throw Exception('Failed to check Stripe payment status: ${e.message}');
    }
  }

  @override
  Future<bool> validateWebhook(Map<String, dynamic> webhookData) async {
    try {
      // Verify Stripe webhook signature
      // In production, you should verify the signature using Stripe's library
      // For now, we'll do basic validation

      final eventType = webhookData['type'];
      final paymentIntent = webhookData['data']?['object'];

      if (eventType == null || paymentIntent == null) {
        return false;
      }

      // Valid event types for payment intents
      const validEvents = [
        'payment_intent.succeeded',
        'payment_intent.payment_failed',
        'payment_intent.canceled',
        'payment_intent.processing',
      ];

      return validEvents.contains(eventType);
    } catch (e) {
      if (kDebugMode) {
        print('Stripe webhook validation failed: $e');
      }
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    // Stripe supports various payment methods
    return [
      {
        'code': 'card',
        'name': 'Carte bancaire',
        'description': 'Visa, Mastercard, American Express',
        'icon': 'credit_card',
        'available': true,
      },
      {
        'code': 'sepa_debit',
        'name': 'Prélèvement SEPA',
        'description': 'Pour les comptes bancaires européens',
        'icon': 'account_balance',
        'available': false, // Can be enabled if needed
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> cancelPayment(String transactionId) async {
    try {
      await dioClient.dio.post(
        '$baseUrl/payment_intents/$transactionId/cancel',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${EnvironmentConfig.stripeSecretKey}',
          },
        ),
      );

      return {
        'status': 'cancelled',
        'transaction_id': transactionId,
        'canceled_at': DateTime.now().toIso8601String(),
      };
    } on DioException catch (e) {
      throw Exception('Failed to cancel Stripe payment: ${e.message}');
    }
  }

  /// Create a Stripe customer
  Future<Map<String, dynamic>> createCustomer({
    required String email,
    String? name,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await dioClient.dio.post(
        '$baseUrl/customers',
        data: {
          'email': email,
          if (name != null) 'name': name,
          if (metadata != null) 'metadata': metadata,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${EnvironmentConfig.stripeSecretKey}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      return {
        'customer_id': response.data['id'],
        'email': response.data['email'],
        'created': response.data['created'],
      };
    } on DioException catch (e) {
      throw Exception('Failed to create Stripe customer: ${e.message}');
    }
  }

  /// Create a subscription
  Future<Map<String, dynamic>> createSubscription({
    required String customerId,
    required String priceId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await dioClient.dio.post(
        '$baseUrl/subscriptions',
        data: {
          'customer': customerId,
          'items': [
            {'price': priceId},
          ],
          if (metadata != null) 'metadata': metadata,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${EnvironmentConfig.stripeSecretKey}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      return {
        'subscription_id': response.data['id'],
        'status': response.data['status'],
        'current_period_end': response.data['current_period_end'],
      };
    } on DioException catch (e) {
      throw Exception('Failed to create Stripe subscription: ${e.message}');
    }
  }

  /// Refund a payment
  Future<Map<String, dynamic>> refundPayment({
    required String paymentIntentId,
    double? amount,
    String? reason,
  }) async {
    try {
      final data = <String, dynamic>{
        'payment_intent': paymentIntentId,
        if (amount != null) 'amount': (amount * 100).round(),
        if (reason != null) 'reason': reason,
      };

      final response = await dioClient.dio.post(
        '$baseUrl/refunds',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${EnvironmentConfig.stripeSecretKey}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      return {
        'refund_id': response.data['id'],
        'status': response.data['status'],
        'amount': (response.data['amount'] as int) / 100,
        'created': response.data['created'],
      };
    } on DioException catch (e) {
      throw Exception('Failed to refund Stripe payment: ${e.message}');
    }
  }
}
