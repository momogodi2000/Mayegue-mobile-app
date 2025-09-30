import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/dictionary_entry_entity.dart';
import '../viewmodels/teacher_review_viewmodel.dart';
import '../../../../shared/themes/colors.dart';

/// Teacher dashboard for reviewing AI-suggested dictionary entries
class TeacherReviewView extends StatefulWidget {
  const TeacherReviewView({super.key});

  @override
  State<TeacherReviewView> createState() => _TeacherReviewViewState();
}

class _TeacherReviewViewState extends State<TeacherReviewView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherReviewViewModel>().loadPendingEntries();
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
        title: const Text('Révision du Dictionnaire'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Suggestions IA', icon: Icon(Icons.auto_awesome)),
            Tab(text: 'En attente', icon: Icon(Icons.pending)),
            Tab(text: 'Statistiques', icon: Icon(Icons.analytics)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TeacherReviewViewModel>().refresh(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAiSuggestionsTab(),
          _buildPendingReviewTab(),
          _buildStatisticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBulkActionsDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.batch_prediction),
      ),
    );
  }

  Widget _buildAiSuggestionsTab() {
    return Consumer<TeacherReviewViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.aiSuggestedEntries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Aucune suggestion IA disponible',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text('Les nouvelles suggestions apparaîtront ici'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _requestAiSuggestions(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Demander des suggestions'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: viewModel.aiSuggestedEntries.length,
          itemBuilder: (context, index) {
            final entry = viewModel.aiSuggestedEntries[index];
            return _buildEntryCard(entry, viewModel, isAiSuggested: true);
          },
        );
      },
    );
  }

  Widget _buildPendingReviewTab() {
    return Consumer<TeacherReviewViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.pendingEntries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 64, color: Colors.green),
                const SizedBox(height: 16),
                Text(
                  'Toutes les entrées sont révisées!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text('Bon travail!'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: viewModel.pendingEntries.length,
          itemBuilder: (context, index) {
            final entry = viewModel.pendingEntries[index];
            return _buildEntryCard(entry, viewModel, isAiSuggested: false);
          },
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    return Consumer<TeacherReviewViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatisticsCard(
                'Révisions aujourd\'hui',
                '${viewModel.todayReviews}',
                Icons.today,
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildStatisticsCard(
                'Total vérifié',
                '${viewModel.totalVerified}',
                Icons.verified,
                Colors.green,
              ),
              const SizedBox(height: 16),
              _buildStatisticsCard(
                'En attente',
                '${viewModel.totalPending}',
                Icons.pending,
                Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildStatisticsCard(
                'Suggestions IA',
                '${viewModel.totalAiSuggested}',
                Icons.auto_awesome,
                Colors.purple,
              ),
              const SizedBox(height: 24),
              Text(
                'Progression par langue',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...viewModel.languageProgress.entries.map(
                (entry) => _buildLanguageProgressCard(entry.key, entry.value),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEntryCard(
    DictionaryEntryEntity entry,
    TeacherReviewViewModel viewModel, {
    required bool isAiSuggested,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.canonicalForm,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${entry.languageCode.toUpperCase()} • ${entry.partOfSpeech}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAiSuggested ? Colors.purple[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAiSuggested ? 'IA' : 'En attente',
                    style: TextStyle(
                      color: isAiSuggested ? Colors.purple[800] : Colors.orange[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (entry.ipa != null) ...[
              Text('IPA: ${entry.ipa}'),
              const SizedBox(height: 8),
            ],
            if (entry.translations.isNotEmpty) ...[
              Text(
                'Traductions:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: entry.translations.entries.map((translation) {
                  return Chip(
                    label: Text('${translation.key}: ${translation.value}'),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
            if (entry.exampleSentences.isNotEmpty) ...[
              Text(
                'Exemples:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              ...entry.exampleSentences.take(2).map((example) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• ${example.sentence}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
            if (isAiSuggested) ...[
              Row(
                children: [
                  const Icon(Icons.psychology, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Confiance IA: ${(entry.qualityScore * 100).toInt()}%',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: viewModel.isProcessing
                        ? null
                        : () => _showRejectionDialog(context, entry, viewModel),
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('Rejeter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: viewModel.isProcessing
                        ? null
                        : () => _showEditDialog(context, entry, viewModel),
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: viewModel.isProcessing
                        ? null
                        : () => viewModel.approveEntry(entry.id),
                    icon: const Icon(Icons.check),
                    label: const Text('Approuver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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

  Widget _buildStatisticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageProgressCard(String language, Map<String, int> progress) {
    final total = progress.values.fold(0, (sum, count) => sum + count);
    final verified = progress['verified'] ?? 0;
    final percentage = total > 0 ? (verified / total * 100).toInt() : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: total > 0 ? verified / total : 0,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              '$verified vérifié(s) sur $total entrée(s)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _requestAiSuggestions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demander des suggestions IA'),
        content: const Text(
          'Voulez-vous générer de nouvelles suggestions de vocabulaire avec l\'IA ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TeacherReviewViewModel>().generateAiSuggestions();
            },
            child: const Text('Générer'),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(
    BuildContext context,
    DictionaryEntryEntity entry,
    TeacherReviewViewModel viewModel,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeter l\'entrée'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rejeter "${entry.canonicalForm}" ?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Raison du rejet',
                hintText: 'Expliquez pourquoi cette entrée est rejetée...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.rejectEntry(entry.id, reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    DictionaryEntryEntity entry,
    TeacherReviewViewModel viewModel,
  ) {
    // Navigate to edit view
    Navigator.of(context).pushNamed(
      '/edit-dictionary-entry',
      arguments: entry,
    );
  }

  void _showBulkActionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actions en lot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_box),
              title: const Text('Approuver toutes les suggestions IA fiables'),
              subtitle: const Text('Confiance > 80%'),
              onTap: () {
                Navigator.of(context).pop();
                context.read<TeacherReviewViewModel>().bulkApproveHighConfidence();
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Générer vocabulaire pour toutes les langues'),
              onTap: () {
                Navigator.of(context).pop();
                context.read<TeacherReviewViewModel>().generateVocabularyForAllLanguages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Exporter données révisées'),
              onTap: () {
                Navigator.of(context).pop();
                context.read<TeacherReviewViewModel>().exportReviewedData();
              },
            ),
          ],
        ),
      ),
    );
  }
}