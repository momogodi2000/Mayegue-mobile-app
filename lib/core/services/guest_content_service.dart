import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for managing guest user content
class GuestContentService {
  static Database? _db;
  static FirebaseFirestore? _firestore;

  /// Initialize the service with dependencies
  static void init(Database database, FirebaseFirestore firestore) {
    _db = database;
    _firestore = firestore;
  }

  /// Get basic words for a language
  static Future<List<Map<String, dynamic>>> getBasicWords({
    required String languageCode,
  }) async {
    if (_db == null) {
      throw Exception('GuestContentService not initialized');
    }

    // Get words from SQLite
    final localWords = await _db!.query(
      'words',
      where: 'language_code = ?',
      whereArgs: [languageCode],
      limit: 50,
    );

    // Try to get additional words from Firebase
    List<Map<String, dynamic>> firebaseWords = [];
    try {
      if (_firestore != null) {
        final snapshot = await _firestore!
            .collection('public_content')
            .doc('words')
            .collection('items')
            .where('language_code', isEqualTo: languageCode)
            .where('is_public', isEqualTo: true)
            .limit(50)
            .get();

        firebaseWords = snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList();
      }
    } catch (e) {
      // Ignore Firebase errors and use only local content
    }

    // Merge and return unique words
    final allWords = [...localWords, ...firebaseWords];
    final uniqueWords = <Map<String, dynamic>>[];
    final seenWords = <String>{};

    for (final word in allWords) {
      if (!seenWords.contains(word['word'])) {
        uniqueWords.add(word);
        seenWords.add(word['word'] as String);
      }
    }

    return uniqueWords;
  }

  /// Get words by category
  static Future<List<Map<String, dynamic>>> getWordsByCategory(
    int categoryId, {
    int limit = 50,
  }) async {
    if (_db == null) {
      throw Exception('GuestContentService not initialized');
    }

    // Get words from SQLite
    final localWords = await _db!.query(
      'words',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      limit: limit,
    );

    // Try to get additional words from Firebase
    List<Map<String, dynamic>> firebaseWords = [];
    try {
      if (_firestore != null) {
        final snapshot = await _firestore!
            .collection('public_content')
          .doc('words')
          .collection('items')
            .where('category_id', isEqualTo: categoryId)
            .where('is_public', isEqualTo: true)
            .limit(limit)
            .get();

        firebaseWords = snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList();
      }
    } catch (e) {
      // Ignore Firebase errors and use only local content
    }

    // Merge and return unique words
    final allWords = [...localWords, ...firebaseWords];
    final uniqueWords = <Map<String, dynamic>>[];
    final seenWords = <String>{};

    for (final word in allWords) {
      if (!seenWords.contains(word['word'])) {
        uniqueWords.add(word);
        seenWords.add(word['word'] as String);
      }
    }

    return uniqueWords;
  }

  /// Get lesson content by ID
  static Future<Map<String, dynamic>> getLessonContent(int lessonId) async {
    if (_db == null) {
      throw Exception('GuestContentService not initialized');
    }

    // Get lesson from SQLite
    final lessons = await _db!.query(
      'lessons',
      where: 'id = ?',
      whereArgs: [lessonId],
      limit: 1,
    );

    if (lessons.isEmpty) {
      throw Exception('Lesson not found');
    }

    final lesson = lessons.first;

    // Try to get additional content from Firebase
    try {
      if (_firestore != null) {
        final doc = await _firestore!
            .collection('public_content')
          .doc('lessons')
          .collection('items')
            .doc(lessonId.toString())
          .get();

        if (doc.exists && doc.data()?['is_public'] == true) {
        return {
            ...lesson,
            ...doc.data()!,
            'id': lessonId,
          };
        }
      }
    } catch (e) {
      // Ignore Firebase errors and use only local content
    }

    return lesson;
  }

  /// Get supported languages
  static Future<List<Map<String, dynamic>>> getLanguages() async {
    if (_db == null) {
      throw Exception('GuestContentService not initialized');
    }

    // Get languages from SQLite
    final languages = await _db!.query(
      'languages',
      where: 'is_active = ?',
      whereArgs: [1],
    );

    return languages;
  }

  /// Get available languages for guest users
  static Future<List<Map<String, dynamic>>> getAvailableLanguages() async {
    return await getLanguages();
  }

  /// Get demo lessons for a specific language
  static Future<List<Map<String, dynamic>>> getDemoLessons({
    required String languageCode,
    int limit = 10,
  }) async {
    if (_db == null) {
      throw Exception('GuestContentService not initialized');
    }

    // Get demo lessons from SQLite
    final localLessons = await _db!.query(
      'lessons',
      where: 'language_code = ? AND is_demo = ?',
      whereArgs: [languageCode, 1],
      limit: limit,
    );

    // Try to get additional demo lessons from Firebase
    List<Map<String, dynamic>> firebaseLessons = [];
    try {
      if (_firestore != null) {
        final snapshot = await _firestore!
            .collection('public_content')
            .doc('lessons')
            .collection('items')
            .where('language_code', isEqualTo: languageCode)
            .where('is_demo', isEqualTo: true)
            .where('is_public', isEqualTo: true)
            .limit(limit)
            .get();

        firebaseLessons = snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList();
      }
    } catch (e) {
      // Ignore Firebase errors and use only local content
    }

    // Merge and return unique lessons
    final allLessons = [...localLessons, ...firebaseLessons];
    return allLessons.take(limit).toList();
  }

  /// Get categories for a specific language
  static Future<List<Map<String, dynamic>>> getCategories({
    required String languageCode,
  }) async {
    if (_db == null) {
      throw Exception('GuestContentService not initialized');
    }

    // Get categories from SQLite
    final categories = await _db!.query(
      'categories',
      where: 'language_code = ? AND is_active = ?',
      whereArgs: [languageCode, 1],
    );

    return categories;
  }

  /// Get content statistics for a language
  static Future<Map<String, dynamic>> getContentStats({
    required String languageCode,
  }) async {
    if (_db == null) {
      throw Exception('GuestContentService not initialized');
    }

    // Get word count
    final wordCount = await _db!.rawQuery(
      'SELECT COUNT(*) as count FROM words WHERE language_code = ?',
      [languageCode],
    );

    // Get lesson count
    final lessonCount = await _db!.rawQuery(
      'SELECT COUNT(*) as count FROM lessons WHERE language_code = ?',
      [languageCode],
    );

    // Get category count
    final categoryCount = await _db!.rawQuery(
      'SELECT COUNT(*) as count FROM categories WHERE language_code = ? AND is_active = 1',
      [languageCode],
    );

    return {
      'wordCount': wordCount.first['count'] ?? 0,
      'lessonCount': lessonCount.first['count'] ?? 0,
      'categoryCount': categoryCount.first['count'] ?? 0,
    };
  }

  /// Search words by query
  static Future<List<Map<String, dynamic>>> searchWords({
    required String query,
    required String languageCode,
    int limit = 50,
  }) async {
    if (_db == null) {
      throw Exception('GuestContentService not initialized');
    }

    // Search words in SQLite
    final localWords = await _db!.query(
      'words',
      where: 'language_code = ? AND (word LIKE ? OR translation LIKE ?)',
      whereArgs: [languageCode, '%$query%', '%$query%'],
      limit: limit,
    );

    // Try to search in Firebase
    List<Map<String, dynamic>> firebaseWords = [];
    try {
      if (_firestore != null) {
        final snapshot = await _firestore!
            .collection('public_content')
            .doc('words')
            .collection('items')
            .where('language_code', isEqualTo: languageCode)
            .where('is_public', isEqualTo: true)
            .limit(limit)
            .get();

        firebaseWords = snapshot.docs
            .where((doc) {
              final data = doc.data();
              final word = data['word']?.toString().toLowerCase() ?? '';
              final translation = data['translation']?.toString().toLowerCase() ?? '';
              final searchQuery = query.toLowerCase();
              return word.contains(searchQuery) || translation.contains(searchQuery);
            })
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList();
      }
    } catch (e) {
      // Ignore Firebase errors and use only local content
    }

    // Merge and return unique words
    final allWords = [...localWords, ...firebaseWords];
    final uniqueWords = <Map<String, dynamic>>[];
    final seenWords = <String>{};

    for (final word in allWords) {
      if (!seenWords.contains(word['word'])) {
        uniqueWords.add(word);
        seenWords.add(word['word'] as String);
      }
    }

    return uniqueWords.take(limit).toList();
  }
}