import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/social_viewmodel.dart';

/// View for managing study groups
class StudyGroupsView extends StatefulWidget {
  const StudyGroupsView({Key? key}) : super(key: key);

  @override
  State<StudyGroupsView> createState() => _StudyGroupsViewState();
}

class _StudyGroupsViewState extends State<StudyGroupsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groupes d\'Étude'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to create group
            },
          ),
        ],
      ),
      body: Consumer<SocialViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // Search and filter
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher des groupes...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (query) {
                    // TODO: Implement search
                  },
                ),
              ),

              // Language filter chips
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildLanguageChip('Tous', true),
                    _buildLanguageChip('Français', false),
                    _buildLanguageChip('Anglais', false),
                    _buildLanguageChip('Espagnol', false),
                    _buildLanguageChip('Allemand', false),
                  ],
                ),
              ),

              // Groups list
              Expanded(
                child: ListView.builder(
                  itemCount: 5, // TODO: Use actual data
                  itemBuilder: (context, index) {
                    return _buildGroupCard();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLanguageChip(String language, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(language),
        selected: isSelected,
        onSelected: (selected) {
          // TODO: Implement language filtering
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        checkmarkColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildGroupCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor:
                      Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  child: const Icon(Icons.group, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Groupe d\'étude Français', // TODO: Use actual data
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Apprendre le français ensemble', // TODO: Use actual data
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Join group
                  },
                  child: const Text('Rejoindre'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildGroupStat('Membres', '12'),
                const SizedBox(width: 16),
                _buildGroupStat('Langue', 'Français'),
                const SizedBox(width: 16),
                _buildGroupStat('Niveau', 'Intermédiaire'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Réunion hebdomadaire le mardi',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
