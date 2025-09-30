import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Service for initializing the pre-built SQLite database
class DatabaseInitializationService {
  static const String _assetDatabasePath = 'assets/databases/cameroon_languages.db';
  static const String _databaseName = 'cameroon_languages.db';

  static Database? _database;

  /// Get the database instance, initializing it if necessary
  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initializeDatabase();
    return _database!;
  }

  /// Initialize the database by copying from assets if it doesn't exist
  static Future<Database> _initializeDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    // Check if database already exists
    final exists = await databaseExists(path);

    if (!exists) {
      // Copy database from assets
      await _copyDatabaseFromAssets(path);
    }

    // Open the database
    return await openDatabase(path, readOnly: false);
  }

  /// Copy the database from assets to the app's database directory
  static Future<void> _copyDatabaseFromAssets(String dbPath) async {
    try {
      // Load database from assets
      final data = await rootBundle.load(_assetDatabasePath);
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Ensure the directory exists
      final directory = Directory(dirname(dbPath));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Write the database file
      await File(dbPath).writeAsBytes(bytes, flush: true);
    } catch (e) {
      throw Exception('Error copying database from assets: $e');
    }
  }

  /// Check if the database needs to be updated (for future migrations)
  static Future<bool> needsUpdate() async {
    // For now, always return false since we're using a pre-built database
    // In the future, this could check version numbers
    return false;
  }

  /// Get database statistics
  static Future<Map<String, int>> getDatabaseStats() async {
    final db = await database;

    final languagesCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM languages')
    ) ?? 0;

    final categoriesCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM categories')
    ) ?? 0;

    final translationsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM translations')
    ) ?? 0;

    return {
      'languages': languagesCount,
      'categories': categoriesCount,
      'translations': translationsCount,
    };
  }

  /// Close the database connection
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}