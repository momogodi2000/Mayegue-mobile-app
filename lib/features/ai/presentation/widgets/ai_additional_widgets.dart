import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/ai_viewmodels.dart';

/// Pronunciation Assessment Widget
class PronunciationAssessmentWidget extends StatefulWidget {
  const PronunciationAssessmentWidget({super.key});

  @override
  State<PronunciationAssessmentWidget> createState() =>
      _PronunciationAssessmentWidgetState();
}

class _PronunciationAssessmentWidgetState
    extends State<PronunciationAssessmentWidget> {
  final TextEditingController _wordController = TextEditingController();
  String _language = 'ewondo';
  bool _isRecording = false;

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PronunciationViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Language selector
              DropdownButtonFormField<String>(
                value: _language,
                decoration: const InputDecoration(
                  labelText: 'Language',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'ewondo', child: Text('Ewondo')),
                  DropdownMenuItem(value: 'bafang', child: Text('Bafang')),
                ],
                onChanged: (value) => setState(() => _language = value!),
              ),

              const SizedBox(height: 16),

              // Word input
              TextField(
                controller: _wordController,
                decoration: const InputDecoration(
                  labelText: 'Enter word to practice',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // Record button
              ElevatedButton.icon(
                onPressed: _isRecording ? null : _startRecording,
                icon: const Icon(Icons.mic),
                label: const Text('Start Recording'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              if (_isRecording) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _stopRecording,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Recording'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Assessment results
              if (viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (viewModel.feedback != null)
                _buildFeedbackCard(viewModel.feedback!),
            ],
          ),
        );
      },
    );
  }

  void _startRecording() {
    setState(() => _isRecording = true);
    // Start recording logic would go here
  }

  void _stopRecording() {
    setState(() => _isRecording = false);
    // Stop recording and get feedback
    if (_wordController.text.isNotEmpty) {
      // Call viewModel to assess pronunciation
    }
  }

  Widget _buildFeedbackCard(dynamic feedback) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pronunciation Feedback',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Score: ${feedback.score}/100'),
            const SizedBox(height: 8),
            Text('Accuracy: ${feedback.accuracy}%'),
            const SizedBox(height: 8),
            Text('Suggestions: ${feedback.suggestions}'),
          ],
        ),
      ),
    );
  }
}

/// Content Generation Widget
class ContentGenerationWidget extends StatefulWidget {
  const ContentGenerationWidget({super.key});

  @override
  State<ContentGenerationWidget> createState() =>
      _ContentGenerationWidgetState();
}

class _ContentGenerationWidgetState extends State<ContentGenerationWidget> {
  final TextEditingController _topicController = TextEditingController();
  String _language = 'ewondo';
  String _difficulty = 'beginner';
  String _contentType = 'lesson';

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentGenerationViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Topic input
              TextField(
                controller: _topicController,
                decoration: const InputDecoration(
                  labelText: 'Enter topic for content generation',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Language selector
              DropdownButtonFormField<String>(
                value: _language,
                decoration: const InputDecoration(
                  labelText: 'Language',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'ewondo', child: Text('Ewondo')),
                  DropdownMenuItem(value: 'bafang', child: Text('Bafang')),
                ],
                onChanged: (value) => setState(() => _language = value!),
              ),

              const SizedBox(height: 16),

              // Difficulty selector
              DropdownButtonFormField<String>(
                value: _difficulty,
                decoration: const InputDecoration(
                  labelText: 'Difficulty',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                  DropdownMenuItem(
                      value: 'intermediate', child: Text('Intermediate')),
                  DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                ],
                onChanged: (value) => setState(() => _difficulty = value!),
              ),

              const SizedBox(height: 16),

              // Content type selector
              DropdownButtonFormField<String>(
                value: _contentType,
                decoration: const InputDecoration(
                  labelText: 'Content Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'lesson', child: Text('Lesson')),
                  DropdownMenuItem(value: 'exercise', child: Text('Exercise')),
                  DropdownMenuItem(value: 'quiz', child: Text('Quiz')),
                ],
                onChanged: (value) => setState(() => _contentType = value!),
              ),

              const SizedBox(height: 24),

              // Generate button
              ElevatedButton.icon(
                onPressed: viewModel.isLoading ? null : _generateContent,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate Content'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 24),

              // Generated content
              if (viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (viewModel.generatedContent != null)
                _buildContentCard(viewModel.generatedContent!),
            ],
          ),
        );
      },
    );
  }

  void _generateContent() {
    if (_topicController.text.isNotEmpty) {
      // Call viewModel to generate content
    }
  }

  Widget _buildContentCard(dynamic content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generated Content',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(content.title ?? 'Untitled'),
            const SizedBox(height: 8),
            Text(content.content ?? 'No content generated'),
          ],
        ),
      ),
    );
  }
}

/// AI Recommendations Widget
class AIRecommendationsWidget extends StatefulWidget {
  const AIRecommendationsWidget({super.key});

  @override
  State<AIRecommendationsWidget> createState() =>
      _AIRecommendationsWidgetState();
}

class _AIRecommendationsWidgetState extends State<AIRecommendationsWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AiRecommendationsViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'AI Recommendations',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              if (viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (viewModel.recommendations.isNotEmpty)
                ...viewModel.recommendations
                    .map((recommendation) =>
                        _buildRecommendationCard(recommendation))
                    .toList()
              else
                const Center(
                  child: Text('No recommendations available'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecommendationCard(dynamic recommendation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recommendation.title ?? 'Recommendation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(recommendation.description ?? 'No description'),
            const SizedBox(height: 8),
            Text(
              'Type: ${recommendation.type ?? 'Unknown'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
