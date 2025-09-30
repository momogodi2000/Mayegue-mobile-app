import 'package:flutter/material.dart';
import '../../domain/entities/dictionary_entry_entity.dart';
import '../../domain/entities/word_entity.dart';
import '../../../../shared/themes/dimensions.dart';

/// Widget to display a dictionary word entry in a card format
class DictionaryWordCard extends StatelessWidget {
  final dynamic word; // Accepts both WordEntity and DictionaryEntryEntity
  final VoidCallback? onTap;
  final bool showLanguage;
  final bool showPronunciation;
  final bool showTranslations;

  const DictionaryWordCard({
    super.key,
    required this.word,
    this.onTap,
    this.showLanguage = true,
    this.showPronunciation = true,
    this.showTranslations = true,
  });

  @override
  Widget build(BuildContext context) {
    // Support both WordEntity and DictionaryEntryEntity
    final String displayWord = word is WordEntity
        ? (word as WordEntity).word
        : (word as DictionaryEntryEntity).canonicalForm;

    final String displayLanguage = word is WordEntity
        ? (word as WordEntity).language
        : (word as DictionaryEntryEntity).languageCode;

    final String? displayPronunciation = word is WordEntity
        ? (word as WordEntity).pronunciation
        : (word as DictionaryEntryEntity).ipa;

    final String displayPartOfSpeech = word is WordEntity
        ? (word as WordEntity).category
        : (word as DictionaryEntryEntity).partOfSpeech;

    final Map<String, String> displayTranslations = word is WordEntity
        ? {'translation': (word as WordEntity).translation}
        : (word as DictionaryEntryEntity).translations;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing / 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacing),
          child: Row(
            children: [
              // Word content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Word and language
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayWord,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        if (showLanguage) ...[
                          const SizedBox(width: AppDimensions.spacing / 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacing / 2,
                              vertical: AppDimensions.spacing / 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.borderRadius / 2),
                            ),
                            child: Text(
                              displayLanguage.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacing / 4),
                    // Pronunciation
                    if (showPronunciation && displayPronunciation != null) ...[
                      Text(
                        '/$displayPronunciation/',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                      const SizedBox(height: AppDimensions.spacing / 4),
                    ],
                    // Part of speech / category
                    if (displayPartOfSpeech.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing / 2,
                          vertical: AppDimensions.spacing / 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadius / 2),
                        ),
                        child: Text(
                          displayPartOfSpeech,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    if (showTranslations && displayTranslations.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.spacing / 2),
                      Text(
                        'Traductions:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: AppDimensions.spacing / 4),
                      ...displayTranslations.entries.take(2).map((translation) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: AppDimensions.spacing / 2),
                          child: Text(
                            '• ${translation.key}: ${translation.value}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      }),
                      if (displayTranslations.length > 2)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: AppDimensions.spacing / 2),
                          child: Text(
                            '... et ${displayTranslations.length - 2} autres',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic,
                                    ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              // Action button
              if (onTap != null) ...[
                const SizedBox(width: AppDimensions.spacing / 2),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
