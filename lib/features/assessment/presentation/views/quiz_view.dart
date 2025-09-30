import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../../gamification/presentation/viewmodels/gamification_viewmodel.dart';
import '../../../gamification/domain/entities/gamification.dart';

class QuizView extends StatefulWidget {
  const QuizView({super.key});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  int? _selectedAnswerIndex;

  // Sample quiz data - in a real app, this would come from a repository
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What does "Mbolo" mean in Ewondo?',
      'options': ['Hello', 'Goodbye', 'Thank you', 'Please'],
      'correctAnswer': 0,
    },
    {
      'question': 'How do you say "Water" in Duala?',
      'options': ['Mbo', 'Ngɔ', 'Mboa', 'Nnam'],
      'correctAnswer': 1,
    },
    {
      'question': 'What is the meaning of "Asu" in Bafang?',
      'options': ['Fire', 'Earth', 'Air', 'Water'],
      'correctAnswer': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary Quiz'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/games'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Score: $_score/${_questions.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _isAnswered ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 20),

            // Question counter
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Question
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  currentQuestion['question'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Answer options
            ...List.generate(
              currentQuestion['options'].length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton(
                  onPressed: _isAnswered ? null : () => _selectAnswer(index),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16.0),
                    backgroundColor: _getButtonColor(index),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    currentQuestion['options'][index],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Next/Finish button
            if (_isAnswered)
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentQuestionIndex < _questions.length - 1
                      ? 'Next Question'
                      : 'Finish Quiz',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;

      if (index == _questions[_currentQuestionIndex]['correctAnswer']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedAnswerIndex = null;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    // Award points for completing the quiz
    final authViewModel = context.read<AuthViewModel>();
    final gamificationViewModel = context.read<GamificationViewModel>();

    final userId = authViewModel.currentUser?.id;
    if (userId != null) {
      gamificationViewModel.addPoints(userId, PointActivity.quizCompleted);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your Score: $_score/${_questions.length}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '+${PointValues.quizCompleted} points earned!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getScoreMessage(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/games');
            },
            child: const Text('Back to Games'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Restart quiz
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
                _isAnswered = false;
                _selectedAnswerIndex = null;
              });
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Color _getButtonColor(int index) {
    if (!_isAnswered) return Colors.blue;

    if (index == _questions[_currentQuestionIndex]['correctAnswer']) {
      return Colors.green;
    } else if (index == _selectedAnswerIndex) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  String _getScoreMessage() {
    final percentage = (_score / _questions.length) * 100;
    if (percentage >= 80) {
      return 'Excellent! You have a great knowledge of Cameroonian languages!';
    } else if (percentage >= 60) {
      return 'Good job! Keep practicing to improve your skills.';
    } else {
      return 'Keep learning! Practice makes perfect.';
    }
  }
}
