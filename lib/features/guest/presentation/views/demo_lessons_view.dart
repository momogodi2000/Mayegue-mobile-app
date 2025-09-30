import 'package:flutter/material.dart';
import '../../../../shared/widgets/forms/custom_button.dart';

/// Demo lessons view for guest users with limited free content
class DemoLessonsView extends StatefulWidget {
  const DemoLessonsView({super.key});

  @override
  State<DemoLessonsView> createState() => _DemoLessonsViewState();
}

class _DemoLessonsViewState extends State<DemoLessonsView> {
  int _completedLessons = 0;
  final int _maxGuestLessons = 3;

  final List<Map<String, dynamic>> _demoLessons = [
    {
      'id': 1,
      'title': 'Salutations en Ewondo',
      'description': 'Apprenez à dire bonjour et au revoir',
      'duration': '5 min',
      'difficulty': 'Débutant',
      'language': 'Ewondo',
      'color': Colors.green,
      'icon': Icons.waving_hand,
      'isAvailable': true,
      'content': [
        {
          'type': 'phrase',
          'ewondo': 'Mboté',
          'french': 'Bonjour',
          'audio': 'mbote.mp3'
        },
        {
          'type': 'phrase',
          'ewondo': 'Ndôlon',
          'french': 'Bonsoir',
          'audio': 'ndolon.mp3'
        },
        {
          'type': 'phrase',
          'ewondo': 'Ôyônô',
          'french': 'Au revoir',
          'audio': 'oyono.mp3'
        },
      ],
    },
    {
      'id': 2,
      'title': 'Les nombres en Duala',
      'description': 'Comptez de 1 à 10 en Duala',
      'duration': '7 min',
      'difficulty': 'Débutant',
      'language': 'Duala',
      'color': Colors.blue,
      'icon': Icons.numbers,
      'isAvailable': true,
      'content': [
        {'type': 'number', 'duala': 'Mosi', 'french': 'Un', 'number': 1},
        {'type': 'number', 'duala': 'Bale', 'french': 'Deux', 'number': 2},
        {'type': 'number', 'duala': 'Balalo', 'french': 'Trois', 'number': 3},
      ],
    },
    {
      'id': 3,
      'title': 'La famille en Fulfulde',
      'description': 'Vocabulaire familial de base',
      'duration': '6 min',
      'difficulty': 'Débutant',
      'language': 'Fulfulde',
      'color': Colors.purple,
      'icon': Icons.family_restroom,
      'isAvailable': true,
      'content': [
        {
          'type': 'family',
          'fulfulde': 'Baaba',
          'french': 'Papa',
          'audio': 'baaba.mp3'
        },
        {
          'type': 'family',
          'fulfulde': 'Yaaya',
          'french': 'Maman',
          'audio': 'yaaya.mp3'
        },
        {
          'type': 'family',
          'fulfulde': 'Debbo',
          'french': 'Femme',
          'audio': 'debbo.mp3'
        },
      ],
    },
  ];

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
      body: Column(
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
                                color: Colors.grey, fontSize: 12),
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
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ],
            ),
          ),

          // Lessons list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _demoLessons.length + 1, // +1 for upgrade card
              itemBuilder: (context, index) {
                if (index == _demoLessons.length) {
                  return _buildUpgradeCard();
                }

                final lesson = _demoLessons[index];
                final isCompleted = index < _completedLessons;
                final isAccessible = index <= _completedLessons;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isAccessible ? 4 : 1,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          isAccessible ? lesson['color'] : Colors.grey,
                      child: Icon(
                        isCompleted ? Icons.check : lesson['icon'],
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      lesson['title'],
                      style: TextStyle(
                        color: isAccessible ? Colors.black : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson['description'],
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
                              color: isAccessible ? Colors.orange : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              lesson['duration'],
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isAccessible ? Colors.orange : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.signal_cellular_alt,
                              size: 14,
                              color: isAccessible ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              lesson['difficulty'],
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isAccessible ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: isCompleted
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : isAccessible
                            ? const Icon(Icons.play_circle_outline,
                                color: Colors.green)
                            : const Icon(Icons.lock, color: Colors.grey),
                    enabled: isAccessible,
                    onTap: isAccessible ? () => _startLesson(lesson) : null,
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
              border: Border(top: BorderSide(color: Colors.orange.shade200)),
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
                  onPressed: () => Navigator.of(context).pushNamed('/register'),
                  backgroundColor: Colors.orange,
                ),
              ],
            ),
          ),
        ],
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
            color: Colors.purple.withValues(alpha: 0.3),
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
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Créer un compte',
                  onPressed: () => Navigator.of(context).pushNamed('/register'),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Se connecter',
                  onPressed: () => Navigator.of(context).pushNamed('/login'),
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
              Text('Gratuit',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              SizedBox(width: 16),
              Icon(Icons.check, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text('Sans publicité',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              SizedBox(width: 16),
              Icon(Icons.check, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text('Progression sauvée',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  void _startLesson(Map<String, dynamic> lesson) {
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
                backgroundColor: lesson['color'],
                child: Icon(lesson['icon'], color: Colors.white, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                lesson['title'],
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Langue: ${lesson['language']}',
                style: TextStyle(
                    color: lesson['color'], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              // Lesson content preview
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: lesson['content'].length,
                  itemBuilder: (context, index) {
                    final item = lesson['content'][index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading:
                            const Icon(Icons.volume_up, color: Colors.green),
                        title: Text(
                          item[lesson['language'].toLowerCase()] ??
                              item['ewondo'] ??
                              item['duala'] ??
                              item['fulfulde'] ??
                              'Contenu',
                        ),
                        subtitle: Text(item['french'] ?? 'Traduction'),
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
                        _completeLesson(lesson['id']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lesson['color'],
                      ),
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
      if (_completedLessons < lessonId) {
        _completedLessons = lessonId;
      }
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
                onPressed: () => Navigator.of(context).pushNamed('/register'),
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
              Navigator.of(context).pushNamed('/register');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Créer mon compte'),
          ),
        ],
      ),
    );
  }
}
