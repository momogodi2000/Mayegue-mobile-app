import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service for calling Firebase Cloud Functions
class FirebaseCloudFunctionsService {
  static final FirebaseCloudFunctionsService _instance = FirebaseCloudFunctionsService._internal();
  factory FirebaseCloudFunctionsService() => _instance;
  FirebaseCloudFunctionsService._internal();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Send notification to user via cloud function
  Future<Map<String, dynamic>?> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final callable = _functions.httpsCallable('sendNotificationToUser');
      final result = await callable.call({
        'userId': userId,
        'title': title,
        'body': body,
        'data': data ?? {},
      });
      return result.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return null;
    }
  }

  /// Trigger AI vocabulary generation
  Future<Map<String, dynamic>?> generateAIVocabulary({
    required String languageCode,
    required String category,
    required String difficultyLevel,
    int count = 10,
  }) async {
    try {
      final callable = _functions.httpsCallable('generateAIVocabulary');
      final result = await callable.call({
        'languageCode': languageCode,
        'category': category,
        'difficultyLevel': difficultyLevel,
        'count': count,
      });
      return result.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error generating AI vocabulary: $e');
      return null;
    }
  }

  /// Process payment via cloud function
  Future<Map<String, dynamic>?> processPayment({
    required String paymentMethod,
    required double amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final callable = _functions.httpsCallable('processPayment');
      final result = await callable.call({
        'paymentMethod': paymentMethod,
        'amount': amount,
        'currency': currency,
        'metadata': metadata ?? {},
        'userId': _auth.currentUser?.uid,
      });
      return result.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error processing payment: $e');
      return null;
    }
  }

  /// Moderate user content
  Future<Map<String, dynamic>?> moderateContent({
    required String content,
    required String contentType,
    String? contextData,
  }) async {
    try {
      final callable = _functions.httpsCallable('moderateContent');
      final result = await callable.call({
        'content': content,
        'contentType': contentType,
        'contextData': contextData,
        'userId': _auth.currentUser?.uid,
      });
      return result.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error moderating content: $e');
      return null;
    }
  }

  /// Generate user analytics report
  Future<Map<String, dynamic>?> generateAnalyticsReport({
    required String reportType,
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final callable = _functions.httpsCallable('generateAnalyticsReport');
      final result = await callable.call({
        'reportType': reportType,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'filters': filters ?? {},
        'userId': _auth.currentUser?.uid,
      });
      return result.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error generating analytics report: $e');
      return null;
    }
  }

  /// Sync offline data to Firestore
  Future<Map<String, dynamic>?> syncOfflineData({
    required List<Map<String, dynamic>> entries,
    required String dataType,
  }) async {
    try {
      final callable = _functions.httpsCallable('syncOfflineData');
      final result = await callable.call({
        'entries': entries,
        'dataType': dataType,
        'userId': _auth.currentUser?.uid,
      });
      return result.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error syncing offline data: $e');
      return null;
    }
  }

  /// Send bulk notifications to topic
  Future<Map<String, dynamic>?> sendBulkNotification({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final callable = _functions.httpsCallable('sendBulkNotification');
      final result = await callable.call({
        'topic': topic,
        'title': title,
        'body': body,
        'data': data ?? {},
      });
      return result.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error sending bulk notification: $e');
      return null;
    }
  }

  /// Process teacher dictionary review
  Future<Map<String, dynamic>?> processTeacherReview({
    required String entryId,
    required String reviewAction, // 'approve' or 'reject'
    String? reviewNotes,
  }) async {
    try {
      final callable = _functions.httpsCallable('processTeacherReview');
      final result = await callable.call({
        'entryId': entryId,
        'reviewAction': reviewAction,
        'reviewNotes': reviewNotes,
        'reviewerId': _auth.currentUser?.uid,
      });
      return result.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error processing teacher review: $e');
      return null;
    }
  }

  /// Create backup of user data
  Future<Map<String, dynamic>?> createUserDataBackup() async {
    try {
      final callable = _functions.httpsCallable('createUserDataBackup');
      final result = await callable.call({
        'userId': _auth.currentUser?.uid,
      });
      return result.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error creating data backup: $e');
      return null;
    }
  }

  /// Restore user data from backup
  Future<Map<String, dynamic>?> restoreUserDataFromBackup({
    required String backupId,
  }) async {
    try {
      final callable = _functions.httpsCallable('restoreUserDataFromBackup');
      final result = await callable.call({
        'backupId': backupId,
        'userId': _auth.currentUser?.uid,
      });
      return result.data as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error restoring data from backup: $e');
      return null;
    }
  }
}