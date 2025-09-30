import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/language_model.dart';

/// Remote data source for language operations with Firebase
abstract class LanguageRemoteDataSource {
  /// Get all languages from Firestore
  Future<List<LanguageModel>> getAllLanguages();

  /// Get language by ID
  Future<LanguageModel?> getLanguageById(String id);

  /// Get languages by region
  Future<List<LanguageModel>> getLanguagesByRegion(String region);

  /// Get languages by status
  Future<List<LanguageModel>> getLanguagesByStatus(String status);

  /// Search languages
  Future<List<LanguageModel>> searchLanguages(String query);

  /// Create language
  Future<LanguageModel> createLanguage(LanguageModel language);

  /// Update language
  Future<LanguageModel> updateLanguage(LanguageModel language);

  /// Delete language
  Future<void> deleteLanguage(String id);

  /// Get language statistics
  Future<Map<String, dynamic>> getLanguageStatistics();
}

/// Firebase implementation of LanguageRemoteDataSource
class LanguageRemoteDataSourceImpl implements LanguageRemoteDataSource {
  final FirebaseFirestore firestore;
  final CollectionReference languagesCollection;

  LanguageRemoteDataSourceImpl({
    required this.firestore,
  }) : languagesCollection = firestore.collection('languages');

  @override
  Future<List<LanguageModel>> getAllLanguages() async {
    try {
      final querySnapshot = await languagesCollection
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => LanguageModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all languages: $e');
    }
  }

  @override
  Future<LanguageModel?> getLanguageById(String id) async {
    try {
      final doc = await languagesCollection.doc(id).get();
      if (!doc.exists) return null;

      return LanguageModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get language by ID: $e');
    }
  }

  @override
  Future<List<LanguageModel>> getLanguagesByRegion(String region) async {
    try {
      final querySnapshot = await languagesCollection
          .where('region', isEqualTo: region)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => LanguageModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get languages by region: $e');
    }
  }

  @override
  Future<List<LanguageModel>> getLanguagesByStatus(String status) async {
    try {
      final querySnapshot = await languagesCollection
          .where('status', isEqualTo: status)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => LanguageModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get languages by status: $e');
    }
  }

  @override
  Future<List<LanguageModel>> searchLanguages(String query) async {
    try {
      final results = <LanguageModel>[];

      // Search by name (case-insensitive prefix search)
      final nameQuery = await languagesCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '$query\uf8ff')
          .get();

      // Search by group (case-insensitive prefix search)
      final groupQuery = await languagesCollection
          .where('group', isGreaterThanOrEqualTo: query)
          .where('group', isLessThan: '$query\uf8ff')
          .get();

      // Search by region (case-insensitive prefix search)
      final regionQuery = await languagesCollection
          .where('region', isGreaterThanOrEqualTo: query)
          .where('region', isLessThan: '$query\uf8ff')
          .get();

      // Combine results and remove duplicates
      final seenIds = <String>{};
      for (final doc in [...nameQuery.docs, ...groupQuery.docs, ...regionQuery.docs]) {
        if (!seenIds.contains(doc.id)) {
          results.add(LanguageModel.fromFirestore(doc));
          seenIds.add(doc.id);
        }
      }

      return results;
    } catch (e) {
      throw Exception('Failed to search languages: $e');
    }
  }

  @override
  Future<LanguageModel> createLanguage(LanguageModel language) async {
    try {
      final docRef = await languagesCollection.add(language.toFirestore());
      final doc = await docRef.get();

      return LanguageModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to create language: $e');
    }
  }

  @override
  Future<LanguageModel> updateLanguage(LanguageModel language) async {
    try {
      await languagesCollection
          .doc(language.id)
          .update(language.toFirestore());

      final updatedDoc = await languagesCollection.doc(language.id).get();
      return LanguageModel.fromFirestore(updatedDoc);
    } catch (e) {
      throw Exception('Failed to update language: $e');
    }
  }

  @override
  Future<void> deleteLanguage(String id) async {
    try {
      await languagesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete language: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getLanguageStatistics() async {
    try {
      final querySnapshot = await languagesCollection.get();

      final stats = <String, dynamic>{
        'total': querySnapshot.docs.length,
        'by_region': <String, int>{},
        'by_status': <String, int>{},
        'by_family': <String, int>{},
      };

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Count by region
        final region = data['region'] as String? ?? 'Unknown';
        stats['by_region'][region] = (stats['by_region'][region] ?? 0) + 1;

        // Count by status
        final status = data['status'] as String? ?? 'active';
        stats['by_status'][status] = (stats['by_status'][status] ?? 0) + 1;

        // Count by family
        final family = data['family'] as String? ?? 'Unknown';
        stats['by_family'][family] = (stats['by_family'][family] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to get language statistics: $e');
    }
  }
}
