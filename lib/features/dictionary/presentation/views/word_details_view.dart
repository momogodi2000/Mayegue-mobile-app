import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../viewmodels/dictionary_viewmodel.dart';
import '../../domain/entities/word_entity.dart';

/// View for displaying detailed information about a word
class WordDetailsView extends StatefulWidget {
  final String wordId;

  const WordDetailsView({
    super.key,
    required this.wordId,
  });

  @override
  State<WordDetailsView> createState() => _WordDetailsViewState();
}

class _WordDetailsViewState extends State<WordDetailsView> {
  @override
  void initState() {
    super.initState();
    // Load translations when view opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DictionaryViewModel>().loadTranslations(widget.wordId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du mot'),
        elevation: 0,
      ),
      body: Consumer<DictionaryViewModel>(
        builder: (context, viewModel, child) {
          // Find the word in search results or we need to load it
          WordEntity? word;
          try {
            word = viewModel.searchResults
                .firstWhere((w) => w.id == widget.wordId);
          } catch (e) {
            try {
              word = viewModel.favoriteWords
                  .firstWhere((w) => w.id == widget.wordId);
            } catch (e) {
              word = null;
            }
          }

          if (word == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppDimensions.spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Word header
                _buildWordHeader(word, viewModel),
                SizedBox(height: AppDimensions.spacing),
                // Translations
                if (viewModel.isLoadingTranslations)
                  const Center(child: CircularProgressIndicator())
                else if (viewModel.translations.isNotEmpty)
                  _buildTranslationsSection(viewModel)
                else
                  _buildNoTranslationsView(),
                SizedBox(height: AppDimensions.spacing),
                // Additional information
                _buildAdditionalInfo(word),
                SizedBox(height: AppDimensions.spacing),
                // Actions
                _buildActions(word, viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWordHeader(WordEntity word, DictionaryViewModel viewModel) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word and language
            Row(
              children: [
                Expanded(
                  child: Text(
                    word.word,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacing / 2,
                    vertical: AppDimensions.spacing / 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadius / 2),
                  ),
                  child: Text(
                    viewModel.getLanguageName(word.language),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.spacing / 2),
            // Translation
            Text(
              word.translation,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.color
                        ?.withValues(alpha: 0.8),
                  ),
            ),
            // Pronunciation
            if (word.pronunciation != null &&
                word.pronunciation!.isNotEmpty) ...[
              SizedBox(height: AppDimensions.spacing / 2),
              Row(
                children: [
                  Icon(
                    Icons.volume_up,
                    size: 16,
                    color: Theme.of(context).disabledColor,
                  ),
                  SizedBox(width: AppDimensions.spacing / 4),
                  Text(
                    word.pronunciation!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ],
            // Phonetic
            if (word.phonetic != null && word.phonetic!.isNotEmpty) ...[
              SizedBox(height: AppDimensions.spacing / 4),
              Text(
                '/${word.phonetic}/',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationsSection(DictionaryViewModel viewModel) {
    // Group translations by language
    final translationsByLanguage = <String, List<dynamic>>{};
    for (final translation in viewModel.translations) {
      if (!translationsByLanguage.containsKey(translation.targetLanguage)) {
        translationsByLanguage[translation.targetLanguage] = [];
      }
      translationsByLanguage[translation.targetLanguage]!.add(translation);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Traductions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: AppDimensions.spacing),
        ...translationsByLanguage.entries.map((entry) {
          final languageCode = entry.key;
          final translations = entry.value;

          return Card(
            margin: EdgeInsets.only(bottom: AppDimensions.spacing / 2),
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.spacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language header
                  Row(
                    children: [
                      Text(
                        viewModel.getLanguageName(languageCode),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      SizedBox(width: AppDimensions.spacing / 2),
                      Text(
                        '(${viewModel.getNativeLanguageName(languageCode)})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).disabledColor,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.spacing / 2),
                  // Translation list
                  ...translations.map((translation) {
                    return Padding(
                      padding:
                          EdgeInsets.only(bottom: AppDimensions.spacing / 4),
                      child: Row(
                        children: [
                          if (translation.isPrimary)
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                          if (translation.isPrimary)
                            SizedBox(width: AppDimensions.spacing / 4),
                          Expanded(
                            child: Text(
                              translation.translation,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNoTranslationsView() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.spacing),
        child: Column(
          children: [
            Icon(
              Icons.translate,
              size: 48,
              color: Theme.of(context).disabledColor,
            ),
            SizedBox(height: AppDimensions.spacing / 2),
            Text(
              'Aucune traduction disponible',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: AppDimensions.spacing / 4),
            Text(
              'Les traductions pour ce mot seront ajoutées prochainement.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(WordEntity word) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations supplémentaires',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppDimensions.spacing),
        Card(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.spacing),
            child: Column(
              children: [
                // Category
                if (word.category.isNotEmpty) ...[
                  _buildInfoRow('Catégorie', _capitalizeFirst(word.category)),
                  SizedBox(height: AppDimensions.spacing / 2),
                ],
                // Difficulty
                _buildInfoRow('Difficulté', '${word.difficulty}/5'),
                // Synonyms
                if (word.synonyms.isNotEmpty) ...[
                  SizedBox(height: AppDimensions.spacing / 2),
                  _buildInfoRow('Synonymes', word.synonyms.join(', ')),
                ],
                // Antonyms
                if (word.antonyms.isNotEmpty) ...[
                  SizedBox(height: AppDimensions.spacing / 2),
                  _buildInfoRow('Antonymes', word.antonyms.join(', ')),
                ],
                // Definition
                if (word.definition != null && word.definition!.isNotEmpty) ...[
                  SizedBox(height: AppDimensions.spacing / 2),
                  _buildInfoRow('Définition', word.definition!),
                ],
                // Example
                if (word.example != null && word.example!.isNotEmpty) ...[
                  SizedBox(height: AppDimensions.spacing / 2),
                  _buildInfoRow('Exemple', '"${word.example}"'),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(WordEntity word, DictionaryViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: AppDimensions.spacing),
        Row(
          children: [
            // Favorite button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement favorite toggle
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fonctionnalité à venir')),
                  );
                },
                icon: const Icon(Icons.favorite_border),
                label: const Text('Ajouter aux favoris'),
              ),
            ),
            SizedBox(width: AppDimensions.spacing),
            // Share button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement share
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fonctionnalité à venir')),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Partager'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
