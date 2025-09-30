import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

/// Local auth datasource for offline support
abstract class AuthLocalDataSource {
  Future<UserEntity?> getCurrentUser();
  Future<void> saveUser(UserEntity user);
  Future<void> updateUser(UserEntity user);
  Future<void> deleteUser(String userId);
  Future<List<UserEntity>> getAllUsers();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<UserEntity?> getCurrentUser() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      'users',
      limit: 1,
      orderBy: 'created_at DESC',
    );

    if (maps.isNotEmpty) {
      return UserModel.fromFirestore(maps.first, maps.first['id'] as String);
    }
    return null;
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    final db = await DatabaseHelper.database;
    final userData = {
      'id': user.id,
      'email': user.email,
      'displayName': user.displayName,
      'phoneNumber': user.phoneNumber,
      'photoUrl': user.photoUrl,
      'role': user.role,
      'createdAt': user.createdAt.toIso8601String(),
      'lastLoginAt': user.lastLoginAt?.toIso8601String(),
      'isEmailVerified': user.isEmailVerified ? 1 : 0,
      'preferences': user.preferences?.toString(),
      'last_sync': DateTime.now().toIso8601String(),
      'is_synced': 1,
    };

    await db.insert(
      'users',
      userData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final db = await DatabaseHelper.database;
    final userData = {
      'email': user.email,
      'displayName': user.displayName,
      'phoneNumber': user.phoneNumber,
      'photoUrl': user.photoUrl,
      'role': user.role,
      'lastLoginAt': user.lastLoginAt?.toIso8601String(),
      'isEmailVerified': user.isEmailVerified ? 1 : 0,
      'preferences': user.preferences?.toString(),
      'last_sync': DateTime.now().toIso8601String(),
      'is_synced': 1,
    };

    await db.update(
      'users',
      userData,
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  @override
  Future<void> deleteUser(String userId) async {
    final db = await DatabaseHelper.database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('users');

    return maps.map((map) => UserModel.fromFirestore(map, map['id'] as String)).toList();
  }
}
