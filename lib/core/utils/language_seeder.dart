import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mayegue/features/languages/data/models/language_model.dart';

/// Utility class for seeding language data into Firestore
class LanguageSeeder {
  final FirebaseFirestore _firestore;

  LanguageSeeder(this._firestore);

  /// Seed traditional Cameroonian languages
  Future<void> seedLanguages() async {
    final languages = _getLanguagesData();

    final batch = _firestore.batch();
    final collection = _firestore.collection('languages');

    for (final language in languages) {
      final docRef = collection.doc(language.id);
      batch.set(docRef, language.toFirestore());
    }

    await batch.commit();
  }

  /// Clear all languages from Firestore
  Future<void> clearLanguages() async {
    final snapshot = await _firestore.collection('languages').get();
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Get the predefined languages data
  List<LanguageModel> _getLanguagesData() {
    final now = DateTime.now();

    return [
      LanguageModel(
        id: 'ewondo',
        name: 'Ewondo',
        group: 'Beti-Pahuin',
        region: 'Central',
        type: 'Primary',
        status: 'active',
        createdAt: now,
        updatedAt: now,
      ),
      LanguageModel(
        id: 'duala',
        name: 'Duala',
        group: 'Coastal Bantu',
        region: 'Littoral',
        type: 'Commercial',
        status: 'active',
        createdAt: now,
        updatedAt: now,
      ),
      LanguageModel(
        id: 'bafang',
        name: 'Bafang/Fe\'efe\'e',
        group: 'Grassfields',
        region: 'West',
        type: 'Regional',
        status: 'active',
        createdAt: now,
        updatedAt: now,
      ),
      LanguageModel(
        id: 'fulfulde',
        name: 'Fulfulde',
        group: 'Niger-Congo',
        region: 'North',
        type: 'Pastoral',
        status: 'active',
        createdAt: now,
        updatedAt: now,
      ),
      LanguageModel(
        id: 'bassa',
        name: 'Bassa',
        group: 'A40 Bantu',
        region: 'Central-Littoral',
        type: 'Traditional',
        status: 'active',
        createdAt: now,
        updatedAt: now,
      ),
      LanguageModel(
        id: 'bamum',
        name: 'Bamum',
        group: 'Grassfields',
        region: 'West',
        type: 'Heritage',
        status: 'active',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
