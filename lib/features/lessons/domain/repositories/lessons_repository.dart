import '../entities/lesson_entity.dart';

/// Repository interface for lessons management
abstract class LessonsRepository {
  /// Get all available chapters for a language
  Future<List<ChapterEntity>> getChapters(String language);

  /// Get lessons for a specific chapter
  Future<List<LessonEntity>> getLessonsByChapter(String chapterId);

  /// Get a specific lesson by ID
  Future<LessonEntity?> getLessonById(String lessonId);

  /// Get lesson progress for a user
  Future<LessonProgressEntity?> getLessonProgress(String userId, String lessonId);

  /// Update lesson progress
  Future<void> updateLessonProgress(LessonProgressEntity progress);

  /// Get all lesson progress for a user
  Future<List<LessonProgressEntity>> getUserProgress(String userId);

  /// Get recommended lessons based on user progress
  Future<List<LessonEntity>> getRecommendedLessons(String userId, String language);

  /// Search lessons by title or content
  Future<List<LessonEntity>> searchLessons(String query, {String? language});

  /// Get lessons by difficulty level
  Future<List<LessonEntity>> getLessonsByDifficulty(String difficulty, String language);

  /// Get lessons by category
  Future<List<LessonEntity>> getLessonsByCategory(String category, String language);

  /// Get premium lessons
  Future<List<LessonEntity>> getPremiumLessons(String language);

  /// Get free lessons for guest users
  Future<List<LessonEntity>> getFreeLessons(String language);

  /// Check if lesson is unlocked for user
  Future<bool> isLessonUnlocked(String userId, String lessonId);

  /// Complete an exercise
  Future<void> completeExercise({
    required String userId,
    required String lessonId,
    required String exerciseId,
    required bool isCorrect,
    required int score,
    Map<String, dynamic>? metadata,
  });

  /// Get user's learning statistics
  Future<Map<String, dynamic>> getLearningStatistics(String userId);

  /// Reset lesson progress
  Future<void> resetLessonProgress(String userId, String lessonId);

  /// Get lesson completion certificate data
  Future<Map<String, dynamic>?> getLessonCertificate(String userId, String lessonId);

  /// Cache lesson for offline access
  Future<void> cacheLessonForOffline(String lessonId);

  /// Get cached lessons for offline access
  Future<List<LessonEntity>> getCachedLessons();

  /// Remove lesson from offline cache
  Future<void> removeCachedLesson(String lessonId);
}