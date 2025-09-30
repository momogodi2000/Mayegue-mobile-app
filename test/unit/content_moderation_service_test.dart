import 'package:flutter_test/flutter_test.dart';

import 'package:mayegue/core/services/content_moderation_service.dart';

void main() {
  late ContentModerationService moderationService;

  setUp(() {
    moderationService = ContentModerationService('test-api-key');
  });

  group('ContentModerationService', () {
    test('containsSpam - detects spam patterns', () async {
      expect(await moderationService.containsSpam('Buy viagra now!'), isTrue);
      expect(await moderationService.containsSpam('Win a free prize today!'), isTrue);
      expect(await moderationService.containsSpam('Check out this website: http://spam.com'), isTrue);
      expect(await moderationService.containsSpam('This is a normal message'), isFalse);
    });

    test('containsSpam - case insensitive', () async {
      expect(await moderationService.containsSpam('FREE MONEY NOW'), isTrue);
      expect(await moderationService.containsSpam('ViAgRa'), isTrue);
    });

    test('containsSpam - phone number detection', () async {
      expect(await moderationService.containsSpam('Call me at 123456789012'), isTrue);
      expect(await moderationService.containsSpam('My number is 123-456-7890'), isFalse);
    });

    test('ModerationResult toString', () {
      final result = ModerationResult(
        isApproved: false,
        flaggedCategories: ['hate', 'violence'],
        confidence: 0.85,
        reason: 'Content flagged by AI moderation',
      );

      expect(
        result.toString(),
        'ModerationResult(isApproved: false, categories: [hate, violence], confidence: 0.85, reason: Content flagged by AI moderation)',
      );
    });

    test('ModerationAction enum values', () {
      expect(ModerationAction.approve, ModerationAction.approve);
      expect(ModerationAction.flag, ModerationAction.flag);
      expect(ModerationAction.reject, ModerationAction.reject);
    });

    test('ModerationResult constructor', () {
      final result = ModerationResult(
        isApproved: true,
        flaggedCategories: [],
        confidence: 0.0,
        reason: 'Test reason',
      );

      expect(result.isApproved, isTrue);
      expect(result.flaggedCategories, isEmpty);
      expect(result.confidence, 0.0);
      expect(result.reason, 'Test reason');
    });
  });
}
