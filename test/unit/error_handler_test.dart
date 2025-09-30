import 'package:flutter_test/flutter_test.dart';
import 'package:mayegue/core/errors/error_handler.dart';
import 'package:mayegue/core/errors/exceptions.dart';
import 'package:mayegue/core/errors/failures.dart';

void main() {
  group('ErrorHandler', () {
    group('handleException', () {
      test('should convert ServerException to ServerFailure', () {
        const exception = ServerException('Server error');
        final failure = ErrorHandler.handleException(exception);
        
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Server error');
      });

      test('should convert AuthException to AuthFailure', () {
        const exception = AuthException('Auth error');
        final failure = ErrorHandler.handleException(exception);
        
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Auth error');
      });

      test('should convert NetworkException to NetworkFailure', () {
        const exception = NetworkException('Network error');
        final failure = ErrorHandler.handleException(exception);
        
        expect(failure, isA<NetworkFailure>());
        expect(failure.message, 'Network error');
      });

      test('should convert ValidationException to ValidationFailure', () {
        const exception = ValidationException('Validation error');
        final failure = ErrorHandler.handleException(exception);
        
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'Validation error');
      });

      test('should convert PaymentException to PaymentFailure', () {
        const exception = PaymentException('Payment error');
        final failure = ErrorHandler.handleException(exception);
        
        expect(failure, isA<PaymentFailure>());
        expect(failure.message, 'Payment error');
      });

      test('should convert unknown exception to ServerFailure', () {
        final exception = Exception('Unknown error');
        final failure = ErrorHandler.handleException(exception);
        
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Une erreur inattendue s\'est produite');
      });
    });

    group('logError', () {
      test('should log error without throwing', () {
        // logError prints to console in debug mode, but doesn't throw
        ErrorHandler.logError('test error', StackTrace.current);
        // If we get here, it didn't throw
        expect(true, isTrue);
      });
    });

    group('handleAsyncError', () {
      test('should return result when operation succeeds', () async {
        final result = await ErrorHandler.handleAsyncError(() async => 'success');
        expect(result, 'success');
      });

      test('should rethrow error when operation fails', () async {
        expect(
          () async => await ErrorHandler.handleAsyncError(() async => throw Exception('error')),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
