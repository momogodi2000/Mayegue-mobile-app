import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/payment_constants.dart';

/// Abstract interface for payment data sources (CamPay, NouPai, etc.)
abstract class PaymentDataSource {
  /// Initiate a payment transaction
  Future<Map<String, dynamic>> initiatePayment({
    required String phoneNumber,
    required double amount,
    required String description,
    required String externalReference,
    String? currency,
  });

  /// Check payment status
  Future<Map<String, dynamic>> checkPaymentStatus(String transactionId);

  /// Validate webhook/callback data
  Future<bool> validateWebhook(Map<String, dynamic> webhookData);

  /// Get payment methods
  Future<List<Map<String, dynamic>>> getPaymentMethods();

  /// Cancel payment
  Future<Map<String, dynamic>> cancelPayment(String transactionId);
}

/// CamPay implementation for Cameroon Mobile Money
class CamPayDataSourceImpl implements PaymentDataSource {
  final DioClient dioClient;
  static const String baseUrl = 'https://api.campay.net/api';

  CamPayDataSourceImpl(this.dioClient);

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
      if (!_isValidPhoneNumber(phoneNumber)) {
        throw Exception('Invalid Cameroon phone number format');
      }

      if (amount <= 0) {
        throw Exception('Amount must be greater than 0');
      }

      final payload = {
        'amount': amount.toStringAsFixed(0), // CamPay expects integer amounts
        'currency': currency,
        'from': _formatPhoneNumber(phoneNumber),
        'description': description,
        'external_reference': externalReference,
        'redirect_url': PaymentConstants.campayRedirectUrl,
        'webhook_url': PaymentConstants.campayWebhookUrl,
      };

      final response = await dioClient.dio.post(
        '$baseUrl/collect/',
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Token ${PaymentConstants.campayApiKey}',
            'Content-Type': 'application/json',
          },
        ),
      );

      debugPrint('CamPay payment initiated: ${response.data}');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('CamPay DioException: ${e.response?.data}');
      throw _handleDioException(e);
    } catch (e) {
      debugPrint('CamPay general error: $e');
      throw Exception('CamPay payment initiation failed: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> checkPaymentStatus(String transactionId) async {
    try {
      final response = await dioClient.dio.get(
        '$baseUrl/transaction/$transactionId/',
        options: Options(
          headers: {
            'Authorization': 'Token ${PaymentConstants.campayApiKey}',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('CamPay status check failed: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> cancelPayment(String transactionId) async {
    try {
      final response = await dioClient.dio.delete(
        '$baseUrl/transaction/$transactionId/',
        options: Options(
          headers: {
            'Authorization': 'Token ${PaymentConstants.campayApiKey}',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('CamPay payment cancellation failed: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final response = await dioClient.dio.get(
        '$baseUrl/payment-methods/',
        options: Options(
          headers: {
            'Authorization': 'Token ${PaymentConstants.campayApiKey}',
          },
        ),
      );

      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['results'] ?? []);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Failed to get payment methods: $e');
    }
  }

  @override
  Future<bool> validateWebhook(Map<String, dynamic> webhookData) async {
    try {
      // CamPay webhook validation
      final signature = webhookData['signature'] as String?;
      if (signature == null) return false;

      // Remove signature from data for validation
      final dataToValidate = Map<String, dynamic>.from(webhookData);
      dataToValidate.remove('signature');

      // Create signature
      final sortedKeys = dataToValidate.keys.toList()..sort();
      final signatureString =
          sortedKeys.map((key) => '$key=${dataToValidate[key]}').join('&');

      final expectedSignature = _generateSignature(signatureString);

      return signature == expectedSignature;
    } catch (e) {
      debugPrint('Webhook validation error: $e');
      return false;
    }
  }

  /// Validate Cameroon phone number format
  bool _isValidPhoneNumber(String phoneNumber) {
    // Cameroon phone numbers: +237 6XX XXX XXX or 6XX XXX XXX
    final regex = RegExp(r'^(\+237|237)?[26][0-9]{8}$');
    return regex.hasMatch(phoneNumber.replaceAll(RegExp(r'[\s-]'), ''));
  }

  /// Format phone number for CamPay
  String _formatPhoneNumber(String phoneNumber) {
    // Remove all non-digits
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // Add country code if missing
    if (digitsOnly.length == 9 && digitsOnly.startsWith(RegExp(r'[26]'))) {
      return '+237$digitsOnly';
    } else if (digitsOnly.length == 12 && digitsOnly.startsWith('237')) {
      return '+$digitsOnly';
    } else if (digitsOnly.length == 11 && digitsOnly.startsWith('237')) {
      return '+$digitsOnly';
    }

    return phoneNumber; // Return as-is if already formatted
  }

  /// Generate HMAC signature for webhook validation
  String _generateSignature(String data) {
    final key = utf8.encode(PaymentConstants.campayWebhookSecret);
    final bytes = utf8.encode(data);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  /// Handle Dio exceptions with specific error messages
  Exception _handleDioException(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return Exception(
            'Invalid request: ${e.response?.data['message'] ?? 'Bad request'}');
      case 401:
        return Exception('Authentication failed: Invalid API key');
      case 402:
        return Exception('Insufficient funds or payment declined');
      case 404:
        return Exception('Transaction not found');
      case 429:
        return Exception('Too many requests: Please try again later');
      case 500:
        return Exception('CamPay server error: Please try again later');
      default:
        return Exception(
            'Payment failed: ${e.response?.data['message'] ?? e.message}');
    }
  }
}

/// Orange Money specific implementation
class OrangeMoneyDataSourceImpl implements PaymentDataSource {
  final DioClient dioClient;

  OrangeMoneyDataSourceImpl(this.dioClient);

  @override
  Future<Map<String, dynamic>> initiatePayment({
    required String phoneNumber,
    required double amount,
    required String description,
    required String externalReference,
    String? currency = 'XAF',
  }) async {
    // Orange Money specific implementation
    // Use CamPay as fallback since it supports Orange Money
    final campaySource = CamPayDataSourceImpl(dioClient);
    return campaySource.initiatePayment(
      phoneNumber: phoneNumber,
      amount: amount,
      description: description,
      externalReference: externalReference,
      currency: currency,
    );
  }

  @override
  Future<Map<String, dynamic>> checkPaymentStatus(String transactionId) async {
    final campaySource = CamPayDataSourceImpl(dioClient);
    return campaySource.checkPaymentStatus(transactionId);
  }

  @override
  Future<bool> validateWebhook(Map<String, dynamic> webhookData) async {
    final campaySource = CamPayDataSourceImpl(dioClient);
    return campaySource.validateWebhook(webhookData);
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    final campaySource = CamPayDataSourceImpl(dioClient);
    return campaySource.getPaymentMethods();
  }

  @override
  Future<Map<String, dynamic>> cancelPayment(String transactionId) async {
    final campaySource = CamPayDataSourceImpl(dioClient);
    return campaySource.cancelPayment(transactionId);
  }
}

/// MTN Mobile Money specific implementation
class MTNMoMoDataSourceImpl implements PaymentDataSource {
  final DioClient dioClient;

  MTNMoMoDataSourceImpl(this.dioClient);

  @override
  Future<Map<String, dynamic>> initiatePayment({
    required String phoneNumber,
    required double amount,
    required String description,
    required String externalReference,
    String? currency = 'XAF',
  }) async {
    // MTN MoMo specific implementation
    // Use CamPay as fallback since it supports MTN MoMo
    final campaySource = CamPayDataSourceImpl(dioClient);
    return campaySource.initiatePayment(
      phoneNumber: phoneNumber,
      amount: amount,
      description: description,
      externalReference: externalReference,
      currency: currency,
    );
  }

  @override
  Future<Map<String, dynamic>> checkPaymentStatus(String transactionId) async {
    final campaySource = CamPayDataSourceImpl(dioClient);
    return campaySource.checkPaymentStatus(transactionId);
  }

  @override
  Future<bool> validateWebhook(Map<String, dynamic> webhookData) async {
    final campaySource = CamPayDataSourceImpl(dioClient);
    return campaySource.validateWebhook(webhookData);
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    final campaySource = CamPayDataSourceImpl(dioClient);
    return campaySource.getPaymentMethods();
  }

  @override
  Future<Map<String, dynamic>> cancelPayment(String transactionId) async {
    final campaySource = CamPayDataSourceImpl(dioClient);
    return campaySource.cancelPayment(transactionId);
  }
}
