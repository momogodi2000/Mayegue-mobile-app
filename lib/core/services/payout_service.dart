import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

/// Automated payout system for teachers
class PayoutService {
  final FirebaseService _firebaseService = FirebaseService();

  // Commission rates
  static const double _teacherCommissionRate = 0.70; // 70% for teachers
  static const double _platformFeeRate = 0.20; // 20% platform fee
  static const double _paymentProcessingFee = 0.05; // 5% payment processing

  // Minimum payout threshold
  static const double _minimumPayoutAmount = 10000; // 10,000 FCFA

  /// Calculate teacher earnings for a subscription
  double calculateTeacherEarnings(double subscriptionAmount) {
    return subscriptionAmount * _teacherCommissionRate;
  }

  /// Calculate platform fee
  double calculatePlatformFee(double subscriptionAmount) {
    return subscriptionAmount * _platformFeeRate;
  }

  /// Calculate payment processing fee
  double calculateProcessingFee(double amount) {
    return amount * _paymentProcessingFee;
  }

  /// Process subscription payment and distribute earnings
  Future<void> processSubscriptionPayment({
    required String userId,
    required String teacherId,
    required double amount,
    required String subscriptionType,
  }) async {
    try {
      final teacherEarnings = calculateTeacherEarnings(amount);
      final platformFee = calculatePlatformFee(amount);
      final processingFee = calculateProcessingFee(amount);

      // Record the transaction
      await _recordTransaction(
        userId: userId,
        teacherId: teacherId,
        amount: amount,
        teacherEarnings: teacherEarnings,
        platformFee: platformFee,
        processingFee: processingFee,
        type: 'subscription',
        subscriptionType: subscriptionType,
      );

      // Add to teacher's pending earnings
      await _addToTeacherEarnings(teacherId, teacherEarnings);

      // Check if teacher qualifies for automatic payout
      await _checkAndProcessPayout(teacherId);
    } catch (e) {
      rethrow;
    }
  }

  /// Process course sale payment
  Future<void> processCourseSale({
    required String userId,
    required String teacherId,
    required String courseId,
    required double amount,
  }) async {
    try {
      const double courseCommissionRate =
          0.75; // 75% for teachers on course sales
      final teacherEarnings = amount * courseCommissionRate;
      final platformFee = amount * 0.20; // 20% platform fee
      final processingFee = amount * 0.05; // 5% processing fee

      // Record the transaction
      await _recordTransaction(
        userId: userId,
        teacherId: teacherId,
        courseId: courseId,
        amount: amount,
        teacherEarnings: teacherEarnings,
        platformFee: platformFee,
        processingFee: processingFee,
        type: 'course_sale',
      );

      // Add to teacher's pending earnings
      await _addToTeacherEarnings(teacherId, teacherEarnings);

      // Check if teacher qualifies for automatic payout
      await _checkAndProcessPayout(teacherId);
    } catch (e) {
      rethrow;
    }
  }

  /// Record transaction in Firestore
  Future<void> _recordTransaction({
    required String userId,
    required String teacherId,
    String? courseId,
    required double amount,
    required double teacherEarnings,
    required double platformFee,
    required double processingFee,
    required String type,
    String? subscriptionType,
  }) async {
    final transactionData = {
      'userId': userId,
      'teacherId': teacherId,
      'courseId': courseId,
      'amount': amount,
      'teacherEarnings': teacherEarnings,
      'platformFee': platformFee,
      'processingFee': processingFee,
      'type': type,
      'subscriptionType': subscriptionType,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'completed',
    };

    await _firebaseService.firestore
        .collection('transactions')
        .add(transactionData);
  }

  /// Add earnings to teacher's pending balance
  Future<void> _addToTeacherEarnings(String teacherId, double amount) async {
    final teacherRef =
        _firebaseService.firestore.collection('users').doc(teacherId);

    await _firebaseService.firestore.runTransaction((transaction) async {
      final teacherDoc = await transaction.get(teacherRef);

      if (!teacherDoc.exists) {
        throw Exception('Teacher document not found');
      }

      final currentEarnings = teacherDoc.data()?['pendingEarnings'] ?? 0.0;
      final newEarnings = currentEarnings + amount;

      transaction.update(teacherRef, {
        'pendingEarnings': newEarnings,
        'lastEarningUpdate': DateTime.now().toIso8601String(),
      });
    });
  }

  /// Check if teacher qualifies for payout and process if eligible
  Future<void> _checkAndProcessPayout(String teacherId) async {
    final teacherDoc = await _firebaseService.firestore
        .collection('users')
        .doc(teacherId)
        .get();

    if (!teacherDoc.exists) return;

    final pendingEarnings = teacherDoc.data()?['pendingEarnings'] ?? 0.0;

    if (pendingEarnings >= _minimumPayoutAmount) {
      await _processPayout(teacherId, pendingEarnings);
    }
  }

  /// Process payout for teacher
  Future<void> _processPayout(String teacherId, double amount) async {
    try {
      // Get teacher's payout method
      final teacherDoc = await _firebaseService.firestore
          .collection('users')
          .doc(teacherId)
          .get();

      final payoutMethod = teacherDoc.data()?['payoutMethod'];
      if (payoutMethod == null) {
        return;
      }

      // For now, just mark as ready for manual processing
      // In production, this would integrate with payment processors like CamPay

      // Update teacher's balance
      await _firebaseService.firestore
          .collection('users')
          .doc(teacherId)
          .update({
        'pendingEarnings': 0.0,
        'totalEarned': FieldValue.increment(amount),
        'lastPayoutDate': DateTime.now().toIso8601String(),
      });

      // Record payout
      await _firebaseService.firestore.collection('payouts').add({
        'teacherId': teacherId,
        'amount': amount,
        'method': payoutMethod,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'pending_manual_processing', // In production: 'completed'
      });
    } catch (e) {
      // Record failed payout
      await _firebaseService.firestore.collection('payouts').add({
        'teacherId': teacherId,
        'amount': amount,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'failed',
        'error': e.toString(),
      });
    }
  }

  /// Get teacher's earnings summary
  Future<Map<String, dynamic>> getTeacherEarnings(String teacherId) async {
    final teacherDoc = await _firebaseService.firestore
        .collection('users')
        .doc(teacherId)
        .get();

    if (!teacherDoc.exists) {
      return {};
    }

    final data = teacherDoc.data()!;
    return {
      'pendingEarnings': data['pendingEarnings'] ?? 0.0,
      'totalEarned': data['totalEarned'] ?? 0.0,
      'lastPayoutDate': data['lastPayoutDate'],
      'lastEarningUpdate': data['lastEarningUpdate'],
    };
  }

  /// Get platform revenue summary (admin only)
  Future<Map<String, dynamic>> getPlatformRevenue() async {
    final transactions =
        await _firebaseService.firestore.collection('transactions').get();

    double totalRevenue = 0.0;
    double totalPlatformFees = 0.0;
    double totalProcessingFees = 0.0;

    for (final doc in transactions.docs) {
      final data = doc.data();
      totalRevenue += data['amount'] ?? 0.0;
      totalPlatformFees += data['platformFee'] ?? 0.0;
      totalProcessingFees += data['processingFee'] ?? 0.0;
    }

    return {
      'totalRevenue': totalRevenue,
      'totalPlatformFees': totalPlatformFees,
      'totalProcessingFees': totalProcessingFees,
      'netRevenue': totalPlatformFees - totalProcessingFees,
    };
  }

  /// Schedule monthly payouts (to be called by Cloud Scheduler)
  Future<void> processMonthlyPayouts() async {
    final teachers = await _firebaseService.firestore
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .where('pendingEarnings', isGreaterThanOrEqualTo: _minimumPayoutAmount)
        .get();

    for (final teacherDoc in teachers.docs) {
      final teacherId = teacherDoc.id;
      final pendingEarnings = teacherDoc.data()['pendingEarnings'] ?? 0.0;

      await _processPayout(teacherId, pendingEarnings);
    }
  }
}
