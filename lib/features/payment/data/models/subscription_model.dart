import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/subscription_entity.dart';

/// Subscription model for data layer
class SubscriptionModel extends SubscriptionEntity {
  const SubscriptionModel({
    required super.id,
    required super.userId,
    required super.planId,
    required super.planName,
    required super.price,
    required super.currency,
    required super.interval,
    required super.status,
    required super.startDate,
    required super.endDate,
    super.cancelledAt,
    super.autoRenew,
  });

  /// Create from Firestore document
  factory SubscriptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubscriptionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      planId: data['planId'] ?? '',
      planName: data['planName'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'XAF',
      interval: data['interval'] ?? 'monthly',
      status: data['status'] ?? 'pending',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 30)),
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
      autoRenew: data['autoRenew'] ?? true,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'planId': planId,
      'planName': planName,
      'price': price,
      'currency': currency,
      'interval': interval,
      'status': status,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'cancelledAt':
          cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'autoRenew': autoRenew,
    };
  }

  /// Create from entity
  factory SubscriptionModel.fromEntity(SubscriptionEntity entity) {
    return SubscriptionModel(
      id: entity.id,
      userId: entity.userId,
      planId: entity.planId,
      planName: entity.planName,
      price: entity.price,
      currency: entity.currency,
      interval: entity.interval,
      status: entity.status,
      startDate: entity.startDate,
      endDate: entity.endDate,
      cancelledAt: entity.cancelledAt,
      autoRenew: entity.autoRenew,
    );
  }
}
