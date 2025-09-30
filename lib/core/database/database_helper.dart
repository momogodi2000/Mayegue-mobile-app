import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Database helper for managing SQLite database operations
class DatabaseHelper {
  static const String _databaseName = 'mayegue_app.db';
  static const int _databaseVersion = 1;

  static Database? _database;

  /// Singleton instance
  static DatabaseHelper get instance => DatabaseHelper._();

  DatabaseHelper._();

  /// Get database instance (singleton pattern)
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  static Future<void> _onCreate(Database db, int version) async {
    // Create dictionary entries table
    await db.execute('''
      CREATE TABLE dictionary_entries (
        id TEXT PRIMARY KEY,
        language_code TEXT NOT NULL,
        canonical_form TEXT NOT NULL,
        orthography_variants TEXT,
        ipa TEXT,
        audio_file_references TEXT,
        part_of_speech TEXT NOT NULL,
        translations TEXT,
        example_sentences TEXT,
        tags TEXT,
        difficulty_level TEXT NOT NULL,
        contributor_id TEXT,
        review_status TEXT NOT NULL,
        verified_by TEXT,
        quality_score REAL DEFAULT 0.0,
        last_updated INTEGER NOT NULL,
        source_reference TEXT,
        metadata TEXT,
        search_terms TEXT,
        is_deleted INTEGER DEFAULT 0,
        needs_sync INTEGER DEFAULT 1,
        has_conflict INTEGER DEFAULT 0,
        conflict_data TEXT,
        last_synced INTEGER,
        deleted_at INTEGER,
        UNIQUE(id)
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX idx_dictionary_language_code ON dictionary_entries(language_code)
    ''');

    await db.execute('''
      CREATE INDEX idx_dictionary_canonical_form ON dictionary_entries(canonical_form)
    ''');

    await db.execute('''
      CREATE INDEX idx_dictionary_review_status ON dictionary_entries(review_status)
    ''');

    await db.execute('''
      CREATE INDEX idx_dictionary_search_terms ON dictionary_entries(search_terms)
    ''');

    await db.execute('''
      CREATE INDEX idx_dictionary_sync_status ON dictionary_entries(needs_sync, has_conflict)
    ''');

    await db.execute('''
      CREATE INDEX idx_dictionary_last_updated ON dictionary_entries(last_updated)
    ''');

    // Create user progress table
    await db.execute('''
      CREATE TABLE user_progress (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        language_code TEXT NOT NULL,
        entry_id TEXT NOT NULL,
        progress_type TEXT NOT NULL,
        progress_value REAL DEFAULT 0.0,
        last_practiced INTEGER,
        streak_count INTEGER DEFAULT 0,
        mastery_level TEXT DEFAULT 'novice',
        metadata TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        needs_sync INTEGER DEFAULT 1,
        FOREIGN KEY(entry_id) REFERENCES dictionary_entries(id),
        UNIQUE(user_id, entry_id, progress_type)
      )
    ''');

    // Create indexes for user progress
    await db.execute('''
      CREATE INDEX idx_progress_user_language ON user_progress(user_id, language_code)
    ''');

    await db.execute('''
      CREATE INDEX idx_progress_entry ON user_progress(entry_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_progress_sync ON user_progress(needs_sync)
    ''');

    // Create offline actions table for tracking user actions while offline
    await db.execute('''
      CREATE TABLE offline_actions (
        id TEXT PRIMARY KEY,
        action_type TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        action_data TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        user_id TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_retry INTEGER,
        is_processed INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_offline_actions_user ON offline_actions(user_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_offline_actions_processed ON offline_actions(is_processed)
    ''');

    // Create sync metadata table
    await db.execute('''
      CREATE TABLE sync_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  /// Handle database upgrades
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema migrations here
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }

  /// Close database connection
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Clear all data (for testing or reset purposes)
  static Future<void> clearAllData() async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('dictionary_entries');
      await txn.delete('user_progress');
      await txn.delete('offline_actions');
      await txn.delete('sync_metadata');
    });
  }

  /// Get database size information
  static Future<Map<String, int>> getDatabaseInfo() async {
    final db = await database;

    final dictionaryCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM dictionary_entries WHERE is_deleted = 0')
    ) ?? 0;

    final progressCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM user_progress')
    ) ?? 0;

    final offlineActionsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM offline_actions WHERE is_processed = 0')
    ) ?? 0;

    final conflictsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM dictionary_entries WHERE has_conflict = 1')
    ) ?? 0;

    final pendingSyncCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM dictionary_entries WHERE needs_sync = 1')
    ) ?? 0;

    return {
      'dictionaryEntries': dictionaryCount,
      'userProgress': progressCount,
      'offlineActions': offlineActionsCount,
      'conflicts': conflictsCount,
      'pendingSync': pendingSyncCount,
    };
  }

  /// Vacuum database to reclaim space
  static Future<void> vacuum() async {
    final db = await database;
    await db.execute('VACUUM');
  }
}