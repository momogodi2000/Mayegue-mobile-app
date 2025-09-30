/// Payment entity representing a payment transaction
class PaymentEntity {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final String method; // 'campay', 'noupai', 'card'
  final String status; // 'pending', 'completed', 'failed', 'cancelled'
  final String? transactionId;
  final String? reference;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;

  const PaymentEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    this.transactionId,
    this.reference,
    required this.createdAt,
    this.completedAt,
    this.failureReason,
  });

  PaymentEntity copyWith({
    String? id,
    String? userId,
    double? amount,
    String? currency,
    String? method,
    String? status,
    String? transactionId,
    String? reference,
    DateTime? createdAt,
    DateTime? completedAt,
    String? failureReason,
  }) {
    return PaymentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      method: method ?? this.method,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      reference: reference ?? this.reference,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
    );
  }
}
