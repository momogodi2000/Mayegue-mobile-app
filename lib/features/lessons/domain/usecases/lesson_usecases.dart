import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/lesson.dart';
import '../repositories/lesson_repository.dart';

/// Get lessons by course usecase
class GetLessonsByCourseUsecase {
  final LessonRepository repository;

  GetLessonsByCourseUsecase(this.repository);

  Future<Either<Failure, List<Lesson>>> call(String courseId) async {
    return await repository.getLessonsByCourse(courseId);
  }
}

/// Get lesson by ID usecase
class GetLessonByIdUsecase {
  final LessonRepository repository;

  GetLessonByIdUsecase(this.repository);

  Future<Either<Failure, Lesson>> call(String lessonId) async {
    return await repository.getLessonById(lessonId);
  }
}

/// Get next lesson usecase
class GetNextLessonUsecase {
  final LessonRepository repository;

  GetNextLessonUsecase(this.repository);

  Future<Either<Failure, Lesson?>> call(String courseId, int currentOrder) async {
    return await repository.getNextLesson(courseId, currentOrder);
  }
}

/// Get previous lesson usecase
class GetPreviousLessonUsecase {
  final LessonRepository repository;

  GetPreviousLessonUsecase(this.repository);

  Future<Either<Failure, Lesson?>> call(String courseId, int currentOrder) async {
    return await repository.getPreviousLesson(courseId, currentOrder);
  }
}

/// Update lesson status usecase
class UpdateLessonStatusUsecase {
  final LessonRepository repository;

  UpdateLessonStatusUsecase(this.repository);

  Future<Either<Failure, bool>> call(String lessonId, LessonStatus status) async {
    return await repository.updateLessonStatus(lessonId, status);
  }
}

/// Complete lesson usecase
class CompleteLessonUsecase {
  final LessonRepository repository;

  CompleteLessonUsecase(this.repository);

  Future<Either<Failure, bool>> call(String lessonId) async {
    return await repository.completeLesson(lessonId);
  }
}

/// Reset lesson usecase
class ResetLessonUsecase {
  final LessonRepository repository;

  ResetLessonUsecase(this.repository);

  Future<Either<Failure, bool>> call(String lessonId) async {
    return await repository.resetLesson(lessonId);
  }
}

/// Create lesson usecase (for teachers)
class CreateLessonUsecase {
  final LessonRepository repository;

  CreateLessonUsecase(this.repository);

  Future<Either<Failure, Lesson>> call(Lesson lesson) async {
    return await repository.createLesson(lesson);
  }
}

/// Update lesson usecase (for teachers)
class UpdateLessonUsecase {
  final LessonRepository repository;

  UpdateLessonUsecase(this.repository);

  Future<Either<Failure, Lesson>> call(String lessonId, Lesson lesson) async {
    return await repository.updateLesson(lessonId, lesson);
  }
}

/// Delete lesson usecase (for teachers)
class DeleteLessonUsecase {
  final LessonRepository repository;

  DeleteLessonUsecase(this.repository);

  Future<Either<Failure, bool>> call(String lessonId) async {
    return await repository.deleteLesson(lessonId);
  }
}
