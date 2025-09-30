import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../../ai/domain/entities/ai_entities.dart';
import '../../../ai/domain/usecases/ai_usecases.dart';

/// ViewModel for AI Chat functionality
class AiChatViewModel extends ChangeNotifier {
  final SendMessageToAI sendMessageToAI;
  final StartConversation startConversation;
  final GetUserConversations getUserConversations;

  AiChatViewModel({
    required this.sendMessageToAI,
    required this.startConversation,
    required this.getUserConversations,
  });

  // State
  List<ConversationEntity> _conversations = const <ConversationEntity>[];
  ConversationEntity? _currentConversation;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ConversationEntity> get conversations => _conversations;
  ConversationEntity? get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load user conversations
  Future<void> loadConversations(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result =
        await getUserConversations(GetUserConversationsParams(userId: userId));

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
      },
      (conversations) {
        _conversations = conversations;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Start a new conversation
  Future<void> createNewConversation(String userId, String title) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await startConversation(
      StartConversationParams(
        userId: userId,
        title: title,
      ),
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
      },
      (conversation) {
        _currentConversation = conversation;
        _conversations.insert(0, conversation);
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Send message to AI
  Future<void> sendMessage(
      String conversationId, String message, String userId) async {
    if (_currentConversation == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await sendMessageToAI(
      SendMessageParams(
        conversationId: conversationId,
        message: message,
        userId: userId,
      ),
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
      },
      (response) {
        // Update current conversation with new messages
        // Add user message and AI response (this would be handled by the repository)
        loadConversations(userId); // Refresh conversations
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Set current conversation
  void setCurrentConversation(ConversationEntity conversation) {
    _currentConversation = conversation;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server error: ${failure.message}';
    } else if (failure is NotFoundFailure) {
      return 'Not found: ${failure.message}';
    } else {
      return 'An unexpected error occurred';
    }
  }
}

/// ViewModel for Translation functionality
class TranslationViewModel extends ChangeNotifier {
  final TranslateText translateText;
  final GetTranslationHistory getTranslationHistory;

  TranslationViewModel({
    required this.translateText,
    required this.getTranslationHistory,
  });

  // State
  TranslationEntity? _currentTranslation;
  List<TranslationEntity> _translationHistory = const <TranslationEntity>[];
  bool _isLoading = false;
  String? _error;

  // Getters
  TranslationEntity? get currentTranslation => _currentTranslation;
  List<TranslationEntity> get translationHistory => _translationHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Translate text
  Future<void> translate({
    required String userId,
    required String sourceText,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await translateText(
      TranslateTextParams(
        userId: userId,
        sourceText: sourceText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      ),
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
      },
      (translation) {
        _currentTranslation = translation;
        _translationHistory.insert(0, translation);
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Load translation history
  Future<void> loadTranslationHistory(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getTranslationHistory(
        GetTranslationHistoryParams(userId: userId));

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
      },
      (history) {
        _translationHistory = history;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Translation failed: ${failure.message}';
    } else {
      return 'An unexpected error occurred';
    }
  }
}

/// ViewModel for Pronunciation Assessment functionality
class PronunciationViewModel extends ChangeNotifier {
  final AssessPronunciation assessPronunciation;
  final GetPronunciationHistory getPronunciationHistory;

  PronunciationViewModel({
    required this.assessPronunciation,
    required this.getPronunciationHistory,
  });

  // State
  PronunciationAssessmentEntity? _currentAssessment;
  List<PronunciationAssessmentEntity> _assessmentHistory =
      const <PronunciationAssessmentEntity>[];
  bool _isLoading = false;
  String? _error;

  // Getters
  PronunciationAssessmentEntity? get currentAssessment => _currentAssessment;
  List<PronunciationAssessmentEntity> get assessmentHistory =>
      _assessmentHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PronunciationAssessmentEntity? get feedback => _currentAssessment;

  /// Assess pronunciation
  Future<void> assess({
    required String userId,
    required String word,
    required String language,
    required String audioUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await assessPronunciation(
      AssessPronunciationParams(
        userId: userId,
        word: word,
        language: language,
        audioUrl: audioUrl,
      ),
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
      },
      (assessment) {
        _currentAssessment = assessment;
        _assessmentHistory.insert(0, assessment);
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Load pronunciation history
  Future<void> loadPronunciationHistory(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getPronunciationHistory(
        GetPronunciationHistoryParams(userId: userId));

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
      },
      (history) {
        _assessmentHistory = history;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Assessment failed: ${failure.message}';
    } else {
      return 'An unexpected error occurred';
    }
  }
}

/// ViewModel for Content Generation functionality
class ContentGenerationViewModel extends ChangeNotifier {
  final GenerateContent generateContent;

  ContentGenerationViewModel({
    required this.generateContent,
  });

  // State
  ContentGenerationEntity? _currentContent;
  bool _isLoading = false;
  String? _error;

  // Getters
  ContentGenerationEntity? get currentContent => _currentContent;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ContentGenerationEntity? get generatedContent => _currentContent;

  /// Generate content
  Future<void> generate({
    required String userId,
    required String type,
    required String topic,
    required String language,
    required String difficulty,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await generateContent(
      GenerateContentParams(
        userId: userId,
        type: type,
        topic: topic,
        language: language,
        difficulty: difficulty,
      ),
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
      },
      (content) {
        _currentContent = content;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Content generation failed: ${failure.message}';
    } else {
      return 'An unexpected error occurred';
    }
  }
}

/// ViewModel for AI Learning Recommendations
class AiRecommendationsViewModel extends ChangeNotifier {
  final GetPersonalizedRecommendations getPersonalizedRecommendations;

  AiRecommendationsViewModel({
    required this.getPersonalizedRecommendations,
  });

  // State
  List<AiLearningRecommendationEntity> _recommendations =
      const <AiLearningRecommendationEntity>[];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<AiLearningRecommendationEntity> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load personalized recommendations
  Future<void> loadRecommendations(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getPersonalizedRecommendations(
        GetPersonalizedRecommendationsParams(userId: userId));

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
      },
      (recommendations) {
        _recommendations = recommendations;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Failed to load recommendations: ${failure.message}';
    } else {
      return 'An unexpected error occurred';
    }
  }
}
