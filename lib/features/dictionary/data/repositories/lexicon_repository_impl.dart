import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/dictionary_entry_entity.dart';
import '../../domain/repositories/lexicon_repository.dart';
import '../datasources/lexicon_remote_datasource.dart';
import '../datasources/lexicon_local_datasource.dart';
import '../models/dictionary_entry_model.dart';

/// Implementation of the canonical lexicon repository
class LexiconRepositoryImpl implements LexiconRepository {
  final LexiconRemoteDataSource remoteDataSource;
  final LexiconLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  LexiconRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, DictionaryEntryEntity>> getDictionaryEntry(String id) async {
    try {
      // Try local first for offline capability
      try {
        final localEntry = await localDataSource.getEntry(id);
        if (localEntry != null) {
          return Right(localEntry.toEntity());
        }
      } catch (_) {
        // Continue to remote if local fails
      }

      // Check network connectivity
      if (await networkInfo.isConnected) {
        final remoteEntry = await remoteDataSource.getDictionaryEntry(id);

        // Cache locally for offline access
        await localDataSource.cacheEntry(remoteEntry);

        return Right(remoteEntry.toEntity());
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DictionaryEntryEntity>>> searchEntries({
    required String query,
    String? languageCode,
    List<String>? tags,
    DifficultyLevel? difficultyLevel,
    ReviewStatus? reviewStatus,
    int limit = 20,
    String? startAfter,
  }) async {
    try {
      // For search, prioritize remote data for freshness
      if (await networkInfo.isConnected) {
        final remoteEntries = await remoteDataSource.searchEntries(
          query: query,
          languageCode: languageCode,
          tags: tags,
          difficultyLevel: difficultyLevel,
          reviewStatus: reviewStatus,
          limit: limit,
          startAfter: startAfter,
        );

        // Cache results locally
        for (final entry in remoteEntries) {
          await localDataSource.cacheEntry(entry);
        }

        return Right(remoteEntries.map((e) => e.toEntity()).toList());
      } else {
        // Fallback to local search when offline
        final localEntries = await localDataSource.searchEntries(
          query: query,
          languageCode: languageCode,
          limit: limit,
        );
        return Right(localEntries.map((e) => e.toEntity()).toList());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DictionaryEntryEntity>>> getEntriesByLanguage(
    String languageCode, {
    int limit = 50,
    String? startAfter,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteEntries = await remoteDataSource.getEntriesByLanguage(
          languageCode,
          limit: limit,
          startAfter: startAfter,
        );

        // Cache for offline access
        for (final entry in remoteEntries) {
          await localDataSource.cacheEntry(entry);
        }

        return Right(remoteEntries.map((e) => e.toEntity()).toList());
      } else {
        final localEntries = await localDataSource.getEntriesByLanguage(
          languageCode,
        );
        return Right(localEntries.map((e) => e.toEntity()).toList());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DictionaryEntryEntity>>> getPendingReviewEntries({
    String? languageCode,
    int limit = 20,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final entries = await remoteDataSource.getPendingReviewEntries(
          languageCode: languageCode,
          limit: limit,
        );
        return Right(entries.map((e) => e.toEntity()).toList());
      } else {
        return const Left(NetworkFailure('Review features require internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DictionaryEntryEntity>>> getAiSuggestedEntries({
    String? languageCode,
    int limit = 20,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final entries = await remoteDataSource.getAiSuggestedEntries(
          languageCode: languageCode,
          limit: limit,
        );
        return Right(entries.map((e) => e.toEntity()).toList());
      } else {
        return const Left(NetworkFailure('AI features require internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DictionaryEntryEntity>> createEntry(
    DictionaryEntryEntity entry,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final model = DictionaryEntryModel.fromEntity(entry);
        final createdEntry = await remoteDataSource.createEntry(model);

        // Cache locally
        await localDataSource.cacheEntry(createdEntry);

        return Right(createdEntry.toEntity());
      } else {
        // Queue for sync when online
        final model = DictionaryEntryModel.fromEntity(entry);
        await localDataSource.queueForSync(model);
        return Right(entry);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DictionaryEntryEntity>> updateEntry(
    DictionaryEntryEntity entry,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final model = DictionaryEntryModel.fromEntity(entry);
        final updatedEntry = await remoteDataSource.updateEntry(model);

        // Update cache
        await localDataSource.cacheEntry(updatedEntry);

        return Right(updatedEntry.toEntity());
      } else {
        // Queue for sync when online
        final model = DictionaryEntryModel.fromEntity(entry);
        await localDataSource.queueForSync(model);
        return Right(entry);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEntry(String id) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteEntry(id);

        // Remove from cache
        await localDataSource.removeFromCache(id);

        return const Right(null);
      } else {
        // Queue deletion for sync
        await localDataSource.queueDeletionForSync(id);
        return const Right(null);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DictionaryEntryEntity>>> bulkCreateEntries(
    List<DictionaryEntryEntity> entries,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final models = entries.map((e) => DictionaryEntryModel.fromEntity(e)).toList();
        final createdEntries = await remoteDataSource.bulkCreateEntries(models);

        // Cache all entries
        for (final entry in createdEntries) {
          await localDataSource.cacheEntry(entry);
        }

        return Right(createdEntries.map((e) => e.toEntity()).toList());
      } else {
        return const Left(NetworkFailure('Bulk operations require internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DictionaryEntryEntity>> markAsVerified(
    String entryId,
    String reviewerId,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final verifiedEntry = await remoteDataSource.markAsVerified(entryId, reviewerId);

        // Update cache
        await localDataSource.cacheEntry(verifiedEntry);

        return Right(verifiedEntry.toEntity());
      } else {
        return const Left(NetworkFailure('Review actions require internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRejected(
    String entryId,
    String reviewerId,
    String reason,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.markAsRejected(entryId, reviewerId, reason);
        return const Right(null);
      } else {
        return const Left(NetworkFailure('Review actions require internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getWordSuggestions(
    String query,
    String languageCode, {
    int limit = 10,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final suggestions = await remoteDataSource.getWordSuggestions(
          query,
          languageCode,
          limit: limit,
        );
        return Right(suggestions);
      } else {
        final suggestions = await localDataSource.getWordSuggestions(
          query: query,
          limit: limit,
        );
        return Right(suggestions);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DictionaryEntryEntity>>> getEntriesByContributor(
    String contributorId, {
    int limit = 20,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final entries = await remoteDataSource.getEntriesByContributor(
          contributorId,
          limit: limit,
        );
        return Right(entries.map((e) => e.toEntity()).toList());
      } else {
        return const Left(NetworkFailure('Contributor data requires internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DictionaryEntryEntity>> getRandomEntry(
    String languageCode, {
    DifficultyLevel? difficultyLevel,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final entry = await remoteDataSource.getRandomEntry(
          languageCode,
          difficultyLevel: difficultyLevel,
        );
        return Right(entry.toEntity());
      } else {
        final entry = await localDataSource.getRandomEntry();
        if (entry == null) {
          return const Left(UnknownFailure('No entry found'));
        }
        return Right(entry.toEntity());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DictionaryEntryEntity>>> getEntriesByDifficulty(
    String languageCode,
    DifficultyLevel difficulty, {
    int limit = 20,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final entries = await remoteDataSource.getEntriesByDifficulty(
          languageCode,
          difficulty,
          limit: limit,
        );
        return Right(entries.map((e) => e.toEntity()).toList());
      } else {
        final entries = await localDataSource.getEntriesByDifficulty(
          difficulty,
        );
        return Right(entries.map((e) => e.toEntity()).toList());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> getTranslations(
    String word,
    String fromLanguage,
    List<String> toLanguages,
  ) async {
    try {
      // Implementation would search for entries with matching canonical form
      // and extract translations for requested languages
      final searchResult = await searchEntries(
        query: word,
        languageCode: fromLanguage,
        limit: 1,
      );

      return searchResult.fold(
        (failure) => Left(failure),
        (entries) {
          if (entries.isEmpty) {
            return const Right(<String, String>{});
          }

          final entry = entries.first;
          final translations = <String, String>{};

          for (final langCode in toLanguages) {
            if (entry.translations.containsKey(langCode)) {
              translations[langCode] = entry.translations[langCode]!;
            }
          }

          return Right(translations);
        },
      );
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Stream<List<DictionaryEntryEntity>> watchEntries({
    String? languageCode,
    ReviewStatus? reviewStatus,
  }) {
    try {
      return remoteDataSource
          .watchEntries(
            languageCode: languageCode,
            reviewStatus: reviewStatus,
          )
          .map((models) => models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Stream.error(ServerException('Failed to watch entries: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, LexiconStatistics>> getStatistics() async {
    try {
      if (await networkInfo.isConnected) {
        final statsData = await remoteDataSource.getStatistics();
        final stats = LexiconStatistics.fromJson(statsData);
        return Right(stats);
      } else {
        return const Left(NetworkFailure('Statistics require internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> syncOfflineEntries() async {
    try {
      if (await networkInfo.isConnected) {
        // Get queued entries for sync
        final queuedEntries = await localDataSource.getQueuedForSync();

        // Sync each entry
        for (final entry in queuedEntries) {
          try {
            await remoteDataSource.createEntry(entry);
            await localDataSource.markAsSynced(entry.id);
          } catch (e) {
            // Log error but continue with other entries
            debugPrint('Failed to sync entry ${entry.id}: $e');
          }
        }

        // Get queued deletions
        final queuedDeletions = await localDataSource.getQueuedDeletions();

        // Sync deletions
        for (final entryId in queuedDeletions) {
          try {
            await remoteDataSource.deleteEntry(entryId);
            await localDataSource.removeDeletionFromQueue(entryId);
          } catch (e) {
            // Log error but continue
            debugPrint('Failed to sync deletion $entryId: $e');
          }
        }

        return const Right(null);
      } else {
        return const Left(NetworkFailure('Sync requires internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> downloadEntriesForOffline(
    String languageCode, {
    DifficultyLevel? maxDifficulty,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        // Download in batches
        const batchSize = 50;
        String? lastDocId;

        while (true) {
          final entries = await remoteDataSource.getEntriesByLanguage(
            languageCode,
            limit: batchSize,
            startAfter: lastDocId,
          );

          if (entries.isEmpty) break;

          // Filter by difficulty if specified
          List<DictionaryEntryModel> filteredEntries = entries;
          if (maxDifficulty != null) {
            filteredEntries = entries
                .where((e) => e.difficultyLevel.index <= maxDifficulty.index)
                .toList();
          }

          // Cache entries locally
          for (final entry in filteredEntries) {
            await localDataSource.cacheEntry(entry);
          }

          lastDocId = entries.last.id;

          // Break if we got less than batch size (end of data)
          if (entries.length < batchSize) break;
        }

        return const Right(null);
      } else {
        return const Left(NetworkFailure('Download requires internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }
}