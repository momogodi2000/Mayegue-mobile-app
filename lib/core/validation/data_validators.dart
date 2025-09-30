import '../../features/dictionary/domain/entities/dictionary_entry_entity.dart';

/// Comprehensive data validation utilities for Firebase data integrity
class DataValidators {

  /// Validate dictionary entry data before Firebase operations
  static ValidationResult validateDictionaryEntry(DictionaryEntryEntity entry) {
    final errors = <String>[];

    // Required field validation
    if (entry.canonicalForm.isEmpty) {
      errors.add('Canonical form cannot be empty');
    }

    if (entry.languageCode.isEmpty) {
      errors.add('Language code cannot be empty');
    }

    if (entry.partOfSpeech.isEmpty) {
      errors.add('Part of speech cannot be empty');
    }

    // Language code validation
    if (!_isValidLanguageCode(entry.languageCode)) {
      errors.add('Invalid language code: ${entry.languageCode}');
    }

    // Difficulty level validation
    if (!_isValidDifficultyLevel(entry.difficultyLevel)) {
      errors.add('Invalid difficulty level: ${entry.difficultyLevel}');
    }

    // Review status validation
    if (!_isValidReviewStatus(entry.reviewStatus)) {
      errors.add('Invalid review status: ${entry.reviewStatus}');
    }

    // Part of speech validation
    if (!_isValidPartOfSpeech(entry.partOfSpeech)) {
      errors.add('Invalid part of speech: ${entry.partOfSpeech}');
    }

    // Quality score validation
    if (entry.qualityScore < 0 || entry.qualityScore > 1) {
      errors.add('Quality score must be between 0 and 1');
    }

    // Canonical form validation
    if (entry.canonicalForm.length > 100) {
      errors.add('Canonical form too long (max 100 characters)');
    }

    if (!_isValidWord(entry.canonicalForm)) {
      errors.add('Canonical form contains invalid characters');
    }

    // IPA validation
    if (entry.ipa != null && !_isValidIPA(entry.ipa!)) {
      errors.add('Invalid IPA notation');
    }

    // Translations validation
    if (entry.translations.isNotEmpty) {
      final translationValidation = _validateTranslations(entry.translations);
      if (!translationValidation.isValid) {
        errors.addAll(translationValidation.errors);
      }
    }

    // Example sentences validation
    if (entry.exampleSentences.isNotEmpty) {
      final exampleValidation = _validateExampleSentences(entry.exampleSentences);
      if (!exampleValidation.isValid) {
        errors.addAll(exampleValidation.errors);
      }
    }

    // Tags validation
    if (entry.tags.isNotEmpty) {
      final tagValidation = _validateTags(entry.tags);
      if (!tagValidation.isValid) {
        errors.addAll(tagValidation.errors);
      }
    }

    // Audio file references validation
    if (entry.audioFileReferences.isNotEmpty) {
      final audioValidation = _validateAudioReferences(entry.audioFileReferences);
      if (!audioValidation.isValid) {
        errors.addAll(audioValidation.errors);
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Validate user data
  static ValidationResult validateUserData(Map<String, dynamic> userData) {
    final errors = <String>[];

    // Required fields
    final requiredFields = ['email', 'displayName', 'role'];
    for (final field in requiredFields) {
      if (!userData.containsKey(field) || userData[field] == null) {
        errors.add('Missing required field: $field');
      }
    }

    // Email validation
    if (userData['email'] != null && !_isValidEmail(userData['email'])) {
      errors.add('Invalid email format');
    }

    // Display name validation
    if (userData['displayName'] != null) {
      final displayName = userData['displayName'] as String;
      if (displayName.isEmpty || displayName.length > 50) {
        errors.add('Display name must be 1-50 characters');
      }
    }

    // Role validation
    if (userData['role'] != null && !_isValidUserRole(userData['role'])) {
      errors.add('Invalid user role: ${userData['role']}');
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Validate progress data
  static ValidationResult validateProgressData(Map<String, dynamic> progressData) {
    final errors = <String>[];

    // Required fields
    final requiredFields = ['userId', 'entryId', 'progressType'];
    for (final field in requiredFields) {
      if (!progressData.containsKey(field) || progressData[field] == null) {
        errors.add('Missing required field: $field');
      }
    }

    // Progress type validation
    if (progressData['progressType'] != null &&
        !_isValidProgressType(progressData['progressType'])) {
      errors.add('Invalid progress type: ${progressData['progressType']}');
    }

    // Progress value validation
    if (progressData['progressValue'] != null) {
      final value = progressData['progressValue'];
      if (value is! num || value < 0 || value > 1) {
        errors.add('Progress value must be a number between 0 and 1');
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  // Private validation methods

  static bool _isValidLanguageCode(String languageCode) {
    const validCodes = ['ewondo', 'duala', 'bafang', 'fulfulde', 'bassa', 'bamum'];
    return validCodes.contains(languageCode.toLowerCase());
  }

  static bool _isValidDifficultyLevel(DifficultyLevel difficulty) {
    return DifficultyLevel.values.contains(difficulty);
  }

  static bool _isValidReviewStatus(ReviewStatus status) {
    return ReviewStatus.values.contains(status);
  }

  static bool _isValidPartOfSpeech(String partOfSpeech) {
    const validParts = [
      'noun', 'verb', 'adjective', 'adverb', 'pronoun', 'preposition',
      'conjunction', 'interjection', 'article', 'determiner', 'particle'
    ];
    return validParts.contains(partOfSpeech.toLowerCase());
  }

  static bool _isValidWord(String word) {
    // Basic validation for word characters (letters, spaces, hyphens, apostrophes)
    final wordPattern = RegExp(r"^[a-zA-ZÀ-ÿ\u0100-\u024F\u1E00-\u1EFF\s\-']+$");
    return wordPattern.hasMatch(word) && word.trim().isNotEmpty;
  }

  static bool _isValidIPA(String ipa) {
    // Basic IPA character validation (simplified)
    final ipaPattern = RegExp(r"^[a-zA-ZÀ-ÿɑɒæɐɞɨɯɪʊʏʉɘɵɤɣχʁhɦʔɢŋɴɲɳɭɽɾrɟcɕʝɭβθðsʃʒʐvzʑɹɻjɰlɭʎʟwɥ̃̈̊̊̃̈̄̀́̂̌̇̋̏̑̌̇̚ːˈˌ\.\s\[\]\/\-ˈˌ]+$");
    return ipaPattern.hasMatch(ipa);
  }

  static bool _isValidEmail(String email) {
    final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailPattern.hasMatch(email);
  }

  static bool _isValidUserRole(String role) {
    const validRoles = ['learner', 'teacher', 'admin'];
    return validRoles.contains(role.toLowerCase());
  }

  static bool _isValidProgressType(String progressType) {
    const validTypes = ['learned', 'practiced', 'mastered', 'reviewed'];
    return validTypes.contains(progressType.toLowerCase());
  }

  static ValidationResult _validateTranslations(Map<String, String> translations) {
    final errors = <String>[];
    const validLanguageCodes = ['fr', 'en', 'ewondo', 'duala', 'bafang', 'fulfulde', 'bassa', 'bamum'];

    if (translations.length > 10) {
      errors.add('Too many translations (max 10)');
    }

    for (final entry in translations.entries) {
      if (!validLanguageCodes.contains(entry.key.toLowerCase())) {
        errors.add('Invalid translation language code: ${entry.key}');
      }

      if (entry.value.isEmpty || entry.value.length > 200) {
        errors.add('Translation text must be 1-200 characters');
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  static ValidationResult _validateExampleSentences(List<ExampleSentence> examples) {
    final errors = <String>[];

    if (examples.length > 10) {
      errors.add('Too many example sentences (max 10)');
    }

    for (int i = 0; i < examples.length; i++) {
      final example = examples[i];

      if (example.sentence.isEmpty || example.sentence.length > 500) {
        errors.add('Example sentence ${i + 1} must be 1-500 characters');
      }

      if (!_isValidSentence(example.sentence)) {
        errors.add('Example sentence ${i + 1} contains invalid characters');
      }

      // Validate translations within example
      if (example.translations.isNotEmpty) {
        final translationValidation = _validateTranslations(example.translations);
        if (!translationValidation.isValid) {
          errors.addAll(translationValidation.errors.map((e) => 'Example ${i + 1}: $e'));
        }
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  static ValidationResult _validateTags(List<String> tags) {
    final errors = <String>[];
    const validTags = [
      'family', 'greetings', 'food', 'animals', 'nature', 'body', 'colors',
      'numbers', 'time', 'emotions', 'actions', 'objects', 'places', 'weather',
      'clothing', 'health', 'education', 'work', 'sports', 'music', 'culture',
      'tradition', 'ceremony', 'religion', 'basic', 'essential', 'common',
      'formal', 'informal', 'slang', 'archaic', 'modern'
    ];

    if (tags.length > 20) {
      errors.add('Too many tags (max 20)');
    }

    for (final tag in tags) {
      if (!validTags.contains(tag.toLowerCase())) {
        errors.add('Invalid tag: $tag');
      }
    }

    // Check for duplicates
    final uniqueTags = tags.toSet();
    if (uniqueTags.length != tags.length) {
      errors.add('Duplicate tags found');
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  static ValidationResult _validateAudioReferences(List<String> audioRefs) {
    final errors = <String>[];

    if (audioRefs.length > 5) {
      errors.add('Too many audio references (max 5)');
    }

    for (final ref in audioRefs) {
      if (!_isValidAudioReference(ref)) {
        errors.add('Invalid audio reference format: $ref');
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  static bool _isValidSentence(String sentence) {
    // Allow letters, numbers, basic punctuation, and common sentence characters
    final sentencePattern = RegExp(r'^[a-zA-Z0-9\s.,!?;:()\[\]]+$');
    return sentencePattern.hasMatch(sentence);
  }

  static bool _isValidAudioReference(String ref) {
    // Basic validation for audio file references (URLs or file paths)
    final audioPattern = RegExp(r'^(https?:\/\/|gs:\/\/|\/)[^\s]+\.(mp3|wav|m4a|aac|ogg)$', caseSensitive: false);
    return audioPattern.hasMatch(ref);
  }

  /// Validate batch operations
  static ValidationResult validateBatchOperation(List<DictionaryEntryEntity> entries) {
    final errors = <String>[];

    if (entries.isEmpty) {
      errors.add('Batch operation cannot be empty');
      return ValidationResult(isValid: false, errors: errors);
    }

    if (entries.length > 100) {
      errors.add('Batch operation too large (max 100 entries)');
    }

    // Validate each entry
    for (int i = 0; i < entries.length; i++) {
      final entryValidation = validateDictionaryEntry(entries[i]);
      if (!entryValidation.isValid) {
        errors.addAll(entryValidation.errors.map((e) => 'Entry ${i + 1}: $e'));
      }
    }

    // Check for duplicates within batch
    final canonicalForms = entries.map((e) => '${e.languageCode}:${e.canonicalForm}').toList();
    final uniqueForms = canonicalForms.toSet();
    if (uniqueForms.length != canonicalForms.length) {
      errors.add('Duplicate entries found in batch');
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  /// Sanitize text input
  static String sanitizeText(String input) {
    return input.trim();
  }

  /// Sanitize IPA notation
  static String sanitizeIPA(String ipa) {
    // Allow IPA characters, punctuation, and whitespace
    return ipa
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Zɑɒæɐɞɨɯɪʊʏʉɘɵɤɣχʁhɦʔɢŋɴɲɳɭɽɾrɟcɕʝβθðsʃʒʐvzʑɹɻjɰlʎʟwɥˈˌː\s\-.()\[\]]'), '');
  }
}

/// Result of a validation operation
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({
    required this.isValid,
    required this.errors,
  });

  /// Get a formatted error message
  String get errorMessage {
    if (isValid) return '';
    return errors.join('; ');
  }

  /// Get first error
  String? get firstError {
    return errors.isNotEmpty ? errors.first : null;
  }

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, errors: $errors)';
  }
}