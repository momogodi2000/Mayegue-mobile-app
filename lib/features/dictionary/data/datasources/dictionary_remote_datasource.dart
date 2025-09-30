import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../models/word_model.dart';
import '../models/pronunciation_model.dart';
import '../models/translation_model.dart';

/// Remote data source for dictionary operations using Firebase
abstract class DictionaryRemoteDataSource {
  /// Search for words by query across multiple languages
  Future<List<WordModel>> searchWords(
    String query, {
    String? sourceLanguage,
    String? targetLanguage,
    List<String>? categories,
    int? maxDifficulty,
  });

  /// Get word by ID
  Future<WordModel> getWord(String wordId);

  /// Get all translations for a word across all supported languages
  Future<List<TranslationModel>> getAllTranslations(String wordId);

  /// Get translations for a word in specific target languages
  Future<List<TranslationModel>> getTranslations(String wordId, List<String> targetLanguages);

  /// Get pronunciation for a word in specific language
  Future<PronunciationModel> getPronunciation(String wordId, String language);

  /// Add a new word to dictionary
  Future<WordModel> addWord(WordModel word);

  /// Add translation for an existing word
  Future<TranslationModel> addTranslation(TranslationModel translation);

  /// Update an existing word
  Future<WordModel> updateWord(WordModel word);

  /// Update translation
  Future<TranslationModel> updateTranslation(TranslationModel translation);

  /// Delete a word from dictionary
  Future<void> deleteWord(String wordId);

  /// Delete translation
  Future<void> deleteTranslation(String translationId);

  /// Get popular words (most searched/translated)
  Future<List<WordModel>> getPopularWords({int limit = 20, String? language});

  /// Get words by category
  Future<List<WordModel>> getWordsByCategory(String category, {String? language, int limit = 50});

  /// Get words by difficulty level
  Future<List<WordModel>> getWordsByDifficulty(int difficulty, {String? language, int limit = 50});

  /// Get dictionary statistics
  Future<Map<String, dynamic>> getDictionaryStatistics();

  /// Increment usage count for a word
  Future<void> incrementUsageCount(String wordId);

  /// Get autocomplete suggestions for search
  Future<List<String>> getAutocompleteSuggestions(String query, String language, {int limit = 10});

  /// Get words starting with a letter
  Future<List<WordModel>> getWordsByLetter(String letter, String language, {int limit = 100});

  /// Save word to favorites
  Future<void> saveToFavorites(String wordId, String userId);

  /// Remove word from favorites
  Future<void> removeFromFavorites(String wordId, String userId);

  /// Get user's favorite words
  Future<List<WordModel>> getFavoriteWords(String userId);

  /// Report incorrect translation
  Future<void> reportIncorrectTranslation(String translationId, String userId, String reason);
}

/// Firebase implementation of DictionaryRemoteDataSource
class DictionaryRemoteDataSourceImpl implements DictionaryRemoteDataSource {
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;

  DictionaryRemoteDataSourceImpl({
    required this.firestore,
    required this.networkInfo,
  });

  @override
  Future<List<WordModel>> searchWords(
    String query, {
    String? sourceLanguage,
    String? targetLanguage,
    List<String>? categories,
    int? maxDifficulty,
  }) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      Query queryRef = firestore.collection('dictionary');

      if (sourceLanguage != null) {
        queryRef = queryRef.where('language', isEqualTo: sourceLanguage);
      }

      if (categories != null && categories.isNotEmpty) {
        queryRef = queryRef.where('category', whereIn: categories);
      }

      if (maxDifficulty != null) {
        queryRef = queryRef.where('difficulty', isLessThanOrEqualTo: maxDifficulty);
      }

      // Search by word starting with query (case insensitive would need additional setup)
      queryRef = queryRef
          .where('word', isGreaterThanOrEqualTo: query)
          .where('word', isLessThan: '$query\uf8ff')
          .orderBy('usageCount', descending: true)
          .limit(20);

      final snapshot = await queryRef.get();
      return snapshot.docs
          .map((doc) => WordModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to search words: ${e.toString()}');
    }
  }

  @override
  Future<WordModel> getWord(String wordId) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      final doc = await firestore.collection('dictionary').doc(wordId).get();
      if (!doc.exists) {
        throw const NotFoundFailure('Word not found');
      }
      return WordModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      if (e is NotFoundFailure) rethrow;
      throw ServerFailure('Failed to get word: ${e.toString()}');
    }
  }

  @override
  Future<List<TranslationModel>> getAllTranslations(String wordId) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      final query = await firestore
          .collection('translations')
          .where('wordId', isEqualTo: wordId)
          .orderBy('isPrimary', descending: true)
          .get();

      return query.docs
          .map((doc) => TranslationModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to get translations: ${e.toString()}');
    }
  }

  @override
  Future<List<TranslationModel>> getTranslations(String wordId, List<String> targetLanguages) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      final query = await firestore
          .collection('translations')
          .where('wordId', isEqualTo: wordId)
          .where('targetLanguage', whereIn: targetLanguages)
          .orderBy('isPrimary', descending: true)
          .get();

      return query.docs
          .map((doc) => TranslationModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to get translations: ${e.toString()}');
    }
  }

  @override
  Future<PronunciationModel> getPronunciation(String wordId, String language) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      final query = await firestore
          .collection('pronunciations')
          .where('wordId', isEqualTo: wordId)
          .where('language', isEqualTo: language)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw const NotFoundFailure('Pronunciation not found');
      }

      final doc = query.docs.first;
      return PronunciationModel.fromFirestore(doc.data(), doc.id);
    } catch (e) {
      if (e is NotFoundFailure) rethrow;
      throw ServerFailure('Failed to get pronunciation: ${e.toString()}');
    }
  }

  @override
  Future<WordModel> addWord(WordModel word) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      final docRef = await firestore.collection('dictionary').add(word.toFirestore());
      return word.copyWith(id: docRef.id);
    } catch (e) {
      throw ServerFailure('Failed to add word: ${e.toString()}');
    }
  }

  @override
  Future<TranslationModel> addTranslation(TranslationModel translation) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      final docRef = await firestore.collection('translations').add(translation.toFirestore());
      return translation.copyWith(id: docRef.id);
    } catch (e) {
      throw ServerFailure('Failed to add translation: ${e.toString()}');
    }
  }

  @override
  Future<WordModel> updateWord(WordModel word) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      await firestore.collection('dictionary').doc(word.id).update(word.toFirestore());
      return word;
    } catch (e) {
      throw ServerFailure('Failed to update word: ${e.toString()}');
    }
  }

  @override
  Future<TranslationModel> updateTranslation(TranslationModel translation) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      await firestore.collection('translations').doc(translation.id).update(translation.toFirestore());
      return translation;
    } catch (e) {
      throw ServerFailure('Failed to update translation: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteWord(String wordId) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      // Delete word and all its translations
      final batch = firestore.batch();
      batch.delete(firestore.collection('dictionary').doc(wordId));

      // Delete translations
      final translations = await firestore
          .collection('translations')
          .where('wordId', isEqualTo: wordId)
          .get();
      for (final doc in translations.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw ServerFailure('Failed to delete word: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTranslation(String translationId) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      await firestore.collection('translations').doc(translationId).delete();
    } catch (e) {
      throw ServerFailure('Failed to delete translation: ${e.toString()}');
    }
  }

  @override
  Future<List<WordModel>> getPopularWords({int limit = 20, String? language}) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      Query queryRef = firestore.collection('dictionary')
          .orderBy('usageCount', descending: true)
          .limit(limit);

      if (language != null) {
        queryRef = queryRef.where('language', isEqualTo: language);
      }

      final snapshot = await queryRef.get();
      return snapshot.docs
          .map((doc) => WordModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to get popular words: ${e.toString()}');
    }
  }

  @override
  Future<List<WordModel>> getWordsByCategory(String category, {String? language, int limit = 50}) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      Query queryRef = firestore.collection('dictionary')
          .where('category', isEqualTo: category)
          .orderBy('usageCount', descending: true)
          .limit(limit);

      if (language != null) {
        queryRef = queryRef.where('language', isEqualTo: language);
      }

      final snapshot = await queryRef.get();
      return snapshot.docs
          .map((doc) => WordModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to get words by category: ${e.toString()}');
    }
  }

  @override
  Future<List<WordModel>> getWordsByDifficulty(int difficulty, {String? language, int limit = 50}) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      Query queryRef = firestore.collection('dictionary')
          .where('difficulty', isEqualTo: difficulty)
          .orderBy('usageCount', descending: true)
          .limit(limit);

      if (language != null) {
        queryRef = queryRef.where('language', isEqualTo: language);
      }

      final snapshot = await queryRef.get();
      return snapshot.docs
          .map((doc) => WordModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to get words by difficulty: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getDictionaryStatistics() async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      final wordsCount = await firestore.collection('dictionary').count().get();
      final translationsCount = await firestore.collection('translations').count().get();

      // Get language distribution
      final languagesSnapshot = await firestore.collection('dictionary')
          .get();
      final languageStats = <String, int>{};
      for (final doc in languagesSnapshot.docs) {
        final language = doc.data()['language'] as String?;
        if (language != null) {
          languageStats[language] = (languageStats[language] ?? 0) + 1;
        }
      }

      return {
        'totalWords': wordsCount.count,
        'totalTranslations': translationsCount.count,
        'languageDistribution': languageStats,
        'lastUpdated': DateTime.now(),
      };
    } catch (e) {
      throw ServerFailure('Failed to get dictionary statistics: ${e.toString()}');
    }
  }

  @override
  Future<void> incrementUsageCount(String wordId) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      await firestore.collection('dictionary').doc(wordId).update({
        'usageCount': FieldValue.increment(1),
        'lastAccessed': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerFailure('Failed to increment usage count: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getAutocompleteSuggestions(String query, String language, {int limit = 10}) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      final snapshot = await firestore.collection('dictionary')
          .where('language', isEqualTo: language)
          .where('word', isGreaterThanOrEqualTo: query)
          .where('word', isLessThan: '$query\uf8ff')
          .orderBy('word')
          .orderBy('usageCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['word'] as String)
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to get autocomplete suggestions: ${e.toString()}');
    }
  }

  @override
  Future<List<WordModel>> getWordsByLetter(String letter, String language, {int limit = 100}) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      final snapshot = await firestore.collection('dictionary')
          .where('language', isEqualTo: language)
          .where('word', isGreaterThanOrEqualTo: letter)
          .where('word', isLessThan: '${letter}z')
          .orderBy('word')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => WordModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to get words by letter: ${e.toString()}');
    }
  }

  @override
  Future<void> saveToFavorites(String wordId, String userId) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      await firestore.collection('favorites').doc('${userId}_$wordId').set({
        'userId': userId,
        'wordId': wordId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerFailure('Failed to save to favorites: ${e.toString()}');
    }
  }

  @override
  Future<void> removeFromFavorites(String wordId, String userId) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      await firestore.collection('favorites').doc('${userId}_$wordId').delete();
    } catch (e) {
      throw ServerFailure('Failed to remove from favorites: ${e.toString()}');
    }
  }

  @override
  Future<List<WordModel>> getFavoriteWords(String userId) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      final favoritesQuery = await firestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      final wordIds = favoritesQuery.docs.map((doc) => doc.data()['wordId'] as String).toList();

      if (wordIds.isEmpty) return [];

      final wordsQuery = await firestore
          .collection('dictionary')
          .where(FieldPath.documentId, whereIn: wordIds)
          .get();

      return wordsQuery.docs
          .map((doc) => WordModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to get favorite words: ${e.toString()}');
    }
  }

  @override
  Future<void> reportIncorrectTranslation(String translationId, String userId, String reason) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure('No internet connection');
    }

    try {
      await firestore.collection('translation_reports').add({
        'translationId': translationId,
        'userId': userId,
        'reason': reason,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerFailure('Failed to report incorrect translation: ${e.toString()}');
    }
  }
}
