import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Abstract AI Service interface
abstract class AIService {
  /// Generate content using AI
  Future<String> generateContent(String prompt, {
    String model,
    double temperature,
    int maxTokens,
  });

  /// Generate lesson content
  Future<String> generateLesson({
    required String languageName,
    required String topic,
    required String level,
  });

  /// Generate quiz questions
  Future<String> generateQuizQuestions({
    required String languageName,
    required String topic,
    int numberOfQuestions,
  });

  /// Translate text
  Future<String> translate({
    required String text,
    required String fromLanguage,
    required String toLanguage,
  });


  /// Generate vocabulary entries for dictionary enrichment
  Future<List<Map<String, dynamic>>> generateVocabulary({
    required String languageCode,
    String? category,
    required String difficultyLevel,
    int count = 10,
    String? context,
  });

  /// Expand existing vocabulary entry with additional content
  Future<Map<String, dynamic>> expandVocabularyEntry({
    required String word,
    required String languageCode,
    required Map<String, dynamic> currentData,
    required String expansionType,
  });

  /// Generate comprehensive pronunciation guide with IPA
  Future<String> generatePronunciationGuide({
    required String word,
    required String languageCode,
    bool includeIPA = true,
    bool includeDescription = true,
  });
}

/// Service for Gemini AI integration
class GeminiAIService implements AIService {
  final String apiKey;
  final String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  GeminiAIService({required this.apiKey});

  @override
  Future<String> generateContent(String prompt, {
    String model = 'gemini-pro',
    double temperature = 0.7,
    int maxTokens = 1000,
  }) async {
    try {
      final url = Uri.parse('$baseUrl?key=$apiKey');

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': temperature,
          'maxOutputTokens': maxTokens,
        }
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            return parts[0]['text'] as String;
          }
        }
        throw Exception('Invalid response format from Gemini AI');
      } else {
        throw Exception('Gemini AI API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to generate content with Gemini AI: $e');
    }
  }

  @override
  Future<String> generateLesson({
    required String languageName,
    required String topic,
    required String level,
  }) async {
    final prompt = '''
Generate a comprehensive lesson for learning $languageName.
Topic: $topic
Level: $level

Please provide:
1. Lesson objectives
2. Key vocabulary (with translations)
3. Grammar explanation
4. Practice exercises
5. Cultural context

Format the response as a structured JSON object.
''';

    return await generateContent(prompt);
  }

  @override
  Future<String> generateQuizQuestions({
    required String languageName,
    required String topic,
    int numberOfQuestions = 5,
  }) async {
    final prompt = '''
Generate $numberOfQuestions quiz questions about $topic in $languageName.
Include multiple choice questions with 4 options each.
Format as JSON array with question, options, and correct_answer fields.
''';

    return await generateContent(prompt);
  }

  @override
  Future<String> translate({
    required String text,
    required String fromLanguage,
    required String toLanguage,
  }) async {
    final prompt = 'Translate the following text from $fromLanguage to $toLanguage: "$text"';
    return await generateContent(prompt);
  }

  /// Generate language learning content
  Future<String> generateLanguageLesson({
    required String languageName,
    required String topic,
    String difficulty = 'intermediate',
  }) async {
    final prompt = '''
Generate a comprehensive lesson for learning $languageName.
Topic: $topic
Difficulty level: $difficulty

Please provide:
1. Introduction to the topic in both English and $languageName
2. Key vocabulary with pronunciations
3. Grammar explanations
4. Practice exercises
5. Cultural context where relevant

Format the response in a structured, educational manner.
''';

    return await generateContent(prompt);
  }

  /// Translate text between languages
  Future<String> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final prompt = '''
Translate the following text from $sourceLanguage to $targetLanguage:

"$text"

Please provide:
1. The direct translation
2. Cultural context or nuances if applicable
3. Alternative translations if there are multiple meanings
''';

    return await generateContent(prompt);
  }

  /// Generate language statistics and insights
  Future<String> generateLanguageInsights({
    required String languageName,
    required String region,
    required int speakers,
    required String status,
  }) async {
    final prompt = '''
Provide insights about the $languageName language:

- Region: $region
- Estimated speakers: $speakers
- Status: $status

Please include:
1. Historical context
2. Current usage and domains
3. Challenges and preservation efforts
4. Interesting facts
5. Comparison with related languages
''';

    return await generateContent(prompt);
  }

  @override
  Future<List<Map<String, dynamic>>> generateVocabulary({
    required String languageCode,
    String? category,
    required String difficultyLevel,
    int count = 10,
    String? context,
  }) async {
    final prompt = '''
Generate $count vocabulary words for the $languageCode language.
Difficulty level: $difficultyLevel
${category != null ? 'Category: $category' : ''}
${context != null ? 'Context: $context' : ''}

For each word, provide a JSON object with the following structure:
{
  "word": "canonical form of the word",
  "variants": ["orthography variant 1", "variant 2"],
  "ipa": "IPA transcription",
  "partOfSpeech": "noun/verb/adjective/etc",
  "translations": {
    "en": "English translation",
    "fr": "French translation"
  },
  "examples": [
    {
      "sentence": "example sentence in $languageCode",
      "translations": {
        "en": "English translation of sentence",
        "fr": "French translation of sentence"
      }
    }
  ],
  "tags": ["category", "theme", "level"],
  "confidence": 0.8,
  "category": "$category"
}

Return as a JSON array of objects. Ensure cultural appropriateness and accuracy for Cameroonian traditional languages.
''';

    try {
      final response = await generateContent(prompt, maxTokens: 2000);

      // Parse JSON response
      final List<dynamic> jsonResponse = jsonDecode(response);
      return jsonResponse.cast<Map<String, dynamic>>();
    } catch (e) {
      // If JSON parsing fails, return empty list
      debugPrint('Failed to parse AI vocabulary response: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> expandVocabularyEntry({
    required String word,
    required String languageCode,
    required Map<String, dynamic> currentData,
    required String expansionType,
  }) async {
    final prompt = '''
Expand the vocabulary entry for "$word" in $languageCode.
Current data: ${jsonEncode(currentData)}
Expansion type: $expansionType

Based on the expansion type, enhance the entry with:
- translations: Add more language translations
- examples: Add more example sentences with translations
- pronunciation: Improve IPA transcription and add pronunciation notes
- orthographyVariants: Add spelling variants and regional differences
- comprehensive: All of the above

Return a JSON object with the new/additional content:
{
  "translations": {"language_code": "translation"},
  "examples": [{"sentence": "...", "translations": {...}}],
  "variants": ["variant1", "variant2"],
  "ipa": "improved IPA",
  "confidence": 0.9,
  "type": "$expansionType"
}
''';

    try {
      final response = await generateContent(prompt, maxTokens: 1500);
      return jsonDecode(response) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to parse AI expansion response: $e');
      return {};
    }
  }

  @override
  Future<String> generatePronunciationGuide({
    required String word,
    required String languageCode,
    bool includeIPA = true,
    bool includeDescription = true,
  }) async {
    final prompt = '''
Create a pronunciation guide for "$word" in $languageCode.

${includeIPA ? 'Include IPA transcription.' : ''}
${includeDescription ? 'Include detailed pronunciation description.' : ''}

Provide:
1. ${includeIPA ? 'IPA transcription: /transcription/' : ''}
2. ${includeDescription ? 'Syllable breakdown with stress markers' : ''}
3. ${includeDescription ? 'Pronunciation description in simple terms' : ''}
4. ${includeDescription ? 'Common mistakes to avoid' : ''}
5. ${includeDescription ? 'Tips for English speakers' : ''}

For Cameroonian languages, consider tonal patterns and unique phonemes.
''';

    return await generateContent(prompt);
  }
}
