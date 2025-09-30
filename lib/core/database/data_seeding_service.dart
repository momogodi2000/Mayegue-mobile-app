import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/dictionary/data/models/dictionary_entry_model.dart';
import '../../features/lessons/data/models/lesson_model.dart';
import '../../features/lessons/data/datasources/lesson_local_datasource.dart';
import 'database_helper.dart';
import 'cameroon_languages_database_helper.dart';

/// Service for seeding the main app database with initial Cameroon languages data
class DataSeedingService {
  static const String _seededKey = 'cameroon_languages_seeded';

  /// Check if the database has already been seeded
  static Future<bool> isSeeded() async {
    final db = await DatabaseHelper.database;
    final result = await db.query(
      'sync_metadata',
      where: 'key = ?',
      whereArgs: [_seededKey],
    );
    return result.isNotEmpty;
  }

  /// Mark the database as seeded
  static Future<void> markAsSeeded() async {
    final db = await DatabaseHelper.database;
    await db.insert(
      'sync_metadata',
      {
        'key': _seededKey,
        'value': 'true',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Seed the main database with Cameroon languages data
  static Future<void> seedDatabase() async {
    // Check if already seeded
    if (await isSeeded()) {
      debugPrint('Database already seeded with Cameroon languages data');
      return;
    }

    debugPrint('Seeding database with Cameroon languages data...');

    try {
      // Get data from Cameroon languages database
      final dictionaryEntries = await CameroonLanguagesDatabaseHelper.getDictionaryEntriesFromTranslations();
      final lessons = await CameroonLanguagesDatabaseHelper.getLessonsFromTranslations();

      final db = await DatabaseHelper.database;

      // Insert dictionary entries
      await db.transaction((txn) async {
        for (final entry in dictionaryEntries) {
          final model = DictionaryEntryModel.fromEntity(entry);
          await txn.insert(
            'dictionary_entries',
            model.toSQLite(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });

      // Insert lessons into Hive (not SQLite)
      final lessonLocalDataSource = LessonLocalDataSource();
      await lessonLocalDataSource.initialize();
      
      for (final lesson in lessons) {
        final lessonModel = LessonModel.fromEntity(lesson);
        await lessonLocalDataSource.createLesson(lessonModel);
      }

      // Mark as seeded
      await markAsSeeded();

      debugPrint('Successfully seeded database with ${dictionaryEntries.length} dictionary entries and ${lessons.length} lessons');

    } catch (e) {
      debugPrint('Error seeding database: $e');
      rethrow;
    }
  }

  /// Get seeding statistics
  static Future<Map<String, int>> getSeedingStats() async {
    final db = await DatabaseHelper.database;

    final dictionaryCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM dictionary_entries WHERE contributor_id = ?', ['system'])
    ) ?? 0;

    // For lessons, we need to check Hive boxes
    final lessonLocalDataSource = LessonLocalDataSource();
    await lessonLocalDataSource.initialize();
    
    // Get lesson count from Hive (this is approximate since we can't easily count)
    // For now, return 0 and note that lessons are in Hive
    const lessonCount = 0; // TODO: Implement proper counting from Hive
    const contentCount = 0; // TODO: Implement proper counting from Hive

    return {
      'dictionaryEntries': dictionaryCount,
      'lessons': lessonCount,
      'lessonContents': contentCount,
    };
  }

  /// Clear seeded data (for testing or reset)
  static Future<void> clearSeededData() async {
    final db = await DatabaseHelper.database;

    await db.transaction((txn) async {
      // Delete system-contributed dictionary entries
      await txn.delete(
        'dictionary_entries',
        where: 'contributor_id = ?',
        whereArgs: ['system'],
      );

      // Remove seeded marker
      await txn.delete(
        'sync_metadata',
        where: 'key = ?',
        whereArgs: [_seededKey],
      );
    });

    // Clear lessons from Hive
    final lessonLocalDataSource = LessonLocalDataSource();
    await lessonLocalDataSource.initialize();
    
    // Clear all lessons (this is a simple approach - in production you'd want to be more selective)
    // For now, we'll leave this as is since the lesson datasource already has sample data initialization
  }
}