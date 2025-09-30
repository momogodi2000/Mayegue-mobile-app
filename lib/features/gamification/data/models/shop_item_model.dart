import '../../domain/entities/gamification.dart';

/// ShopItem model for data serialization
class ShopItemModel extends ShopItem {
  const ShopItemModel({
    required super.id,
    required super.name,
    required super.description,
    required super.iconName,
    required super.price,
    required super.type,
    required super.metadata,
    required super.isAvailable,
  });

  /// Create ShopItemModel from JSON
  factory ShopItemModel.fromJson(Map<String, dynamic> json) {
    return ShopItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
      price: json['price'] as int,
      type: ShopItemType.values[json['type'] as int],
      metadata: json['metadata'] as Map<String, dynamic>,
      isAvailable: json['isAvailable'] as bool,
    );
  }

  /// Convert ShopItemModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'price': price,
      'type': type.index,
      'metadata': metadata,
      'isAvailable': isAvailable,
    };
  }

  /// Create ShopItemModel from ShopItem entity
  factory ShopItemModel.fromEntity(ShopItem item) {
    return ShopItemModel(
      id: item.id,
      name: item.name,
      description: item.description,
      iconName: item.iconName,
      price: item.price,
      type: item.type,
      metadata: item.metadata,
      isAvailable: item.isAvailable,
    );
  }
}
