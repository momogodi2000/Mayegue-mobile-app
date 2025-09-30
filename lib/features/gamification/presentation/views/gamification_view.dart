import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/gamification_viewmodel.dart';
import '../widgets/progress_card.dart';
import '../widgets/achievements_widget.dart';
import '../widgets/leaderboard_widget.dart';

class GamificationView extends StatefulWidget {
  final String userId;

  const GamificationView({
    super.key,
    required this.userId,
  });

  @override
  State<GamificationView> createState() => _GamificationViewState();
}

class _GamificationViewState extends State<GamificationView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load data when view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<GamificationViewModel>();
      viewModel.loadUserProgress(widget.userId);
      viewModel.loadUserAchievements(widget.userId);
      viewModel.loadLeaderboard();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GamificationViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gamification'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Progression', icon: Icon(Icons.trending_up)),
            Tab(text: 'Succès', icon: Icon(Icons.emoji_events)),
            Tab(text: 'Classement', icon: Icon(Icons.leaderboard)),
            Tab(text: 'Boutique', icon: Icon(Icons.shop)),
          ],
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          viewModel.loadUserProgress(widget.userId);
                          viewModel.loadUserAchievements(widget.userId);
                          viewModel.loadLeaderboard();
                        },
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Progression tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: ProgressCard(
                        userProgress: viewModel.userProgress,
                        levelProgress: viewModel.levelProgress,
                      ),
                    ),

                    // Achievements tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: AchievementsWidget(
                        achievements: viewModel.userAchievements,
                      ),
                    ),

                    // Leaderboard tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: LeaderboardWidget(
                        leaderboard: viewModel.leaderboard,
                        currentUserId: widget.userId,
                      ),
                    ),

                    // Shop tab
                    const Center(
                      child: Text('Boutique - Coming Soon'),
                    ),
                  ],
                ),
    );
  }
}
