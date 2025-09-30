import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/social_viewmodel.dart';
import '../widgets/user_profile_card.dart';
import '../widgets/progress_share_card.dart';
import 'study_groups_view.dart';

/// Social view for user profiles and following
class SocialView extends StatefulWidget {
  const SocialView({Key? key}) : super(key: key);

  @override
  State<SocialView> createState() => _SocialViewState();
}

class _SocialViewState extends State<SocialView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communauté'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Découvrir'),
            Tab(text: 'Suivis'),
            Tab(text: 'Progression'),
            Tab(text: 'Groupes'),
            Tab(text: 'Profil'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiscoverTab(),
          _buildFollowingTab(),
          _buildProgressTab(),
          _buildStudyGroupsTab(),
          _buildProfileTab(),
        ],
      ),
    );
  }

  Widget _buildDiscoverTab() {
    return Consumer<SocialViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher des utilisateurs...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onSubmitted: (query) {
                  // TODO: Implement search
                },
              ),
            ),

            // Users list
            Expanded(
              child: viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : viewModel.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error,
                                  size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text('Erreur: ${viewModel.error}'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => viewModel.refreshUsers(),
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: viewModel.users.length,
                          itemBuilder: (context, index) {
                            final user = viewModel.users[index];
                            return UserProfileCard(user: user);
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressTab() {
    return Consumer<SocialViewModel>(
      builder: (context, viewModel, child) {
        return RefreshIndicator(
          onRefresh: () async {
            // TODO: Refresh progress feed
          },
          child: viewModel.progressFeed.isEmpty
              ? const Center(
                  child: Text('Aucun progrès partagé pour le moment'),
                )
              : ListView.builder(
                  itemCount: viewModel.progressFeed.length,
                  itemBuilder: (context, index) {
                    final progressItem = viewModel.progressFeed[index];
                    return ProgressShareCard(
                      progressData: progressItem,
                      onLikePressed: () {
                        // TODO: Implement like functionality
                      },
                      onCommentPressed: () {
                        // TODO: Implement comment functionality
                      },
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildStudyGroupsTab() {
    return const StudyGroupsView();
  }

  Widget _buildFollowingTab() {
    return Consumer<SocialViewModel>(
      builder: (context, viewModel, child) {
        return RefreshIndicator(
          onRefresh: () async {
            // TODO: Refresh following list
          },
          child: viewModel.following.isEmpty
              ? const Center(
                  child: Text('Vous ne suivez personne encore'),
                )
              : ListView.builder(
                  itemCount: viewModel.following.length,
                  itemBuilder: (context, index) {
                    final user = viewModel.following[index];
                    return UserProfileCard(
                      user: user,
                      isFollowing: true,
                      onUnfollowPressed: () {
                        // TODO: Implement unfollow
                      },
                      showFollowButton: true,
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Consumer<SocialViewModel>(
      builder: (context, viewModel, child) {
        final user = viewModel.currentUserProfile;

        if (user == null) {
          return const Center(
            child: Text('Profil non chargé'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user.avatar != null
                          ? NetworkImage(user.avatar!)
                          : null,
                      child: user.avatar == null
                          ? Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  fontSize: 36, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user.bio != null && user.bio!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        user.bio!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildProfileStat('Posts', user.postsCount),
                  _buildProfileStat('Suiveurs', viewModel.followers.length),
                  _buildProfileStat('Suivis', viewModel.following.length),
                  _buildProfileStat('Réputation', user.reputation),
                ],
              ),

              const SizedBox(height: 32),

              // Languages
              const Text(
                'Langues',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: user.languages.map((language) {
                  return Chip(
                    label: Text(language),
                    backgroundColor:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  );
                }).toList(),
              ),

              if (user.location != null && user.location!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 8),
                    Text(user.location!),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // Edit profile button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to edit profile
                  },
                  child: const Text('Modifier le profil'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileStat(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
