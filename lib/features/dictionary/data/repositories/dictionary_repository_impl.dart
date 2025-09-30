import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/word_entity.dart';
import '../../domain/entities/pronunciation_entity.dart';
import '../../domain/entities/translation_entity.dart';
import '../../domain/repositories/dictionary_repository.dart';
import '../datasources/dictionary_local_datasource.dart';
import '../datasources/dictionary_remote_datasource.dart';
import '../models/word_model.dart';
import '../models/translation_model.dart';

/// Implementation of DictionaryRepository
class DictionaryRepositoryImpl implements DictionaryRepository {
  final DictionaryRemoteDataSource remoteDataSource;
  final DictionaryLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  DictionaryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<WordEntity>>> searchWords(
    String query, {
    String? sourceLanguage,
    String? targetLanguage,
    List<String>? categories,
    int? maxDifficulty,
  }) async {
    try {
      // Try to get cached results first
      final cachedResults = await localDataSource.getCachedSearchResults(query);
      if (cachedResults != null && cachedResults.isNotEmpty) {
        return Right(cachedResults.map((model) => model.toEntity()).toList());
      }

      // If no cache or cache is empty, fetch from remote
      if (await networkInfo.isConnected) {
        final remoteResults = await remoteDataSource.searchWords(
          query,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          categories: categories,
          maxDifficulty: maxDifficulty,
        );

        // Cache the results
        await localDataSource.cacheSearchResults(query, remoteResults);

        return Right(remoteResults.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, WordEntity>> getWord(String wordId) async {
    try {
      // Try to get cached word first
      final cachedWord = await localDataSource.getCachedWord(wordId);
      if (cachedWord != null) {
        return Right(cachedWord.toEntity());
      }

      // If no cache, fetch from remote
      if (await networkInfo.isConnected) {
        final remoteWord = await remoteDataSource.getWord(wordId);

        // Cache the word
        await localDataSource.cacheWord(remoteWord);

        return Right(remoteWord.toEntity());
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PronunciationEntity>> getPronunciation(String wordId, String language) async {
    try {
      if (await networkInfo.isConnected) {
        final pronunciation = await remoteDataSource.getPronunciation(wordId, language);
        return Right(pronunciation.toEntity());
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<TranslationEntity>>> getTranslations(String wordId, List<String> targetLanguages) async {
    try {
      if (await networkInfo.isConnected) {
        final translations = await remoteDataSource.getTranslations(wordId, targetLanguages);
        return Right(translations.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> saveToFavorites(String wordId, String userId) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.saveToFavorites(wordId, userId);
        return const Right(true);
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> removeFromFavorites(String wordId, String userId) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.removeFromFavorites(wordId, userId);
        return const Right(true);
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<WordEntity>>> getFavoriteWords(String userId) async {
    try {
      // Try to get cached favorites first
      final cachedFavorites = await localDataSource.getCachedFavoriteWords();
      if (cachedFavorites != null && cachedFavorites.isNotEmpty) {
        return Right(cachedFavorites.map((model) => model.toEntity()).toList());
      }

      // If no cache, fetch from remote
      if (await networkInfo.isConnected) {
        final remoteFavorites = await remoteDataSource.getFavoriteWords(userId);

        // Cache the results
        await localDataSource.cacheFavoriteWords(remoteFavorites);

        return Right(remoteFavorites.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<WordEntity>>> getWordsByCategory(String category, {String? language, int limit = 50}) async {
    try {
      if (await networkInfo.isConnected) {
        final words = await remoteDataSource.getWordsByCategory(category, language: language, limit: limit);
        return Right(words.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, WordEntity>> addWord(WordEntity word) async {
    try {
      if (await networkInfo.isConnected) {
        final wordModel = WordModel(
          id: word.id,
          word: word.word,
          language: word.language,
          translation: word.translation,
          pronunciation: word.pronunciation,
          phonetic: word.phonetic,
          definition: word.definition,
          example: word.example,
          audioUrl: word.audioUrl,
          synonyms: word.synonyms,
          antonyms: word.antonyms,
          category: word.category,
          difficulty: word.difficulty,
          createdAt: word.createdAt,
          updatedAt: word.updatedAt,
        );
        final result = await remoteDataSource.addWord(wordModel);
        return Right(result.toEntity());
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, TranslationEntity>> addTranslation(TranslationEntity translation) async {
    try {
      if (await networkInfo.isConnected) {
        final translationModel = TranslationModel(
          id: translation.id,
          wordId: translation.wordId,
          sourceLanguage: translation.sourceLanguage,
          targetLanguage: translation.targetLanguage,
          translation: translation.translation,
          context: translation.context,
          isPrimary: translation.isPrimary,
          createdAt: translation.createdAt,
        );
        final result = await remoteDataSource.addTranslation(translationModel);
        return Right(result.toEntity());
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, WordEntity>> updateWord(WordEntity word) async {
    try {
      if (await networkInfo.isConnected) {
        final wordModel = WordModel(
          id: word.id,
          word: word.word,
          language: word.language,
          translation: word.translation,
          pronunciation: word.pronunciation,
          phonetic: word.phonetic,
          definition: word.definition,
          example: word.example,
          audioUrl: word.audioUrl,
          synonyms: word.synonyms,
          antonyms: word.antonyms,
          category: word.category,
          difficulty: word.difficulty,
          createdAt: word.createdAt,
          updatedAt: word.updatedAt,
        );
        final result = await remoteDataSource.updateWord(wordModel);
        return Right(result.toEntity());
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, TranslationEntity>> updateTranslation(TranslationEntity translation) async {
    try {
      if (await networkInfo.isConnected) {
        final translationModel = TranslationModel(
          id: translation.id,
          wordId: translation.wordId,
          sourceLanguage: translation.sourceLanguage,
          targetLanguage: translation.targetLanguage,
          translation: translation.translation,
          context: translation.context,
          isPrimary: translation.isPrimary,
          createdAt: translation.createdAt,
        );
        final result = await remoteDataSource.updateTranslation(translationModel);
        return Right(result.toEntity());
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWord(String wordId) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteWord(wordId);
        return const Right(null);
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTranslation(String translationId) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteTranslation(translationId);
        return const Right(null);
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<WordEntity>>> getWordsByLetter(String letter, String language, {int limit = 100}) async {
    try {
      if (await networkInfo.isConnected) {
        final words = await remoteDataSource.getWordsByLetter(letter, language, limit: limit);
        return Right(words.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> translatePhrase(String phrase, String sourceLanguage, String targetLanguage) async {
    // This would typically use AI service, but for now return a simple implementation
    return Right('$phrase (translated from $sourceLanguage to $targetLanguage)');
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTranslationHistory(String userId, {int limit = 50}) async {
    // This would fetch from Firestore, but for now return empty list
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> reportIncorrectTranslation(String translationId, String userId, String reason) async {
    try {
      if (await networkInfo.isConnected) {
        // This would save a report to Firestore, but for now just return success
        return const Right(null);
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<TranslationEntity>>> getAllTranslations(String wordId) async {
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.getAllTranslations(wordId);
        return Right(result.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAutocompleteSuggestions(
    String query,
    String language, {
    int limit = 10,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.getAutocompleteSuggestions(query, language, limit: limit);
        return Right(result);
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDictionaryStatistics() async {
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.getDictionaryStatistics();
        return Right(result);
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<WordEntity>>> getWordsByDifficulty(
    int difficulty, {
    String? language,
    int limit = 50,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.getWordsByDifficulty(difficulty, language: language, limit: limit);
        return Right(result.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<WordEntity>>> getPopularWords({
    int limit = 20,
    String? language,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.getPopularWords(limit: limit, language: language);
        return Right(result.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementUsageCount(String wordId) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.incrementUsageCount(wordId);
        return const Right(null);
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
