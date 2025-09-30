import 'package:equatable/equatable.dart';

/// Lesson entity representing a language lesson
class LessonEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String language;
  final String difficulty;
  final int duration; // in minutes
  final String category;
  final List<String> objectives;
  final String? audioUrl;
  final String? videoUrl;
  final String? thumbnailUrl;
  final bool isPremium;
  final int order;
  final String chapterId;
  final List<ExerciseEntity> exercises;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const LessonEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.language,
    required this.difficulty,
    required this.duration,
    required this.category,
    required this.objectives,
    this.audioUrl,
    this.videoUrl,
    this.thumbnailUrl,
    required this.isPremium,
    required this.order,
    required this.chapterId,
    required this.exercises,
    required this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        language,
        difficulty,
        duration,
        category,
        objectives,
        audioUrl,
        videoUrl,
        thumbnailUrl,
        isPremium,
        order,
        chapterId,
        exercises,
        metadata,
        createdAt,
        updatedAt,
      ];

  LessonEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? language,
    String? difficulty,
    int? duration,
    String? category,
    List<String>? objectives,
    String? audioUrl,
    String? videoUrl,
    String? thumbnailUrl,
    bool? isPremium,
    int? order,
    String? chapterId,
    List<ExerciseEntity>? exercises,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LessonEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      language: language ?? this.language,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      objectives: objectives ?? this.objectives,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isPremium: isPremium ?? this.isPremium,
      order: order ?? this.order,
      chapterId: chapterId ?? this.chapterId,
      exercises: exercises ?? this.exercises,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Exercise entity representing a lesson exercise
class ExerciseEntity extends Equatable {
  final String id;
  final String lessonId;
  final String
      type; // 'multiple_choice', 'fill_blank', 'audio_match', 'pronunciation'
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String? audioUrl;
  final String? imageUrl;
  final int points;
  final int order;
  final Map<String, dynamic> metadata;

  const ExerciseEntity({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.audioUrl,
    this.imageUrl,
    required this.points,
    required this.order,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        lessonId,
        type,
        question,
        options,
        correctAnswer,
        explanation,
        audioUrl,
        imageUrl,
        points,
        order,
        metadata,
      ];

  ExerciseEntity copyWith({
    String? id,
    String? lessonId,
    String? type,
    String? question,
    List<String>? options,
    String? correctAnswer,
    String? explanation,
    String? audioUrl,
    String? imageUrl,
    int? points,
    int? order,
    Map<String, dynamic>? metadata,
  }) {
    return ExerciseEntity(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      type: type ?? this.type,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      points: points ?? this.points,
      order: order ?? this.order,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Chapter entity representing a lesson chapter/course
class ChapterEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String language;
  final String difficulty;
  final List<LessonEntity> lessons;
  final String? thumbnailUrl;
  final bool isPremium;
  final int order;
  final int estimatedHours;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ChapterEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.language,
    required this.difficulty,
    required this.lessons,
    this.thumbnailUrl,
    required this.isPremium,
    required this.order,
    required this.estimatedHours,
    required this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        language,
        difficulty,
        lessons,
        thumbnailUrl,
        isPremium,
        order,
        estimatedHours,
        metadata,
        createdAt,
        updatedAt,
      ];

  ChapterEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? language,
    String? difficulty,
    List<LessonEntity>? lessons,
    String? thumbnailUrl,
    bool? isPremium,
    int? order,
    int? estimatedHours,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChapterEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      language: language ?? this.language,
      difficulty: difficulty ?? this.difficulty,
      lessons: lessons ?? this.lessons,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isPremium: isPremium ?? this.isPremium,
      order: order ?? this.order,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Lesson progress entity
class LessonProgressEntity extends Equatable {
  final String id;
  final String userId;
  final String lessonId;
  final double completionPercentage;
  final int totalExercises;
  final int completedExercises;
  final int correctAnswers;
  final int totalScore;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime lastAccessedAt;
  final Map<String, dynamic> exerciseResults;

  const LessonProgressEntity({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.completionPercentage,
    required this.totalExercises,
    required this.completedExercises,
    required this.correctAnswers,
    required this.totalScore,
    required this.isCompleted,
    this.completedAt,
    required this.lastAccessedAt,
    required this.exerciseResults,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        lessonId,
        completionPercentage,
        totalExercises,
        completedExercises,
        correctAnswers,
        totalScore,
        isCompleted,
        completedAt,
        lastAccessedAt,
        exerciseResults,
      ];

  LessonProgressEntity copyWith({
    String? id,
    String? userId,
    String? lessonId,
    double? completionPercentage,
    int? totalExercises,
    int? completedExercises,
    int? correctAnswers,
    int? totalScore,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? lastAccessedAt,
    Map<String, dynamic>? exerciseResults,
  }) {
    return LessonProgressEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      totalExercises: totalExercises ?? this.totalExercises,
      completedExercises: completedExercises ?? this.completedExercises,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalScore: totalScore ?? this.totalScore,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      exerciseResults: exerciseResults ?? this.exerciseResults,
    );
  }
}
