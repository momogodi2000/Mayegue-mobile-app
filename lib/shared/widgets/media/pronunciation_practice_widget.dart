import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/services/audio_service.dart';
import '../../themes/colors.dart';

/// Widget for pronunciation practice with recording and AI feedback
class PronunciationPracticeWidget extends StatefulWidget {
  final String targetWord;
  final String targetLanguage;
  final String? targetIPA;
  final String? nativeAudioUrl;
  final Function(PronunciationResult)? onPronunciationResult;
  final VoidCallback? onClose;

  const PronunciationPracticeWidget({
    super.key,
    required this.targetWord,
    required this.targetLanguage,
    this.targetIPA,
    this.nativeAudioUrl,
    this.onPronunciationResult,
    this.onClose,
  });

  @override
  State<PronunciationPracticeWidget> createState() =>
      _PronunciationPracticeWidgetState();
}

class _PronunciationPracticeWidgetState
    extends State<PronunciationPracticeWidget> with TickerProviderStateMixin {
  late AudioService _audioService;
  late AnimationController _waveformController;
  late AnimationController _recordingController;
  late Animation<double> _waveformAnimation;
  late Animation<double> _recordingAnimation;

  PronunciationResult? _lastResult;
  bool _isAnalyzing = false;
  bool _showInstructions = true;
  int _attemptCount = 0;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();

    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _recordingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _waveformAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveformController, curve: Curves.easeInOut),
    );
    _recordingAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _recordingController, curve: Curves.elasticOut),
    );

    _audioService.addListener(_onAudioServiceChanged);
  }

  @override
  void dispose() {
    _audioService.removeListener(_onAudioServiceChanged);
    _audioService.dispose();
    _waveformController.dispose();
    _recordingController.dispose();
    super.dispose();
  }

  void _onAudioServiceChanged() {
    setState(() {});

    if (_audioService.isRecording) {
      _waveformController.repeat();
      _recordingController.repeat(reverse: true);
    } else {
      _waveformController.stop();
      _recordingController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1 * 255),
            AppColors.secondary.withValues(alpha: 0.05 * 255),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2 * 255),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          if (_showInstructions) _buildInstructions(),
          if (!_showInstructions) ...[
            _buildTargetWord(),
            const SizedBox(height: 24),
            _buildNativeAudioSection(),
            const SizedBox(height: 32),
            _buildRecordingSection(),
            const SizedBox(height: 24),
            if (_lastResult != null) _buildResultSection(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.record_voice_over,
          color: AppColors.primary,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pratique de Prononciation',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              Text(
                'Langue: ${widget.targetLanguage}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
        if (widget.onClose != null)
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close),
            color: Colors.grey[600],
          ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.help_outline,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Comment utiliser la pratique de prononciation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '1. Écoutez la prononciation native\n'
              '2. Appuyez sur le bouton d\'enregistrement\n'
              '3. Prononcez le mot clairement\n'
              '4. Arrêtez l\'enregistrement\n'
              '5. Recevez des commentaires IA',
              textAlign: TextAlign.left,
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() => _showInstructions = false),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('Commencer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetWord() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              widget.targetWord,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (widget.targetIPA != null) ...[
              const SizedBox(height: 8),
              Text(
                '/${widget.targetIPA}/',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNativeAudioSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.volume_up, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prononciation native',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Text(
                    'Écoutez attentivement la prononciation',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _playNativeAudio,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Écouter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.onSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Votre prononciation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // Waveform visualization
            if (_audioService.isRecording)
              AnimatedBuilder(
                animation: _waveformAnimation,
                builder: (context, child) {
                  return SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: WaveformPainter(_waveformAnimation.value),
                    ),
                  );
                },
              )
            else
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _audioService.hasRecording
                        ? 'Enregistrement terminé (${_formatDuration(_audioService.recordingDuration)})'
                        : 'Aucun enregistrement',
                    style: const TextStyle(color: Color(0xFF757575)),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            // Recording controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Record button
                AnimatedBuilder(
                  animation: _recordingAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _audioService.isRecording
                          ? _recordingAnimation.value
                          : 1.0,
                      child: FloatingActionButton(
                        onPressed: _audioService.isRecording
                            ? _stopRecording
                            : _startRecording,
                        backgroundColor: _audioService.isRecording
                            ? Colors.red
                            : AppColors.primary,
                        child: Icon(
                          _audioService.isRecording ? Icons.stop : Icons.mic,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                // Play recorded audio
                if (_audioService.hasRecording)
                  FloatingActionButton(
                    onPressed: _audioService.isPlaying
                        ? _stopPlayback
                        : _playRecording,
                    backgroundColor: AppColors.secondary,
                    child: Icon(
                      _audioService.isPlaying ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                // Delete recording
                if (_audioService.hasRecording)
                  FloatingActionButton(
                    onPressed: _deleteRecording,
                    backgroundColor: Colors.grey,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
              ],
            ),
            if (_audioService.isRecording) ...[
              const SizedBox(height: 16),
              Text(
                'Enregistrement... ${_formatDuration(_audioService.recordingDuration)}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    final result = _lastResult!;
    final scoreColor = _getScoreColor(result.score);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: scoreColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Résultat de l\'analyse',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.1 * 255),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${(result.score * 100).toInt()}%',
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: result.score,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            ),
            const SizedBox(height: 16),
            if (result.feedback.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb,
                            color: Colors.blue[700], size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Conseils d\'amélioration',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.feedback,
                      style: const TextStyle(color: Color(0xFF1565C0)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (_audioService.hasRecording && !_isAnalyzing)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _analyzeRecording,
              icon: const Icon(Icons.psychology),
              label: const Text('Analyser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
            ),
          ),
        if (_isAnalyzing)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: null,
              icon: const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              label: const Text('Analyse...'),
            ),
          ),
        if (_lastResult != null) ...[
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _tryAgain,
            child: const Text('Réessayer'),
          ),
        ],
      ],
    );
  }

  Future<void> _playNativeAudio() async {
    if (widget.nativeAudioUrl != null) {
      // In a real implementation, you would play the native audio URL
      // For now, we'll just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lecture audio native...')),
      );
    }
  }

  Future<void> _startRecording() async {
    final success = await _audioService.startRecording();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de démarrer l\'enregistrement'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopRecording() async {
    await _audioService.stopRecording();
  }

  Future<void> _playRecording() async {
    await _audioService.startPlayback();
  }

  Future<void> _stopPlayback() async {
    await _audioService.stopPlayback();
  }

  Future<void> _deleteRecording() async {
    await _audioService.deleteCurrentRecording();
    setState(() {
      _lastResult = null;
    });
  }

  Future<void> _analyzeRecording() async {
    if (!_audioService.hasRecording) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Simulate AI analysis - in a real implementation, you would:
      // 1. Send the audio to a speech recognition service
      // 2. Compare with the target pronunciation
      // 3. Generate feedback using AI

      await Future.delayed(
          const Duration(seconds: 2)); // Simulate processing time

      final result = PronunciationResult(
        score: 0.75 + (0.2 * (1 - _attemptCount * 0.1)).clamp(0.0, 1.0),
        feedback: _generateFeedback(),
        targetWord: widget.targetWord,
        attemptNumber: _attemptCount + 1,
        timestamp: DateTime.now(),
      );

      setState(() {
        _lastResult = result;
        _attemptCount++;
      });

      widget.onPronunciationResult?.call(result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'analyse: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  String _generateFeedback() {
    final feedbacks = [
      'Excellent ! Votre prononciation est très proche de la prononciation native.',
      'Bonne prononciation ! Essayez d\'accentuer davantage la première syllabe.',
      'Pas mal ! Attention à la longueur des voyelles.',
      'Continuez à pratiquer. Concentrez-vous sur la tonalité.',
      'Bon effort ! Essayez de parler plus lentement et distinctement.',
    ];

    final score = _lastResult?.score ?? 0.7;
    if (score > 0.8) return feedbacks[0];
    if (score > 0.6) return feedbacks[1];
    if (score > 0.4) return feedbacks[2];
    if (score > 0.2) return feedbacks[3];
    return feedbacks[4];
  }

  void _tryAgain() {
    setState(() {
      _lastResult = null;
    });
    _deleteRecording();
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

/// Custom painter for waveform visualization
class WaveformPainter extends CustomPainter {
  final double animationValue;

  WaveformPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final waveHeight = size.height * 0.3;
    const frequency = 4;

    for (double x = 0; x <= size.width; x++) {
      final normalizedX = x / size.width;
      final wave = waveHeight *
          sin((normalizedX * frequency * 2 * 3.14159) +
              (animationValue * 2 * 3.14159));
      final y = size.height / 2 + wave;

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Result of pronunciation analysis
class PronunciationResult {
  final double score; // 0.0 to 1.0
  final String feedback;
  final String targetWord;
  final int attemptNumber;
  final DateTime timestamp;

  const PronunciationResult({
    required this.score,
    required this.feedback,
    required this.targetWord,
    required this.attemptNumber,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'feedback': feedback,
      'targetWord': targetWord,
      'attemptNumber': attemptNumber,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
