import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment_entity.dart';

/// Payment model for data layer
class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.userId,
    required super.amount,
    required super.currency,
    required super.method,
    required super.status,
    super.transactionId,
    super.reference,
    required super.createdAt,
    super.completedAt,
    super.failureReason,
  });

  /// Create from Firestore document
  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'XAF',
      method: data['method'] ?? '',
      status: data['status'] ?? 'pending',
      transactionId: data['transactionId'],
      reference: data['reference'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      failureReason: data['failureReason'],
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'method': method,
      'status': status,
      'transactionId': transactionId,
      'reference': reference,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'failureReason': failureReason,
    };
  }

  /// Create from entity
  factory PaymentModel.fromEntity(PaymentEntity entity) {
    return PaymentModel(
      id: entity.id,
      userId: entity.userId,
      amount: entity.amount,
      currency: entity.currency,
      method: entity.method,
      status: entity.status,
      transactionId: entity.transactionId,
      reference: entity.reference,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
      failureReason: entity.failureReason,
    );
  }
}
