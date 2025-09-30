import 'package:hive/hive.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/progress.dart';
import '../models/progress_model.dart';

/// Abstract data source for progress operations
abstract class ProgressDataSource {
  Future<List<ProgressModel>> getUserProgress(String userId);
  Future<ProgressModel?> getLessonProgress(String userId, String lessonId);
  Future<List<ProgressModel>> getCourseProgress(String userId, String courseId);
  Future<bool> saveProgress(ProgressModel progress);
  Future<bool> updateProgressStatus(String progressId, ProgressStatus status);
  Future<bool> updateCurrentPosition(String progressId, int position);
  Future<bool> updateScore(String progressId, int score);
  Future<bool> addTimeSpent(String progressId, int seconds);
  Future<bool> resetProgress(String progressId);
  Future<bool> deleteProgress(String progressId);
}

/// Local data source implementation using Hive
class ProgressLocalDataSource implements ProgressDataSource {
  static const String _progressBoxName = 'progress';

  late Box<ProgressModel> _progressBox;

  Future<void> initialize() async {
    _progressBox = await Hive.openBox<ProgressModel>(_progressBoxName);
  }

  @override
  Future<List<ProgressModel>> getUserProgress(String userId) async {
    try {
      return _progressBox.values
          .where((progress) => progress.userId == userId)
          .toList();
    } catch (e) {
      throw CacheFailure('Failed to load user progress: $e');
    }
  }

  @override
  Future<ProgressModel?> getLessonProgress(
      String userId, String lessonId) async {
    try {
      return _progressBox.values.cast<ProgressModel?>().firstWhere(
            (progress) =>
                progress?.userId == userId && progress?.lessonId == lessonId,
            orElse: () => null,
          );
    } catch (e) {
      throw CacheFailure('Failed to load lesson progress: $e');
    }
  }

  @override
  Future<List<ProgressModel>> getCourseProgress(
      String userId, String courseId) async {
    try {
      return _progressBox.values
          .where((progress) =>
              progress.userId == userId && progress.courseId == courseId)
          .toList();
    } catch (e) {
      throw CacheFailure('Failed to load course progress: $e');
    }
  }

  @override
  Future<bool> saveProgress(ProgressModel progress) async {
    try {
      await _progressBox.put(progress.id, progress);
      return true;
    } catch (e) {
      throw CacheFailure('Failed to save progress: $e');
    }
  }

  @override
  Future<bool> updateProgressStatus(
      String progressId, ProgressStatus status) async {
    try {
      final progress = _progressBox.get(progressId);
      if (progress == null) {
        throw CacheFailure('Progress not found: $progressId');
      }

      final updatedProgress = ProgressModel(
        id: progress.id,
        userId: progress.userId,
        lessonId: progress.lessonId,
        courseId: progress.courseId,
        status: status,
        currentPosition: progress.currentPosition,
        score: progress.score,
        timeSpent: progress.timeSpent,
        startedAt: progress.startedAt,
        completedAt: status == ProgressStatus.completed
            ? DateTime.now()
            : progress.completedAt,
        lastAccessedAt: DateTime.now(),
      );

      await _progressBox.put(progressId, updatedProgress);
      return true;
    } catch (e) {
      throw CacheFailure('Failed to update progress status: $e');
    }
  }

  @override
  Future<bool> updateCurrentPosition(String progressId, int position) async {
    try {
      final progress = _progressBox.get(progressId);
      if (progress == null) {
        throw CacheFailure('Progress not found: $progressId');
      }

      final updatedProgress = ProgressModel(
        id: progress.id,
        userId: progress.userId,
        lessonId: progress.lessonId,
        courseId: progress.courseId,
        status: progress.status,
        currentPosition: position,
        score: progress.score,
        timeSpent: progress.timeSpent,
        startedAt: progress.startedAt,
        completedAt: progress.completedAt,
        lastAccessedAt: DateTime.now(),
      );

      await _progressBox.put(progressId, updatedProgress);
      return true;
    } catch (e) {
      throw CacheFailure('Failed to update current position: $e');
    }
  }

  @override
  Future<bool> updateScore(String progressId, int score) async {
    try {
      final progress = _progressBox.get(progressId);
      if (progress == null) {
        throw CacheFailure('Progress not found: $progressId');
      }

      final updatedProgress = ProgressModel(
        id: progress.id,
        userId: progress.userId,
        lessonId: progress.lessonId,
        courseId: progress.courseId,
        status: progress.status,
        currentPosition: progress.currentPosition,
        score: score,
        timeSpent: progress.timeSpent,
        startedAt: progress.startedAt,
        completedAt: progress.completedAt,
        lastAccessedAt: DateTime.now(),
      );

      await _progressBox.put(progressId, updatedProgress);
      return true;
    } catch (e) {
      throw CacheFailure('Failed to update score: $e');
    }
  }

  @override
  Future<bool> addTimeSpent(String progressId, int seconds) async {
    try {
      final progress = _progressBox.get(progressId);
      if (progress == null) {
        throw CacheFailure('Progress not found: $progressId');
      }

      final updatedProgress = ProgressModel(
        id: progress.id,
        userId: progress.userId,
        lessonId: progress.lessonId,
        courseId: progress.courseId,
        status: progress.status,
        currentPosition: progress.currentPosition,
        score: progress.score,
        timeSpent: progress.timeSpent + seconds,
        startedAt: progress.startedAt,
        completedAt: progress.completedAt,
        lastAccessedAt: DateTime.now(),
      );

      await _progressBox.put(progressId, updatedProgress);
      return true;
    } catch (e) {
      throw CacheFailure('Failed to add time spent: $e');
    }
  }

  @override
  Future<bool> resetProgress(String progressId) async {
    try {
      final progress = _progressBox.get(progressId);
      if (progress == null) {
        throw CacheFailure('Progress not found: $progressId');
      }

      final resetProgress = ProgressModel(
        id: progress.id,
        userId: progress.userId,
        lessonId: progress.lessonId,
        courseId: progress.courseId,
        status: ProgressStatus.notStarted,
        currentPosition: 0,
        score: 0,
        timeSpent: 0,
        startedAt: DateTime.now(),
        completedAt: null,
        lastAccessedAt: DateTime.now(),
      );

      await _progressBox.put(progressId, resetProgress);
      return true;
    } catch (e) {
      throw CacheFailure('Failed to reset progress: $e');
    }
  }

  @override
  Future<bool> deleteProgress(String progressId) async {
    try {
      await _progressBox.delete(progressId);
      return true;
    } catch (e) {
      throw CacheFailure('Failed to delete progress: $e');
    }
  }
}
