/// Dictionary entity representing a word with translations
class DictionaryEntity {
  final String id;
  final String word;
  final String sourceLanguage; // 'fr', 'en', or language code
  final Map<String, String> translations; // Map of language code -> translation
  final Map<String, String>? pronunciations; // Optional pronunciation guides
  final Map<String, List<String>>? examples; // Optional example sentences
  final List<String>? categories; // Word categories (noun, verb, etc.)
  final String? partOfSpeech; // noun, verb, adjective, etc.
  final String? definition; // English/French definition
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy; // User ID who added the word
  final int usageCount; // How many times this word has been looked up

  const DictionaryEntity({
    required this.id,
    required this.word,
    required this.sourceLanguage,
    required this.translations,
    this.pronunciations,
    this.examples,
    this.categories,
    this.partOfSpeech,
    this.definition,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.usageCount = 0,
  });

  /// Get translation for a specific language
  String? getTranslation(String languageCode) {
    return translations[languageCode];
  }

  /// Check if word has translation for a specific language
  bool hasTranslation(String languageCode) {
    return translations.containsKey(languageCode) && translations[languageCode]!.isNotEmpty;
  }

  /// Get all available target languages for this word
  List<String> getAvailableLanguages() {
    return translations.keys.where((lang) => translations[lang]!.isNotEmpty).toList();
  }

  /// Get pronunciation for a specific language
  String? getPronunciation(String languageCode) {
    return pronunciations?[languageCode];
  }

  /// Get examples for a specific language
  List<String>? getExamples(String languageCode) {
    return examples?[languageCode];
  }

  /// Check if word belongs to a category
  bool hasCategory(String category) {
    return categories?.contains(category) ?? false;
  }

  DictionaryEntity copyWith({
    String? id,
    String? word,
    String? sourceLanguage,
    Map<String, String>? translations,
    Map<String, String>? pronunciations,
    Map<String, List<String>>? examples,
    List<String>? categories,
    String? partOfSpeech,
    String? definition,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    int? usageCount,
  }) {
    return DictionaryEntity(
      id: id ?? this.id,
      word: word ?? this.word,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      translations: translations ?? this.translations,
      pronunciations: pronunciations ?? this.pronunciations,
      examples: examples ?? this.examples,
      categories: categories ?? this.categories,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      definition: definition ?? this.definition,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}