import 'package:equatable/equatable.dart';

/// Base game entity
abstract class GameEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String language;
  final GameType type;
  final GameDifficulty difficulty;
  final int estimatedDuration; // in minutes
  final String thumbnailUrl;
  final int maxScore;
  final Map<String, dynamic> gameData;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const GameEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.language,
    required this.type,
    required this.difficulty,
    required this.estimatedDuration,
    required this.thumbnailUrl,
    required this.maxScore,
    required this.gameData,
    required this.isPremium,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        language,
        type,
        difficulty,
        estimatedDuration,
        thumbnailUrl,
        maxScore,
        gameData,
        isPremium,
        createdAt,
        updatedAt,
      ];
}

/// Memory game entity
class MemoryGameEntity extends GameEntity {
  final List<MemoryCard> cards;
  final int gridSize; // 4x4, 6x6, etc.

  const MemoryGameEntity({
    required super.id,
    required super.title,
    required super.description,
    required super.language,
    required super.difficulty,
    required super.estimatedDuration,
    required super.thumbnailUrl,
    required super.maxScore,
    required super.gameData,
    required super.isPremium,
    required super.createdAt,
    super.updatedAt,
    required this.cards,
    required this.gridSize,
  }) : super(type: GameType.memory);

  @override
  List<Object?> get props => super.props + [cards, gridSize];
}

/// Word matching game entity
class WordMatchingGameEntity extends GameEntity {
  final List<WordPair> wordPairs;
  final int timeLimit; // in seconds

  const WordMatchingGameEntity({
    required super.id,
    required super.title,
    required super.description,
    required super.language,
    required super.difficulty,
    required super.estimatedDuration,
    required super.thumbnailUrl,
    required super.maxScore,
    required super.gameData,
    required super.isPremium,
    required super.createdAt,
    super.updatedAt,
    required this.wordPairs,
    required this.timeLimit,
  }) : super(type: GameType.wordMatching);

  @override
  List<Object?> get props => super.props + [wordPairs, timeLimit];
}

/// Quiz game entity
class QuizGameEntity extends GameEntity {
  final List<QuizQuestion> questions;
  final int timePerQuestion; // in seconds

  const QuizGameEntity({
    required super.id,
    required super.title,
    required super.description,
    required super.language,
    required super.difficulty,
    required super.estimatedDuration,
    required super.thumbnailUrl,
    required super.maxScore,
    required super.gameData,
    required super.isPremium,
    required super.createdAt,
    super.updatedAt,
    required this.questions,
    required this.timePerQuestion,
  }) : super(type: GameType.quiz);

  @override
  List<Object?> get props => super.props + [questions, timePerQuestion];
}

/// Pronunciation game entity
class PronunciationGameEntity extends GameEntity {
  final List<PronunciationChallenge> challenges;
  final double accuracyThreshold; // minimum accuracy required

  const PronunciationGameEntity({
    required super.id,
    required super.title,
    required super.description,
    required super.language,
    required super.difficulty,
    required super.estimatedDuration,
    required super.thumbnailUrl,
    required super.maxScore,
    required super.gameData,
    required super.isPremium,
    required super.createdAt,
    super.updatedAt,
    required this.challenges,
    required this.accuracyThreshold,
  }) : super(type: GameType.pronunciation);

  @override
  List<Object?> get props => super.props + [challenges, accuracyThreshold];
}

/// Word puzzle game entity
class WordPuzzleGameEntity extends GameEntity {
  final List<WordPuzzle> puzzles;
  final int hintsAllowed;

  const WordPuzzleGameEntity({
    required super.id,
    required super.title,
    required super.description,
    required super.language,
    required super.difficulty,
    required super.estimatedDuration,
    required super.thumbnailUrl,
    required super.maxScore,
    required super.gameData,
    required super.isPremium,
    required super.createdAt,
    super.updatedAt,
    required this.puzzles,
    required this.hintsAllowed,
  }) : super(type: GameType.wordPuzzle);

  @override
  List<Object?> get props => super.props + [puzzles, hintsAllowed];
}

/// Game types enum
enum GameType {
  memory,
  wordMatching,
  quiz,
  pronunciation,
  wordPuzzle,
  crossword,
  fillInBlanks,
  sequencing,
}

/// Game difficulty enum
enum GameDifficulty {
  beginner,
  intermediate,
  advanced,
  expert,
}

/// Memory card for memory games
class MemoryCard extends Equatable {
  final String id;
  final String word;
  final String translation;
  final String? audioUrl;
  final String? imageUrl;

  const MemoryCard({
    required this.id,
    required this.word,
    required this.translation,
    this.audioUrl,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, word, translation, audioUrl, imageUrl];
}

/// Word pair for word matching games
class WordPair extends Equatable {
  final String id;
  final String sourceWord;
  final String targetWord;
  final String? hint;
  final String? audioUrl;

  const WordPair({
    required this.id,
    required this.sourceWord,
    required this.targetWord,
    this.hint,
    this.audioUrl,
  });

  @override
  List<Object?> get props => [id, sourceWord, targetWord, hint, audioUrl];
}

/// Quiz question for quiz games
class QuizQuestion extends Equatable {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String? audioUrl;
  final String? imageUrl;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.audioUrl,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        question,
        options,
        correctAnswer,
        explanation,
        audioUrl,
        imageUrl,
      ];
}

/// Pronunciation challenge for pronunciation games
class PronunciationChallenge extends Equatable {
  final String id;
  final String word;
  final String phonetic;
  final String translation;
  final String audioUrl;
  final double targetAccuracy;

  const PronunciationChallenge({
    required this.id,
    required this.word,
    required this.phonetic,
    required this.translation,
    required this.audioUrl,
    required this.targetAccuracy,
  });

  @override
  List<Object?> get props => [
        id,
        word,
        phonetic,
        translation,
        audioUrl,
        targetAccuracy,
      ];
}

/// Word puzzle for word puzzle games
class WordPuzzle extends Equatable {
  final String id;
  final String word;
  final String clue;
  final List<String> scrambledLetters;
  final String? hint;

  const WordPuzzle({
    required this.id,
    required this.word,
    required this.clue,
    required this.scrambledLetters,
    this.hint,
  });

  @override
  List<Object?> get props => [id, word, clue, scrambledLetters, hint];
}

/// Game progress entity
class GameProgressEntity extends Equatable {
  final String id;
  final String userId;
  final String gameId;
  final int currentScore;
  final int bestScore;
  final int attemptsCount;
  final bool isCompleted;
  final DateTime lastPlayedAt;
  final Map<String, dynamic> progressData;

  const GameProgressEntity({
    required this.id,
    required this.userId,
    required this.gameId,
    required this.currentScore,
    required this.bestScore,
    required this.attemptsCount,
    required this.isCompleted,
    required this.lastPlayedAt,
    required this.progressData,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        gameId,
        currentScore,
        bestScore,
        attemptsCount,
        isCompleted,
        lastPlayedAt,
        progressData,
      ];

  GameProgressEntity copyWith({
    String? id,
    String? userId,
    String? gameId,
    int? currentScore,
    int? bestScore,
    int? attemptsCount,
    bool? isCompleted,
    DateTime? lastPlayedAt,
    Map<String, dynamic>? progressData,
  }) {
    return GameProgressEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gameId: gameId ?? this.gameId,
      currentScore: currentScore ?? this.currentScore,
      bestScore: bestScore ?? this.bestScore,
      attemptsCount: attemptsCount ?? this.attemptsCount,
      isCompleted: isCompleted ?? this.isCompleted,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      progressData: progressData ?? this.progressData,
    );
  }
}
