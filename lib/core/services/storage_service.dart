import 'package:hive_flutter/hive_flutter.dart';

/// Local storage service using Hive
class StorageService {
  static const String _userBox = 'user_box';
  static const String _settingsBox = 'settings_box';
  static const String _cacheBox = 'cache_box';

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  bool _initialized = false;

  /// Initialize Hive
  Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();
    _initialized = true;
  }

  /// Get user data box
  Future<Box> get userBox async {
    await initialize();
    return await Hive.openBox(_userBox);
  }

  /// Get settings box
  Future<Box> get settingsBox async {
    await initialize();
    return await Hive.openBox(_settingsBox);
  }

  /// Get cache box
  Future<Box> get cacheBox async {
    await initialize();
    return await Hive.openBox(_cacheBox);
  }

  /// Save user data
  Future<void> saveUserData(String key, dynamic value) async {
    final box = await userBox;
    await box.put(key, value);
  }

  /// Get user data
  Future<dynamic> getUserData(String key) async {
    final box = await userBox;
    return box.get(key);
  }

  /// Save setting
  Future<void> saveSetting(String key, dynamic value) async {
    final box = await settingsBox;
    await box.put(key, value);
  }

  /// Get setting
  Future<dynamic> getSetting(String key) async {
    final box = await settingsBox;
    return box.get(key);
  }

  /// Cache data with expiration
  Future<void> cacheData(String key, dynamic value, {Duration? ttl}) async {
    final box = await cacheBox;
    final cacheItem = {
      'data': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'ttl': ttl?.inMilliseconds,
    };
    await box.put(key, cacheItem);
  }

  /// Get cached data
  Future<dynamic> getCachedData(String key) async {
    final box = await cacheBox;
    final cacheItem = box.get(key);

    if (cacheItem == null) return null;

    final timestamp = cacheItem['timestamp'] as int?;
    final ttl = cacheItem['ttl'] as int?;

    if (timestamp == null) return null;

    // Check if cache is expired
    if (ttl != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - timestamp > ttl) {
        await box.delete(key);
        return null;
      }
    }

    return cacheItem['data'];
  }

  /// Clear all data
  Future<void> clearAll() async {
    final userBox = await this.userBox;
    final settingsBox = await this.settingsBox;
    final cacheBox = await this.cacheBox;

    await userBox.clear();
    await settingsBox.clear();
    await cacheBox.clear();
  }

  /// Close all boxes
  Future<void> close() async {
    await Hive.close();
  }
}
