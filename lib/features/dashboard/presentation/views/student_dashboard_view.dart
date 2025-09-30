import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/student_dashboard_viewmodel.dart';
import '../../../../shared/widgets/layouts/app_scaffold.dart';
import '../../../../shared/widgets/user_guide_widget.dart';
import '../../../../core/constants/supported_languages.dart';
import '../../../../core/constants/routes.dart';

class StudentDashboardView extends StatefulWidget {
  const StudentDashboardView({super.key});

  @override
  State<StudentDashboardView> createState() => _StudentDashboardViewState();
}

class _StudentDashboardViewState extends State<StudentDashboardView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentDashboardViewModel>().loadStudentDashboard();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentDashboardViewModel>(
      builder: (context, viewModel, child) {
        return AppScaffold(
          isLoading: viewModel.isLoading,
          loadingMessage: 'Chargement du tableau de bord...',
          hasError: viewModel.hasError,
          errorTitle: 'Erreur',
          errorMessage: viewModel.errorMessage,
          onRetry: () => viewModel.refreshDashboard(),
          showAppBar: !viewModel.isLoading && !viewModel.hasError,
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  backgroundImage: viewModel.profilePicture != null
                      ? NetworkImage(viewModel.profilePicture!)
                      : null,
                  child: viewModel.profilePicture == null
                      ? Text(
                          viewModel.studentName.isNotEmpty
                              ? viewModel.studentName[0].toUpperCase()
                              : 'E',
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Salut, ${viewModel.studentName}!',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Niveau: ${viewModel.currentLevel}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => _showNotifications(context, viewModel),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => viewModel.refreshDashboard(),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'guide',
                    child: Row(
                      children: [
                        Icon(Icons.help_outline),
                        SizedBox(width: 8),
                        Text('Guide Apprenant'),
                      ],
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(value: 'profile', child: Text('Mon Profil')),
                  PopupMenuItem(value: 'settings', child: Text('Paramètres')),
                  PopupMenuDivider(),
                  PopupMenuItem(value: 'logout', child: Text('Déconnexion')),
                ],
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard), text: 'Accueil'),
                Tab(icon: Icon(Icons.language), text: 'Langues'),
                Tab(icon: Icon(Icons.school), text: 'Leçons'),
                Tab(icon: Icon(Icons.games), text: 'Jeux'),
                Tab(icon: Icon(Icons.quiz), text: 'Quiz'),
                Tab(icon: Icon(Icons.person), text: 'Profil'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(context, viewModel),
              _buildLanguagesTab(context, viewModel),
              _buildLessonsTab(context, viewModel),
              _buildGamesTab(context, viewModel),
              _buildQuizTab(context, viewModel),
              _buildProfileTab(context, viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    StudentDashboardViewModel viewModel,
  ) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refreshDashboard(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue dans votre apprentissage!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Continuez à apprendre les langues traditionnelles du Cameroun',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: viewModel.overallProgress / 100,
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Progression globale: ${viewModel.overallProgress.toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Current Streak Card
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.orange[700],
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${viewModel.currentStreak} jours',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: Colors.orange[700]),
                        ),
                        const Text('Série actuelle'),
                      ],
                    ),
                    const Spacer(),
                    if (viewModel.streakGoal > 0)
                      Text(
                        'Objectif: ${viewModel.streakGoal}',
                        style: TextStyle(color: Colors.orange[600]),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Icon(Icons.school, color: Colors.blue[600]),
                          const SizedBox(height: 8),
                          Text(
                            '${viewModel.completedLessons}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const Text('Leçons'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Icon(Icons.games, color: Colors.green[600]),
                          const SizedBox(height: 8),
                          Text(
                            '${viewModel.gamesPlayed}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const Text('Jeux'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Icon(Icons.quiz, color: Colors.purple[600]),
                          const SizedBox(height: 8),
                          Text(
                            '${viewModel.quizzesTaken}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const Text('Quiz'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Continue Learning Section
            Text(
              'Continuer l\'apprentissage',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            if (viewModel.currentLearningLanguages.isNotEmpty) ...[
              ...viewModel.currentLearningLanguages.map((languageCode) {
                final languageInfo = SupportedLanguages.getLanguageInfo(
                  languageCode,
                );
                final progress = viewModel.getLanguageProgress(languageCode);

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(languageInfo?.flag ?? '🇨🇲'),
                    ),
                    title: Text(languageInfo?.name ?? languageCode),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Progression: ${progress.toStringAsFixed(1)}%'),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: progress / 100,
                          backgroundColor: Colors.grey[300],
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () =>
                          _continueLearning(context, viewModel, languageCode),
                      child: const Text('Continuer'),
                    ),
                  ),
                );
              }).toList(),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.language, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      const Text('Aucune langue en cours d\'apprentissage'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _tabController.animateTo(1),
                        child: const Text('Choisir une langue'),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Recent Activities
            Text(
              'Activités récentes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            ...viewModel.recentActivities
                .map(
                  (activity) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(_getActivityIcon(activity['type'])),
                      ),
                      title: Text(activity['title']),
                      subtitle: Text(activity['description']),
                      trailing: Text(activity['time']),
                    ),
                  ),
                )
                .toList(),

            const SizedBox(height: 16),

            // User Guide
            UserGuideWidget(
              role: 'student',
              title: 'Guide Étudiant',
              sections: UserGuideSections.getStudentGuide(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagesTab(
    BuildContext context,
    StudentDashboardViewModel viewModel,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choisissez votre langue d\'apprentissage',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Apprenez les langues traditionnelles du Cameroun',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Currently Learning Languages
          if (viewModel.currentLearningLanguages.isNotEmpty) ...[
            Text(
              'En cours d\'apprentissage',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...viewModel.currentLearningLanguages.map((languageCode) {
              final languageInfo = SupportedLanguages.getLanguageInfo(
                languageCode,
              );
              final progress = viewModel.getLanguageProgress(languageCode);

              return Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            languageInfo?.flag ?? '🇨🇲',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  languageInfo?.name ?? languageCode,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  languageInfo?.nativeName ?? languageCode,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  'Région: ${languageInfo?.region}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _removeLanguage(
                              context,
                              viewModel,
                              languageCode,
                            ),
                            tooltip: 'Arrêter l\'apprentissage',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Progression: ${progress.toStringAsFixed(1)}%'),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () =>
                                _startLesson(context, viewModel, languageCode),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Leçon'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _startGame(context, viewModel, languageCode),
                            icon: const Icon(Icons.games),
                            label: const Text('Jeu'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _startQuiz(context, viewModel, languageCode),
                            icon: const Icon(Icons.quiz),
                            label: const Text('Quiz'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
          ],

          // Available Languages
          Text(
            'Langues disponibles',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          ...SupportedLanguages.languages.entries.map((entry) {
            final languageCode = entry.key;
            final languageInfo = entry.value;
            final isLearning = viewModel.currentLearningLanguages.contains(
              languageCode,
            );
            final isCompleted = viewModel.completedLanguages.contains(
              languageCode,
            );

            return Card(
              color: isCompleted ? Colors.green[50] : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          languageInfo.flag,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    languageInfo.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  if (isCompleted) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                languageInfo.nativeName,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontStyle: FontStyle.italic),
                              ),
                              Text(
                                'Région: ${languageInfo.region}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                'Niveau: ${languageInfo.difficulty.displayName}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '${(languageInfo.speakers / 1000000).toStringAsFixed(1)}M locuteurs',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (isLearning)
                          ElevatedButton(
                            onPressed: () => _continueLearning(
                              context,
                              viewModel,
                              languageCode,
                            ),
                            child: const Text('Continuer'),
                          )
                        else if (!isCompleted)
                          ElevatedButton(
                            onPressed: () =>
                                _addLanguage(context, viewModel, languageCode),
                            child: const Text('Commencer'),
                          )
                        else
                          ElevatedButton(
                            onPressed: () => _reviewLanguage(
                              context,
                              viewModel,
                              languageCode,
                            ),
                            child: const Text('Réviser'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      languageInfo.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      languageInfo.culturalInfo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLessonsTab(
    BuildContext context,
    StudentDashboardViewModel viewModel,
  ) {
    return DefaultTabController(
      length: viewModel.currentLearningLanguages.length + 1,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: [
              const Tab(text: 'Toutes'),
              ...viewModel.currentLearningLanguages.map((languageCode) {
                final languageInfo = SupportedLanguages.getLanguageInfo(
                  languageCode,
                );
                return Tab(
                  text: languageInfo?.name ?? languageCode,
                  icon: Text(languageInfo?.flag ?? '🇨🇲'),
                );
              }).toList(),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAllLessons(context, viewModel),
                ...viewModel.currentLearningLanguages
                    .map(
                      (languageCode) => _buildLanguageLessons(
                        context,
                        viewModel,
                        languageCode,
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllLessons(
    BuildContext context,
    StudentDashboardViewModel viewModel,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.availableLessons.length,
      itemBuilder: (context, index) {
        final lesson = viewModel.availableLessons[index];
        return _buildLessonCard(context, viewModel, lesson);
      },
    );
  }

  Widget _buildLanguageLessons(
    BuildContext context,
    StudentDashboardViewModel viewModel,
    String languageCode,
  ) {
    final lessons = viewModel.getLessonsByLanguage(languageCode);

    if (lessons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Aucune leçon disponible pour cette langue'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return _buildLessonCard(context, viewModel, lesson);
      },
    );
  }

  Widget _buildLessonCard(
    BuildContext context,
    StudentDashboardViewModel viewModel,
    Map<String, dynamic> lesson,
  ) {
    final isCompleted = lesson['isCompleted'] ?? false;
    final isLocked = lesson['isLocked'] ?? false;
    final progress = lesson['progress']?.toDouble() ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isCompleted
              ? Colors.green
              : isLocked
              ? Colors.grey
              : Colors.blue,
          child: Icon(
            isCompleted
                ? Icons.check
                : isLocked
                ? Icons.lock
                : Icons.play_arrow,
            color: Colors.white,
          ),
        ),
        title: Text(
          lesson['title'],
          style: TextStyle(color: isLocked ? Colors.grey : null),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lesson['description']),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${lesson['duration']} min'),
                const SizedBox(width: 16),
                Icon(Icons.bar_chart, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(lesson['difficulty']),
              ],
            ),
            if (progress > 0) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(height: 4),
              Text('${progress.toStringAsFixed(0)}% terminé'),
            ],
          ],
        ),
        trailing: isLocked
            ? const Icon(Icons.lock, color: Colors.grey)
            : ElevatedButton(
                onPressed: () =>
                    _startLessonById(context, viewModel, lesson['id']),
                child: Text(isCompleted ? 'Réviser' : 'Commencer'),
              ),
      ),
    );
  }

  Widget _buildGamesTab(
    BuildContext context,
    StudentDashboardViewModel viewModel,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: viewModel.availableGames.length,
      itemBuilder: (context, index) {
        final game = viewModel.availableGames[index];
        return _buildGameCard(context, viewModel, game);
      },
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    StudentDashboardViewModel viewModel,
    Map<String, dynamic> game,
  ) {
    final isUnlocked = game['isUnlocked'] ?? true;
    final bestScore = game['bestScore'] ?? 0;

    return Card(
      child: InkWell(
        onTap: isUnlocked
            ? () => _playGame(context, viewModel, game['id'])
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.games,
                    size: 32,
                    color: isUnlocked ? Colors.blue : Colors.grey,
                  ),
                  const Spacer(),
                  if (!isUnlocked) const Icon(Icons.lock, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                game['title'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isUnlocked ? null : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                game['description'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isUnlocked ? null : Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              if (bestScore > 0) ...[
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber[700]),
                    const SizedBox(width: 4),
                    Text('Meilleur: $bestScore'),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              ElevatedButton(
                onPressed: isUnlocked
                    ? () => _playGame(context, viewModel, game['id'])
                    : null,
                child: const Text('Jouer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizTab(
    BuildContext context,
    StudentDashboardViewModel viewModel,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.availableQuizzes.length,
      itemBuilder: (context, index) {
        final quiz = viewModel.availableQuizzes[index];
        return _buildQuizCard(context, viewModel, quiz);
      },
    );
  }

  Widget _buildQuizCard(
    BuildContext context,
    StudentDashboardViewModel viewModel,
    Map<String, dynamic> quiz,
  ) {
    final isCompleted = quiz['isCompleted'] ?? false;
    final bestScore = quiz['bestScore']?.toDouble() ?? 0.0;
    final attempts = quiz['attempts'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isCompleted ? Colors.purple : Colors.orange,
          child: Icon(
            isCompleted ? Icons.quiz : Icons.help_outline,
            color: Colors.white,
          ),
        ),
        title: Text(quiz['title']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quiz['description']),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.question_answer, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${quiz['questionCount']} questions'),
                const SizedBox(width: 16),
                Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${quiz['timeLimit']} min'),
              ],
            ),
            if (isCompleted) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber[700]),
                  const SizedBox(width: 4),
                  Text('Meilleur score: ${bestScore.toStringAsFixed(0)}%'),
                  const SizedBox(width: 16),
                  Text('Tentatives: $attempts'),
                ],
              ),
            ],
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _takeQuiz(context, viewModel, quiz['id']),
          child: Text(isCompleted ? 'Retenter' : 'Commencer'),
        ),
      ),
    );
  }

  Widget _buildProfileTab(
    BuildContext context,
    StudentDashboardViewModel viewModel,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: viewModel.profilePicture != null
                        ? NetworkImage(viewModel.profilePicture!)
                        : null,
                    child: viewModel.profilePicture == null
                        ? Text(
                            viewModel.studentName.isNotEmpty
                                ? viewModel.studentName[0].toUpperCase()
                                : 'E',
                            style: const TextStyle(fontSize: 36),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.studentName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    viewModel.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text('Niveau: ${viewModel.currentLevel}'),
                    backgroundColor: Colors.blue[100],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '${viewModel.currentStreak}',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: Colors.orange[700]),
                        ),
                        const Text('Jours de série'),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '${viewModel.totalExperience}',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: Colors.blue[700]),
                        ),
                        const Text('Points XP'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Achievements
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Achievements',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: viewModel.achievements
                        .map(
                          (achievement) => Chip(
                            avatar: Icon(
                              _getAchievementIcon(achievement['type']),
                              size: 16,
                            ),
                            label: Text(achievement['title']),
                            backgroundColor: Colors.amber[100],
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Settings
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  trailing: Switch(
                    value: viewModel.notificationsEnabled,
                    onChanged: (value) => viewModel.toggleNotifications(value),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Mode sombre'),
                  trailing: Switch(
                    value: viewModel.darkModeEnabled,
                    onChanged: (value) => viewModel.toggleDarkMode(value),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Langue de l\'interface'),
                  subtitle: Text(viewModel.interfaceLanguage),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showLanguageSelector(context, viewModel),
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Modifier le profil'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _editProfile(context, viewModel),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Se déconnecter'),
                  onTap: () => _showLogoutDialog(context, viewModel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'lesson_completed':
        return Icons.school;
      case 'game_played':
        return Icons.games;
      case 'quiz_taken':
        return Icons.quiz;
      case 'achievement_earned':
        return Icons.star;
      case 'streak_maintained':
        return Icons.local_fire_department;
      default:
        return Icons.circle;
    }
  }

  IconData _getAchievementIcon(String type) {
    switch (type) {
      case 'first_lesson':
        return Icons.school;
      case 'streak_master':
        return Icons.local_fire_department;
      case 'quiz_champion':
        return Icons.quiz;
      case 'game_master':
        return Icons.games;
      case 'language_explorer':
        return Icons.language;
      default:
        return Icons.star;
    }
  }

  // Action methods
  void _showNotifications(
    BuildContext context,
    StudentDashboardViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (viewModel.notifications.isEmpty)
              const Text('Aucune notification')
            else
              ...viewModel.notifications
                  .map(
                    (notification) => ListTile(
                      title: Text(notification['title']),
                      subtitle: Text(notification['message']),
                      trailing: Text(notification['time']),
                    ),
                  )
                  .toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _continueLearning(
    BuildContext context,
    StudentDashboardViewModel viewModel,
    String languageCode,
  ) {
    // TODO: Navigate to continue learning screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Continuer l\'apprentissage de ${SupportedLanguages.getDisplayName(languageCode)}',
        ),
      ),
    );
  }

  void _addLanguage(
    BuildContext context,
    StudentDashboardViewModel viewModel,
    String languageCode,
  ) {
    viewModel.startLearningLanguage(languageCode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Apprentissage de ${SupportedLanguages.getDisplayName(languageCode)} commencé!',
        ),
      ),
    );
  }

  void _removeLanguage(
    BuildContext context,
    StudentDashboardViewModel viewModel,
    String languageCode,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer'),
        content: Text(
          'Êtes-vous sûr de vouloir arrêter l\'apprentissage de ${SupportedLanguages.getDisplayName(languageCode)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.stopLearningLanguage(languageCode);
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _reviewLanguage(
    BuildContext context,
    StudentDashboardViewModel viewModel,
    String languageCode,
  ) {
    // TODO: Navigate to review screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Révision de ${SupportedLanguages.getDisplayName(languageCode)}',
        ),
      ),
    );
  }

  void _startLesson(
    BuildContext context,
    StudentDashboardViewModel viewModel,
    String languageCode,
  ) {
    // TODO: Navigate to lesson screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Démarrage d\'une leçon en ${SupportedLanguages.getDisplayName(languageCode)}',
        ),
      ),
    );
  }

  void _startGame(
    BuildContext context,
    StudentDashboardViewModel viewModel,
    String languageCode,
  ) {
    // TODO: Navigate to game screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Démarrage d\'un jeu en ${SupportedLanguages.getDisplayName(languageCode)}',
        ),
      ),
    );
  }

  void _startQuiz(
    BuildContext context,
    StudentDashboardViewModel viewModel,
    String languageCode,
  ) {
    // TODO: Navigate to quiz screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Démarrage d\'un quiz en ${SupportedLanguages.getDisplayName(languageCode)}',
        ),
      ),
    );
  }

  void _startLessonById(
    BuildContext context,
    StudentDashboardViewModel viewModel,
    String lessonId,
  ) {
    // TODO: Navigate to specific lesson
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Démarrage de la leçon $lessonId')));
  }

  void _playGame(
    BuildContext context,
    StudentDashboardViewModel viewModel,
    String gameId,
  ) {
    // TODO: Navigate to specific game
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Lancement du jeu $gameId')));
  }

  void _takeQuiz(
    BuildContext context,
    StudentDashboardViewModel viewModel,
    String quizId,
  ) {
    // TODO: Navigate to specific quiz
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Démarrage du quiz $quizId')));
  }

  void _showLanguageSelector(
    BuildContext context,
    StudentDashboardViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Langue de l\'interface'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Français'),
              onTap: () {
                Navigator.of(context).pop();
                viewModel.changeInterfaceLanguage('fr');
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                Navigator.of(context).pop();
                viewModel.changeInterfaceLanguage('en');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile(BuildContext context, StudentDashboardViewModel viewModel) {
    // TODO: Navigate to edit profile screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Modification du profil')));
  }

  void _showLogoutDialog(
    BuildContext context,
    StudentDashboardViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.logout();
              context.go(Routes.login);
            },
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'guide':
        context.push(Routes.studentGuide);
        break;
      case 'profile':
        context.push(Routes.profile);
        break;
      case 'logout':
        _showLogoutDialog(context, context.read<StudentDashboardViewModel>());
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$action - À implémenter')));
    }
  }
}
