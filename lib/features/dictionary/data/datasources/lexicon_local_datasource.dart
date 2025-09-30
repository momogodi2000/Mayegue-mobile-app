import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/dictionary_entry_model.dart';
import '../../domain/entities/dictionary_entry_entity.dart';
import '../../../../core/database/database_helper.dart';

/// Local data source for dictionary entries using SQLite
abstract class LexiconLocalDataSource {
  Future<List<DictionaryEntryModel>> getAllEntries();
  Future<List<DictionaryEntryModel>> getEntriesByLanguage(String languageCode);
  Future<DictionaryEntryModel?> getEntry(String id);
  Future<List<DictionaryEntryModel>> searchEntries({
    String? query,
    String? languageCode,
    DifficultyLevel? difficulty,
    ReviewStatus? status,
    List<String>? tags,
    int? limit,
    int? offset,
  });
  Future<void> insertEntry(DictionaryEntryModel entry);
  Future<void> insertEntries(List<DictionaryEntryModel> entries);
  Future<void> updateEntry(DictionaryEntryModel entry);
  Future<void> deleteEntry(String id);
  Future<void> markAsDeleted(String id, DateTime deletedAt);
  Future<List<DictionaryEntryModel>> getPendingSyncEntries();
  Future<List<DictionaryEntryModel>> getConflictEntries();
  Future<void> markAsSynced(String id);
  Future<void> markAsConflict(String id, Map<String, dynamic> conflictData);
  Future<void> resolveConflict(String id, DictionaryEntryModel resolvedEntry);
  Future<void> queueForSync(DictionaryEntryModel entry);
  Future<int> getEntriesCount({String? languageCode, ReviewStatus? status});
  Future<void> clearAll();
  
  // Additional methods
  Future<void> cacheEntry(DictionaryEntryModel entry);
  Future<List<String>> getWordSuggestions({String? query, int? limit});
  Future<DictionaryEntryModel?> getRandomEntry();
  Future<void> removeFromCache(String id);
  Future<void> queueDeletionForSync(String id);
  Future<List<DictionaryEntryModel>> getQueuedForSync();
  Future<List<String>> getQueuedDeletions();
  Future<void> removeDeletionFromQueue(String id);
  Future<List<DictionaryEntryModel>> getEntriesByDifficulty(DifficultyLevel difficulty);
}

class LexiconLocalDataSourceImpl implements LexiconLocalDataSource {
  Future<Database> get _database => DatabaseHelper.database;

  static const String _tableName = 'dictionary_entries';

  @override
  Future<List<DictionaryEntryModel>> getAllEntries() async {
    final List<Map<String, dynamic>> maps = await (await _database).query(
      _tableName,
      where: 'is_deleted = ?',
      whereArgs: [0],
      orderBy: 'canonical_form ASC',
    );

    return maps.map((map) => DictionaryEntryModel.fromSQLite(map)).toList();
  }

  @override
  Future<List<DictionaryEntryModel>> getEntriesByLanguage(String languageCode) async {
    final List<Map<String, dynamic>> maps = await (await _database).query(
      _tableName,
      where: 'language_code = ? AND is_deleted = ?',
      whereArgs: [languageCode, 0],
      orderBy: 'canonical_form ASC',
    );

    return maps.map((map) => DictionaryEntryModel.fromSQLite(map)).toList();
  }

  @override
  Future<DictionaryEntryModel?> getEntry(String id) async {
    final List<Map<String, dynamic>> maps = await (await _database).query(
      _tableName,
      where: 'id = ? AND is_deleted = ?',
      whereArgs: [id, 0],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return DictionaryEntryModel.fromSQLite(maps.first);
    }
    return null;
  }

  @override
  Future<List<DictionaryEntryModel>> searchEntries({
    String? query,
    String? languageCode,
    DifficultyLevel? difficulty,
    ReviewStatus? status,
    List<String>? tags,
    int? limit,
    int? offset,
  }) async {
    String whereClause = 'is_deleted = ?';
    List<dynamic> whereArgs = [0];

    if (query != null && query.isNotEmpty) {
      whereClause += ' AND (canonical_form LIKE ? OR search_terms LIKE ?)';
      whereArgs.addAll(['%$query%', '%$query%']);
    }

    if (languageCode != null) {
      whereClause += ' AND language_code = ?';
      whereArgs.add(languageCode);
    }

    if (difficulty != null) {
      whereClause += ' AND difficulty_level = ?';
      whereArgs.add(difficulty.toString().split('.').last);
    }

    if (status != null) {
      whereClause += ' AND review_status = ?';
      whereArgs.add(status.toString().split('.').last);
    }

    if (tags != null && tags.isNotEmpty) {
      // Simple tag search - check if any tag is contained in the tags JSON
      for (String tag in tags) {
        whereClause += ' AND tags LIKE ?';
        whereArgs.add('%"$tag"%');
      }
    }

    final List<Map<String, dynamic>> maps = await (await _database).query(
      _tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'canonical_form ASC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => DictionaryEntryModel.fromSQLite(map)).toList();
  }

  @override
  Future<void> insertEntry(DictionaryEntryModel entry) async {
    await (await _database).insert(
      _tableName,
      entry.toSQLite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> insertEntries(List<DictionaryEntryModel> entries) async {
    final batch = (await _database).batch();
    for (final entry in entries) {
      batch.insert(
        _tableName,
        entry.toSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  @override
  Future<void> updateEntry(DictionaryEntryModel entry) async {
    await (await _database).update(
      _tableName,
      entry.toSQLite(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  @override
  Future<void> deleteEntry(String id) async {
    await (await _database).delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> markAsDeleted(String id, DateTime deletedAt) async {
    await (await _database).update(
      _tableName,
      {
        'is_deleted': 1,
        'deleted_at': deletedAt.millisecondsSinceEpoch,
        'needs_sync': 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<DictionaryEntryModel>> getPendingSyncEntries() async {
    final List<Map<String, dynamic>> maps = await (await _database).query(
      _tableName,
      where: 'needs_sync = ? AND has_conflict = ?',
      whereArgs: [1, 0],
      orderBy: 'last_updated ASC',
    );

    return maps.map((map) => DictionaryEntryModel.fromSQLite(map)).toList();
  }

  @override
  Future<List<DictionaryEntryModel>> getConflictEntries() async {
    final List<Map<String, dynamic>> maps = await (await _database).query(
      _tableName,
      where: 'has_conflict = ?',
      whereArgs: [1],
      orderBy: 'last_updated DESC',
    );

    return maps.map((map) => DictionaryEntryModel.fromSQLite(map)).toList();
  }

  @override
  Future<void> markAsSynced(String id) async {
    await (await _database).update(
      _tableName,
      {
        'needs_sync': 0,
        'last_synced': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> markAsConflict(String id, Map<String, dynamic> conflictData) async {
    await (await _database).update(
      _tableName,
      {
        'has_conflict': 1,
        'conflict_data': jsonEncode(conflictData),
        'needs_sync': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> resolveConflict(String id, DictionaryEntryModel resolvedEntry) async {
    await (await _database).update(
      _tableName,
      {
        ...resolvedEntry.toSQLite(),
        'has_conflict': 0,
        'conflict_data': null,
        'needs_sync': 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> queueForSync(DictionaryEntryModel entry) async {
    await (await _database).insert(
      _tableName,
      entry.toSQLite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<int> getEntriesCount({String? languageCode, ReviewStatus? status}) async {
    String whereClause = 'is_deleted = ?';
    List<dynamic> whereArgs = [0];

    if (languageCode != null) {
      whereClause += ' AND language_code = ?';
      whereArgs.add(languageCode);
    }

    if (status != null) {
      whereClause += ' AND review_status = ?';
      whereArgs.add(status.toString().split('.').last);
    }

    final result = await (await _database).query(
      _tableName,
      columns: ['COUNT(*) as count'],
      where: whereClause,
      whereArgs: whereArgs,
    );

    return result.first['count'] as int;
  }

  @override
  Future<void> clearAll() async {
    await (await _database).delete(_tableName);
  }

  @override
  Future<void> cacheEntry(DictionaryEntryModel entry) async {
    // Check if entry exists, update or insert accordingly
    final existing = await getEntry(entry.id);
    if (existing != null) {
      await updateEntry(entry);
    } else {
      await insertEntry(entry);
    }
  }

  @override
  Future<List<String>> getWordSuggestions({String? query, int? limit}) async {
    if (query == null || query.isEmpty) return [];

    final results = await (await _database).query(
      _tableName,
      columns: ['canonical_form'],
      where: 'canonical_form LIKE ? AND is_deleted = ?',
      whereArgs: ['%$query%', 0],
      limit: limit ?? 10,
      orderBy: 'canonical_form ASC',
    );

    return results.map((row) => row['canonical_form'] as String).toList();
  }

  @override
  Future<DictionaryEntryModel?> getRandomEntry() async {
    final results = await (await _database).query(
      _tableName,
      where: 'is_deleted = ?',
      whereArgs: [0],
      limit: 1,
      orderBy: 'RANDOM()',
    );

    if (results.isEmpty) return null;
    return DictionaryEntryModel.fromSQLite(results.first);
  }

  @override
  Future<void> removeFromCache(String id) async {
    await deleteEntry(id);
  }

  @override
  Future<void> queueDeletionForSync(String id) async {
    await (await _database).update(
      _tableName,
      {'needs_sync': 1, 'sync_operation': 'delete'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<DictionaryEntryModel>> getQueuedForSync() async {
    final results = await (await _database).query(
      _tableName,
      where: 'needs_sync = ?',
      whereArgs: [1],
    );

    return results.map((row) => DictionaryEntryModel.fromSQLite(row)).toList();
  }

  @override
  Future<List<String>> getQueuedDeletions() async {
    final results = await (await _database).query(
      _tableName,
      columns: ['id'],
      where: 'needs_sync = ? AND sync_operation = ?',
      whereArgs: [1, 'delete'],
    );

    return results.map((row) => row['id'] as String).toList();
  }

  @override
  Future<void> removeDeletionFromQueue(String id) async {
    await (await _database).update(
      _tableName,
      {'needs_sync': 0, 'sync_operation': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<DictionaryEntryModel>> getEntriesByDifficulty(DifficultyLevel difficulty) async {
    final results = await (await _database).query(
      _tableName,
      where: 'difficulty = ? AND is_deleted = ?',
      whereArgs: [difficulty.toString().split('.').last, 0],
      orderBy: 'canonical_form ASC',
    );

    return results.map((row) => DictionaryEntryModel.fromSQLite(row)).toList();
  }
}