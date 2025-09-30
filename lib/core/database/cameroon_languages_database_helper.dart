import 'package:sqflite/sqflite.dart';
import '../../features/dictionary/domain/entities/dictionary_entry_entity.dart';
import '../../features/lessons/domain/entities/lesson.dart';
import '../../features/lessons/domain/entities/lesson_content.dart';
import 'database_initialization_service.dart';

/// Database helper specifically for Cameroon languages data
class CameroonLanguagesDatabaseHelper {
  static Database? _database;

  /// Get the database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await DatabaseInitializationService.database;
    return _database!;
  }

  /// Get all languages
  static Future<List<Map<String, dynamic>>> getAllLanguages() async {
    final db = await database;
    return await db.query('languages');
  }

  /// Get all categories
  static Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query('categories');
  }

  /// Get translations by language
  static Future<List<Map<String, dynamic>>> getTranslationsByLanguage(
      String languageId) async {
    final db = await database;
    return await db.query(
      'translations',
      where: 'language_id = ?',
      whereArgs: [languageId],
    );
  }

  /// Get lessons by language
  static Future<List<Map<String, dynamic>>> getLessonsByLanguage(
      String languageId) async {
    final db = await database;
    return await db.query(
      'lessons',
      where: 'language_id = ?',
      whereArgs: [languageId],
      orderBy: 'order_index',
    );
  }

  /// Get all lessons
  static Future<List<Map<String, dynamic>>> getAllLessons() async {
    final db = await database;
    return await db.query('lessons', orderBy: 'language_id, order_index');
  }

  /// Get lesson by ID
  static Future<Map<String, dynamic>?> getLessonById(int lessonId) async {
    final db = await database;
    final results = await db.query(
      'lessons',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get lessons by level
  static Future<List<Map<String, dynamic>>> getLessonsByLevel(
      String level) async {
    final db = await database;
    return await db.query(
      'lessons',
      where: 'level = ?',
      whereArgs: [level],
      orderBy: 'language_id, order_index',
    );
  }

  /// Convert Cameroon languages data to dictionary entries
  static Future<List<DictionaryEntryEntity>>
      getDictionaryEntriesFromTranslations() async {
    final translations = await database.then((db) => db.query('translations'));
    final languages = await getAllLanguages();
    final categories = await getAllCategories();

    // Create language and category maps for lookup
    final languageMap = Map.fromEntries(
        languages.map((lang) => MapEntry(lang['language_id'], lang)));

    final categoryMap = Map.fromEntries(
        categories.map((cat) => MapEntry(cat['category_id'], cat)));

    return translations.map((translation) {
      final languageId = translation['language_id'] as String;
      final categoryId = translation['category_id'] as String;
      final language = languageMap[languageId];
      final category = categoryMap[categoryId];

      return DictionaryEntryEntity(
        id: '${languageId}_${translation['translation_id']}',
        languageCode: languageId,
        canonicalForm: translation['translation'] as String,
        orthographyVariants: const [],
        ipa: translation['pronunciation'] as String?,
        audioFileReferences: const [],
        partOfSpeech: _mapCategoryToPartOfSpeech(categoryId),
        translations: {
          'fr': translation['french_text'] as String,
        },
        exampleSentences: const [],
        tags: [category?['category_name'] as String? ?? categoryId],
        difficultyLevel:
            _mapDifficultyLevel(translation['difficulty_level'] as String?),
        contributorId: 'system',
        reviewStatus: ReviewStatus.humanVerified,
        qualityScore: 1.0,
        lastUpdated: DateTime.now(),
        sourceReference: 'cameroon_languages_database',
        metadata: {
          'language_name': language?['language_name'],
          'region': language?['region'],
          'category_description': category?['description'],
        },
      );
    }).toList();
  }

  /// Convert translations to lesson content
  static Future<List<Lesson>> getLessonsFromTranslations() async {
    final languages = await getAllLanguages();
    final categories = await getAllCategories();

    final lessons = <Lesson>[];

    for (final language in languages) {
      final languageId = language['language_id'] as String;
      final languageName = language['language_name'] as String;

      // Group translations by category for this language
      final translations = await getTranslationsByLanguage(languageId);

      for (final category in categories) {
        final categoryId = category['category_id'] as String;
        final categoryName = category['category_name'] as String;

        final categoryTranslations =
            translations.where((t) => t['category_id'] == categoryId).toList();

        if (categoryTranslations.isNotEmpty) {
          final lessonContent = categoryTranslations.map((translation) {
            return LessonContent(
              id: '${languageId}_${categoryId}_${translation['translation_id']}',
              lessonId: '${languageId}_${categoryId}_lesson',
              type: ContentType.text,
              content:
                  '${translation['french_text']} - ${translation['translation']}',
              order: categoryTranslations.indexOf(translation),
              metadata: {
                'pronunciation': translation['pronunciation'],
                'difficulty': translation['difficulty_level'],
                'french_text': translation['french_text'],
                'translation': translation['translation'],
              },
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }).toList();

          lessons.add(
            Lesson(
              id: '${languageId}_${categoryId}_lesson',
              courseId: '${languageId}_basics',
              title: '$categoryName - $languageName',
              description: 'Apprenez les $categoryName en $languageName',
              order: categories.indexOf(category),
              type: LessonType.vocabulary,
              status: LessonStatus.available,
              estimatedDuration:
                  categoryTranslations.length * 2, // 2 minutes per word
              thumbnailUrl: '',
              contents: lessonContent,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        }
      }
    }

    return lessons;
  }

  /// Map category ID to part of speech
  static String _mapCategoryToPartOfSpeech(String categoryId) {
    switch (categoryId) {
      case 'GRT':
        return 'greeting';
      case 'NUM':
        return 'number';
      case 'FAM':
        return 'noun';
      case 'FOD':
        return 'noun';
      case 'BOD':
        return 'noun';
      case 'VRB':
        return 'verb';
      case 'ADJ':
        return 'adjective';
      case 'HOM':
        return 'noun';
      case 'ANI':
        return 'noun';
      case 'NAT':
        return 'noun';
      case 'PRO':
        return 'noun';
      case 'TRA':
        return 'noun';
      case 'EMO':
        return 'noun';
      case 'REL':
        return 'noun';
      case 'MUS':
        return 'noun';
      case 'SPO':
        return 'verb';
      case 'EDU':
        return 'noun';
      case 'HEA':
        return 'noun';
      case 'MON':
        return 'noun';
      case 'DIR':
        return 'adverb';
      case 'TIM':
        return 'noun';
      case 'CLO':
        return 'noun';
      case 'PHR':
        return 'phrase';
      default:
        return 'unknown';
    }
  }

  /// Map difficulty level string to enum
  static DifficultyLevel _mapDifficultyLevel(String? difficulty) {
    switch (difficulty) {
      case 'beginner':
        return DifficultyLevel.beginner;
      case 'intermediate':
        return DifficultyLevel.intermediate;
      case 'advanced':
        return DifficultyLevel.advanced;
      default:
        return DifficultyLevel.beginner;
    }
  }

  /// Close the database connection
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
