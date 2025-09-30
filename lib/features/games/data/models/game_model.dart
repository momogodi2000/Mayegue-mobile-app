import '../../domain/entities/game_entity.dart';

/// Data model for Game
class GameModel extends GameEntity {
  const GameModel({
    required super.id,
    required super.title,
    required super.description,
    required super.language,
    required super.type,
    required super.difficulty,
    required super.estimatedDuration,
    required super.thumbnailUrl,
    required super.maxScore,
    required super.gameData,
    required super.isPremium,
    required super.createdAt,
    super.updatedAt,
  });

  /// Factory constructor from JSON
  factory GameModel.fromJson(Map<String, dynamic> json) {
    final gameType = GameType.values[json['type'] as int];

    switch (gameType) {
      case GameType.memory:
        return MemoryGameModel.fromJson(json);
      case GameType.wordMatching:
        return WordMatchingGameModel.fromJson(json);
      case GameType.quiz:
        return QuizGameModel.fromJson(json);
      case GameType.pronunciation:
        return PronunciationGameModel.fromJson(json);
      case GameType.wordPuzzle:
        return WordPuzzleGameModel.fromJson(json);
      default:
        return GameModel._fromJson(json);
    }
  }

  factory GameModel._fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      language: json['language'] as String,
      type: GameType.values[json['type'] as int],
      difficulty: GameDifficulty.values[json['difficulty'] as int],
      estimatedDuration: json['estimatedDuration'] as int,
      thumbnailUrl: json['thumbnailUrl'] as String,
      maxScore: json['maxScore'] as int,
      gameData: Map<String, dynamic>.from(json['gameData'] ?? {}),
      isPremium: json['isPremium'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'language': language,
      'type': type.index,
      'difficulty': difficulty.index,
      'estimatedDuration': estimatedDuration,
      'thumbnailUrl': thumbnailUrl,
      'maxScore': maxScore,
      'gameData': gameData,
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Factory constructor from Entity
  factory GameModel.fromEntity(GameEntity entity) {
    switch (entity.type) {
      case GameType.memory:
        return MemoryGameModel.fromEntity(entity as MemoryGameEntity);
      case GameType.wordMatching:
        return WordMatchingGameModel.fromEntity(
            entity as WordMatchingGameEntity);
      case GameType.quiz:
        return QuizGameModel.fromEntity(entity as QuizGameEntity);
      case GameType.pronunciation:
        return PronunciationGameModel.fromEntity(
            entity as PronunciationGameEntity);
      case GameType.wordPuzzle:
        return WordPuzzleGameModel.fromEntity(entity as WordPuzzleGameEntity);
      default:
        return GameModel(
          id: entity.id,
          title: entity.title,
          description: entity.description,
          language: entity.language,
          type: entity.type,
          difficulty: entity.difficulty,
          estimatedDuration: entity.estimatedDuration,
          thumbnailUrl: entity.thumbnailUrl,
          maxScore: entity.maxScore,
          gameData: entity.gameData,
          isPremium: entity.isPremium,
          createdAt: entity.createdAt,
          updatedAt: entity.updatedAt,
        );
    }
  }
}

/// Memory game model
class MemoryGameModel extends GameModel implements MemoryGameEntity {
  @override
  final List<MemoryCard> cards;

  @override
  final int gridSize;

  const MemoryGameModel({
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

  factory MemoryGameModel.fromJson(Map<String, dynamic> json) {
    return MemoryGameModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      language: json['language'] as String,
      difficulty: GameDifficulty.values[json['difficulty'] as int],
      estimatedDuration: json['estimatedDuration'] as int,
      thumbnailUrl: json['thumbnailUrl'] as String,
      maxScore: json['maxScore'] as int,
      gameData: Map<String, dynamic>.from(json['gameData'] ?? {}),
      isPremium: json['isPremium'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      cards: (json['cards'] as List<dynamic>?)
              ?.map((e) => MemoryCardModel.fromJson(e as Map<String, dynamic>))
              .cast<MemoryCard>()
              .toList() ??
          [],
      gridSize: json['gridSize'] as int,
    );
  }

  factory MemoryGameModel.fromEntity(MemoryGameEntity entity) {
    return MemoryGameModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      language: entity.language,
      difficulty: entity.difficulty,
      estimatedDuration: entity.estimatedDuration,
      thumbnailUrl: entity.thumbnailUrl,
      maxScore: entity.maxScore,
      gameData: entity.gameData,
      isPremium: entity.isPremium,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      cards: entity.cards,
      gridSize: entity.gridSize,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'cards':
          cards.map((c) => MemoryCardModel.fromEntity(c).toJson()).toList(),
      'gridSize': gridSize,
    });
    return json;
  }
}

/// Word matching game model
class WordMatchingGameModel extends GameModel
    implements WordMatchingGameEntity {
  @override
  final List<WordPair> wordPairs;

  @override
  final int timeLimit;

  const WordMatchingGameModel({
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

  factory WordMatchingGameModel.fromJson(Map<String, dynamic> json) {
    return WordMatchingGameModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      language: json['language'] as String,
      difficulty: GameDifficulty.values[json['difficulty'] as int],
      estimatedDuration: json['estimatedDuration'] as int,
      thumbnailUrl: json['thumbnailUrl'] as String,
      maxScore: json['maxScore'] as int,
      gameData: Map<String, dynamic>.from(json['gameData'] ?? {}),
      isPremium: json['isPremium'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      wordPairs: (json['wordPairs'] as List<dynamic>?)
              ?.map((e) => WordPairModel.fromJson(e as Map<String, dynamic>))
              .cast<WordPair>()
              .toList() ??
          [],
      timeLimit: json['timeLimit'] as int,
    );
  }

  factory WordMatchingGameModel.fromEntity(WordMatchingGameEntity entity) {
    return WordMatchingGameModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      language: entity.language,
      difficulty: entity.difficulty,
      estimatedDuration: entity.estimatedDuration,
      thumbnailUrl: entity.thumbnailUrl,
      maxScore: entity.maxScore,
      gameData: entity.gameData,
      isPremium: entity.isPremium,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      wordPairs: entity.wordPairs,
      timeLimit: entity.timeLimit,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'wordPairs':
          wordPairs.map((wp) => WordPairModel.fromEntity(wp).toJson()).toList(),
      'timeLimit': timeLimit,
    });
    return json;
  }
}

/// Quiz game model
class QuizGameModel extends GameModel implements QuizGameEntity {
  @override
  final List<QuizQuestion> questions;

  @override
  final int timePerQuestion;

  const QuizGameModel({
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

  factory QuizGameModel.fromJson(Map<String, dynamic> json) {
    return QuizGameModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      language: json['language'] as String,
      difficulty: GameDifficulty.values[json['difficulty'] as int],
      estimatedDuration: json['estimatedDuration'] as int,
      thumbnailUrl: json['thumbnailUrl'] as String,
      maxScore: json['maxScore'] as int,
      gameData: Map<String, dynamic>.from(json['gameData'] ?? {}),
      isPremium: json['isPremium'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      questions: (json['questions'] as List<dynamic>?)
              ?.map(
                  (e) => QuizQuestionModel.fromJson(e as Map<String, dynamic>))
              .cast<QuizQuestion>()
              .toList() ??
          [],
      timePerQuestion: json['timePerQuestion'] as int,
    );
  }

  factory QuizGameModel.fromEntity(QuizGameEntity entity) {
    return QuizGameModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      language: entity.language,
      difficulty: entity.difficulty,
      estimatedDuration: entity.estimatedDuration,
      thumbnailUrl: entity.thumbnailUrl,
      maxScore: entity.maxScore,
      gameData: entity.gameData,
      isPremium: entity.isPremium,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      questions: entity.questions,
      timePerQuestion: entity.timePerQuestion,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'questions': questions
          .map((q) => QuizQuestionModel.fromEntity(q).toJson())
          .toList(),
      'timePerQuestion': timePerQuestion,
    });
    return json;
  }
}

/// Pronunciation game model
class PronunciationGameModel extends GameModel
    implements PronunciationGameEntity {
  @override
  final List<PronunciationChallenge> challenges;

  @override
  final double accuracyThreshold;

  const PronunciationGameModel({
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

  factory PronunciationGameModel.fromJson(Map<String, dynamic> json) {
    return PronunciationGameModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      language: json['language'] as String,
      difficulty: GameDifficulty.values[json['difficulty'] as int],
      estimatedDuration: json['estimatedDuration'] as int,
      thumbnailUrl: json['thumbnailUrl'] as String,
      maxScore: json['maxScore'] as int,
      gameData: Map<String, dynamic>.from(json['gameData'] ?? {}),
      isPremium: json['isPremium'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      challenges: (json['challenges'] as List<dynamic>?)
              ?.map((e) => PronunciationChallengeModel.fromJson(
                  e as Map<String, dynamic>))
              .cast<PronunciationChallenge>()
              .toList() ??
          [],
      accuracyThreshold: (json['accuracyThreshold'] as num).toDouble(),
    );
  }

  factory PronunciationGameModel.fromEntity(PronunciationGameEntity entity) {
    return PronunciationGameModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      language: entity.language,
      difficulty: entity.difficulty,
      estimatedDuration: entity.estimatedDuration,
      thumbnailUrl: entity.thumbnailUrl,
      maxScore: entity.maxScore,
      gameData: entity.gameData,
      isPremium: entity.isPremium,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      challenges: entity.challenges,
      accuracyThreshold: entity.accuracyThreshold,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'challenges': challenges
          .map((c) => PronunciationChallengeModel.fromEntity(c).toJson())
          .toList(),
      'accuracyThreshold': accuracyThreshold,
    });
    return json;
  }
}

/// Word puzzle game model
class WordPuzzleGameModel extends GameModel implements WordPuzzleGameEntity {
  @override
  final List<WordPuzzle> puzzles;

  @override
  final int hintsAllowed;

  const WordPuzzleGameModel({
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

  factory WordPuzzleGameModel.fromJson(Map<String, dynamic> json) {
    return WordPuzzleGameModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      language: json['language'] as String,
      difficulty: GameDifficulty.values[json['difficulty'] as int],
      estimatedDuration: json['estimatedDuration'] as int,
      thumbnailUrl: json['thumbnailUrl'] as String,
      maxScore: json['maxScore'] as int,
      gameData: Map<String, dynamic>.from(json['gameData'] ?? {}),
      isPremium: json['isPremium'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      puzzles: (json['puzzles'] as List<dynamic>?)
              ?.map((e) => WordPuzzleModel.fromJson(e as Map<String, dynamic>))
              .cast<WordPuzzle>()
              .toList() ??
          [],
      hintsAllowed: json['hintsAllowed'] as int,
    );
  }

  factory WordPuzzleGameModel.fromEntity(WordPuzzleGameEntity entity) {
    return WordPuzzleGameModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      language: entity.language,
      difficulty: entity.difficulty,
      estimatedDuration: entity.estimatedDuration,
      thumbnailUrl: entity.thumbnailUrl,
      maxScore: entity.maxScore,
      gameData: entity.gameData,
      isPremium: entity.isPremium,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      puzzles: entity.puzzles,
      hintsAllowed: entity.hintsAllowed,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'puzzles':
          puzzles.map((p) => WordPuzzleModel.fromEntity(p).toJson()).toList(),
      'hintsAllowed': hintsAllowed,
    });
    return json;
  }
}

// Supporting models

class MemoryCardModel extends MemoryCard {
  const MemoryCardModel({
    required super.id,
    required super.word,
    required super.translation,
    super.audioUrl,
    super.imageUrl,
  });

  factory MemoryCardModel.fromJson(Map<String, dynamic> json) {
    return MemoryCardModel(
      id: json['id'] as String,
      word: json['word'] as String,
      translation: json['translation'] as String,
      audioUrl: json['audioUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
    };
  }

  factory MemoryCardModel.fromEntity(MemoryCard entity) {
    return MemoryCardModel(
      id: entity.id,
      word: entity.word,
      translation: entity.translation,
      audioUrl: entity.audioUrl,
      imageUrl: entity.imageUrl,
    );
  }
}

class WordPairModel extends WordPair {
  const WordPairModel({
    required super.id,
    required super.sourceWord,
    required super.targetWord,
    super.hint,
    super.audioUrl,
  });

  factory WordPairModel.fromJson(Map<String, dynamic> json) {
    return WordPairModel(
      id: json['id'] as String,
      sourceWord: json['sourceWord'] as String,
      targetWord: json['targetWord'] as String,
      hint: json['hint'] as String?,
      audioUrl: json['audioUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceWord': sourceWord,
      'targetWord': targetWord,
      'hint': hint,
      'audioUrl': audioUrl,
    };
  }

  factory WordPairModel.fromEntity(WordPair entity) {
    return WordPairModel(
      id: entity.id,
      sourceWord: entity.sourceWord,
      targetWord: entity.targetWord,
      hint: entity.hint,
      audioUrl: entity.audioUrl,
    );
  }
}

class QuizQuestionModel extends QuizQuestion {
  const QuizQuestionModel({
    required super.id,
    required super.question,
    required super.options,
    required super.correctAnswer,
    required super.explanation,
    super.audioUrl,
    super.imageUrl,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] as String,
      explanation: json['explanation'] as String,
      audioUrl: json['audioUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
    };
  }

  factory QuizQuestionModel.fromEntity(QuizQuestion entity) {
    return QuizQuestionModel(
      id: entity.id,
      question: entity.question,
      options: entity.options,
      correctAnswer: entity.correctAnswer,
      explanation: entity.explanation,
      audioUrl: entity.audioUrl,
      imageUrl: entity.imageUrl,
    );
  }
}

class PronunciationChallengeModel extends PronunciationChallenge {
  const PronunciationChallengeModel({
    required super.id,
    required super.word,
    required super.phonetic,
    required super.translation,
    required super.audioUrl,
    required super.targetAccuracy,
  });

  factory PronunciationChallengeModel.fromJson(Map<String, dynamic> json) {
    return PronunciationChallengeModel(
      id: json['id'] as String,
      word: json['word'] as String,
      phonetic: json['phonetic'] as String,
      translation: json['translation'] as String,
      audioUrl: json['audioUrl'] as String,
      targetAccuracy: (json['targetAccuracy'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'phonetic': phonetic,
      'translation': translation,
      'audioUrl': audioUrl,
      'targetAccuracy': targetAccuracy,
    };
  }

  factory PronunciationChallengeModel.fromEntity(
      PronunciationChallenge entity) {
    return PronunciationChallengeModel(
      id: entity.id,
      word: entity.word,
      phonetic: entity.phonetic,
      translation: entity.translation,
      audioUrl: entity.audioUrl,
      targetAccuracy: entity.targetAccuracy,
    );
  }
}

class WordPuzzleModel extends WordPuzzle {
  const WordPuzzleModel({
    required super.id,
    required super.word,
    required super.clue,
    required super.scrambledLetters,
    super.hint,
  });

  factory WordPuzzleModel.fromJson(Map<String, dynamic> json) {
    return WordPuzzleModel(
      id: json['id'] as String,
      word: json['word'] as String,
      clue: json['clue'] as String,
      scrambledLetters: List<String>.from(json['scrambledLetters'] ?? []),
      hint: json['hint'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'clue': clue,
      'scrambledLetters': scrambledLetters,
      'hint': hint,
    };
  }

  factory WordPuzzleModel.fromEntity(WordPuzzle entity) {
    return WordPuzzleModel(
      id: entity.id,
      word: entity.word,
      clue: entity.clue,
      scrambledLetters: entity.scrambledLetters,
      hint: entity.hint,
    );
  }
}

/// Game progress model
class GameProgressModel extends GameProgressEntity {
  const GameProgressModel({
    required super.id,
    required super.userId,
    required super.gameId,
    required super.currentScore,
    required super.bestScore,
    required super.attemptsCount,
    required super.isCompleted,
    required super.lastPlayedAt,
    required super.progressData,
  });

  factory GameProgressModel.fromJson(Map<String, dynamic> json) {
    return GameProgressModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      gameId: json['gameId'] as String,
      currentScore: json['currentScore'] as int,
      bestScore: json['bestScore'] as int,
      attemptsCount: json['attemptsCount'] as int,
      isCompleted: json['isCompleted'] as bool,
      lastPlayedAt: DateTime.parse(json['lastPlayedAt'] as String),
      progressData: Map<String, dynamic>.from(json['progressData'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'gameId': gameId,
      'currentScore': currentScore,
      'bestScore': bestScore,
      'attemptsCount': attemptsCount,
      'isCompleted': isCompleted,
      'lastPlayedAt': lastPlayedAt.toIso8601String(),
      'progressData': progressData,
    };
  }

  factory GameProgressModel.fromEntity(GameProgressEntity entity) {
    return GameProgressModel(
      id: entity.id,
      userId: entity.userId,
      gameId: entity.gameId,
      currentScore: entity.currentScore,
      bestScore: entity.bestScore,
      attemptsCount: entity.attemptsCount,
      isCompleted: entity.isCompleted,
      lastPlayedAt: entity.lastPlayedAt,
      progressData: entity.progressData,
    );
  }
}
