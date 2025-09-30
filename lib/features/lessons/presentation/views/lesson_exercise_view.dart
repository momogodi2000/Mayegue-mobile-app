import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/themes/colors.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_content.dart';
import '../viewmodels/lessons_viewmodel.dart';

/// Interactive exercise view for lesson content
class LessonExerciseView extends StatefulWidget {
  final Lesson lesson;

  const LessonExerciseView({
    super.key,
    required this.lesson,
  });

  @override
  State<LessonExerciseView> createState() => _LessonExerciseViewState();
}

class _LessonExerciseViewState extends State<LessonExerciseView>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  int _currentIndex = 0;
  final Map<int, String?> _userAnswers = {};
  final Map<int, bool> _answerResults = {};
  int _correctAnswers = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  List<LessonContent> get _exercises {
    return widget.lesson.contents
        .where((content) => content.type == ContentType.interactive)
        .toList();
  }

  double get _progress {
    if (_exercises.isEmpty) return 0;
    return (_currentIndex + 1) / _exercises.length;
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _exercises;

    if (exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.lesson.title),
          backgroundColor: AppColors.primary,
        ),
        body: const Center(
          child: Text(
            'Aucun exercice disponible pour cette leçon',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: AppColors.primary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progress * _progressAnimation.value,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              );
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1}/${exercises.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _progressController.forward();
              },
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                return _buildExerciseCard(exercises[index], index);
              },
            ),
          ),
          _buildNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(LessonContent exercise, int index) {
    final options = exercise.metadata?['options'] as List<String>? ?? [];
    final correctAnswer = exercise.metadata?['correctAnswer'] as String? ?? '';
    final explanation = exercise.metadata?['explanation'] as String? ?? '';

    final userAnswer = _userAnswers[index];
    final isAnswered = userAnswer != null;
    final isCorrect = _answerResults[index] ?? false;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${index + 1}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Text(
                    exercise.content,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingMedium),

          // Options
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, optionIndex) {
                final option = options[optionIndex];
                final isSelected = userAnswer == option;

                Color? cardColor;
                Color? textColor;
                IconData? icon;

                if (isAnswered) {
                  if (option == correctAnswer) {
                    cardColor = Colors.green.shade100;
                    textColor = Colors.green.shade800;
                    icon = Icons.check_circle;
                  } else if (isSelected && !isCorrect) {
                    cardColor = Colors.red.shade100;
                    textColor = Colors.red.shade800;
                    icon = Icons.cancel;
                  }
                } else if (isSelected) {
                  cardColor = AppColors.primary.withValues(alpha: 0.1);
                  textColor = AppColors.primary;
                }

                return Card(
                  color: cardColor,
                  child: InkWell(
                    onTap: isAnswered
                        ? null
                        : () => _selectAnswer(index, option, correctAnswer),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(AppDimensions.paddingMedium),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: textColor ??
                                    AppColors.onSurface.withValues(alpha: 0.6),
                                width: 2,
                              ),
                              color: isSelected && !isAnswered
                                  ? AppColors.primary
                                  : Colors.transparent,
                            ),
                            child: icon != null
                                ? Icon(icon, size: 16, color: textColor)
                                : isSelected && !isAnswered
                                    ? const Icon(Icons.circle,
                                        size: 12, color: Colors.white)
                                    : null,
                          ),
                          const SizedBox(width: AppDimensions.spacingMedium),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor ?? AppColors.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Explanation (shown after answering)
          if (isAnswered && explanation.isNotEmpty)
            Card(
              color: isCorrect ? Colors.green.shade50 : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isCorrect ? Icons.lightbulb : Icons.info,
                      color: isCorrect ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: AppDimensions.spacingSmall),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCorrect ? 'Bonne réponse !' : 'Explication',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCorrect
                                  ? Colors.green.shade800
                                  : Colors.orange.shade800,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingSmall),
                          Text(
                            explanation,
                            style: TextStyle(
                              color: isCorrect
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    final canGoNext = _currentIndex < _exercises.length - 1;
    final canGoPrevious = _currentIndex > 0;
    final isCompleted = _userAnswers.length == _exercises.length;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: canGoPrevious ? _goToPrevious : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Précédent'),
            ),
          ),

          const SizedBox(width: AppDimensions.spacingMedium),

          // Next/Finish button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: canGoNext
                  ? _goToNext
                  : isCompleted
                      ? _finishExercises
                      : null,
              icon: Icon(canGoNext ? Icons.arrow_forward : Icons.check),
              label: Text(canGoNext ? 'Suivant' : 'Terminer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(int questionIndex, String answer, String correctAnswer) {
    final isCorrect = answer == correctAnswer;

    setState(() {
      _userAnswers[questionIndex] = answer;
      _answerResults[questionIndex] = isCorrect;
      if (isCorrect) {
        _correctAnswers++;
      }
    });

    // Auto-advance after a delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && questionIndex == _currentIndex) {
        _goToNext();
      }
    });
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (_currentIndex < _exercises.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishExercises() {
    final score = (_correctAnswers / _exercises.length * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              score >= 70 ? Icons.celebration : Icons.sentiment_neutral,
              color: score >= 70 ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: AppDimensions.spacingSmall),
            const Text('Exercice terminé'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Votre score: $score%',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text('$_correctAnswers/${_exercises.length} réponses correctes'),
            const SizedBox(height: AppDimensions.spacingMedium),
            LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                score >= 70 ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          if (score < 70)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetExercises();
              },
              child: const Text('Recommencer'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (score >= 70) {
                context.read<LessonsViewModel>().completeCurrentLesson();
              }
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: score >= 70 ? Colors.green : AppColors.primary,
            ),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  void _resetExercises() {
    setState(() {
      _currentIndex = 0;
      _userAnswers.clear();
      _answerResults.clear();
      _correctAnswers = 0;
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _progressController.reset();
  }
}
