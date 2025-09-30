import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

/// User model for data layer
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.phoneNumber,
    super.photoUrl,
    super.role,
    super.languages,
    required super.createdAt,
    super.lastLoginAt,
    super.isEmailVerified,
    super.preferences,
  });

  /// Create from Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      photoUrl: data['photoUrl'],
      role: data['role'] ?? 'learner',
      languages: List<String>.from(data['languages'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      isEmailVerified: data['isEmailVerified'] ?? false,
      preferences: data['preferences'],
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'role': role,
      'languages': languages,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'isEmailVerified': isEmailVerified,
      'preferences': preferences,
    };
  }

  /// Create from Firebase User
  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      phoneNumber: firebaseUser.phoneNumber,
      photoUrl: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: firebaseUser.metadata.lastSignInTime,
      isEmailVerified: firebaseUser.emailVerified,
    );
  }

  /// Create from entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      phoneNumber: entity.phoneNumber,
      photoUrl: entity.photoUrl,
      role: entity.role,
      languages: entity.languages,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
      isEmailVerified: entity.isEmailVerified,
      preferences: entity.preferences,
    );
  }
}
