import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/forms/custom_button.dart';
import '../viewmodels/guest_dashboard_viewmodel.dart';

/// Demo lessons view for guest users with limited free content
class DemoLessonsView extends StatefulWidget {
  const DemoLessonsView({super.key});

  @override
  State<DemoLessonsView> createState() => _DemoLessonsViewState();
}

class _DemoLessonsViewState extends State<DemoLessonsView> {
  int _completedLessons = 0;
  final int _maxGuestLessons = 3;

  @override
  void initState() {
    super.initState();
    // Load lessons from ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuestDashboardViewModel>().initialize();
    });
  }

  // No static fallback - we'll show a proper empty state instead

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leçons de Démonstration'),
        backgroundColor: Colors.green,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_completedLessons/$_maxGuestLessons',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<GuestDashboardViewModel>(
        builder: (context, viewModel, child) {
          final lessons = viewModel.demoLessons;

          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (lessons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune leçon disponible',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Revenez plus tard pour découvrir de nouvelles leçons',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Créer un compte',
                    onPressed: () => context.go('/register'),
                    backgroundColor: Colors.orange,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Progress indicator
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade50,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Progression en mode invité',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Vous avez complété $_completedLessons sur $_maxGuestLessons leçons gratuites',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _completedLessons / _maxGuestLessons,
                      backgroundColor: Colors.green.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              // Lessons list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lessons.length + 1, // +1 for upgrade card
                  itemBuilder: (context, index) {
                    if (index == lessons.length) {
                      return _buildUpgradeCard();
                    }

                    final lesson = lessons[index];
                    final isCompleted = index < _completedLessons;
                    final isAccessible = index <= _completedLessons;

                    // Extract data from map
                    final title = lesson['title'] as String? ?? 'Leçon';
                    final description =
                        lesson['description'] as String? ?? 'Description';
                    final duration = lesson['duration_minutes'] != null
                        ? '${lesson['duration_minutes']} min'
                        : (lesson['duration'] as String? ?? '5 min');
                    final difficulty =
                        lesson['difficulty_level'] as String? ??
                        (lesson['difficulty'] as String? ?? 'Débutant');
                    final languageName =
                        lesson['language_name'] as String? ??
                        (lesson['language'] as String? ?? 'Langue');
                    final color = lesson['color'] as Color? ?? Colors.green;
                    final icon = lesson['icon'] as IconData? ?? Icons.school;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: isAccessible ? 4 : 1,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isAccessible ? color : Colors.grey,
                          child: Icon(
                            isCompleted ? Icons.check : icon,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          title,
                          style: TextStyle(
                            color: isAccessible ? Colors.black : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              description,
                              style: TextStyle(
                                color: isAccessible
                                    ? Colors.grey
                                    : Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  size: 14,
                                  color: isAccessible
                                      ? Colors.orange
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  duration,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isAccessible
                                        ? Colors.orange
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.signal_cellular_alt,
                                  size: 14,
                                  color: isAccessible
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  difficulty,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isAccessible
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: isCompleted
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : isAccessible
                            ? const Icon(
                                Icons.play_circle_outline,
                                color: Colors.green,
                              )
                            : const Icon(Icons.lock, color: Colors.grey),
                        enabled: isAccessible,
                        onTap: isAccessible
                            ? () => _startLesson(
                                lesson,
                                color,
                                icon,
                                languageName,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),

              // Bottom CTA
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border(
                    top: BorderSide(color: Colors.orange.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Débloquez toutes les leçons',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Plus de 100 leçons disponibles',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    CustomButton(
                      text: 'S\'inscrire',
                      onPressed: () => context.go('/register'),
                      backgroundColor: Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUpgradeCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3 * 255),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Passez au niveau supérieur !',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Accédez à plus de 100 leçons interactives, sauvegardez votre progression et rejoignez notre communauté d\'apprentissage.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Créer un compte',
                  onPressed: () => context.go('/register'),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Se connecter',
                  onPressed: () => context.go('/login'),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.white,
                  isOutlined: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text(
                'Gratuit',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              SizedBox(width: 16),
              Icon(Icons.check, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text(
                'Sans publicité',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              SizedBox(width: 16),
              Icon(Icons.check, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text(
                'Progression sauvée',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startLesson(
    Map<String, dynamic> lesson,
    Color color,
    IconData icon,
    String languageName,
  ) {
    final title = lesson['title'] as String? ?? 'Leçon';
    final lessonId = lesson['id'];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color,
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Langue: $languageName',
                style: TextStyle(color: color, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              // Lesson content preview
              FutureBuilder<List<Map<String, dynamic>>>(
                future: context
                    .read<GuestDashboardViewModel>()
                    .getLessonContent(
                      (lessonId is int)
                          ? lessonId
                          : int.tryParse(lessonId.toString()) ?? 0,
                    ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final lessonContent =
                      snapshot.data ??
                      (lesson['content'] as List<Map<String, dynamic>>?) ??
                      [];

                  if (lessonContent.isEmpty) {
                    return const Text('Aucun contenu disponible');
                  }

                  return Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: lessonContent.length,
                      itemBuilder: (context, index) {
                        final item = lessonContent[index];
                        final word =
                            (item['word'] as String?) ??
                            (item['ewondo'] as String?) ??
                            (item['duala'] as String?) ??
                            (item['fulfulde'] as String?) ??
                            'Mot';
                        final translation =
                            (item['translation'] as String?) ??
                            (item['french'] as String?) ??
                            'Traduction';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.volume_up,
                              color: Colors.green,
                            ),
                            title: Text(word),
                            subtitle: Text(translation),
                            dense: true,
                            onTap: () {
                              // Simulate pronunciation
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('🔊 Prononciation jouée'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Fermer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        final id = (lessonId is int)
                            ? lessonId
                            : int.tryParse(lessonId.toString());
                        if (id != null) {
                          _completeLesson(id);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: color),
                      child: const Text('Terminer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _completeLesson(int lessonId) {
    setState(() {
      _completedLessons = (_completedLessons + 1).clamp(0, _maxGuestLessons);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Leçon terminée !'),
          ],
        ),
        backgroundColor: Colors.green,
        action: _completedLessons >= _maxGuestLessons
            ? SnackBarAction(
                label: 'S\'inscrire',
                textColor: Colors.white,
                onPressed: () => context.go('/register'),
              )
            : null,
      ),
    );

    if (_completedLessons >= _maxGuestLessons) {
      Future.delayed(const Duration(seconds: 2), () {
        _showCompletionDialog();
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Félicitations ! 🎉'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Vous avez terminé toutes les leçons gratuites !',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Créez votre compte pour continuer votre apprentissage avec plus de 100 leçons additionnelles.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/register');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Créer mon compte'),
          ),
        ],
      ),
    );
  }
}
