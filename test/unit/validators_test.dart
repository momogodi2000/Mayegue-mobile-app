import 'package:flutter_test/flutter_test.dart';
import 'package:mayegue/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('getEmailError', () {
      test('should return null for valid email', () {
        expect(Validators.getEmailError('test@example.com'), null);
        expect(Validators.getEmailError('user.name+tag@example.co.uk'), null);
      });

      test('should return error for invalid email', () {
        expect(Validators.getEmailError(''), isNotNull);
        expect(Validators.getEmailError('invalid-email'), isNotNull);
        expect(Validators.getEmailError('test@'), isNotNull);
        expect(Validators.getEmailError('@example.com'), isNotNull);
      });

      test('should return error for suspicious email patterns', () {
        expect(Validators.getEmailError('test..double@example.com'), isNotNull);
        expect(Validators.getEmailError('.test@example.com'), isNotNull);
        expect(Validators.getEmailError('test.@example.com'), isNotNull);
        expect(Validators.getEmailError('test@.com'), isNotNull);
      });
    });

    group('getPasswordError', () {
      test('should return null for valid password', () {
        expect(Validators.getPasswordError('Password123'), null);
        expect(Validators.getPasswordError('MySecurePass1'), null);
      });

      test('should return error for invalid password', () {
        expect(Validators.getPasswordError(''), isNotNull);
        expect(Validators.getPasswordError('123'), isNotNull);
        expect(Validators.getPasswordError('password'), isNotNull); // no uppercase
        expect(Validators.getPasswordError('PASSWORD'), isNotNull); // no lowercase
        expect(Validators.getPasswordError('Password'), isNotNull); // no digit
      });
    });

    group('getNameError', () {
      test('should return null for valid name', () {
        expect(Validators.getNameError('John'), null);
        expect(Validators.getNameError('Marie-Claire'), null);
      });

      test('should return error for invalid name', () {
        expect(Validators.getNameError(''), isNotNull);
        expect(Validators.getNameError('A'), isNotNull);
        expect(Validators.getNameError('A' * 51), isNotNull); // too long
      });

      test('should return error for dangerous characters', () {
        expect(Validators.getNameError('John<script>'), isNotNull);
      });
    });

    group('getPhoneError', () {
      test('should return null for valid phone', () {
        expect(Validators.getPhoneError('+237612345678'), null);
        expect(Validators.getPhoneError('612345678'), null);
      });

      test('should return error for invalid phone', () {
        expect(Validators.getPhoneError(''), isNotNull);
        expect(Validators.getPhoneError('abc'), isNotNull);
        expect(Validators.getPhoneError('123'), isNotNull);
        expect(Validators.getPhoneError('+237123456789'), isNotNull); // Invalid: doesn't start with valid prefix
        expect(Validators.getPhoneError('123456789'), isNotNull); // Invalid: doesn't start with 6, 2, or 9
      });
    });

    group('validateTextInput', () {
      test('should return true for valid input', () {
        expect(Validators.validateTextInput('Valid input'), true);
      });

      test('should return false for invalid input', () {
        expect(Validators.validateTextInput(''), false);
        expect(Validators.validateTextInput('A', minLength: 2), false);
        expect(Validators.validateTextInput('<script>alert(1)</script>'), false);
      });
    });
  });
}
