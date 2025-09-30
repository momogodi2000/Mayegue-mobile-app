/// Model for language subscription data
class LangueAbonnement {
  final String id;
  final String userId;
  final String languageId;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LangueAbonnement({
    required this.id,
    required this.userId,
    required this.languageId,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from map (for database operations)
  factory LangueAbonnement.fromMap(Map<String, dynamic> map) {
    return LangueAbonnement(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      languageId: map['languageId'] ?? '',
      startDate: DateTime.tryParse(map['startDate'] ?? '') ?? DateTime.now(),
      endDate:
          map['endDate'] != null ? DateTime.tryParse(map['endDate']) : null,
      isActive: map['isActive'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Convert to map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'languageId': languageId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  LangueAbonnement copyWith({
    String? id,
    String? userId,
    String? languageId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LangueAbonnement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      languageId: languageId ?? this.languageId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LangueAbonnement &&
        other.id == id &&
        other.userId == userId &&
        other.languageId == languageId &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      languageId,
      startDate,
      endDate,
      isActive,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'LangueAbonnement(id: $id, userId: $userId, languageId: $languageId, startDate: $startDate, endDate: $endDate, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
