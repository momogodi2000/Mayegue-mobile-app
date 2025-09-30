import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/supported_languages.dart';
import '../../../../shared/widgets/user_guide_widget.dart';
import '../viewmodels/teacher_dashboard_viewmodel.dart';
import '../widgets/teacher_stats_widget.dart';
import '../widgets/student_progress_widget.dart';
import '../widgets/analytics_widget.dart';
import '../widgets/content_management_widget.dart';
import '../widgets/teacher_dictionary_contribution_dialog.dart';

/// Dashboard view specifically designed for teachers
class TeacherDashboardView extends StatefulWidget {
  const TeacherDashboardView({super.key});

  @override
  State<TeacherDashboardView> createState() => _TeacherDashboardViewState();
}

class _TeacherDashboardViewState extends State<TeacherDashboardView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDashboardData() {
    final viewModel = context.read<TeacherDashboardViewModel>();
    viewModel.loadTeacherDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord Enseignant'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text('Mon Profil')),
              const PopupMenuItem(value: 'settings', child: Text('Paramètres')),
              const PopupMenuItem(value: 'help', child: Text('Aide')),
              const PopupMenuItem(value: 'logout', child: Text('Déconnexion')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Aperçu', icon: Icon(Icons.dashboard, size: 20)),
            Tab(text: 'Étudiants', icon: Icon(Icons.people, size: 20)),
            Tab(text: 'Contenu', icon: Icon(Icons.library_books, size: 20)),
            Tab(text: 'Analytiques', icon: Icon(Icons.analytics, size: 20)),
            Tab(text: 'Outils', icon: Icon(Icons.build, size: 20)),
          ],
        ),
      ),
      body: Consumer<TeacherDashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.hasError) {
            return _buildErrorView(viewModel);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(viewModel),
              _buildStudentsTab(viewModel),
              _buildContentTab(viewModel),
              _buildAnalyticsTab(viewModel),
              _buildToolsTab(viewModel),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickActions(context),
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add),
        label: const Text('Actions'),
      ),
    );
  }

  Widget _buildOverviewTab(TeacherDashboardViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          _buildWelcomeCard(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Quick stats
          TeacherStatsWidget(
            totalStudents: viewModel.totalStudents,
            activeStudents: viewModel.activeStudents,
            completedLessons: viewModel.completedLessonsCount,
            averageProgress: viewModel.averageStudentProgress,
          ),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Recent activities
          _buildRecentActivitiesCard(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Quick actions
          _buildQuickActionsGrid(),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Language distribution
          _buildLanguageDistributionCard(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // User Guide
          UserGuideWidget(
            role: 'teacher',
            title: 'Guide Enseignant',
            sections: UserGuideSections.getTeacherGuide(),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab(TeacherDashboardViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search and filter
          _buildStudentSearchBar(viewModel),
          const SizedBox(height: AppDimensions.spacingMedium),

          // Student progress overview
          StudentProgressWidget(
            students: viewModel.students,
            onStudentTap: (student) => _viewStudentDetails(context, student),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Class performance
          _buildClassPerformanceCard(viewModel),
        ],
      ),
    );
  }

  Widget _buildContentTab(TeacherDashboardViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content management tools
          ContentManagementWidget(
            onCreateLesson: () => _createNewLesson(context),
            onCreateGame: () => _createNewGame(context),
            onManageVocabulary: () => _manageVocabulary(context),
            onUploadMedia: () => _uploadMedia(context),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Content library
          _buildContentLibraryCard(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Pending reviews
          _buildPendingReviewsCard(viewModel),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(TeacherDashboardViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analytics overview
          AnalyticsWidget(
            teacherData: viewModel.analyticsData,
            onExportReport: () => _exportReport(context),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Detailed metrics
          _buildDetailedMetricsCard(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Student engagement
          _buildEngagementMetricsCard(viewModel),
        ],
      ),
    );
  }

  Widget _buildToolsTab(TeacherDashboardViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teaching tools
          _buildTeachingToolsGrid(),
          const SizedBox(height: AppDimensions.spacingLarge),

          // AI Assistant
          _buildAIAssistantCard(),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Communication tools
          _buildCommunicationToolsCard(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Settings and preferences
          _buildTeacherSettingsCard(viewModel),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(TeacherDashboardViewModel viewModel) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.indigo.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue, ${viewModel.teacherName}!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            Text(
              'Vous enseignez ${viewModel.teachingLanguages.length} langue(s) à ${viewModel.totalStudents} étudiants',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Wrap(
              spacing: 8,
              children: viewModel.teachingLanguages.map((language) {
                final info = SupportedLanguages.getLanguageInfo(language);
                return Chip(
                  label: Text('${info?.flag} ${info?.name}'),
                  backgroundColor: Colors.white.withValues(alpha: 51),
                  labelStyle: const TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesCard(TeacherDashboardViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activités Récentes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => _viewAllActivities(context),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            ...viewModel.recentActivities
                .take(5)
                .map(
                  (activity) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.spacingSmall,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getActivityIcon(activity['type']),
                          color: Colors.indigo,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.spacingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                activity['description'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          activity['time'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = [
      {
        'title': 'Nouvelle Leçon',
        'icon': Icons.add_circle,
        'color': Colors.green,
        'action': () => _createNewLesson(context),
      },
      {
        'title': 'Nouveau Jeu',
        'icon': Icons.games,
        'color': Colors.orange,
        'action': () => _createNewGame(context),
      },
      {
        'title': 'Évaluation',
        'icon': Icons.assignment,
        'color': Colors.blue,
        'action': () => _createAssessment(context),
      },
      {
        'title': 'Messagerie',
        'icon': Icons.message,
        'color': Colors.purple,
        'action': () => _openMessaging(context),
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions Rapides',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return InkWell(
                  onTap: action['action'] as VoidCallback,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadius,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withValues(alpha: 25),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadius,
                      ),
                      border: Border.all(
                        color: (action['color'] as Color).withValues(alpha: 76),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          action['icon'] as IconData,
                          color: action['color'] as Color,
                          size: 32,
                        ),
                        const SizedBox(height: AppDimensions.spacingSmall),
                        Text(
                          action['title'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: action['color'] as Color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDistributionCard(TeacherDashboardViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Répartition par Langue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            ...viewModel.languageDistribution.entries.map((entry) {
              final language = entry.key;
              final count = entry.value;
              final info = SupportedLanguages.getLanguageInfo(language);

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.spacingSmall,
                ),
                child: Row(
                  children: [
                    Text(
                      info?.flag ?? '🇨🇲',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: AppDimensions.spacingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info?.name ?? language,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          LinearProgressIndicator(
                            value: count / viewModel.totalStudents,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMedium),
                    Text(
                      '$count étudiants',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentSearchBar(TeacherDashboardViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Rechercher un étudiant...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
                onChanged: (query) => viewModel.searchStudents(query),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: (filter) => viewModel.filterStudents(filter),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'all',
                  child: Text('Tous les étudiants'),
                ),
                const PopupMenuItem(
                  value: 'active',
                  child: Text('Étudiants actifs'),
                ),
                const PopupMenuItem(
                  value: 'struggling',
                  child: Text('En difficulté'),
                ),
                const PopupMenuItem(value: 'advanced', child: Text('Avancés')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassPerformanceCard(TeacherDashboardViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance de la Classe',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPerformanceMetric(
                  'Moyenne Générale',
                  '${viewModel.averageScore.toStringAsFixed(1)}%',
                  Colors.blue,
                  Icons.trending_up,
                ),
                _buildPerformanceMetric(
                  'Taux de Réussite',
                  '${viewModel.successRate.toStringAsFixed(1)}%',
                  Colors.green,
                  Icons.check_circle,
                ),
                _buildPerformanceMetric(
                  'Engagement',
                  '${viewModel.engagementRate.toStringAsFixed(1)}%',
                  Colors.orange,
                  Icons.favorite,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetric(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: AppDimensions.spacingSmall),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContentLibraryCard(TeacherDashboardViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bibliothèque de Contenu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => _viewContentLibrary(context),
                  child: const Text('Gérer'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildContentCount(
                  'Leçons',
                  viewModel.lessonsCount,
                  Icons.book,
                ),
                _buildContentCount('Jeux', viewModel.gamesCount, Icons.games),
                _buildContentCount('Quiz', viewModel.quizzesCount, Icons.quiz),
                _buildContentCount(
                  'Médias',
                  viewModel.mediaCount,
                  Icons.perm_media,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCount(String title, int count, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.indigo, size: 24),
        const SizedBox(height: AppDimensions.spacingSmall / 2),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildTeachingToolsGrid() {
    final tools = [
      {
        'title': 'Générateur de Quiz',
        'icon': Icons.quiz,
        'color': Colors.blue,
        'action': () => _openQuizGenerator(context),
      },
      {
        'title': 'Créateur de Jeux',
        'icon': Icons.games,
        'color': Colors.green,
        'action': () => _openGameCreator(context),
      },
      {
        'title': 'Assistant IA',
        'icon': Icons.psychology,
        'color': Colors.purple,
        'action': () => _openAIAssistant(context),
      },
      {
        'title': 'Phonétique',
        'icon': Icons.record_voice_over,
        'color': Colors.orange,
        'action': () => _openPhoneticTool(context),
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Outils Pédagogiques',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: tools.length,
              itemBuilder: (context, index) {
                final tool = tools[index];
                return InkWell(
                  onTap: tool['action'] as VoidCallback,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadius,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    decoration: BoxDecoration(
                      color: (tool['color'] as Color).withValues(alpha: 25),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadius,
                      ),
                      border: Border.all(
                        color: (tool['color'] as Color).withValues(alpha: 76),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tool['icon'] as IconData,
                          color: tool['color'] as Color,
                          size: 28,
                        ),
                        const SizedBox(height: AppDimensions.spacingSmall),
                        Text(
                          tool['title'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: tool['color'] as Color,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAssistantCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology, color: Colors.purple, size: 28),
                SizedBox(width: AppDimensions.spacingMedium),
                Text(
                  'Assistant IA Éducatif',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Text(
              'Utilisez l\'IA pour créer du contenu, générer des exercices, et obtenir des suggestions pédagogiques.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _generateContent(context),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Générer Contenu'),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMedium),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openAIChat(context),
                    icon: const Icon(Icons.chat),
                    label: const Text('Chat IA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
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

  Widget _buildErrorView(TeacherDashboardViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 64),
          const SizedBox(height: AppDimensions.spacingMedium),
          const Text(
            'Une erreur s\'est produite',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            viewModel.errorMessage ?? 'Erreur inconnue',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          ElevatedButton(
            onPressed: _loadDashboardData,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'lesson_completed':
        return Icons.check_circle;
      case 'student_joined':
        return Icons.person_add;
      case 'content_created':
        return Icons.add_circle;
      case 'message_received':
        return Icons.message;
      default:
        return Icons.info;
    }
  }

  // Action methods
  void _showNotifications(BuildContext context) {
    // TODO: Implement notifications view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications - À implémenter')),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    // TODO: Implement menu actions
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$action - À implémenter')));
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Actions Rapides',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              children: [
                _buildQuickAction(
                  'Nouvelle\nLeçon',
                  Icons.book,
                  () => _createNewLesson(context),
                ),
                _buildQuickAction(
                  'Nouveau\nJeu',
                  Icons.games,
                  () => _createNewGame(context),
                ),
                _buildQuickAction(
                  'Message\nGroupe',
                  Icons.group,
                  () => _sendGroupMessage(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.indigo),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Navigation methods (TODO: Implement actual navigation)
  void _createNewLesson(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Création de leçon - À implémenter')),
    );
  }

  void _createNewGame(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Création de jeu - À implémenter')),
    );
  }

  void _createAssessment(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Création d\'évaluation - À implémenter')),
    );
  }

  void _openMessaging(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Messagerie - À implémenter')));
  }

  void _viewStudentDetails(BuildContext context, Map<String, dynamic> student) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Détails étudiant ${student['name']} - À implémenter'),
      ),
    );
  }

  void _viewAllActivities(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Toutes les activités - À implémenter')),
    );
  }

  void _manageVocabulary(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TeacherDictionaryContributionDialog(),
    );
  }

  void _uploadMedia(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upload média - À implémenter')),
    );
  }

  void _exportReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export rapport - À implémenter')),
    );
  }

  void _viewContentLibrary(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bibliothèque de contenu - À implémenter')),
    );
  }

  void _openQuizGenerator(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Générateur de quiz - À implémenter')),
    );
  }

  void _openGameCreator(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Créateur de jeux - À implémenter')),
    );
  }

  void _openAIAssistant(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assistant IA - À implémenter')),
    );
  }

  void _openPhoneticTool(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Outil phonétique - À implémenter')),
    );
  }

  void _generateContent(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Génération contenu IA - À implémenter')),
    );
  }

  void _openAIChat(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Chat IA - À implémenter')));
  }

  void _sendGroupMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message de groupe - À implémenter')),
    );
  }

  Widget _buildPendingReviewsCard(TeacherDashboardViewModel viewModel) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Révisions en Attente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Aucune révision en attente'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedMetricsCard(TeacherDashboardViewModel viewModel) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Métriques Détaillées',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Detailed metrics here'),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementMetricsCard(TeacherDashboardViewModel viewModel) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Métriques d\'Engagement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Engagement metrics here'),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunicationToolsCard(TeacherDashboardViewModel viewModel) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Outils de Communication',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Communication tools here'),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherSettingsCard(TeacherDashboardViewModel viewModel) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paramètres Enseignant',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Teacher settings here'),
          ],
        ),
      ),
    );
  }
}
