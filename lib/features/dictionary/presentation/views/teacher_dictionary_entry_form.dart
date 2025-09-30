import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/dictionary_entry_entity.dart';
import '../viewmodels/teacher_dictionary_viewmodel.dart';

/// View for teachers to add/edit dictionary entries
class TeacherDictionaryEntryForm extends StatefulWidget {
  final DictionaryEntryEntity? editingEntry;

  const TeacherDictionaryEntryForm({
    super.key,
    this.editingEntry,
  });

  @override
  State<TeacherDictionaryEntryForm> createState() =>
      _TeacherDictionaryEntryFormState();
}

class _TeacherDictionaryEntryFormState
    extends State<TeacherDictionaryEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _canonicalFormController;
  late TextEditingController _ipaController;
  late TextEditingController _partOfSpeechController;
  late TextEditingController _tagsController;
  late TextEditingController _exampleSentenceController;
  late TextEditingController _translationController;

  String _selectedLanguage = 'ewondo';
  DifficultyLevel _selectedDifficulty = DifficultyLevel.beginner;
  PartOfSpeech _selectedPartOfSpeech = PartOfSpeech.noun;
  final List<String> _orthographyVariants = [];
  final List<ExampleSentence> _exampleSentences = [];
  final Map<String, String> _translations = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    if (widget.editingEntry != null) {
      _populateForm(widget.editingEntry!);
    }
  }

  void _initializeControllers() {
    _canonicalFormController = TextEditingController();
    _ipaController = TextEditingController();
    _partOfSpeechController = TextEditingController();
    _tagsController = TextEditingController();
    _exampleSentenceController = TextEditingController();
    _translationController = TextEditingController();
  }

  void _populateForm(DictionaryEntryEntity entry) {
    _canonicalFormController.text = entry.canonicalForm;
    _ipaController.text = entry.ipa ?? '';
    // Parse partOfSpeech from String to PartOfSpeech enum
    _selectedPartOfSpeech = PartOfSpeech.values.firstWhere(
      (pos) => pos.name == entry.partOfSpeech,
      orElse: () => PartOfSpeech.noun,
    );
    _selectedLanguage = entry.languageCode;
    _selectedDifficulty = entry.difficultyLevel;
    _orthographyVariants.clear();
    _orthographyVariants.addAll(entry.orthographyVariants);
    _exampleSentences.clear();
    _exampleSentences.addAll(entry.exampleSentences);
    _translations.clear();
    _translations.addAll(entry.translations);
  }

  @override
  void dispose() {
    _canonicalFormController.dispose();
    _ipaController.dispose();
    _partOfSpeechController.dispose();
    _tagsController.dispose();
    _exampleSentenceController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editingEntry != null
            ? 'Modifier l\'entrée'
            : 'Nouvelle entrée'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildTranslationsSection(),
              const SizedBox(height: 24),
              _buildExampleSentencesSection(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations de base',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _canonicalFormController,
              decoration: const InputDecoration(
                labelText: 'Forme canonique',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir la forme canonique';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ipaController,
              decoration: const InputDecoration(
                labelText: 'Prononciation (IPA)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PartOfSpeech>(
              value: _selectedPartOfSpeech,
              decoration: const InputDecoration(
                labelText: 'Classe grammaticale',
                border: OutlineInputBorder(),
              ),
              items: PartOfSpeech.values.map((pos) {
                return DropdownMenuItem(
                  value: pos,
                  child: Text(pos.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPartOfSpeech = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DifficultyLevel>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Niveau de difficulté',
                border: OutlineInputBorder(),
              ),
              items: DifficultyLevel.values.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedDifficulty = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Traductions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._translations.entries.map((entry) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('${entry.key}: ${entry.value}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () {
                          setState(() => _translations.remove(entry.key));
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addTranslation,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une traduction'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleSentencesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phrases d\'exemple',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._exampleSentences.map((sentence) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ewondo: ${sentence.sentence}'),
                      if (sentence.translations.isNotEmpty)
                        Text(
                            'Traduction: ${sentence.translations.values.first}'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () {
                              setState(
                                  () => _exampleSentences.remove(sentence));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addExampleSentence,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une phrase d\'exemple'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _saveEntry,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }

  void _addTranslation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une traduction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _translationController,
              decoration: const InputDecoration(
                labelText: 'Langue',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Traduction',
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (value) {
                if (_translationController.text.isNotEmpty &&
                    value.isNotEmpty) {
                  setState(() {
                    _translations[_translationController.text] = value;
                  });
                  _translationController.clear();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // Implementation for adding translation
              Navigator.of(context).pop();
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _addExampleSentence() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une phrase d\'exemple'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _exampleSentenceController,
              decoration: const InputDecoration(
                labelText: 'Phrase en ewondo',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Traduction (optionnelle)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (_exampleSentenceController.text.isNotEmpty) {
                setState(() {
                  _exampleSentences.add(ExampleSentence(
                    sentence: _exampleSentenceController.text,
                    translations: const {},
                  ));
                });
                _exampleSentenceController.clear();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      final entry = DictionaryEntryEntity(
        id: widget.editingEntry?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        canonicalForm: _canonicalFormController.text,
        ipa: _ipaController.text.isNotEmpty ? _ipaController.text : null,
        partOfSpeech: _selectedPartOfSpeech.name,
        languageCode: _selectedLanguage,
        difficultyLevel: _selectedDifficulty,
        orthographyVariants: _orthographyVariants,
        exampleSentences: _exampleSentences,
        translations: _translations,
        tags: const [],
        metadata: const {},
        audioFileReferences: const [],
        qualityScore: 0.0,
        reviewStatus: ReviewStatus.pendingReview,
        lastUpdated: DateTime.now(),
      );

      final viewModel =
          Provider.of<TeacherDictionaryViewModel>(context, listen: false);

      if (widget.editingEntry != null) {
        viewModel.updateEntry(entry);
      } else {
        viewModel.createEntry(entry);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.editingEntry != null
                ? 'Entrée mise à jour avec succès'
                : 'Entrée ajoutée avec succès'),
          ),
        );
      }
    }
  }
}
