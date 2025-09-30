import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/dictionary_entry_model.dart';
import '../../domain/entities/dictionary_entry_entity.dart';

/// Remote data source for canonical lexicon using Firestore
class LexiconRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collectionPath = 'lexicon';

  LexiconRemoteDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get dictionary entry by ID
  Future<DictionaryEntryModel> getDictionaryEntry(String id) async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(id).get();

      if (!doc.exists) {
        throw const ServerException('Dictionary entry not found');
      }

      return DictionaryEntryModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to get dictionary entry: ${e.toString()}');
    }
  }

  /// Search dictionary entries
  Future<List<DictionaryEntryModel>> searchEntries({
    required String query,
    String? languageCode,
    List<String>? tags,
    DifficultyLevel? difficultyLevel,
    ReviewStatus? reviewStatus,
    int limit = 20,
    String? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> queryRef = _firestore.collection(_collectionPath);

      // Filter by language if specified
      if (languageCode != null) {
        queryRef = queryRef.where('languageCode', isEqualTo: languageCode);
      }

      // Filter by review status if specified
      if (reviewStatus != null) {
        queryRef = queryRef.where('reviewStatus', isEqualTo: reviewStatus.index);
      }

      // Filter by difficulty if specified
      if (difficultyLevel != null) {
        queryRef = queryRef.where('difficultyLevel', isEqualTo: difficultyLevel.index);
      }

      // Text search using searchTerms array
      if (query.isNotEmpty) {
        final searchTerm = query.toLowerCase();
        queryRef = queryRef.where('searchTerms', arrayContains: searchTerm);
      }

      // Filter by tags if specified
      if (tags != null && tags.isNotEmpty) {
        queryRef = queryRef.where('tags', arrayContainsAny: tags);
      }

      // Add pagination
      if (startAfter != null) {
        final startDoc = await _firestore.collection(_collectionPath).doc(startAfter).get();
        queryRef = queryRef.startAfterDocument(startDoc);
      }

      queryRef = queryRef.limit(limit);

      final snapshot = await queryRef.get();
      return snapshot.docs.map((doc) => DictionaryEntryModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to search entries: ${e.toString()}');
    }
  }

  /// Get entries by language
  Future<List<DictionaryEntryModel>> getEntriesByLanguage(
    String languageCode, {
    int limit = 50,
    String? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(_collectionPath)
          .where('languageCode', isEqualTo: languageCode)
          .where('reviewStatus', isEqualTo: ReviewStatus.humanVerified.index)
          .orderBy('canonicalForm')
          .limit(limit);

      if (startAfter != null) {
        final startDoc = await _firestore.collection(_collectionPath).doc(startAfter).get();
        query = query.startAfterDocument(startDoc);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => DictionaryEntryModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to get entries by language: ${e.toString()}');
    }
  }

  /// Get entries pending review
  Future<List<DictionaryEntryModel>> getPendingReviewEntries({
    String? languageCode,
    int limit = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(_collectionPath)
          .where('reviewStatus', whereIn: [
        ReviewStatus.pendingReview.index,
        ReviewStatus.autoSuggested.index,
      ]).orderBy('lastUpdated', descending: true)
          .limit(limit);

      if (languageCode != null) {
        query = query.where('languageCode', isEqualTo: languageCode);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => DictionaryEntryModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to get pending review entries: ${e.toString()}');
    }
  }

  /// Get AI suggested entries
  Future<List<DictionaryEntryModel>> getAiSuggestedEntries({
    String? languageCode,
    int limit = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(_collectionPath)
          .where('reviewStatus', isEqualTo: ReviewStatus.autoSuggested.index)
          .orderBy('qualityScore', descending: true)
          .limit(limit);

      if (languageCode != null) {
        query = query.where('languageCode', isEqualTo: languageCode);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => DictionaryEntryModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to get AI suggested entries: ${e.toString()}');
    }
  }

  /// Create dictionary entry
  Future<DictionaryEntryModel> createEntry(DictionaryEntryModel entry) async {
    try {
      final docRef = _firestore.collection(_collectionPath).doc();
      final entryWithId = DictionaryEntryModel.fromEntity(
        entry.copyWith(id: docRef.id, lastUpdated: DateTime.now()),
      );

      await docRef.set(entryWithId.toFirestore());
      return entryWithId;
    } catch (e) {
      throw ServerException('Failed to create entry: ${e.toString()}');
    }
  }

  /// Update dictionary entry
  Future<DictionaryEntryModel> updateEntry(DictionaryEntryModel entry) async {
    try {
      final updatedEntry = DictionaryEntryModel.fromEntity(
        entry.copyWith(lastUpdated: DateTime.now()),
      );

      await _firestore.collection(_collectionPath).doc(entry.id).update(updatedEntry.toFirestore());
      return updatedEntry;
    } catch (e) {
      throw ServerException('Failed to update entry: ${e.toString()}');
    }
  }

  /// Delete dictionary entry
  Future<void> deleteEntry(String id) async {
    try {
      await _firestore.collection(_collectionPath).doc(id).delete();
    } catch (e) {
      throw ServerException('Failed to delete entry: ${e.toString()}');
    }
  }

  /// Bulk create entries
  Future<List<DictionaryEntryModel>> bulkCreateEntries(
    List<DictionaryEntryModel> entries,
  ) async {
    try {
      final batch = _firestore.batch();
      final createdEntries = <DictionaryEntryModel>[];

      for (final entry in entries) {
        final docRef = _firestore.collection(_collectionPath).doc();
        final entryWithId = DictionaryEntryModel.fromEntity(
          entry.copyWith(id: docRef.id, lastUpdated: DateTime.now()),
        );

        batch.set(docRef, entryWithId.toFirestore());
        createdEntries.add(entryWithId);
      }

      await batch.commit();
      return createdEntries;
    } catch (e) {
      throw ServerException('Failed to bulk create entries: ${e.toString()}');
    }
  }

  /// Mark entry as verified
  Future<DictionaryEntryModel> markAsVerified(String entryId, String reviewerId) async {
    try {
      final entry = await getDictionaryEntry(entryId);
      final verifiedEntry = entry.markAsVerified(reviewerId);

      await _firestore.collection(_collectionPath).doc(entryId).update(verifiedEntry.toFirestore());
      return verifiedEntry;
    } catch (e) {
      throw ServerException('Failed to mark as verified: ${e.toString()}');
    }
  }

  /// Mark entry as rejected
  Future<void> markAsRejected(String entryId, String reviewerId, String reason) async {
    try {
      await _firestore.collection(_collectionPath).doc(entryId).update({
        'reviewStatus': ReviewStatus.rejected.index,
        'lastUpdated': Timestamp.now(),
        'metadata.rejectedBy': reviewerId,
        'metadata.rejectedAt': DateTime.now().toIso8601String(),
        'metadata.rejectionReason': reason,
      });
    } catch (e) {
      throw ServerException('Failed to mark as rejected: ${e.toString()}');
    }
  }

  /// Get word suggestions for autocomplete
  Future<List<String>> getWordSuggestions(
    String query,
    String languageCode, {
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .where('languageCode', isEqualTo: languageCode)
          .where('reviewStatus', isEqualTo: ReviewStatus.humanVerified.index)
          .where('canonicalForm', isGreaterThanOrEqualTo: query)
          .where('canonicalForm', isLessThan: '${query}z')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['canonicalForm'] as String)
          .toList();
    } catch (e) {
      throw ServerException('Failed to get word suggestions: ${e.toString()}');
    }
  }

  /// Get entries by contributor
  Future<List<DictionaryEntryModel>> getEntriesByContributor(
    String contributorId, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .where('contributorId', isEqualTo: contributorId)
          .orderBy('lastUpdated', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => DictionaryEntryModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to get entries by contributor: ${e.toString()}');
    }
  }

  /// Get random entry
  Future<DictionaryEntryModel> getRandomEntry(
    String languageCode, {
    DifficultyLevel? difficultyLevel,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(_collectionPath)
          .where('languageCode', isEqualTo: languageCode)
          .where('reviewStatus', isEqualTo: ReviewStatus.humanVerified.index);

      if (difficultyLevel != null) {
        query = query.where('difficultyLevel', isEqualTo: difficultyLevel.index);
      }

      // Simple random implementation - get random document
      final snapshot = await query.limit(100).get();
      if (snapshot.docs.isEmpty) {
        throw const ServerException('No entries found for random selection');
      }

      final randomIndex = DateTime.now().millisecondsSinceEpoch % snapshot.docs.length;
      return DictionaryEntryModel.fromFirestore(snapshot.docs[randomIndex]);
    } catch (e) {
      throw ServerException('Failed to get random entry: ${e.toString()}');
    }
  }

  /// Get entries by difficulty
  Future<List<DictionaryEntryModel>> getEntriesByDifficulty(
    String languageCode,
    DifficultyLevel difficulty, {
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .where('languageCode', isEqualTo: languageCode)
          .where('difficultyLevel', isEqualTo: difficulty.index)
          .where('reviewStatus', isEqualTo: ReviewStatus.humanVerified.index)
          .orderBy('qualityScore', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => DictionaryEntryModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException('Failed to get entries by difficulty: ${e.toString()}');
    }
  }

  /// Stream entries
  Stream<List<DictionaryEntryModel>> watchEntries({
    String? languageCode,
    ReviewStatus? reviewStatus,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(_collectionPath);

      if (languageCode != null) {
        query = query.where('languageCode', isEqualTo: languageCode);
      }

      if (reviewStatus != null) {
        query = query.where('reviewStatus', isEqualTo: reviewStatus.index);
      }

      query = query.orderBy('lastUpdated', descending: true).limit(50);

      return query.snapshots().map(
            (snapshot) => snapshot.docs
                .map((doc) => DictionaryEntryModel.fromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      throw ServerException('Failed to watch entries: ${e.toString()}');
    }
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      // This would typically be computed using Cloud Functions for better performance
      // For now, we'll implement basic counting
      final allEntries = await _firestore.collection(_collectionPath).get();

      final stats = {
        'totalEntries': allEntries.docs.length,
        'verifiedEntries': 0,
        'pendingEntries': 0,
        'aiSuggestedEntries': 0,
        'entriesByLanguage': <String, int>{},
        'entriesByDifficulty': <String, int>{},
        'entriesByPartOfSpeech': <String, int>{},
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      for (final doc in allEntries.docs) {
        final data = doc.data();
        final reviewStatus = ReviewStatus.values[data['reviewStatus'] as int];
        final languageCode = data['languageCode'] as String;
        final difficulty = DifficultyLevel.values[data['difficultyLevel'] as int];
        final partOfSpeech = data['partOfSpeech'] as String;

        // Count by review status
        switch (reviewStatus) {
          case ReviewStatus.humanVerified:
            stats['verifiedEntries'] = (stats['verifiedEntries'] as int) + 1;
            break;
          case ReviewStatus.pendingReview:
            stats['pendingEntries'] = (stats['pendingEntries'] as int) + 1;
            break;
          case ReviewStatus.autoSuggested:
            stats['aiSuggestedEntries'] = (stats['aiSuggestedEntries'] as int) + 1;
            break;
          case ReviewStatus.rejected:
            break;
        }

        // Count by language
        final langMap = stats['entriesByLanguage'] as Map<String, int>;
        langMap[languageCode] = (langMap[languageCode] ?? 0) + 1;

        // Count by difficulty
        final diffMap = stats['entriesByDifficulty'] as Map<String, int>;
        diffMap[difficulty.displayName] = (diffMap[difficulty.displayName] ?? 0) + 1;

        // Count by part of speech
        final posMap = stats['entriesByPartOfSpeech'] as Map<String, int>;
        posMap[partOfSpeech] = (posMap[partOfSpeech] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw ServerException('Failed to get statistics: ${e.toString()}');
    }
  }
}