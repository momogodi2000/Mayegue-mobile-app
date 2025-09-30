import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sync_operation.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  Database? _database;
  SharedPreferences? _preferences;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<SharedPreferences> get preferences async {
    if (_preferences != null) return _preferences!;
    _preferences = await SharedPreferences.getInstance();
    return _preferences!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mayegue_local.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Sync operations table
    await db.execute('''
      CREATE TABLE sync_operations (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        data TEXT NOT NULL,
        local_id TEXT,
        firebase_id TEXT,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        last_attempt_at TEXT,
        retry_count INTEGER DEFAULT 0,
        max_retries INTEGER DEFAULT 3,
        error_message TEXT,
        metadata TEXT
      )
    ''');

    // Dictionary entries table (local cache)
    await db.execute('''
      CREATE TABLE dictionary_entries (
        id TEXT PRIMARY KEY,
        firebase_id TEXT,
        canonical_form TEXT NOT NULL,
        language_code TEXT NOT NULL,
        translations TEXT,
        pronunciation TEXT,
        phonetic TEXT,
        part_of_speech TEXT,
        definition TEXT,
        examples TEXT,
        difficulty TEXT,
        contributor_id TEXT,
        review_status TEXT,
        tags TEXT,
        audio_url TEXT,
        created_at TEXT,
        updated_at TEXT,
        quality_score REAL,
        usage_count INTEGER DEFAULT 0,
        is_favorite INTEGER DEFAULT 0,
        sync_status TEXT DEFAULT 'synced'
      )
    ''');

    // User progress table
    await db.execute('''
      CREATE TABLE user_progress (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        entry_id TEXT NOT NULL,
        progress_type TEXT NOT NULL,
        progress_value REAL NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT DEFAULT 'synced'
      )
    ''');

    // App metadata table
    await db.execute('''
      CREATE TABLE app_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_dictionary_language ON dictionary_entries(language_code)');
    await db.execute('CREATE INDEX idx_dictionary_status ON dictionary_entries(review_status)');
    await db.execute('CREATE INDEX idx_dictionary_contributor ON dictionary_entries(contributor_id)');
    await db.execute('CREATE INDEX idx_sync_status ON sync_operations(status)');
    await db.execute('CREATE INDEX idx_sync_type ON sync_operations(type)');
    await db.execute('CREATE INDEX idx_progress_user ON user_progress(user_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < newVersion) {
      // Add migration logic for future versions
    }
  }

  // Sync Operations CRUD
  Future<List<SyncOperation>> getPendingSyncOperations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sync_operations',
      where: 'status IN (?, ?, ?)',
      whereArgs: ['pending', 'failed', 'retrying'],
      orderBy: 'created_at ASC',
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return SyncOperation.fromJson({
        'id': map['id'],
        'type': map['type'],
        'data': jsonDecode(map['data']),
        'localId': map['local_id'],
        'firebaseId': map['firebase_id'],
        'status': map['status'],
        'createdAt': map['created_at'],
        'lastAttemptAt': map['last_attempt_at'],
        'retryCount': map['retry_count'],
        'maxRetries': map['max_retries'],
        'errorMessage': map['error_message'],
        'metadata': map['metadata'] != null ? jsonDecode(map['metadata']) : {},
      });
    });
  }

  Future<void> savePendingSyncOperations(List<SyncOperation> operations) async {
    final db = await database;
    final batch = db.batch();

    // Clear existing operations
    batch.delete('sync_operations');

    // Insert new operations
    for (final operation in operations) {
      batch.insert('sync_operations', {
        'id': operation.id,
        'type': operation.type.toString(),
        'data': jsonEncode(operation.data),
        'local_id': operation.localId,
        'firebase_id': operation.firebaseId,
        'status': operation.status.toString(),
        'created_at': operation.createdAt.toIso8601String(),
        'last_attempt_at': operation.lastAttemptAt?.toIso8601String(),
        'retry_count': operation.retryCount,
        'max_retries': operation.maxRetries,
        'error_message': operation.errorMessage,
        'metadata': jsonEncode(operation.metadata),
      });
    }

    await batch.commit();
  }

  Future<void> updateSyncOperation(SyncOperation operation) async {
    final db = await database;
    await db.update(
      'sync_operations',
      {
        'status': operation.status.toString(),
        'last_attempt_at': DateTime.now().toIso8601String(),
        'retry_count': operation.retryCount,
        'error_message': operation.errorMessage,
      },
      where: 'id = ?',
      whereArgs: [operation.id],
    );
  }

  // Dictionary Entry CRUD
  Future<void> updateDictionaryEntryFirebaseId(String localId, String firebaseId) async {
    final db = await database;
    await db.update(
      'dictionary_entries',
      {'firebase_id': firebaseId, 'sync_status': 'synced'},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> insertDictionaryEntry(Map<String, dynamic> entry) async {
    final db = await database;
    await db.insert('dictionary_entries', {
      ...entry,
      'translations': jsonEncode(entry['translations'] ?? {}),
      'examples': jsonEncode(entry['examples'] ?? []),
      'tags': jsonEncode(entry['tags'] ?? []),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getDictionaryEntries({
    String? languageCode,
    String? contributorId,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (languageCode != null) {
      whereClause += 'language_code = ?';
      whereArgs.add(languageCode);
    }

    if (contributorId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'contributor_id = ?';
      whereArgs.add(contributorId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'dictionary_entries',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'updated_at DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) {
      final result = Map<String, dynamic>.from(map);
      if (result['translations'] != null) {
        result['translations'] = jsonDecode(result['translations']);
      }
      if (result['examples'] != null) {
        result['examples'] = jsonDecode(result['examples']);
      }
      if (result['tags'] != null) {
        result['tags'] = jsonDecode(result['tags']);
      }
      return result;
    }).toList();
  }

  // App Metadata CRUD
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await preferences;
    final lastSyncString = prefs.getString('last_sync_time');
    return lastSyncString != null ? DateTime.parse(lastSyncString) : null;
  }

  Future<void> saveLastSyncTime(DateTime time) async {
    final prefs = await preferences;
    await prefs.setString('last_sync_time', time.toIso8601String());
  }

  Future<void> setMetadata(String key, String value) async {
    final db = await database;
    await db.insert(
      'app_metadata',
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getMetadata(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_metadata',
      where: 'key = ?',
      whereArgs: [key],
    );

    return maps.isNotEmpty ? maps.first['value'] as String : null;
  }

  // Cleanup methods
  Future<void> cleanupExpiredOperations() async {
    final db = await database;
    final expiredDate = DateTime.now().subtract(const Duration(days: 7));
    await db.delete(
      'sync_operations',
      where: 'created_at < ? AND status = ?',
      whereArgs: [expiredDate.toIso8601String(), 'completed'],
    );
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('sync_operations');
    await db.delete('dictionary_entries');
    await db.delete('user_progress');
    await db.delete('app_metadata');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}