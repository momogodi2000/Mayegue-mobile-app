import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/routes.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import '../widgets/onboarding_widgets.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Initialize onboarding status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingViewModel>().initialize();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final viewModel = context.read<OnboardingViewModel>();
    if (viewModel.currentStep < OnboardingViewModel.totalSteps - 1) {
      viewModel.nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    final viewModel = context.read<OnboardingViewModel>();
    if (viewModel.currentStep > 0) {
      viewModel.previousStep();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    final viewModel = context.read<OnboardingViewModel>();
    viewModel.completeOnboarding().then((_) {
      if (mounted) {
        context.go(Routes.languages);
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'initialisation: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _skipOnboarding() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Passer l\'introduction'),
        content: const Text(
          'Êtes-vous sûr de vouloir passer l\'introduction ? '
          'Vous pourrez toujours y accéder depuis les paramètres.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _completeOnboarding();
            },
            child: const Text('Passer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<OnboardingViewModel>(
        builder: (context, viewModel, child) {
          return SafeArea(
            child: Column(
              children: [
                // Header with skip button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OnboardingStepIndicator(
                        currentStep: viewModel.currentStep,
                        totalSteps: OnboardingViewModel.totalSteps,
                      ),
                      OnboardingSkipButton(
                        onPressed: _skipOnboarding,
                      ),
                    ],
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      viewModel.setCurrentStep(index);
                    },
                    children: [
                      _buildWelcomePage(),
                      _buildFeaturesPage(),
                      _buildPermissionsPage(),
                      _buildLanguageSelectionPage(),
                    ],
                  ),
                ),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      if (viewModel.currentStep > 0)
                        Expanded(
                          child: OnboardingSecondaryButton(
                            text: 'Précédent',
                            onPressed: _previousPage,
                          ),
                        ),
                      if (viewModel.currentStep > 0) const SizedBox(width: 16),
                      Expanded(
                        child: OnboardingButton(
                          text: viewModel.currentStep ==
                                  OnboardingViewModel.totalSteps - 1
                              ? 'Commencer'
                              : 'Suivant',
                          onPressed: _nextPage,
                          isLoading: viewModel.isLoading,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomePage() {
    return OnboardingPage(
      title: 'Bienvenue dans Mayègue',
      subtitle:
          'Découvrez et apprenez les langues traditionnelles camerounaises',
      child: Column(
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.language,
              size: 100,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Préservez votre héritage culturel',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Mayègue vous permet d\'apprendre les langues traditionnelles '
            'du Cameroun de manière interactive et engageante.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesPage() {
    return const OnboardingPage(
      title: 'Fonctionnalités',
      subtitle: 'Découvrez ce que Mayègue peut vous offrir',
      child: Column(
        children: [
          OnboardingFeatureCard(
            icon: Icons.school,
            title: 'Leçons Interactives',
            description: 'Apprenez avec des leçons structurées et progressives',
          ),
          SizedBox(height: 16),
          OnboardingFeatureCard(
            icon: Icons.volume_up,
            title: 'Prononciation',
            description: 'Améliorez votre prononciation avec l\'IA',
          ),
          SizedBox(height: 16),
          OnboardingFeatureCard(
            icon: Icons.games,
            title: 'Jeux Éducatifs',
            description: 'Apprenez en vous amusant avec des jeux',
          ),
          SizedBox(height: 16),
          OnboardingFeatureCard(
            icon: Icons.people,
            title: 'Communauté',
            description: 'Rejoignez une communauté d\'apprenants',
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsPage() {
    return OnboardingPage(
      title: 'Autorisations',
      subtitle: 'Mayègue a besoin de certaines autorisations pour fonctionner',
      child: Column(
        children: [
          _buildPermissionCard(
            icon: Icons.mic,
            title: 'Microphone',
            description: 'Pour les exercices de prononciation',
            isGranted: true, // This would be checked from permission status
          ),
          const SizedBox(height: 16),
          _buildPermissionCard(
            icon: Icons.camera_alt,
            title: 'Caméra',
            description: 'Pour les exercices visuels',
            isGranted: false,
          ),
          const SizedBox(height: 16),
          _buildPermissionCard(
            icon: Icons.storage,
            title: 'Stockage',
            description: 'Pour sauvegarder vos progrès',
            isGranted: true,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vous pouvez modifier ces autorisations dans les paramètres de votre appareil à tout moment.',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelectionPage() {
    return OnboardingPage(
      title: 'Sélection de Langue',
      subtitle: 'Choisissez la langue que vous souhaitez apprendre',
      child: Column(
        children: [
          Text(
            'Langues disponibles',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 4, // Number of available languages
              itemBuilder: (context, index) {
                final languages = [
                  {'name': 'Ewondo', 'region': 'Centre'},
                  {'name': 'Bafang', 'region': 'Ouest'},
                  {'name': 'Douala', 'region': 'Littoral'},
                  {'name': 'Fulfulde', 'region': 'Nord'},
                ];

                return LanguageCard(
                  language: languages[index],
                  isSelected:
                      index == 0, // This would be managed by the view model
                  onTap: () {
                    // Handle language selection
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    isGranted ? Colors.green.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: isGranted ? Colors.green : Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isGranted ? Icons.check_circle : Icons.pending,
              color: isGranted ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}
