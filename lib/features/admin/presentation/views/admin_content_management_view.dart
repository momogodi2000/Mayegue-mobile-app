import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/user_role.dart';
import '../viewmodels/admin_content_management_viewmodel.dart';
import '../widgets/content_moderation_card.dart';
import '../widgets/content_statistics_widget.dart';
import '../widgets/content_creation_dialog.dart';

/// Admin panel for comprehensive content management
class AdminContentManagementView extends StatefulWidget {
  const AdminContentManagementView({super.key});

  @override
  State<AdminContentManagementView> createState() =>
      _AdminContentManagementViewState();
}

class _AdminContentManagementViewState extends State<AdminContentManagementView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AdminContentManagementViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _viewModel = context.read<AdminContentManagementViewModel>();
    _viewModel.initialize();
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
        title: const Text('Gestion de Contenu'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showCreateContentDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Créer du contenu',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_data',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Exporter les données'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import_data',
                child: Row(
                  children: [
                    Icon(Icons.upload),
                    SizedBox(width: 8),
                    Text('Importer des données'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'backup',
                child: Row(
                  children: [
                    Icon(Icons.backup),
                    SizedBox(width: 8),
                    Text('Sauvegarde'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Paramètres'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Aperçu'),
            Tab(icon: Icon(Icons.book), text: 'Dictionnaire'),
            Tab(icon: Icon(Icons.school), text: 'Leçons'),
            Tab(icon: Icon(Icons.games), text: 'Jeux'),
            Tab(icon: Icon(Icons.people), text: 'Utilisateurs'),
            Tab(icon: Icon(Icons.gavel), text: 'Modération'),
          ],
        ),
      ),
      body: Consumer<AdminContentManagementViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des données...'),
                ],
              ),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(viewModel.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.refresh(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(viewModel),
              _buildDictionaryTab(viewModel),
              _buildLessonsTab(viewModel),
              _buildGamesTab(viewModel),
              _buildUsersTab(viewModel),
              _buildModerationTab(viewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(AdminContentManagementViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'Entrées Dictionnaire',
                  viewModel.contentStatistics.dictionaryEntries.toString(),
                  Icons.book,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Leçons Actives',
                  viewModel.contentStatistics.activeLessons.toString(),
                  Icons.school,
                  Colors.green,
                ),
                _buildStatCard(
                  'Utilisateurs Actifs',
                  viewModel.contentStatistics.activeUsers.toString(),
                  Icons.people,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Contenus en Attente',
                  viewModel.contentStatistics.pendingModerations.toString(),
                  Icons.pending,
                  Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Activity
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history),
                        const SizedBox(width: 8),
                        Text(
                          'Activité Récente',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...viewModel.recentActivities
                        .take(5)
                        .map((activity) => _buildActivityItem(activity)),
                    if (viewModel.recentActivities.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Aucune activité récente'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Content Statistics Widget
            ContentStatisticsWidget(statistics: viewModel.contentStatistics),
          ],
        ),
      ),
    );
  }

  Widget _buildDictionaryTab(AdminContentManagementViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refreshDictionaryContent(),
      child: Column(
        children: [
          // Dictionary management header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Rechercher dans le dictionnaire...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: viewModel.searchDictionaryContent,
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: viewModel.selectedLanguageFilter,
                  hint: const Text('Langue'),
                  items: [
                    'Toutes',
                    'Ewondo',
                    'Duala',
                    'Fe\'efe\'e',
                    'Fulfulde',
                    'Bassa',
                    'Bamum'
                  ]
                      .map((lang) =>
                          DropdownMenuItem(value: lang, child: Text(lang)))
                      .toList(),
                  onChanged: viewModel.setLanguageFilter,
                ),
              ],
            ),
          ),

          // Dictionary entries list
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.filteredDictionaryEntries.length,
              itemBuilder: (context, index) {
                final entry = viewModel.filteredDictionaryEntries[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getLanguageColor(entry.languageCode),
                      child: Text(
                        entry.languageCode.substring(0, 2).toUpperCase(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    title: Text(entry.canonicalForm),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Traduction: ${entry.translations.values.first}'),
                        Text('Statut: ${entry.reviewStatus.name}'),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) =>
                          _handleDictionaryAction(action, entry.id),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'edit', child: Text('Modifier')),
                        const PopupMenuItem(
                            value: 'approve', child: Text('Approuver')),
                        const PopupMenuItem(
                            value: 'reject', child: Text('Rejeter')),
                        const PopupMenuItem(
                            value: 'delete', child: Text('Supprimer')),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsTab(AdminContentManagementViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refreshLessonsContent(),
      child: Column(
        children: [
          // Lessons management header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Rechercher des leçons...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: viewModel.searchLessonsContent,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showCreateLessonDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Nouvelle Leçon'),
                ),
              ],
            ),
          ),

          // Lessons list
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.filteredLessons.length,
              itemBuilder: (context, index) {
                final lesson = viewModel.filteredLessons[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ExpansionTile(
                    leading: Icon(
                      Icons.school,
                      color: _getLevelColor(lesson.difficulty),
                    ),
                    title: Text(lesson.title),
                    subtitle: Text('${lesson.language} • ${lesson.difficulty}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Description: ${lesson.description}'),
                            const SizedBox(height: 8),
                            Text('Durée estimée: ${lesson.duration} min'),
                            const SizedBox(height: 8),
                            Text('Créée le: ${_formatDate(lesson.createdAt)}'),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _editLesson(lesson.id),
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Modifier'),
                                ),
                                TextButton.icon(
                                  onPressed: () => _duplicateLesson(lesson.id),
                                  icon: const Icon(Icons.copy),
                                  label: const Text('Dupliquer'),
                                ),
                                TextButton.icon(
                                  onPressed: () => _deleteLesson(lesson.id),
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Supprimer'),
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.red),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesTab(AdminContentManagementViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refreshGamesContent(),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.games, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Gestion des jeux'),
            Text('Fonctionnalité à venir'),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab(AdminContentManagementViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refreshUsersContent(),
      child: Column(
        children: [
          // Users management header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Rechercher des utilisateurs...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: viewModel.searchUsers,
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: viewModel.selectedRoleFilter,
                  hint: const Text('Rôle'),
                  items: ['Tous', 'Learner', 'Teacher', 'Admin']
                      .map((role) =>
                          DropdownMenuItem(value: role, child: Text(role)))
                      .toList(),
                  onChanged: viewModel.setRoleFilter,
                ),
              ],
            ),
          ),

          // Users list
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.filteredUsers.length,
              itemBuilder: (context, index) {
                final user = viewModel.filteredUsers[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null
                          ? Text(
                              user.displayName?.substring(0, 1).toUpperCase() ??
                                  'U')
                          : null,
                    ),
                    title: Text(user.displayName ?? 'Utilisateur'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${user.email}'),
                        Text('Rôle: ${user.role}'),
                        Text('Inscrit le: ${_formatDate(user.createdAt)}'),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) =>
                          _handleUserAction(action, user.id),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'view', child: Text('Voir le profil')),
                        const PopupMenuItem(
                            value: 'change_role',
                            child: Text('Changer le rôle')),
                        const PopupMenuItem(
                            value: 'suspend', child: Text('Suspendre')),
                        const PopupMenuItem(
                            value: 'delete', child: Text('Supprimer')),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModerationTab(AdminContentManagementViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.refreshModerationContent(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.pendingModerations.length,
        itemBuilder: (context, index) {
          final moderation = viewModel.pendingModerations[index];
          return ContentModerationCard(
            moderation: moderation,
            onApprove: () => viewModel.approveModerationItem(moderation.id),
            onReject: (reason) =>
                viewModel.rejectModerationItem(moderation.id, reason),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(AdminActivity activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            _getActivityIcon(activity.type),
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              activity.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            _formatTime(activity.timestamp),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  void _showCreateContentDialog() {
    showDialog(
      context: context,
      builder: (context) => const ContentCreationDialog(),
    );
  }

  void _showCreateLessonDialog() {
    // Implement lesson creation dialog
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export_data':
        _viewModel.exportData();
        break;
      case 'import_data':
        _viewModel.importData();
        break;
      case 'backup':
        _viewModel.createBackup();
        break;
      case 'settings':
        // Navigate to settings
        break;
    }
  }

  void _handleDictionaryAction(String action, String entryId) {
    switch (action) {
      case 'edit':
        _viewModel.editDictionaryEntry(entryId);
        break;
      case 'approve':
        _viewModel.approveDictionaryEntry(entryId);
        break;
      case 'reject':
        _viewModel.rejectDictionaryEntry(entryId);
        break;
      case 'delete':
        _viewModel.deleteDictionaryEntry(entryId);
        break;
    }
  }

  void _handleUserAction(String action, String userId) {
    switch (action) {
      case 'view':
        _viewModel.viewUserProfile(userId);
        break;
      case 'change_role':
        _showChangeRoleDialog(userId);
        break;
      case 'suspend':
        _viewModel.suspendUser(userId);
        break;
      case 'delete':
        _viewModel.deleteUser(userId);
        break;
    }
  }

  void _showChangeRoleDialog(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le rôle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values
              .map((role) => RadioListTile<UserRole>(
                    title: Text(role.displayName),
                    value: role,
                    groupValue: null, // Current user role would go here
                    onChanged: (newRole) {
                      if (newRole != null) {
                        Navigator.of(context).pop();
                        _viewModel.changeUserRole(userId, newRole);
                      }
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _editLesson(String lessonId) {
    // Implement lesson editing
  }

  void _duplicateLesson(String lessonId) {
    _viewModel.duplicateLesson(lessonId);
  }

  void _deleteLesson(String lessonId) {
    _viewModel.deleteLesson(lessonId);
  }

  Color _getLanguageColor(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'ewondo':
        return Colors.blue;
      case 'duala':
        return Colors.green;
      case 'feefee':
        return Colors.orange;
      case 'fulfulde':
        return Colors.purple;
      case 'bassa':
        return Colors.red;
      case 'bamum':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(AdminActivityType type) {
    switch (type) {
      case AdminActivityType.userRegistration:
        return Icons.person_add;
      case AdminActivityType.contentCreation:
        return Icons.create;
      case AdminActivityType.contentModeration:
        return Icons.gavel;
      case AdminActivityType.systemUpdate:
        return Icons.system_update;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}j';
    }
  }
}

/// Temporary models - these should be moved to appropriate domain files
