import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/usecases/lesson_usecases.dart';

/// ViewModel for lessons management
class LessonsViewModel extends ChangeNotifier {
  final GetLessonsByCourseUsecase getLessonsByCourseUsecase;
  final GetLessonByIdUsecase getLessonByIdUsecase;
  final GetNextLessonUsecase getNextLessonUsecase;
  final GetPreviousLessonUsecase getPreviousLessonUsecase;
  final CompleteLessonUsecase completeLessonUsecase;
  final ResetLessonUsecase resetLessonUsecase;
  final CreateLessonUsecase createLessonUsecase;
  final UpdateLessonUsecase updateLessonUsecase;
  final DeleteLessonUsecase deleteLessonUsecase;

  LessonsViewModel({
    required this.getLessonsByCourseUsecase,
    required this.getLessonByIdUsecase,
    required this.getNextLessonUsecase,
    required this.getPreviousLessonUsecase,
    required this.completeLessonUsecase,
    required this.resetLessonUsecase,
    required this.createLessonUsecase,
    required this.updateLessonUsecase,
    required this.deleteLessonUsecase,
  });

  // State
  List<Lesson> _lessons = [];
  Lesson? _currentLesson;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Lesson> get lessons => _lessons;
  Lesson? get currentLesson => _currentLesson;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Computed getters
  bool get hasNextLesson {
    if (_currentLesson == null) return false;
    return _lessons.any((lesson) =>
        lesson.order > _currentLesson!.order &&
        lesson.status != LessonStatus.locked);
  }

  bool get hasPreviousLesson {
    if (_currentLesson == null) return false;
    return _lessons.any((lesson) => lesson.order < _currentLesson!.order);
  }

  int get completedLessonsCount {
    return _lessons.where((lesson) => lesson.isCompleted).length;
  }

  double get completionPercentage {
    if (_lessons.isEmpty) return 0.0;
    return (completedLessonsCount / _lessons.length) * 100;
  }

  /// Load lessons for a course
  Future<void> loadLessons(String courseId) async {
    _setLoading(true);
    _clearError();

    final result = await getLessonsByCourseUsecase(courseId);

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (lessons) {
        _lessons = lessons;
        notifyListeners();
      },
    );

    _setLoading(false);
  }

  /// Load a specific lesson
  Future<void> loadLesson(String lessonId) async {
    _setLoading(true);
    _clearError();

    final result = await getLessonByIdUsecase(lessonId);

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (lesson) {
        _currentLesson = lesson;
        notifyListeners();
      },
    );

    _setLoading(false);
  }

  /// Set current lesson
  void setCurrentLesson(Lesson lesson) {
    _currentLesson = lesson;
    notifyListeners();
  }

  /// Navigate to next lesson
  Future<void> goToNextLesson() async {
    if (_currentLesson == null) return;

    final result = await getNextLessonUsecase(
      _currentLesson!.courseId,
      _currentLesson!.order,
    );

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (lesson) {
        if (lesson != null) {
          _currentLesson = lesson;
          notifyListeners();
        }
      },
    );
  }

  /// Navigate to previous lesson
  Future<void> goToPreviousLesson() async {
    if (_currentLesson == null) return;

    final result = await getPreviousLessonUsecase(
      _currentLesson!.courseId,
      _currentLesson!.order,
    );

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (lesson) {
        if (lesson != null) {
          _currentLesson = lesson;
          notifyListeners();
        }
      },
    );
  }

  /// Complete current lesson
  Future<bool> completeCurrentLesson() async {
    if (_currentLesson == null) return false;

    _setLoading(true);
    _clearError();

    final result = await completeLessonUsecase(_currentLesson!.id);

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        _setLoading(false);
        return false;
      },
      (success) {
        if (success && _currentLesson != null) {
          // Update local lesson status
          final updatedLesson = _currentLesson!.copyWith(status: LessonStatus.completed);
          _currentLesson = updatedLesson;

          // Update in lessons list
          final index = _lessons.indexWhere((l) => l.id == _currentLesson!.id);
          if (index != -1) {
            _lessons[index] = updatedLesson;
          }

          notifyListeners();
        }
        _setLoading(false);
        return success;
      },
    );
  }

  /// Reset a lesson
  Future<bool> resetLesson(String lessonId) async {
    _setLoading(true);
    _clearError();

    final result = await resetLessonUsecase(lessonId);

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        _setLoading(false);
        return false;
      },
      (success) {
        if (success) {
          // Update local lesson status
          final index = _lessons.indexWhere((l) => l.id == lessonId);
          if (index != -1) {
            final updatedLesson = _lessons[index].copyWith(status: LessonStatus.available);
            _lessons[index] = updatedLesson;

            // Update current lesson if it's the one being reset
            if (_currentLesson?.id == lessonId) {
              _currentLesson = updatedLesson;
            }

            notifyListeners();
          }
        }
        _setLoading(false);
        return success;
      },
    );
  }

  /// Check if lesson is accessible
  bool isLessonAccessible(Lesson lesson) {
    // First lesson is always accessible
    if (lesson.order == 1) return true;

    // Check if previous lesson is completed
    final previousLesson = _lessons
        .where((l) => l.order == lesson.order - 1)
        .firstOrNull;

    return previousLesson?.isCompleted ?? false;
  }

  /// Create a new lesson (Teacher functionality)
  Future<Lesson?> createLesson(Lesson lesson) async {
    _setLoading(true);
    _clearError();

    final result = await createLessonUsecase(lesson);

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        _setLoading(false);
        return null;
      },
      (createdLesson) {
        // Add to local lessons list
        _lessons.add(createdLesson);
        _lessons.sort((a, b) => a.order.compareTo(b.order));
        notifyListeners();
        _setLoading(false);
        return createdLesson;
      },
    );
  }

  /// Update an existing lesson (Teacher functionality)
  Future<Lesson?> updateLesson(String lessonId, Lesson lesson) async {
    _setLoading(true);
    _clearError();

    final result = await updateLessonUsecase(lessonId, lesson);

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        _setLoading(false);
        return null;
      },
      (updatedLesson) {
        // Update in lessons list
        final index = _lessons.indexWhere((l) => l.id == lessonId);
        if (index != -1) {
          _lessons[index] = updatedLesson;
          _lessons.sort((a, b) => a.order.compareTo(b.order));
        }

        // Update current lesson if it's the one being updated
        if (_currentLesson?.id == lessonId) {
          _currentLesson = updatedLesson;
        }

        notifyListeners();
        _setLoading(false);
        return updatedLesson;
      },
    );
  }

  /// Delete a lesson (Teacher functionality)
  Future<bool> deleteLesson(String lessonId) async {
    _setLoading(true);
    _clearError();

    final result = await deleteLessonUsecase(lessonId);

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        _setLoading(false);
        return false;
      },
      (success) {
        if (success) {
          // Remove from lessons list
          _lessons.removeWhere((l) => l.id == lessonId);

          // Clear current lesson if it's the one being deleted
          if (_currentLesson?.id == lessonId) {
            _currentLesson = null;
          }

          notifyListeners();
        }
        _setLoading(false);
        return success;
      },
    );
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is CacheFailure) {
      return 'Erreur de cache: ${failure.message}';
    } else if (failure is NetworkFailure) {
      return 'Erreur réseau: ${failure.message}';
    } else {
      return 'Une erreur s\'est produite: ${failure.message}';
    }
  }
}
