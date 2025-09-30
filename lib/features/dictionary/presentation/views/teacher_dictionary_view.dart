import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/teacher_dictionary_viewmodel.dart';
import 'teacher_dictionary_entry_form.dart';
import '../../../../shared/themes/colors.dart';
import '../../../../shared/widgets/common/error_widget.dart' as custom_error;
import '../../../../shared/widgets/common/loading_widget.dart';

/// Main view for teachers to manage dictionary entries
class TeacherDictionaryView extends StatefulWidget {
  const TeacherDictionaryView({super.key});

  @override
  State<TeacherDictionaryView> createState() => _TeacherDictionaryViewState();
}

class _TeacherDictionaryViewState extends State<TeacherDictionaryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load user entries when the view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherDictionaryViewModel>().loadUserEntries();
    });
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
        title: const Text('Gestion du Dictionnaire'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mes entrées', icon: Icon(Icons.list)),
            Tab(text: 'Nouvelle entrée', icon: Icon(Icons.add)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TeacherDictionaryViewModel>().loadUserEntries();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEntriesList(),
          _buildNewEntryForm(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () => _tabController.animateTo(1),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildEntriesList() {
    return Consumer<TeacherDictionaryViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const LoadingWidget();
        }

        if (viewModel.errorMessage != null && viewModel.userEntries.isEmpty) {
          return custom_error.ErrorWidget(
            title: 'Erreur',
            message: viewModel.errorMessage!,
            onRetry: () => viewModel.loadUserEntries(),
          );
        }

        if (viewModel.userEntries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.book_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Aucune entrée trouvée',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Commencez par ajouter votre première entrée',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await viewModel.loadUserEntries();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.userEntries.length,
            itemBuilder: (context, index) {
              final entry = viewModel.userEntries[index];
              return _buildEntryCard(entry);
            },
          ),
        );
      },
    );
  }

  Widget _buildNewEntryForm() {
    return const TeacherDictionaryEntryForm();
  }

  Widget _buildEntryCard(entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.canonicalForm,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _editEntry(entry);
                        break;
                      case 'delete':
                        _deleteEntry(entry);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Supprimer',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (entry.pronunciation != null) ...[
              Text(
                'Prononciation: ${entry.pronunciation}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              'Classe: ${entry.partOfSpeech.name}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Niveau: ${entry.difficultyLevel.name}',
              style: const TextStyle(fontSize: 14),
            ),
            if (entry.translations.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Traductions:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              ...entry.translations.entries.take(3).map((translation) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 2),
                  child: Text(
                    '• ${translation.key}: ${translation.value}',
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }),
              if (entry.translations.length > 3)
                Text(
                  '... et ${entry.translations.length - 3} autres',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Modifié le ${_formatDate(entry.lastUpdated)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(entry.reviewStatus),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(entry.reviewStatus),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
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

  void _editEntry(entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TeacherDictionaryEntryForm(editingEntry: entry),
      ),
    );
  }

  void _deleteEntry(entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer l\'entrée "${entry.canonicalForm}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              context.read<TeacherDictionaryViewModel>().deleteEntry(entry.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Entrée supprimée avec succès'),
                ),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(status) {
    switch (status.toString()) {
      case 'ReviewStatus.approved':
        return Colors.green;
      case 'ReviewStatus.pending':
        return Colors.orange;
      case 'ReviewStatus.rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(status) {
    switch (status.toString()) {
      case 'ReviewStatus.approved':
        return 'Approuvé';
      case 'ReviewStatus.pending':
        return 'En attente';
      case 'ReviewStatus.rejected':
        return 'Rejeté';
      default:
        return 'Inconnu';
    }
  }
}
