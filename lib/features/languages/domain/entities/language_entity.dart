/// Language Entity - Domain layer representation
class LanguageEntity {
  final String id;
  final String name;
  final String group; // Linguistic family/cluster
  final String region; // Geographical usage region
  final String type; // Role (primary, commercial, heritage, etc.)
  final String status; // active/inactive
  final DateTime createdAt;
  final DateTime updatedAt;

  const LanguageEntity({
    required this.id,
    required this.name,
    required this.group,
    required this.region,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with modified fields
  LanguageEntity copyWith({
    String? id,
    String? name,
    String? group,
    String? region,
    String? type,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LanguageEntity(
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

    return other is LanguageEntity &&
        other.id == id &&
        other.name == name &&
        other.group == group &&
        other.region == region &&
        other.type == type &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        group.hashCode ^
        region.hashCode ^
        type.hashCode ^
        status.hashCode;
  }

  @override
  String toString() {
    return 'LanguageEntity(id: $id, name: $name, group: $group, region: $region, type: $type, status: $status)';
  }
}
