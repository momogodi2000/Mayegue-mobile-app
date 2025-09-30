import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/language_entity.dart';

/// Language Model - Data layer representation for Firebase
class LanguageModel {
  final String id;
  final String name;
  final String group;
  final String region;
  final String type;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LanguageModel({
    required this.id,
    required this.name,
    required this.group,
    required this.region,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Firestore document
  factory LanguageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return LanguageModel(
      id: doc.id,
      name: data['name'] ?? '',
      group: data['group'] ?? '',
      region: data['region'] ?? '',
      type: data['type'] ?? '',
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'group': group,
      'region': region,
      'type': type,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convert to domain entity
  LanguageEntity toEntity() {
    return LanguageEntity(
      id: id,
      name: name,
      group: group,
      region: region,
      type: type,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory LanguageModel.fromEntity(LanguageEntity entity) {
    return LanguageModel(
      id: entity.id,
      name: entity.name,
      group: entity.group,
      region: entity.region,
      type: entity.type,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Create a copy with updated fields
  LanguageModel copyWith({
    String? id,
    String? name,
    String? group,
    String? region,
    String? type,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LanguageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      group: group ?? this.group,
      region: region ?? this.region,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageModel &&
        other.id == id &&
        other.name == name &&
        other.group == group &&
        other.region == region &&
        other.type == type &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      group,
      region,
      type,
      status,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'LanguageModel(id: $id, name: $name, group: $group, region: $region, type: $type, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
