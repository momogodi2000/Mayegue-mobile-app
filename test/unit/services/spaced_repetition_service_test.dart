import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mayegue/core/services/spaced_repetition_service.dart';

void main() {
  group('SpacedRepetitionService Tests', () {
    late SpacedRepetitionService service;
    // Removed unused variables that were causing warnings

    setUpAll(() async {
      // Initialize Hive for testing
      Hive.init('./test/hive_test_db');

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(SpacedRepetitionCardAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ReviewSessionAdapter());
      }
    });

    setUp(() async {
      service = SpacedRepetitionService();
      await service.initialize();
    });

    tearDown(() async {
      // Clean up test data
      try {
        await Hive.box<SpacedRepetitionCard>('spaced_repetition').clear();
        await Hive.box<Map>('sr_statistics').clear();
      } catch (e) {
        // Box might not exist
      }
    });

    tearDownAll(() async {
      await Hive.close();
    });

    test('should initialize successfully', () async {
      expect(service, isNotNull);
    });

    test('should add a new card', () async {
      await service.addCard(
        id: 'test_card_1',
        word: 'mbolo',
        translation: 'bonjour',
        languageCode: 'ewondo',
        pronunciation: 'mbo-lo',
        partOfSpeech: 'noun',
        exampleSentences: ['Mbolo, nga nga ye?'],
      );

      final card = await service.getCard('test_card_1');
      expect(card, isNotNull);
      expect(card!.word, equals('mbolo'));
      expect(card.translation, equals('bonjour'));
      expect(card.languageCode, equals('ewondo'));
      expect(card.easinessFactor, equals(2.5));
      expect(card.repetition, equals(0));
    });

    test('should get new cards correctly', () async {
      // Add multiple cards
      await service.addCard(
        id: 'new_card_1',
        word: 'akeva',
        translation: 'merci',
        languageCode: 'ewondo',
      );

      await service.addCard(
        id: 'new_card_2',
        word: 'muambo',
        translation: 'ami',
        languageCode: 'ewondo',
      );

      final newCards = await service.getNewCards(maxCards: 10);
      expect(newCards.length, equals(2));
      expect(newCards.every((card) => card.repetition == 0), isTrue);
    });

    test('should handle card review with different qualities', () async {
      await service.addCard(
        id: 'review_card_1',
        word: 'biza',
        translation: 'manger',
        languageCode: 'ewondo',
      );

      // Review with good quality
      await service.reviewCard(
        cardId: 'review_card_1',
        quality: ReviewQuality.easy,
        reviewTimeSeconds: 30,
        pronunciationCorrect: true,
      );

      final card = await service.getCard('review_card_1');
      expect(card!.repetition, equals(1));
      expect(card.interval, equals(1));
      expect(card.reviewSessions.length, equals(1));
      expect(card.reviewSessions.first.quality, equals(ReviewQuality.easy));
    });

    test('should reset card on poor quality review', () async {
      await service.addCard(
        id: 'reset_card_1',
        word: 'test_word',
        translation: 'test_translation',
        languageCode: 'ewondo',
      );

      // First, advance the card
      await service.reviewCard(
        cardId: 'reset_card_1',
        quality: ReviewQuality.easy,
      );
      await service.reviewCard(
        cardId: 'reset_card_1',
        quality: ReviewQuality.easy,
      );

      var card = await service.getCard('reset_card_1');
      expect(card!.repetition, greaterThan(0));

      // Now review with poor quality
      await service.reviewCard(
        cardId: 'reset_card_1',
        quality: ReviewQuality.incorrect,
      );

      card = await service.getCard('reset_card_1');
      expect(card!.repetition, equals(0));
      expect(card.interval, equals(1));
    });

    test('should calculate interval optimization for language learning', () async {
      await service.addCard(
        id: 'optimization_card_1',
        word: 'test_word',
        translation: 'test_translation',
        languageCode: 'ewondo', // Tonal language
        partOfSpeech: 'verb', // Difficult POS
      );

      // Review with pronunciation issues
      await service.reviewCard(
        cardId: 'optimization_card_1',
        quality: ReviewQuality.easy,
        pronunciationCorrect: false,
      );

      final card = await service.getCard('optimization_card_1');
      expect(card!.interval, lessThan(6)); // Should be reduced due to pronunciation issues
    });

    test('should get cards due for review', () async {
      // Add cards with different schedules
      await service.addCard(
        id: 'due_card_1',
        word: 'due_word_1',
        translation: 'translation_1',
        languageCode: 'ewondo',
      );

      await service.addCard(
        id: 'due_card_2',
        word: 'due_word_2',
        translation: 'translation_2',
        languageCode: 'duala',
      );

      // Review one card to make it due later
      await service.reviewCard(
        cardId: 'due_card_2',
        quality: ReviewQuality.easy,
      );

      final dueCards = await service.getCardsForReview();
      expect(dueCards.length, greaterThanOrEqualTo(1));
      expect(dueCards.any((card) => card.id == 'due_card_1'), isTrue);
    });

    test('should generate correct statistics', () async {
      // Add cards with different statuses
      await service.addCard(
        id: 'stats_card_1',
        word: 'word_1',
        translation: 'translation_1',
        languageCode: 'ewondo',
      );

      await service.addCard(
        id: 'stats_card_2',
        word: 'word_2',
        translation: 'translation_2',
        languageCode: 'ewondo',
      );

      // Review one card to change its status
      await service.reviewCard(
        cardId: 'stats_card_1',
        quality: ReviewQuality.easy,
      );

      final statistics = await service.getStatistics(languageCode: 'ewondo');
      expect(statistics.totalCards, equals(2));
      expect(statistics.newCards, equals(1));
      expect(statistics.learningCards, greaterThanOrEqualTo(1));
    });

    test('should provide study session recommendations', () async {
      // Add cards to get meaningful recommendations
      for (int i = 0; i < 10; i++) {
        await service.addCard(
          id: 'rec_card_$i',
          word: 'word_$i',
          translation: 'translation_$i',
          languageCode: 'ewondo',
        );
      }

      final recommendation = await service.getStudyRecommendation(
        languageCode: 'ewondo',
        targetMinutes: 15,
      );

      expect(recommendation.newCards, greaterThan(0));
      expect(recommendation.estimatedMinutes, lessThanOrEqualTo(15));
      expect(recommendation.priorityLevel, isNotNull);
    });

    test('should handle card removal', () async {
      await service.addCard(
        id: 'remove_card_1',
        word: 'remove_word',
        translation: 'remove_translation',
        languageCode: 'ewondo',
      );

      var card = await service.getCard('remove_card_1');
      expect(card, isNotNull);

      await service.removeCard('remove_card_1');

      card = await service.getCard('remove_card_1');
      expect(card, isNull);
    });

    test('should update card metadata without affecting schedule', () async {
      await service.addCard(
        id: 'metadata_card_1',
        word: 'metadata_word',
        translation: 'metadata_translation',
        languageCode: 'ewondo',
      );

      final originalCard = await service.getCard('metadata_card_1');
      final originalInterval = originalCard!.interval;
      final originalRepetition = originalCard.repetition;

      await service.updateCardMetadata('metadata_card_1', {
        'custom_field': 'custom_value',
        'difficulty_override': 'hard',
      });

      final updatedCard = await service.getCard('metadata_card_1');
      expect(updatedCard!.metadata['custom_field'], equals('custom_value'));
      expect(updatedCard.interval, equals(originalInterval));
      expect(updatedCard.repetition, equals(originalRepetition));
    });

    test('should export and import data correctly', () async {
      // Add some test data
      await service.addCard(
        id: 'export_card_1',
        word: 'export_word',
        translation: 'export_translation',
        languageCode: 'ewondo',
      );

      await service.reviewCard(
        cardId: 'export_card_1',
        quality: ReviewQuality.easy,
      );

      // Export data
      final exportData = await service.exportData();
      expect(exportData['cards'], isNotNull);
      expect(exportData['statistics'], isNotNull);
      expect(exportData['version'], equals('1.0'));

      // Clear data
      await service.removeCard('export_card_1');

      // Import data
      await service.importData(exportData);

      // Verify data was imported
      final importedCard = await service.getCard('export_card_1');
      expect(importedCard, isNotNull);
      expect(importedCard!.word, equals('export_word'));
    });

    test('should handle edge cases and errors gracefully', () async {
      // Test reviewing non-existent card
      expect(
        () => service.reviewCard(
          cardId: 'non_existent_card',
          quality: ReviewQuality.easy,
        ),
        throwsException,
      );

      // Test getting non-existent card
      final nonExistentCard = await service.getCard('non_existent_card');
      expect(nonExistentCard, isNull);

      // Test removing non-existent card (should not throw)
      await service.removeCard('non_existent_card');
    });

    test('should handle concurrent operations', () async {
      // Add multiple cards concurrently
      final futures = <Future>[];
      for (int i = 0; i < 10; i++) {
        futures.add(service.addCard(
          id: 'concurrent_card_$i',
          word: 'word_$i',
          translation: 'translation_$i',
          languageCode: 'ewondo',
        ));
      }

      await Future.wait(futures);

      // Verify all cards were added
      for (int i = 0; i < 10; i++) {
        final card = await service.getCard('concurrent_card_$i');
        expect(card, isNotNull);
      }
    });

    test('should maintain data consistency across operations', () async {
      await service.addCard(
        id: 'consistency_card_1',
        word: 'consistency_word',
        translation: 'consistency_translation',
        languageCode: 'ewondo',
      );

      // Perform multiple operations
      await service.reviewCard(
        cardId: 'consistency_card_1',
        quality: ReviewQuality.easy,
      );

      await service.updateCardMetadata('consistency_card_1', {
        'test_metadata': 'test_value',
      });

      final card = await service.getCard('consistency_card_1');
      expect(card!.reviewSessions.length, equals(1));
      expect(card.metadata['test_metadata'], equals('test_value'));
      expect(card.repetition, equals(1));
    });
  });
}

/// Mock adapter for testing
class SpacedRepetitionCardAdapter extends TypeAdapter<SpacedRepetitionCard> {
  @override
  final typeId = 0;

  @override
  SpacedRepetitionCard read(BinaryReader reader) {
    // Simplified implementation for testing
    return SpacedRepetitionCard(
      id: reader.readString(),
      word: reader.readString(),
      translation: reader.readString(),
      languageCode: reader.readString(),
      exampleSentences: [],
      metadata: {},
      easinessFactor: 2.5,
      interval: 1,
      repetition: 0,
      nextReviewDate: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, SpacedRepetitionCard obj) {
    // Simplified implementation for testing
    writer.writeString(obj.id);
    writer.writeString(obj.word);
    writer.writeString(obj.translation);
    writer.writeString(obj.languageCode);
  }
}

class ReviewSessionAdapter extends TypeAdapter<ReviewSession> {
  @override
  final typeId = 1;

  @override
  ReviewSession read(BinaryReader reader) {
    return ReviewSession(
      date: DateTime.now(),
      quality: ReviewQuality.easy,
    );
  }

  @override
  void write(BinaryWriter writer, ReviewSession obj) {
    // Simplified implementation for testing
  }
}