/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Server exception
class ServerException extends AppException {
  const ServerException(String message, {String? code}) : super(message, code: code);
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException(String message, {String? code}) : super(message, code: code);
}

/// Authentication exception
class AuthException extends AppException {
  const AuthException(String message, {String? code}) : super(message, code: code);
}

/// Validation exception
class ValidationException extends AppException {
  const ValidationException(String message, {String? code}) : super(message, code: code);
}

/// Payment exception
class PaymentException extends AppException {
  const PaymentException(String message, {String? code}) : super(message, code: code);
}

/// Cache exception
class CacheException extends AppException {
  const CacheException(String message, {String? code}) : super(message, code: code);
}
