import 'dart:convert';
import 'package:http/http.dart' as http;
import 'firebase_service.dart';

/// AI-powered content moderation service
class ContentModerationService {
  final FirebaseService _firebaseService = FirebaseService();
  final String _apiKey; // OpenAI API key
  final String _baseUrl = 'https://api.openai.com/v1';

  ContentModerationService(this._apiKey);

  /// Moderate content using AI
  Future<ModerationResult> moderateContent(
      String content, String contentType) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/moderations'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'input': content,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;

        if (results.isNotEmpty) {
          final result = results[0];
          final flagged = result['flagged'] as bool;
          final categories = result['categories'] as Map<String, dynamic>;

          return ModerationResult(
            isApproved: !flagged,
            flaggedCategories: categories.entries
                .where((entry) => entry.value == true)
                .map((entry) => entry.key)
                .toList(),
            confidence: _calculateConfidence(
                result['category_scores'] as Map<String, dynamic>),
            reason: flagged
                ? 'Content flagged by AI moderation'
                : 'Content approved',
          );
        }
      }

      // Fallback: approve content if API fails
      return ModerationResult(
        isApproved: true,
        flaggedCategories: [],
        confidence: 0.0,
        reason: 'Moderation service unavailable, content approved',
      );
    } catch (e) {
      // Fallback: approve content if there's an error
      return ModerationResult(
        isApproved: true,
        flaggedCategories: [],
        confidence: 0.0,
        reason: 'Moderation service error, content approved',
      );
    }
  }

  /// Moderate forum discussion
  Future<ModerationResult> moderateDiscussion(
      String title, String content) async {
    final fullContent = '$title\n\n$content';
    return moderateContent(fullContent, 'discussion');
  }

  /// Moderate chat message
  Future<ModerationResult> moderateChatMessage(String message) async {
    return moderateContent(message, 'chat');
  }

  /// Moderate user profile content
  Future<ModerationResult> moderateProfile(
      String bio, String displayName) async {
    final content = '$displayName\n\n$bio';
    return moderateContent(content, 'profile');
  }

  /// Check if content contains spam patterns
  Future<bool> containsSpam(String content) async {
    // Simple spam detection patterns
    final spamPatterns = [
      r'\b(?:viagra|casino|lottery|winner)\b',
      r'\b(?:free|win|prize|money)\b.*\b(?:now|today|instant)\b',
      r'(?:http|https|www\.)\S+', // URLs (basic detection)
      r'\b\d{10,}\b', // Long numbers (potentially phone numbers)
    ];

    for (final pattern in spamPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(content)) {
        return true;
      }
    }

    return false;
  }

  /// Auto-moderate and take action
  Future<ModerationAction> autoModerate(
      String contentId, String content, String contentType) async {
    final moderationResult = await moderateContent(content, contentType);
    final containsSpam = await this.containsSpam(content);

    if (!moderationResult.isApproved || containsSpam) {
      // Content is inappropriate
      await _flagContent(contentId, moderationResult, containsSpam);
      return ModerationAction.flag;
    }

    // Content is appropriate
    await _approveContent(contentId);
    return ModerationAction.approve;
  }

  /// Flag inappropriate content
  Future<void> _flagContent(
      String contentId, ModerationResult result, bool isSpam) async {
    await _firebaseService.firestore
        .collection('flagged_content')
        .doc(contentId)
        .set({
      'contentId': contentId,
      'flaggedCategories': result.flaggedCategories,
      'confidence': result.confidence,
      'isSpam': isSpam,
      'reason': result.reason,
      'flaggedAt': DateTime.now().toIso8601String(),
      'status': 'pending_review',
    });
  }

  /// Approve content
  Future<void> _approveContent(String contentId) async {
    // Mark as approved (could add to approved_content collection if needed)
    await _firebaseService.firestore
        .collection('moderated_content')
        .doc(contentId)
        .set({
      'contentId': contentId,
      'status': 'approved',
      'moderatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Manually review flagged content (admin function)
  Future<void> reviewFlaggedContent(String contentId, bool approve) async {
    final batch = _firebaseService.firestore.batch();

    final flaggedDoc =
        _firebaseService.firestore.collection('flagged_content').doc(contentId);

    if (approve) {
      // Move to approved
      batch.update(flaggedDoc, {
        'status': 'approved',
        'reviewedAt': DateTime.now().toIso8601String(),
        'reviewedBy': _firebaseService.auth.currentUser?.uid,
      });
    } else {
      // Keep flagged or take further action
      batch.update(flaggedDoc, {
        'status': 'rejected',
        'reviewedAt': DateTime.now().toIso8601String(),
        'reviewedBy': _firebaseService.auth.currentUser?.uid,
      });

      // Could also hide/delete the original content here
    }

    await batch.commit();
  }

  /// Get moderation statistics
  Future<Map<String, dynamic>> getModerationStats() async {
    final flaggedQuery =
        await _firebaseService.firestore.collection('flagged_content').get();

    final approvedQuery = await _firebaseService.firestore
        .collection('moderated_content')
        .where('status', isEqualTo: 'approved')
        .get();

    final categories = <String, int>{};
    for (final doc in flaggedQuery.docs) {
      final flaggedCategories = doc.data()['flaggedCategories'] as List?;
      if (flaggedCategories != null) {
        for (final category in flaggedCategories) {
          categories[category] = (categories[category] ?? 0) + 1;
        }
      }
    }

    return {
      'totalFlagged': flaggedQuery.size,
      'totalApproved': approvedQuery.size,
      'flaggedByCategory': categories,
      'moderationRate':
          approvedQuery.size / (flaggedQuery.size + approvedQuery.size),
    };
  }

  /// Calculate confidence score from category scores
  double _calculateConfidence(Map<String, dynamic> categoryScores) {
    double totalScore = 0.0;
    int count = 0;

    categoryScores.forEach((key, value) {
      if (value is num) {
        totalScore += value.toDouble();
        count++;
      }
    });

    return count > 0 ? totalScore / count : 0.0;
  }

  /// Batch moderate multiple content items
  Future<List<ModerationResult>> batchModerate(List<String> contents) async {
    final results = <ModerationResult>[];

    for (final content in contents) {
      final result = await moderateContent(content, 'batch');
      results.add(result);

      // Small delay to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return results;
  }
}

/// Moderation result
class ModerationResult {
  final bool isApproved;
  final List<String> flaggedCategories;
  final double confidence;
  final String reason;

  ModerationResult({
    required this.isApproved,
    required this.flaggedCategories,
    required this.confidence,
    required this.reason,
  });

  @override
  String toString() {
    return 'ModerationResult(isApproved: $isApproved, categories: $flaggedCategories, confidence: $confidence, reason: $reason)';
  }
}

/// Moderation actions
enum ModerationAction {
  approve,
  flag,
  reject,
}
