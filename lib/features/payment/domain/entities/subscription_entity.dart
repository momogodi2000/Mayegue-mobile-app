/// Subscription entity representing user subscriptions
class SubscriptionEntity {
  final String id;
  final String userId;
  final String planId;
  final String planName;
  final double price;
  final String currency;
  final String interval; // 'monthly', 'yearly'
  final String status; // 'active', 'cancelled', 'expired', 'pending'
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? cancelledAt;
  final bool autoRenew;

  const SubscriptionEntity({
    required this.id,
    required this.userId,
    required this.planId,
    required this.planName,
    required this.price,
    required this.currency,
    required this.interval,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.cancelledAt,
    this.autoRenew = true,
  });

  SubscriptionEntity copyWith({
    String? id,
    String? userId,
    String? planId,
    String? planName,
    double? price,
    String? currency,
    String? interval,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? cancelledAt,
    bool? autoRenew,
  }) {
    return SubscriptionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      interval: interval ?? this.interval,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      autoRenew: autoRenew ?? this.autoRenew,
    );
  }

  bool get isActive => status == 'active' && endDate.isAfter(DateTime.now());
  bool get isExpired => endDate.isBefore(DateTime.now());

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'planId': planId,
      'planName': planName,
      'price': price,
      'currency': currency,
      'interval': interval,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'autoRenew': autoRenew,
    };
  }
}
