import 'package:flutter/foundation.dart';
import '../../../../core/config/payment_config.dart';
import '../../domain/usecases/process_payment_usecase.dart';
import '../../domain/usecases/get_payment_history_usecase.dart';
import '../../domain/usecases/get_payment_status_usecase.dart';
import '../../domain/usecases/handle_payment_callback_usecase.dart';

/// Payment ViewModel
class PaymentViewModel extends ChangeNotifier {
  final ProcessPaymentUseCase processPaymentUseCase;
  final GetPaymentHistoryUseCase getPaymentHistoryUseCase;
  final GetPaymentStatusUseCase getPaymentStatusUseCase;
  final HandlePaymentCallbackUseCase handlePaymentCallbackUseCase;

  PaymentViewModel({
    required this.processPaymentUseCase,
    required this.getPaymentHistoryUseCase,
    required this.getPaymentStatusUseCase,
    required this.handlePaymentCallbackUseCase,
  });

  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  List<dynamic> _paymentHistory = [];
  dynamic _lastProcessedPayment;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  List<dynamic> get paymentHistory => _paymentHistory;
  dynamic get lastProcessedPayment => _lastProcessedPayment;

  /// Validate payment configuration before processing
  String? validatePaymentConfig() {
    return PaymentConfig.configurationError;
  }

  /// Get available payment methods
  List<String> get availablePaymentMethods =>
      PaymentConfig.availablePaymentMethods;

  Future<void> processPayment({
    required String userId,
    required double amount,
    required String method,
    required String phoneNumber,
  }) async {
    // Validate payment configuration first
    final configError = validatePaymentConfig();
    if (configError != null) {
      _error = configError;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    final params = ProcessPaymentParams(
      userId: userId,
      amount: amount,
      method: method,
      phoneNumber: phoneNumber,
    );

    final result = await processPaymentUseCase(params);

    result.fold(
      (failure) {
        _error = failure.message;
        _lastProcessedPayment = null;
      },
      (payment) {
        _successMessage =
            'Payment initiated successfully. Transaction ID: ${payment.transactionId}';
        _lastProcessedPayment = payment;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPaymentHistory(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final params = GetPaymentHistoryParams(userId: userId);
    final result = await getPaymentHistoryUseCase(params);

    result.fold(
      (failure) {
        _error = failure.message;
      },
      (payments) {
        _paymentHistory = payments;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkPaymentStatus(String paymentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final params = GetPaymentStatusParams(paymentId: paymentId);
    final result = await getPaymentStatusUseCase(params);

    result.fold(
      (failure) {
        _error = failure.message;
      },
      (payment) {
        _successMessage = 'Payment status: ${payment.status}';
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> handlePaymentCallback(Map<String, dynamic> callbackData) async {
    final params = HandlePaymentCallbackParams(callbackData: callbackData);
    final result = await handlePaymentCallbackUseCase(params);

    result.fold(
      (failure) {
        _error = failure.message;
      },
      (success) {
        if (success) {
          _successMessage = 'Payment callback processed successfully';
        } else {
          _error = 'Failed to process payment callback';
        }
      },
    );

    notifyListeners();
  }

  Future<String?> getPaymentStatus(String paymentId) async {
    final params = GetPaymentStatusParams(paymentId: paymentId);
    final result = await getPaymentStatusUseCase(params);

    return result.fold(
      (failure) => null,
      (payment) => payment.status,
    );
  }
}
