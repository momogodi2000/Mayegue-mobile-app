import 'package:flutter/foundation.dart';
import 'failures.dart';
import 'exceptions.dart';

/// Global error handler
class ErrorHandler {
  /// Convert exception to failure
  static Failure handleException(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(exception.message, code: exception.code);
    } else if (exception is NetworkException) {
      return NetworkFailure(exception.message, code: exception.code);
    } else if (exception is AuthException) {
      return AuthFailure(exception.message, code: exception.code);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message, code: exception.code);
    } else if (exception is PaymentException) {
      return PaymentFailure(exception.message, code: exception.code);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message, code: exception.code);
    } else {
      return const ServerFailure('Une erreur inattendue s\'est produite');
    }
  }

  /// Log error for debugging
  static void logError(Object error, StackTrace? stackTrace) {
    if (kDebugMode) {
      debugPrint('Error: $error');
      debugPrint('StackTrace: $stackTrace');
    }
    // TODO: Send to crash reporting service (Crashlytics)
  }

  /// Handle async errors
  static Future<T> handleAsyncError<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      logError(error, stackTrace);
      rethrow;
    }
  }
}
