import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Terms and Conditions page that users must accept before proceeding
class TermsAndConditionsView extends StatefulWidget {
  const TermsAndConditionsView({super.key});

  @override
  State<TermsAndConditionsView> createState() => _TermsAndConditionsViewState();
}

class _TermsAndConditionsViewState extends State<TermsAndConditionsView> {
  bool _acceptedTerms = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onAcceptTerms() async {
    if (_acceptedTerms) {
      // Store acceptance in SharedPreferences
      await _storeTermsAcceptance();
      // Navigate to landing page for proper onboarding flow
      if (mounted) {
        context.go('/landing');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez accepter les termes et conditions pour continuer',
          ),
        ),
      );
    }
  }

  Future<void> _storeTermsAcceptance() async {
    // Store terms acceptance in SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('terms_accepted', true);
      await prefs.setString(
        'terms_accepted_date',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('Error storing terms acceptance: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termes et Conditions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Termes et Conditions d\'Utilisation',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mayègue - Application d\'Apprentissage des Langues Camerounaises',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Terms content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          '1. Acceptation des Termes',
                          'En utilisant l\'application Mayègue, vous acceptez d\'être lié par ces termes et conditions d\'utilisation.',
                        ),
                        _buildSection(
                          '2. Description du Service',
                          'Mayègue est une application mobile dédiée à l\'apprentissage des langues traditionnelles camerounaises, incluant l\'Ewondo, le Bafang et d\'autres langues locales.',
                        ),
                        _buildSection(
                          '3. Utilisation Acceptable',
                          'Vous vous engagez à utiliser l\'application de manière responsable et respectueuse envers la communauté et le contenu culturel.',
                        ),
                        _buildSection(
                          '4. Propriété Intellectuelle',
                          'Tout le contenu de l\'application, incluant les textes, images, audio et vidéos, est protégé par les droits d\'auteur et appartient à Mayègue ou à ses partenaires.',
                        ),
                        _buildSection(
                          '5. Protection des Données',
                          'Nous nous engageons à protéger votre vie privée conformément à notre politique de confidentialité. Vos données personnelles sont traitées de manière sécurisée.',
                        ),
                        _buildSection(
                          '6. Limitation de Responsabilité',
                          'Mayègue ne peut être tenu responsable des dommages indirects résultant de l\'utilisation de l\'application.',
                        ),
                        _buildSection(
                          '7. Modifications',
                          'Nous nous réservons le droit de modifier ces termes à tout moment. Les modifications prendront effet dès leur publication dans l\'application.',
                        ),
                        _buildSection(
                          '8. Contact',
                          'Pour toute question concernant ces termes, contactez-nous à support@mayegue.com',
                        ),

                        const SizedBox(height: 20),

                        // Cultural note
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            border: Border.all(color: Colors.orange.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'En acceptant, vous contribuez à la préservation du patrimoine culturel camerounais.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Acceptance checkbox
              Row(
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptedTerms = value ?? false;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                  const Expanded(
                    child: Text(
                      'J\'ai lu et j\'accepte les termes et conditions',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Exit app or show dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Quitter Mayegue'),
                            content: const Text(
                              'Êtes-vous sûr de vouloir quitter l\'application ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // Close app - this is platform specific
                                },
                                child: const Text('Quitter'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('Refuser'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _acceptedTerms ? _onAcceptTerms : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _acceptedTerms
                            ? Colors.green
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Accepter et Continuer'),
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

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
