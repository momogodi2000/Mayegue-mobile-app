import 'package:hive/hive.dart';
import '../../../../core/errors/failures.dart';
import '../models/word_model.dart';

/// Local data source for dictionary operations using Hive
abstract class DictionaryLocalDataSource {
  /// Cache search results
  Future<void> cacheSearchResults(String query, List<WordModel> words);

  /// Get cached search results
  Future<List<WordModel>?> getCachedSearchResults(String query);

  /// Cache word details
  Future<void> cacheWord(WordModel word);

  /// Get cached word
  Future<WordModel?> getCachedWord(String wordId);

  /// Cache favorite words
  Future<void> cacheFavoriteWords(List<WordModel> words);

  /// Get cached favorite words
  Future<List<WordModel>?> getCachedFavoriteWords();

  /// Clear all cached data
  Future<void> clearCache();
}

/// Hive implementation of DictionaryLocalDataSource
class DictionaryLocalDataSourceImpl implements DictionaryLocalDataSource {
  static const String searchResultsBox = 'dictionary_search_results';
  static const String wordsBoxName = 'dictionary_words';
  static const String favoritesBoxName = 'dictionary_favorites';

  @override
  Future<void> cacheSearchResults(String query, List<WordModel> words) async {
    try {
      final box = await Hive.openBox(searchResultsBox);
      final wordIds = words.map((word) => word.id).toList();
      await box.put(query, {
        'wordIds': wordIds,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // Also cache individual words
      final wordsBox = await Hive.openBox(wordsBoxName);
      for (final word in words) {
        await wordsBox.put(word.id, word.toJson());
      }
    } catch (e) {
      throw CacheFailure('Failed to cache search results: ${e.toString()}');
    }
  }

  @override
  Future<List<WordModel>?> getCachedSearchResults(String query) async {
    try {
      final box = await Hive.openBox(searchResultsBox);
      final cached = box.get(query);

      if (cached == null) return null;

      final data = cached as Map;
      final timestamp = data['timestamp'] as int;
      final wordIds = data['wordIds'] as List;

      // Check if cache is expired (24 hours)
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - timestamp > 24 * 60 * 60 * 1000) {
        await box.delete(query);
        return null;
      }

      final wordsBox = await Hive.openBox(wordsBoxName);
      final words = <WordModel>[];

      for (final wordId in wordIds) {
        final wordData = wordsBox.get(wordId);
        if (wordData != null) {
          words.add(WordModel.fromJson(wordData));
        }
      }

      return words;
    } catch (e) {
      throw CacheFailure('Failed to get cached search results: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheWord(WordModel word) async {
    try {
      final box = await Hive.openBox(wordsBoxName);
      await box.put(word.id, word.toJson());
    } catch (e) {
      throw CacheFailure('Failed to cache word: ${e.toString()}');
    }
  }

  @override
  Future<WordModel?> getCachedWord(String wordId) async {
    try {
      final box = await Hive.openBox(wordsBoxName);
      final data = box.get(wordId);
      if (data == null) return null;
      return WordModel.fromJson(data);
    } catch (e) {
      throw CacheFailure('Failed to get cached word: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheFavoriteWords(List<WordModel> words) async {
    try {
      final box = await Hive.openBox(favoritesBoxName);
      final wordIds = words.map((word) => word.id).toList();
      await box.put('favorites', {
        'wordIds': wordIds,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // Also cache individual words
      final wordsBox = await Hive.openBox(wordsBoxName);
      for (final word in words) {
        await wordsBox.put(word.id, word.toJson());
      }
    } catch (e) {
      throw CacheFailure('Failed to cache favorite words: ${e.toString()}');
    }
  }

  @override
  Future<List<WordModel>?> getCachedFavoriteWords() async {
    try {
      final box = await Hive.openBox(favoritesBoxName);
      final cached = box.get('favorites');

      if (cached == null) return null;

      final data = cached as Map;
      final timestamp = data['timestamp'] as int;
      final wordIds = data['wordIds'] as List;

      // Check if cache is expired (1 hour for favorites)
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - timestamp > 60 * 60 * 1000) {
        await box.delete('favorites');
        return null;
      }

      final wordsBox = await Hive.openBox(wordsBoxName);
      final words = <WordModel>[];

      for (final wordId in wordIds) {
        final wordData = wordsBox.get(wordId);
        if (wordData != null) {
          words.add(WordModel.fromJson(wordData));
        }
      }

      return words;
    } catch (e) {
      throw CacheFailure('Failed to get cached favorite words: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final searchBox = await Hive.openBox(searchResultsBox);
      final wordsBox = await Hive.openBox(wordsBoxName);
      final favoritesBox = await Hive.openBox(favoritesBoxName);

      await searchBox.clear();
      await wordsBox.clear();
      await favoritesBox.clear();
    } catch (e) {
      throw CacheFailure('Failed to clear cache: ${e.toString()}');
    }
  }
}
