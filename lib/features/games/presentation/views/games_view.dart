import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/routes.dart';
import '../../../../core/constants/supported_languages.dart';
import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../../gamification/presentation/viewmodels/gamification_viewmodel.dart';
import '../widgets/game_card.dart';
import '../widgets/quick_stats_card.dart';

class GamesView extends StatefulWidget {
  const GamesView({super.key});
  @override
  State<GamesView> createState() => _GamesViewState();
}

class _GamesViewState extends State<GamesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedLanguage;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games & Learning'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Games', icon: Icon(Icons.games)),
            Tab(text: 'Progress', icon: Icon(Icons.trending_up)),
            Tab(text: 'Leaderboards', icon: Icon(Icons.leaderboard)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGamesTab(),
          _buildProgressTab(),
          _buildLeaderboardsTab(),
        ],
      ),
    );
  }

  Widget _buildGamesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats
          const Row(
            children: [
              Expanded(
                child: QuickStatsCard(
                  title: 'Games Played',
                  value: '12',
                  icon: Icons.play_circle,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: QuickStatsCard(
                  title: 'Best Score',
                  value: '2,450',
                  icon: Icons.star,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Language Selection
          const Text(
            'Choose a Language',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: SupportedLanguages.languages.length,
              itemBuilder: (context, index) {
                final language =
                    SupportedLanguages.languages.values.elementAt(index);
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(language.name),
                    selected: _selectedLanguage == language.code,
                    onSelected: (selected) {
                      setState(() {
                        _selectedLanguage = selected ? language.code : null;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // Game Categories
          const Text(
            'Game Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              GameCard(
                title: 'Vocabulary Quiz',
                description: 'Test your knowledge of words and phrases',
                icon: Icons.quiz,
                color: Colors.blue,
                onTap: () => context.go(Routes.quiz),
              ),
              GameCard(
                title: 'Word Match',
                description: 'Match words with their meanings',
                icon: Icons.memory,
                color: Colors.green,
                onTap: () => _showComingSoonDialog(context, 'Word Match'),
              ),
              GameCard(
                title: 'Pronunciation',
                description: 'Practice correct pronunciation',
                icon: Icons.mic,
                color: Colors.orange,
                onTap: () =>
                    _showComingSoonDialog(context, 'Pronunciation Game'),
              ),
              GameCard(
                title: 'Culture Quiz',
                description: 'Learn about Cameroonian culture',
                icon: Icons.celebration,
                color: Colors.purple,
                onTap: () => _showComingSoonDialog(context, 'Culture Quiz'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return Consumer2<AuthViewModel, GamificationViewModel>(
      builder: (context, authViewModel, gamificationViewModel, child) {
        final userId = authViewModel.currentUser?.id;

        // Load user progress when tab is opened
        if (userId != null && gamificationViewModel.userProgress == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            gamificationViewModel.loadUserProgress(userId);
            gamificationViewModel.loadUserAchievements(userId);
          });
        }

        final userProgress = gamificationViewModel.userProgress;

        return RefreshIndicator(
          onRefresh: () async {
            if (userId != null) {
              await gamificationViewModel.loadUserProgress(userId);
              await gamificationViewModel.loadUserAchievements(userId);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Progress',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (gamificationViewModel.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (userProgress != null) ...[
                  // Level and XP
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Level ${userProgress.currentLevel}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${userProgress.experiencePoints} XP',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: gamificationViewModel.levelProgress,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              gamificationViewModel.levelProgress >= 0.8
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(gamificationViewModel.levelProgress * 100).round()}% to Level ${userProgress.currentLevel + 1}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Achievements
                  const Text(
                    'Recent Achievements',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (gamificationViewModel.userAchievements.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                              'Complete quizzes and lessons to earn achievements!'),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            gamificationViewModel.userAchievements.length,
                        itemBuilder: (context, index) {
                          final achievement =
                              gamificationViewModel.userAchievements[index];
                          return Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.emoji_events,
                                      color: Colors.amber,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      achievement.title,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ] else
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text('Sign in to track your progress!'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardsTab() {
    return Consumer<GamificationViewModel>(
      builder: (context, gamificationViewModel, child) {
        // Load leaderboard when tab is opened
        if (gamificationViewModel.leaderboard.isEmpty &&
            !gamificationViewModel.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            gamificationViewModel.loadLeaderboard(limit: 20);
          });
        }

        return RefreshIndicator(
          onRefresh: () async {
            await gamificationViewModel.loadLeaderboard(limit: 20);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Leaderboards',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (gamificationViewModel.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (gamificationViewModel.leaderboard.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                            'No leaderboard data available yet. Complete some quizzes to get started!'),
                      ),
                    ),
                  )
                else ...[
                  // Top 3 Podium
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 2nd Place
                      if (gamificationViewModel.leaderboard.length >= 2)
                        _buildPodiumItem(
                          gamificationViewModel.leaderboard[1],
                          2,
                          height: 80,
                          color: Colors.grey,
                        ),
                      const SizedBox(width: 8),

                      // 1st Place
                      if (gamificationViewModel.leaderboard.isNotEmpty)
                        _buildPodiumItem(
                          gamificationViewModel.leaderboard[0],
                          1,
                          height: 100,
                          color: Colors.amber,
                        ),

                      const SizedBox(width: 8),

                      // 3rd Place
                      if (gamificationViewModel.leaderboard.length >= 3)
                        _buildPodiumItem(
                          gamificationViewModel.leaderboard[2],
                          3,
                          height: 60,
                          color: Colors.brown,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Full Leaderboard
                  const Text(
                    'Full Rankings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Show current user rank prominently if they're not in top 3
                  Consumer<AuthViewModel>(
                    builder: (context, authViewModel, child) {
                      final currentUserId = authViewModel.currentUser?.id;
                      final currentUserEntry = gamificationViewModel.leaderboard
                          .where((entry) => entry.userId == currentUserId)
                          .firstOrNull;

                      if (currentUserEntry != null &&
                          currentUserEntry.rank > 3) {
                        return Column(
                          children: [
                            Card(
                              color: Colors.blue.shade50,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    '${currentUserEntry.rank}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: const Text(
                                  'Your Rank',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle:
                                    Text('${currentUserEntry.totalPoints} XP'),
                                trailing:
                                    const Icon(Icons.star, color: Colors.blue),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Top Players',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: gamificationViewModel.leaderboard.length,
                    itemBuilder: (context, index) {
                      final entry = gamificationViewModel.leaderboard[index];
                      final isCurrentUser = entry.userId ==
                          context.read<AuthViewModel>().currentUser?.id;

                      return Card(
                        elevation: isCurrentUser ? 4 : 1,
                        color: isCurrentUser ? Colors.blue.shade50 : null,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getRankColor(entry.rank),
                            child: Text(
                              '${entry.rank}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            entry.userName,
                            style: TextStyle(
                              fontWeight: isCurrentUser
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text('${entry.totalPoints} XP'),
                          trailing: Icon(
                            isCurrentUser ? Icons.person : Icons.star,
                            color: isCurrentUser ? Colors.blue : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPodiumItem(dynamic entry, int position,
      {required double height, required Color color}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: color,
          child: Text(
            entry.userName.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3 * 255),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${entry.totalPoints}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Text(
                'XP',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '#$position',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  void _showComingSoonDialog(BuildContext context, String gameName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$gameName - Coming Soon'),
        content: const Text(
            'This game is currently under development. Check back soon for updates!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
