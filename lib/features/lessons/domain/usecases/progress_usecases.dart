import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/progress.dart';
import '../repositories/progress_repository.dart';

/// Get user progress usecase
class GetUserProgressUsecase {
  final ProgressRepository repository;

  GetUserProgressUsecase(this.repository);

  Future<Either<Failure, List<Progress>>> call(String userId) async {
    return await repository.getUserProgress(userId);
  }
}

/// Get lesson progress usecase
class GetLessonProgressUsecase {
  final ProgressRepository repository;

  GetLessonProgressUsecase(this.repository);

  Future<Either<Failure, Progress?>> call(String userId, String lessonId) async {
    return await repository.getLessonProgress(userId, lessonId);
  }
}

/// Get course progress usecase
class GetCourseProgressUsecase {
  final ProgressRepository repository;

  GetCourseProgressUsecase(this.repository);

  Future<Either<Failure, List<Progress>>> call(String userId, String courseId) async {
    return await repository.getCourseProgress(userId, courseId);
  }
}

/// Save progress usecase
class SaveProgressUsecase {
  final ProgressRepository repository;

  SaveProgressUsecase(this.repository);

  Future<Either<Failure, bool>> call(Progress progress) async {
    return await repository.saveProgress(progress);
  }
}

/// Update progress status usecase
class UpdateProgressStatusUsecase {
  final ProgressRepository repository;

  UpdateProgressStatusUsecase(this.repository);

  Future<Either<Failure, bool>> call(String progressId, ProgressStatus status) async {
    return await repository.updateProgressStatus(progressId, status);
  }
}

/// Update current position usecase
class UpdateCurrentPositionUsecase {
  final ProgressRepository repository;

  UpdateCurrentPositionUsecase(this.repository);

  Future<Either<Failure, bool>> call(String progressId, int position) async {
    return await repository.updateCurrentPosition(progressId, position);
  }
}

/// Update score usecase
class UpdateScoreUsecase {
  final ProgressRepository repository;

  UpdateScoreUsecase(this.repository);

  Future<Either<Failure, bool>> call(String progressId, int score) async {
    return await repository.updateScore(progressId, score);
  }
}

/// Add time spent usecase
class AddTimeSpentUsecase {
  final ProgressRepository repository;

  AddTimeSpentUsecase(this.repository);

  Future<Either<Failure, bool>> call(String progressId, int seconds) async {
    return await repository.addTimeSpent(progressId, seconds);
  }
}

/// Reset progress usecase
class ResetProgressUsecase {
  final ProgressRepository repository;

  ResetProgressUsecase(this.repository);

  Future<Either<Failure, bool>> call(String progressId) async {
    return await repository.resetProgress(progressId);
  }
}

/// Delete progress usecase
class DeleteProgressUsecase {
  final ProgressRepository repository;

  DeleteProgressUsecase(this.repository);

  Future<Either<Failure, bool>> call(String progressId) async {
    return await repository.deleteProgress(progressId);
  }
}
