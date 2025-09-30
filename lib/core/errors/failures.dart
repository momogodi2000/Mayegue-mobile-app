/// Base failure class
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure(String message, {String? code}) : super(message, code: code);
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure(String message, {String? code}) : super(message, code: code);
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure(String message, {String? code}) : super(message, code: code);
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure(String message, {String? code}) : super(message, code: code);
}

/// Payment failure
class PaymentFailure extends Failure {
  const PaymentFailure(String message, {String? code}) : super(message, code: code);
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure(String message, {String? code}) : super(message, code: code);
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message, {String? code}) : super(message, code: code);
}

/// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure(String message, {String? code}) : super(message, code: code);
}
