import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'firebase_service.dart';

/// Service for handling Two-Factor Authentication (2FA)
class TwoFactorAuthService {
  final FirebaseService _firebaseService;

  TwoFactorAuthService(this._firebaseService);

  /// Generate a 6-digit OTP code
  String _generateOTP() {
    final random = Random.secure();
    final code = random.nextInt(900000) + 100000; // Generates 6-digit code
    return code.toString();
  }

  /// Hash the OTP for secure storage
  String _hashOTP(String otp) {
    final bytes = utf8.encode(otp);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Send OTP via email
  Future<bool> sendOTPViaEmail(String userId, String email) async {
    try {
      final otp = _generateOTP();
      final hashedOTP = _hashOTP(otp);
      final expiresAt = DateTime.now().add(const Duration(minutes: 10));

      // Store OTP in Firestore
      await _firebaseService.firestore.collection('otp_codes').doc(userId).set({
        'hashedCode': hashedOTP,
        'expiresAt': Timestamp.fromDate(expiresAt),
        'attempts': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'method': 'email',
      });

      // TODO: Integrate with email service to send OTP
      // For now, we'll log it in debug mode
      if (kDebugMode) {
        print('OTP for $email: $otp (expires at $expiresAt)');
      }

      // In production, use Firebase Cloud Functions or email service
      // to send the OTP to the user's email

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending OTP via email: $e');
      }
      return false;
    }
  }

  /// Send OTP via SMS (using Firebase Auth phone verification)
  Future<String> sendOTPViaSMS(String phoneNumber) async {
    try {
      final completer = Completer<String>();

      await _firebaseService.auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-retrieval or instant verification
          if (kDebugMode) {
            print('Phone verification completed automatically');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            print('Phone verification failed: ${e.message}');
          }
          completer.completeError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          if (kDebugMode) {
            print('OTP sent to $phoneNumber');
          }
          completer.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (kDebugMode) {
            print('Auto retrieval timeout');
          }
        },
      );

      return await completer.future;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending OTP via SMS: $e');
      }
      rethrow;
    }
  }

  /// Verify OTP code
  Future<bool> verifyOTP(String userId, String otpCode) async {
    try {
      final otpDoc = await _firebaseService.firestore
          .collection('otp_codes')
          .doc(userId)
          .get();

      if (!otpDoc.exists) {
        throw Exception('No OTP found for this user');
      }

      final data = otpDoc.data()!;
      final hashedCode = data['hashedCode'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final attempts = (data['attempts'] as int?) ?? 0;

      // Check if OTP has expired
      if (DateTime.now().isAfter(expiresAt)) {
        await _deleteOTP(userId);
        throw Exception('OTP has expired');
      }

      // Check if too many attempts
      if (attempts >= 3) {
        await _deleteOTP(userId);
        throw Exception('Too many failed attempts. Please request a new OTP');
      }

      // Verify the OTP
      final inputHashedOTP = _hashOTP(otpCode);

      if (inputHashedOTP == hashedCode) {
        // OTP is correct - delete it
        await _deleteOTP(userId);

        // Mark 2FA as verified for this session
        await _firebaseService.firestore.collection('users').doc(userId).update(
          {'lastTwoFactorVerification': FieldValue.serverTimestamp()},
        );

        return true;
      } else {
        // Increment failed attempts
        await _firebaseService.firestore
            .collection('otp_codes')
            .doc(userId)
            .update({'attempts': FieldValue.increment(1)});

        throw Exception('Invalid OTP code');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying OTP: $e');
      }
      rethrow;
    }
  }

  /// Delete OTP code
  Future<void> _deleteOTP(String userId) async {
    try {
      await _firebaseService.firestore
          .collection('otp_codes')
          .doc(userId)
          .delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting OTP: $e');
      }
    }
  }

  /// Enable 2FA for a user
  Future<void> enable2FA(String userId) async {
    try {
      await _firebaseService.firestore.collection('users').doc(userId).update({
        'twoFactorEnabled': true,
        'twoFactorEnabledAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('2FA enabled for user: $userId');
      }
    } catch (e) {
      throw Exception('Failed to enable 2FA: $e');
    }
  }

  /// Disable 2FA for a user
  Future<void> disable2FA(String userId) async {
    try {
      await _firebaseService.firestore.collection('users').doc(userId).update({
        'twoFactorEnabled': false,
        'twoFactorDisabledAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('2FA disabled for user: $userId');
      }
    } catch (e) {
      throw Exception('Failed to disable 2FA: $e');
    }
  }

  /// Check if user has 2FA enabled
  Future<bool> is2FAEnabled(String userId) async {
    try {
      final userDoc = await _firebaseService.firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return false;
      }

      return userDoc.data()?['twoFactorEnabled'] == true;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking 2FA status: $e');
      }
      return false;
    }
  }

  /// Check if user needs 2FA verification for this session
  Future<bool> needs2FAVerification(String userId) async {
    try {
      if (!await is2FAEnabled(userId)) {
        return false;
      }

      final userDoc = await _firebaseService.firestore
          .collection('users')
          .doc(userId)
          .get();

      final lastVerification = userDoc.data()?['lastTwoFactorVerification'];

      if (lastVerification == null) {
        return true;
      }

      final lastVerificationDate = (lastVerification as Timestamp).toDate();
      final now = DateTime.now();

      // Require 2FA verification every 24 hours
      return now.difference(lastVerificationDate).inHours >= 24;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if 2FA verification needed: $e');
      }
      return true; // Err on the side of caution
    }
  }

  /// Generate backup codes for 2FA
  Future<List<String>> generateBackupCodes(String userId) async {
    try {
      final List<String> backupCodes = [];

      for (int i = 0; i < 10; i++) {
        final code = _generateOTP();
        backupCodes.add(code);
      }

      // Hash and store backup codes
      final hashedCodes = backupCodes.map((code) => _hashOTP(code)).toList();

      await _firebaseService.firestore.collection('users').doc(userId).update({
        'backupCodes': hashedCodes,
        'backupCodesGeneratedAt': FieldValue.serverTimestamp(),
      });

      return backupCodes;
    } catch (e) {
      throw Exception('Failed to generate backup codes: $e');
    }
  }

  /// Verify backup code
  Future<bool> verifyBackupCode(String userId, String backupCode) async {
    try {
      final userDoc = await _firebaseService.firestore
          .collection('users')
          .doc(userId)
          .get();

      final backupCodes = List<String>.from(
        userDoc.data()?['backupCodes'] ?? [],
      );

      final hashedInput = _hashOTP(backupCode);

      if (backupCodes.contains(hashedInput)) {
        // Remove used backup code
        backupCodes.remove(hashedInput);

        await _firebaseService.firestore
            .collection('users')
            .doc(userId)
            .update({
              'backupCodes': backupCodes,
              'lastTwoFactorVerification': FieldValue.serverTimestamp(),
            });

        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying backup code: $e');
      }
      return false;
    }
  }
}

class Completer<T> {
  bool _isCompleted = false;
  dynamic _result;
  dynamic _error;
  final List<Function> _callbacks = [];

  bool get isCompleted => _isCompleted;

  Future<T> get future {
    if (_isCompleted) {
      if (_error != null) {
        return Future.error(_error);
      }
      return Future.value(_result);
    }

    final future = Future<T>(() {
      while (!_isCompleted) {
        // Wait for completion
      }
      if (_error != null) {
        throw _error;
      }
      return _result;
    });

    return future;
  }

  void complete(T value) {
    if (_isCompleted) return;
    _isCompleted = true;
    _result = value;
    for (final callback in _callbacks) {
      callback();
    }
  }

  void completeError(dynamic error) {
    if (_isCompleted) return;
    _isCompleted = true;
    _error = error;
    for (final callback in _callbacks) {
      callback();
    }
  }
}
