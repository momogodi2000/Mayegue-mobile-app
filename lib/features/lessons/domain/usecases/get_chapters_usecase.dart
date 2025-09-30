import '../entities/lesson_entity.dart';
import '../repositories/lessons_repository.dart';

/// Use case for getting chapters by language
class GetChaptersUseCase {
  final LessonsRepository repository;

  GetChaptersUseCase(this.repository);

  Future<List<ChapterEntity>> call(String language) async {
    try {
      final chapters = await repository.getChapters(language);
      // Sort chapters by order
      chapters.sort((a, b) => a.order.compareTo(b.order));
      return chapters;
    } catch (e) {
      throw Exception('Failed to get chapters: $e');
    }
  }
}

/// Use case for getting lessons by chapter
class GetLessonsByChapterUseCase {
  final LessonsRepository repository;

  GetLessonsByChapterUseCase(this.repository);

  Future<List<LessonEntity>> call(String chapterId) async {
    try {
      final lessons = await repository.getLessonsByChapter(chapterId);
      // Sort lessons by order
      lessons.sort((a, b) => a.order.compareTo(b.order));
      return lessons;
    } catch (e) {
      throw Exception('Failed to get lessons: $e');
    }
  }
}

/// Use case for getting a specific lesson
class GetLessonUseCase {
  final LessonsRepository repository;

  GetLessonUseCase(this.repository);

  Future<LessonEntity?> call(String lessonId) async {
    try {
      return await repository.getLessonById(lessonId);
    } catch (e) {
      throw Exception('Failed to get lesson: $e');
    }
  }
}

/// Use case for getting lesson progress
class GetLessonProgressUseCase {
  final LessonsRepository repository;

  GetLessonProgressUseCase(this.repository);

  Future<LessonProgressEntity?> call(String userId, String lessonId) async {
    try {
      return await repository.getLessonProgress(userId, lessonId);
    } catch (e) {
      throw Exception('Failed to get lesson progress: $e');
    }
  }
}

/// Use case for updating lesson progress
class UpdateLessonProgressUseCase {
  final LessonsRepository repository;

  UpdateLessonProgressUseCase(this.repository);

  Future<void> call(LessonProgressEntity progress) async {
    try {
      await repository.updateLessonProgress(progress);
    } catch (e) {
      throw Exception('Failed to update lesson progress: $e');
    }
  }
}

/// Use case for completing an exercise
class CompleteExerciseUseCase {
  final LessonsRepository repository;

  CompleteExerciseUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String lessonId,
    required String exerciseId,
    required bool isCorrect,
    required int score,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await repository.completeExercise(
        userId: userId,
        lessonId: lessonId,
        exerciseId: exerciseId,
        isCorrect: isCorrect,
        score: score,
        metadata: metadata,
      );
    } catch (e) {
      throw Exception('Failed to complete exercise: $e');
    }
  }
}

/// Use case for getting recommended lessons
class GetRecommendedLessonsUseCase {
  final LessonsRepository repository;

  GetRecommendedLessonsUseCase(this.repository);

  Future<List<LessonEntity>> call(String userId, String language) async {
    try {
      return await repository.getRecommendedLessons(userId, language);
    } catch (e) {
      throw Exception('Failed to get recommended lessons: $e');
    }
  }
}

/// Use case for searching lessons
class SearchLessonsUseCase {
  final LessonsRepository repository;

  SearchLessonsUseCase(this.repository);

  Future<List<LessonEntity>> call(String query, {String? language}) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }
      return await repository.searchLessons(query, language: language);
    } catch (e) {
      throw Exception('Failed to search lessons: $e');
    }
  }
}

/// Use case for checking if lesson is unlocked
class IsLessonUnlockedUseCase {
  final LessonsRepository repository;

  IsLessonUnlockedUseCase(this.repository);

  Future<bool> call(String userId, String lessonId) async {
    try {
      return await repository.isLessonUnlocked(userId, lessonId);
    } catch (e) {
      // If error occurs, assume lesson is locked
      return false;
    }
  }
}

/// Use case for getting user learning statistics
class GetLearningStatisticsUseCase {
  final LessonsRepository repository;

  GetLearningStatisticsUseCase(this.repository);

  Future<Map<String, dynamic>> call(String userId) async {
    try {
      return await repository.getLearningStatistics(userId);
    } catch (e) {
      throw Exception('Failed to get learning statistics: $e');
    }
  }
}

/// Use case for getting free lessons for guests
class GetFreeLessonsUseCase {
  final LessonsRepository repository;

  GetFreeLessonsUseCase(this.repository);

  Future<List<LessonEntity>> call(String language) async {
    try {
      final lessons = await repository.getFreeLessons(language);
      // Sort lessons by order and limit to first 3 for guests
      lessons.sort((a, b) => a.order.compareTo(b.order));
      return lessons.take(3).toList();
    } catch (e) {
      throw Exception('Failed to get free lessons: $e');
    }
  }
}
