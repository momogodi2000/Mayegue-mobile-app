/// Constants for the six traditional Cameroonian languages supported by Mayegue
class LanguageConstants {
  // Language codes
  static const String ewondo = 'ewondo';
  static const String duala = 'duala';
  static const String feefe = 'feefe';
  static const String fulfulde = 'fulfulde';
  static const String bassa = 'bassa';
  static const String bamum = 'bamum';
  static const String french = 'fr';
  static const String english = 'en';

  // All supported language codes
  static const List<String> allLanguageCodes = [
    ewondo,
    duala,
    feefe,
    fulfulde,
    bassa,
    bamum,
    french,
    english,
  ];

  // Traditional Cameroonian languages only
  static const List<String> cameroonianLanguages = [
    ewondo,
    duala,
    feefe,
    fulfulde,
    bassa,
    bamum,
  ];

  // Modern languages for translation
  static const List<String> modernLanguages = [
    french,
    english,
  ];

  // Language information
  static const Map<String, LanguageInfo> languageInfo = {
    ewondo: LanguageInfo(
      code: ewondo,
      name: 'Ewondo',
      nativeName: 'Ewondo',
      family: 'Beti-Pahuin',
      region: 'Centre',
      speakers: 577000,
      iso639: 'ewo',
      description: 'Ewondo is a Bantu language spoken by the Ewondo people of Cameroon. It is the primary language of the Centre region and is widely used in Yaoundé.',
    ),
    duala: LanguageInfo(
      code: duala,
      name: 'Duala',
      nativeName: 'Duálá',
      family: 'Bantu',
      region: 'Littoral',
      speakers: 87000,
      iso639: 'dua',
      description: 'Duala is a Bantu language spoken by the Duala people of Cameroon. It is the primary language of the Littoral region and is widely used in Douala.',
    ),
    feefe: LanguageInfo(
      code: feefe,
      name: "Fe'efe'e",
      nativeName: "Fe'efe'e",
      family: 'Bamileke',
      region: 'West',
      speakers: 50000,
      iso639: 'fmp',
      description: "Fe'efe'e is a Bamileke language spoken in the West region of Cameroon. It is part of the larger Grassfields Bantu language family.",
    ),
    fulfulde: LanguageInfo(
      code: fulfulde,
      name: 'Fulfulde',
      nativeName: 'Fulfulde',
      family: 'Niger-Congo',
      region: 'North, Adamawa, Far North',
      speakers: 1000000,
      iso639: 'ful',
      description: 'Fulfulde is a Niger-Congo language spoken by the Fulani people across West and Central Africa, including northern Cameroon.',
    ),
    bassa: LanguageInfo(
      code: bassa,
      name: 'Bassa',
      nativeName: 'Ɓàsàa',
      family: 'Bantu',
      region: 'Centre, Littoral, South',
      speakers: 300000,
      iso639: 'bas',
      description: 'Bassa is a Bantu language spoken by the Bassa people of Cameroon. It is primarily spoken in the Centre, Littoral, and South regions.',
    ),
    bamum: LanguageInfo(
      code: bamum,
      name: 'Bamum',
      nativeName: 'Shümom',
      family: 'Grassfields Bantu',
      region: 'West',
      speakers: 215000,
      iso639: 'bax',
      description: 'Bamum is a Grassfields Bantu language spoken by the Bamum people in the West region of Cameroon. It has its own writing system called Bamum script.',
    ),
    french: LanguageInfo(
      code: french,
      name: 'French',
      nativeName: 'Français',
      family: 'Romance',
      region: 'Official language',
      speakers: 10000000,
      iso639: 'fra',
      description: 'French is one of the two official languages of Cameroon, widely used in education, government, and business.',
    ),
    english: LanguageInfo(
      code: english,
      name: 'English',
      nativeName: 'English',
      family: 'Germanic',
      region: 'Official language',
      speakers: 7000000,
      iso639: 'eng',
      description: 'English is one of the two official languages of Cameroon, primarily used in the Northwest and Southwest regions.',
    ),
  };

  // Difficulty levels for learning
  static const List<String> difficultyLevels = [
    'beginner',
    'intermediate',
    'advanced',
    'expert',
  ];

  // Common word categories
  static const List<String> wordCategories = [
    'greetings',
    'family',
    'food',
    'animals',
    'nature',
    'body',
    'colors',
    'numbers',
    'time',
    'emotions',
    'actions',
    'objects',
    'places',
    'weather',
    'clothing',
    'health',
    'education',
    'work',
    'sports',
    'music',
    'culture',
    'tradition',
    'ceremony',
    'religion',
  ];

  // Learning contexts
  static const List<String> learningContexts = [
    'basic',
    'essential',
    'common',
    'formal',
    'informal',
    'ceremonial',
    'academic',
    'professional',
    'cultural',
    'historical',
  ];

  /// Check if a language code is valid
  static bool isValidLanguageCode(String code) {
    return allLanguageCodes.contains(code.toLowerCase());
  }

  /// Check if a language is a traditional Cameroonian language
  static bool isCameroonianLanguage(String code) {
    return cameroonianLanguages.contains(code.toLowerCase());
  }

  /// Get language information by code
  static LanguageInfo? getLanguageInfo(String code) {
    return languageInfo[code.toLowerCase()];
  }

  /// Get all languages in a region
  static List<LanguageInfo> getLanguagesByRegion(String region) {
    return languageInfo.values
        .where((info) => info.region.toLowerCase().contains(region.toLowerCase()))
        .toList();
  }

  /// Get languages by family
  static List<LanguageInfo> getLanguagesByFamily(String family) {
    return languageInfo.values
        .where((info) => info.family.toLowerCase().contains(family.toLowerCase()))
        .toList();
  }
}

class LanguageInfo {
  final String code;
  final String name;
  final String nativeName;
  final String family;
  final String region;
  final int speakers;
  final String iso639;
  final String description;

  const LanguageInfo({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.family,
    required this.region,
    required this.speakers,
    required this.iso639,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'nativeName': nativeName,
      'family': family,
      'region': region,
      'speakers': speakers,
      'iso639': iso639,
      'description': description,
    };
  }

  factory LanguageInfo.fromJson(Map<String, dynamic> json) {
    return LanguageInfo(
      code: json['code'] as String,
      name: json['name'] as String,
      nativeName: json['nativeName'] as String,
      family: json['family'] as String,
      region: json['region'] as String,
      speakers: json['speakers'] as int,
      iso639: json['iso639'] as String,
      description: json['description'] as String,
    );
  }
}