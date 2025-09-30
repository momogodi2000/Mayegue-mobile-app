import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/supported_languages.dart';
import '../../../../shared/themes/colors.dart';
import '../viewmodels/guest_dashboard_viewmodel.dart';
import '../widgets/language_showcase_card.dart';
import '../widgets/demo_lesson_card.dart';
import '../widgets/feature_highlight_card.dart';
import '../widgets/testimonial_card.dart';

/// Complete guest dashboard with comprehensive demo functionality
class GuestDashboardView extends StatefulWidget {
  const GuestDashboardView({super.key});

  @override
  State<GuestDashboardView> createState() => _GuestDashboardViewState();
}

class _GuestDashboardViewState extends State<GuestDashboardView>
    with TickerProviderStateMixin {
  late AnimationController _heroAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _heroAnimation;
  late Animation<Offset> _cardSlideAnimation;

  @override
  void initState() {
    super.initState();
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _heroAnimation = CurvedAnimation(
      parent: _heroAnimationController,
      curve: Curves.easeInOut,
    );

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _startAnimations();

    // Initialize guest viewmodel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuestDashboardViewModel>().initialize();
    });
  }

  void _startAnimations() {
    _heroAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GuestDashboardViewModel>(
        builder: (context, viewModel, child) {
          return CustomScrollView(
            slivers: [
              _buildHeroSection(),
              _buildLanguagesShowcase(viewModel),
              _buildDemoLessonsSection(viewModel),
              _buildFeaturesSection(),
              _buildTestimonialsSection(viewModel),
              _buildPricingSection(),
              _buildCallToActionSection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroSection() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _heroAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * _heroAnimation.value),
            child: Opacity(
              opacity: _heroAnimation.value,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                      AppColors.primary.withValues(alpha: 0.8 * 255),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.asset(
                          'assets/images/cameroon_pattern.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Main content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo and title
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color:
                                    Colors.white.withValues(alpha: 0.15 * 255),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      Colors.white.withValues(alpha: 0.3 * 255),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.school,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Mayegue',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 48,
                                        ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Subtitle
                            Text(
                              'Découvrez les Langues\nTraditionnelles du Cameroun',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                            ),

                            const SizedBox(height: 16),

                            // Description
                            Text(
                              'Apprenez Ewondo, Duala, Fe\'efe\'e, Fulfulde, Bassa et Bamum\navec notre méthode interactive innovante',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.white
                                        .withValues(alpha: 0.9 * 255),
                                    height: 1.5,
                                  ),
                            ),

                            const SizedBox(height: 40),

                            // Action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _startDemo(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.play_arrow),
                                        SizedBox(width: 8),
                                        Text(
                                          'Essayer Gratuitement',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        context.go('/auth/register'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                          color: Colors.white, width: 2),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'S\'inscrire',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Stats
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatItem('1000+', 'Mots'),
                                _buildStatItem('6', 'Langues'),
                                _buildStatItem('500+', 'Apprenants'),
                              ],
                            ),
                          ],
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
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8 * 255),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguagesShowcase(GuestDashboardViewModel viewModel) {
    return SliverToBoxAdapter(
      child: SlideTransition(
        position: _cardSlideAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Explorez nos Langues',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Découvrez la richesse culturelle du Cameroun',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 32),

              // Languages grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: SupportedLanguages.languages.length,
                itemBuilder: (context, index) {
                  final language =
                      SupportedLanguages.languages.values.toList()[index];
                  return LanguageShowcaseCard(
                    languageName: language.name,
                    greeting: language.greeting,
                    region: language.region,
                    color: language.color,
                    onTap: () => _exploreLanguage(language.code),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoLessonsSection(GuestDashboardViewModel viewModel) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
        ),
        child: Column(
          children: [
            Text(
              'Leçons Démo',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez nos leçons interactives gratuitement',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),

            // Demo lessons list
            if (viewModel.demoLessons.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.demoLessons.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final lesson = viewModel.demoLessons[index];
                  return DemoLessonCard(
                    title: lesson.title,
                    description: lesson.description,
                    language: lesson.language,
                    duration: lesson.duration,
                    onTap: () => _startDemoLesson(lesson.id),
                  );
                },
              )
            else
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.school,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Leçons de démonstration en préparation',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.mic,
        'title': 'Reconnaissance Vocale',
        'description':
            'Perfectionnez votre prononciation avec notre IA avancée',
        'color': Colors.blue,
      },
      {
        'icon': Icons.psychology,
        'title': 'IA Conversationnelle',
        'description': 'Pratiquez avec notre assistant IA bilingue',
        'color': Colors.green,
      },
      {
        'icon': Icons.replay,
        'title': 'Répétition Espacée',
        'description': 'Mémorisez efficacement avec notre système adaptatif',
        'color': Colors.orange,
      },
      {
        'icon': Icons.people,
        'title': 'Communauté Active',
        'description': 'Échangez avec d\'autres apprenants passionnés',
        'color': Colors.purple,
      },
      {
        'icon': Icons.offline_bolt,
        'title': 'Mode Hors Ligne',
        'description': 'Continuez à apprendre même sans connexion',
        'color': Colors.teal,
      },
      {
        'icon': Icons.school,
        'title': 'Contenu Expert',
        'description': 'Créé par des locuteurs natifs et linguistes',
        'color': Colors.red,
      },
    ];

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Fonctionnalités Avancées',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Une expérience d\'apprentissage moderne et complète',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return FeatureHighlightCard(
                  icon: feature['icon'] as IconData,
                  title: feature['title'] as String,
                  description: feature['description'] as String,
                  color: feature['color'] as Color,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialsSection(GuestDashboardViewModel viewModel) {
    final testimonials = [
      {
        'name': 'Marie Ngono',
        'role': 'Étudiante',
        'comment':
            'Grâce à Mayegue, j\'ai redécouvert l\'Ewondo de mes grands-parents. L\'application est intuitive et vraiment efficace !',
        'rating': 5,
        'avatar': 'assets/images/avatars/marie.jpg',
      },
      {
        'name': 'Jean-Paul Dibango',
        'role': 'Enseignant',
        'comment':
            'Excellent outil pour préserver nos langues. Les fonctionnalités pour enseignants sont particulièrement bien pensées.',
        'rating': 5,
        'avatar': 'assets/images/avatars/jean.jpg',
      },
      {
        'name': 'Fatou Amadou',
        'role': 'Linguiste',
        'comment':
            'Une approche moderne et respectueuse de nos traditions linguistiques. Je recommande vivement !',
        'rating': 5,
        'avatar': 'assets/images/avatars/fatou.jpg',
      },
    ];

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05 * 255),
        ),
        child: Column(
          children: [
            Text(
              'Ce que disent nos utilisateurs',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: testimonials.length,
                itemBuilder: (context, index) {
                  final testimonial = testimonials[index];
                  return TestimonialCard(
                    name: testimonial['name'] as String,
                    role: testimonial['role'] as String,
                    comment: testimonial['comment'] as String,
                    rating: testimonial['rating'] as int,
                    avatarUrl: testimonial['avatar'] as String,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Tarifs Simples',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choisissez l\'abonnement qui vous convient',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                // Free Plan
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            'Gratuit',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '0 FCFA',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                          ),
                          const SizedBox(height: 16),
                          const Text('• Leçons de base'),
                          const Text('• Dictionnaire limité'),
                          const Text('• 3 langues'),
                          const SizedBox(height: 24),
                          OutlinedButton(
                            onPressed: () => context.go('/auth/register'),
                            child: const Text('Commencer'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Premium Plan
                Expanded(
                  child: Card(
                    elevation: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.secondary,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              'Premium',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '2500 FCFA/mois',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            const Text('• Toutes les leçons',
                                style: TextStyle(color: Colors.white)),
                            const Text('• Dictionnaire complet',
                                style: TextStyle(color: Colors.white)),
                            const Text('• 6 langues',
                                style: TextStyle(color: Colors.white)),
                            const Text('• IA conversationnelle',
                                style: TextStyle(color: Colors.white)),
                            const Text('• Mode hors ligne',
                                style: TextStyle(color: Colors.white)),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => context.go('/auth/register'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                              ),
                              child: const Text('Essayer 7 jours'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallToActionSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.rocket_launch,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            Text(
              'Prêt à commencer ?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Rejoignez des centaines d\'apprenants qui préservent\net transmettent les langues camerounaises',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9 * 255),
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go('/auth/register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _startDemo(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Essayer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startDemo() {
    context.go('/guest/demo');
  }

  void _exploreLanguage(String languageCode) {
    context.go('/guest/explore/$languageCode');
  }

  void _startDemoLesson(String lessonId) {
    context.go('/guest/demo/lesson/$lessonId');
  }
}

/// Demo lesson model for guest experience
class DemoLesson {
  final String id;
  final String title;
  final String description;
  final String languageCode;
  final String languageName;
  final String difficultyLevel;
  final int estimatedDuration;
  final String thumbnailUrl;
  final bool isAvailable;

  const DemoLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.languageCode,
    required this.languageName,
    required this.difficultyLevel,
    required this.estimatedDuration,
    required this.thumbnailUrl,
    this.isAvailable = true,
  });
}
