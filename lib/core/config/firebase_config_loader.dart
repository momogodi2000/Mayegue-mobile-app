import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FirebaseConfigLoader {
  static const String _firebaseDataPath = 'firebase/';

  // Cache for loaded JSON data
  static final Map<String, dynamic> _cache = {};

  /// Load Firebase seed data from JSON files
  static Future<Map<String, dynamic>?> loadSeedData(String fileName) async {
    try {
      final cacheKey = 'seed_$fileName';
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey];
      }

      String jsonString;

      if (kIsWeb) {
        // For web, load from assets
        jsonString = await rootBundle.loadString('assets/$_firebaseDataPath$fileName');
      } else {
        // For mobile, try to load from assets first, then from file system
        try {
          jsonString = await rootBundle.loadString('assets/$_firebaseDataPath$fileName');
        } catch (e) {
          // Fallback to file system for development
          final file = File('$_firebaseDataPath$fileName');
          if (await file.exists()) {
            jsonString = await file.readAsString();
          } else {
            debugPrint('❌ Firebase seed file not found: $fileName');
            return null;
          }
        }
      }

      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      _cache[cacheKey] = data;

      debugPrint('✅ Loaded Firebase seed data: $fileName');
      return data;
    } catch (e) {
      debugPrint('❌ Error loading Firebase seed data $fileName: $e');
      return null;
    }
  }

  /// Load dictionary seed data
  static Future<List<Map<String, dynamic>>> loadDictionarySeedData() async {
    try {
      final data = await loadSeedData('enhanced_dictionary_seed.json');
      if (data != null && data['words'] != null) {
        return List<Map<String, dynamic>>.from(data['words']);
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error loading dictionary seed data: $e');
      return [];
    }
  }

  /// Load lesson seed data
  static Future<List<Map<String, dynamic>>> loadLessonSeedData() async {
    try {
      final data = await loadSeedData('lesson_seed_data.json');
      if (data != null && data['lessons'] != null) {
        return List<Map<String, dynamic>>.from(data['lessons']);
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error loading lesson seed data: $e');
      return [];
    }
  }

  /// Load gamification seed data
  static Future<Map<String, dynamic>> loadGamificationSeedData() async {
    try {
      final data = await loadSeedData('gamification_seed_data.json');
      return data ?? {};
    } catch (e) {
      debugPrint('❌ Error loading gamification seed data: $e');
      return {};
    }
  }

  /// Load Firestore indexes configuration
  static Future<Map<String, dynamic>?> loadFirestoreIndexes() async {
    try {
      return await loadSeedData('firestore.indexes.json');
    } catch (e) {
      debugPrint('❌ Error loading Firestore indexes: $e');
      return null;
    }
  }

  /// Load general Firebase seed data
  static Future<Map<String, dynamic>?> loadGeneralSeedData() async {
    try {
      return await loadSeedData('firebase_seed_data.json');
    } catch (e) {
      debugPrint('❌ Error loading general Firebase seed data: $e');
      return null;
    }
  }

  /// Initialize all seed data
  static Future<FirebaseSeedDataBundle> initializeAllSeedData() async {
    debugPrint('🔄 Loading all Firebase seed data...');

    final futures = [
      loadDictionarySeedData(),
      loadLessonSeedData(),
      loadGamificationSeedData(),
      loadFirestoreIndexes(),
      loadGeneralSeedData(),
    ];

    final results = await Future.wait(futures);

    final bundle = FirebaseSeedDataBundle(
      dictionaryData: results[0] as List<Map<String, dynamic>>,
      lessonData: results[1] as List<Map<String, dynamic>>,
      gamificationData: results[2] as Map<String, dynamic>,
      firestoreIndexes: results[3] as Map<String, dynamic>?,
      generalSeedData: results[4] as Map<String, dynamic>?,
    );

    debugPrint('✅ All Firebase seed data loaded successfully');
    debugPrint('📊 Dictionary entries: ${bundle.dictionaryData.length}');
    debugPrint('📚 Lesson entries: ${bundle.lessonData.length}');
    debugPrint('🎮 Gamification data loaded: ${bundle.gamificationData.isNotEmpty}');

    return bundle;
  }

  /// Check if all required files exist
  static Future<bool> validateSeedDataFiles() async {
    final requiredFiles = [
      'enhanced_dictionary_seed.json',
      'lesson_seed_data.json',
      'gamification_seed_data.json',
      'firestore.indexes.json',
      'firebase_seed_data.json',
    ];

    for (final fileName in requiredFiles) {
      try {
        if (kIsWeb) {
          await rootBundle.loadString('assets/$_firebaseDataPath$fileName');
        } else {
          try {
            await rootBundle.loadString('assets/$_firebaseDataPath$fileName');
          } catch (e) {
            final file = File('$_firebaseDataPath$fileName');
            if (!await file.exists()) {
              debugPrint('❌ Missing Firebase seed file: $fileName');
              return false;
            }
          }
        }
      } catch (e) {
        debugPrint('❌ Cannot access Firebase seed file: $fileName');
        return false;
      }
    }

    debugPrint('✅ All Firebase seed data files validated');
    return true;
  }

  /// Clear cache
  static void clearCache() {
    _cache.clear();
    debugPrint('🧹 Firebase config cache cleared');
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'cached_files': _cache.keys.toList(),
      'cache_size': _cache.length,
      'memory_usage_estimate': _cache.toString().length * 2, // rough estimate
    };
  }
}

/// Bundle containing all Firebase seed data
class FirebaseSeedDataBundle {
  final List<Map<String, dynamic>> dictionaryData;
  final List<Map<String, dynamic>> lessonData;
  final Map<String, dynamic> gamificationData;
  final Map<String, dynamic>? firestoreIndexes;
  final Map<String, dynamic>? generalSeedData;

  const FirebaseSeedDataBundle({
    required this.dictionaryData,
    required this.lessonData,
    required this.gamificationData,
    this.firestoreIndexes,
    this.generalSeedData,
  });

  /// Check if all data is loaded
  bool get isComplete {
    return dictionaryData.isNotEmpty &&
           lessonData.isNotEmpty &&
           gamificationData.isNotEmpty;
  }

  /// Get summary statistics
  Map<String, dynamic> get stats {
    return {
      'dictionary_entries': dictionaryData.length,
      'lesson_entries': lessonData.length,
      'gamification_loaded': gamificationData.isNotEmpty,
      'indexes_loaded': firestoreIndexes != null,
      'general_data_loaded': generalSeedData != null,
      'is_complete': isComplete,
    };
  }

  /// Get all unique languages from dictionary data
  Set<String> get availableLanguages {
    final languages = <String>{};
    for (final word in dictionaryData) {
      if (word['languageCode'] != null) {
        languages.add(word['languageCode'] as String);
      }
    }
    return languages;
  }

  /// Get word count by language
  Map<String, int> get wordCountByLanguage {
    final counts = <String, int>{};
    for (final word in dictionaryData) {
      final lang = word['languageCode'] as String?;
      if (lang != null) {
        counts[lang] = (counts[lang] ?? 0) + 1;
      }
    }
    return counts;
  }
}