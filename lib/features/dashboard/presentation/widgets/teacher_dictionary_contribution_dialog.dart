import 'package:flutter/material.dart';
import '../../../../core/constants/supported_languages.dart';
import '../../../dictionary/domain/entities/dictionary_entry_entity.dart';
import '../../../dictionary/data/models/dictionary_entry_model.dart';
import '../../../dictionary/data/datasources/lexicon_local_datasource.dart';

/// Dialog for teachers to contribute new dictionary entries
class TeacherDictionaryContributionDialog extends StatefulWidget {
  final Future<void> Function(DictionaryEntryEntity entry)? onCreateEntry;

  const TeacherDictionaryContributionDialog({
    super.key,
    this.onCreateEntry,
  });

  @override
  State<TeacherDictionaryContributionDialog> createState() =>
      _TeacherDictionaryContributionDialogState();
}

class _TeacherDictionaryContributionDialogState
    extends State<TeacherDictionaryContributionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _canonicalFormController = TextEditingController();
  final _ipaController = TextEditingController();
  final _partOfSpeechController = TextEditingController();
  final _translationController = TextEditingController();
  final _exampleSentenceController = TextEditingController();

  String _selectedLanguage = SupportedLanguages.defaultLanguage;
  DifficultyLevel _selectedDifficulty = DifficultyLevel.beginner;
  bool _isLoading = false;

  @override
  void dispose() {
    _canonicalFormController.dispose();
    _ipaController.dispose();
    _partOfSpeechController.dispose();
    _translationController.dispose();
    _exampleSentenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter une entrée au dictionnaire'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Language selection
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: const InputDecoration(
                  labelText: 'Langue',
                  border: OutlineInputBorder(),
                ),
                items: SupportedLanguages.languageCodes.map((language) {
                  return DropdownMenuItem(
                    value: language,
                    child: Text(SupportedLanguages.getDisplayName(language)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une langue';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Canonical form
              TextFormField(
                controller: _canonicalFormController,
                decoration: const InputDecoration(
                  labelText: 'Forme canonique',
                  hintText: 'Entrez le mot en écriture standard',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La forme canonique est requise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // IPA pronunciation
              TextFormField(
                controller: _ipaController,
                decoration: const InputDecoration(
                  labelText: 'Prononciation IPA (optionnel)',
                  hintText: '/pronɔsjasjɔ̃/',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Part of speech
              TextFormField(
                controller: _partOfSpeechController,
                decoration: const InputDecoration(
                  labelText: 'Catégorie grammaticale',
                  hintText: 'nom, verbe, adjectif, etc.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La catégorie grammaticale est requise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Translation
              TextFormField(
                controller: _translationController,
                decoration: const InputDecoration(
                  labelText: 'Traduction en français',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La traduction est requise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Difficulty level
              DropdownButtonFormField<DifficultyLevel>(
                value: _selectedDifficulty,
                decoration: const InputDecoration(
                  labelText: 'Niveau de difficulté',
                  border: OutlineInputBorder(),
                ),
                items: DifficultyLevel.values.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(_getDifficultyDisplayName(level)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDifficulty = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Example sentence
              TextFormField(
                controller: _exampleSentenceController,
                decoration: const InputDecoration(
                  labelText: 'Exemple de phrase (optionnel)',
                  hintText: 'Une phrase utilisant ce mot',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitEntry,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Ajouter'),
        ),
      ],
    );
  }

  String _getDifficultyDisplayName(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return 'Débutant';
      case DifficultyLevel.intermediate:
        return 'Intermédiaire';
      case DifficultyLevel.advanced:
        return 'Avancé';
      case DifficultyLevel.expert:
        return 'Expert';
    }
  }

  Future<void> _submitEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create the dictionary entry
      final entry = DictionaryEntryEntity(
        id: '', // Will be generated
        languageCode: _selectedLanguage,
        canonicalForm: _canonicalFormController.text.trim(),
        orthographyVariants: const [], // Can be added later
        ipa: _ipaController.text.trim().isEmpty
            ? null
            : _ipaController.text.trim(),
        audioFileReferences: const [], // Can be added later
        partOfSpeech: _partOfSpeechController.text.trim(),
        translations: {'fr': _translationController.text.trim()},
        exampleSentences: _exampleSentenceController.text.trim().isEmpty
            ? []
            : [
                ExampleSentence(
                  sentence: _exampleSentenceController.text.trim(),
                  translations: const {}, // Can be added later
                  audioReference: null,
                )
              ],
        tags: const [], // Can be added later
        difficultyLevel: _selectedDifficulty,
        contributorId: null, // Will be set by the system
        reviewStatus: ReviewStatus.pendingReview,
        qualityScore: 0.0,
        lastUpdated: DateTime.now(),
        sourceReference: 'teacher_contribution',
        metadata: const {},
      );

      // Save the entry
      if (widget.onCreateEntry != null) {
        await widget.onCreateEntry!(entry);
      } else {
        // Save to local database for offline sync
        final localDataSource = LexiconLocalDataSourceImpl();
        final model = DictionaryEntryModel.fromEntity(entry);
        await localDataSource.queueForSync(model);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Entrée ajoutée avec succès! Elle sera examinée avant publication.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
