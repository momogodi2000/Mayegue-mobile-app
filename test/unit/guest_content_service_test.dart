import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mayegue/core/services/guest_content_service.dart';

class FakeDatabase implements Database {
  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    if (table == 'words') {
      return [
        {
          'id': 1,
          'word': 'bonjour',
          'translation': 'hello',
          'language_code': 'fr',
          'category_id': 1,
        },
        {
          'id': 2,
          'word': 'merci',
          'translation': 'thank you',
          'language_code': 'fr',
          'category_id': 1,
        },
      ];
    } else if (table == 'lessons') {
      return [
        {
          'id': 1,
          'title': 'Basic Greetings',
          'description': 'Learn basic greetings in French',
          'language_code': 'fr',
          'level': 'beginner',
          'category_id': 1,
        },
      ];
    } else if (table == 'languages') {
      return [
        {
          'id': 1,
          'code': 'fr',
          'name': 'French',
          'native_name': 'Français',
          'is_active': 1,
        },
        {
          'id': 2,
          'code': 'en',
          'name': 'English',
          'native_name': 'English',
          'is_active': 1,
        },
      ];
    }
    return [];
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeFirestore implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return FakeCollectionReference();
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: subtype_of_sealed_class
class FakeCollectionReference
    implements CollectionReference<Map<String, dynamic>> {
  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    return FakeQuerySnapshot();
  }

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    return FakeDocumentReference();
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: subtype_of_sealed_class
class FakeDocumentReference implements DocumentReference<Map<String, dynamic>> {
  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return FakeCollectionReference();
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeQuerySnapshot implements QuerySnapshot<Map<String, dynamic>> {
  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs => [
    FakeQueryDocumentSnapshot(),
  ];

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: subtype_of_sealed_class
class FakeQueryDocumentSnapshot
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data = {
    'id': 'firebase_1',
    'word': 'au revoir',
    'translation': 'goodbye',
    'language_code': 'fr',
    'category_id': 1,
    'is_public': true,
    'added_at': Timestamp.now(),
  };

  @override
  Map<String, dynamic> data() => _data;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeDatabase fakeDatabase;
  late FakeFirestore fakeFirestore;

  setUp(() {
    fakeDatabase = FakeDatabase();
    fakeFirestore = FakeFirestore();
    GuestContentService.init(fakeDatabase, fakeFirestore);
  });

  group('GuestContentService', () {
    test('getBasicWords returns words from SQLite', () async {
      final words = await GuestContentService.getBasicWords(languageCode: 'fr');
      expect(words, isNotEmpty);
      expect(words.first['word'], equals('bonjour'));
      expect(words.first['translation'], equals('hello'));
    });

    test('getWordsByCategory returns words from SQLite', () async {
      final words = await GuestContentService.getWordsByCategory(1);
      expect(words, isNotEmpty);
      expect(words.first['word'], equals('bonjour'));
      expect(words.first['category_id'], equals(1));
    });

    test('getLessonContent returns lesson from SQLite', () async {
      final lesson = await GuestContentService.getLessonContent(1);
      expect(lesson, isNotNull);
      expect(lesson['title'], equals('Basic Greetings'));
      expect(lesson['language_code'], equals('fr'));
    });

    test('getLanguages returns languages from SQLite', () async {
      final words = await GuestContentService.getBasicWords(languageCode: 'fr');
      expect(words, isNotEmpty);
      expect(words.first['language_code'], equals('fr'));
    });

    test('merges Firebase content with SQLite content', () async {
      final words = await GuestContentService.getBasicWords(languageCode: 'fr');
      expect(words, hasLength(3)); // 2 from SQLite + 1 from Firebase
      expect(words.any((w) => w['word'] == 'au revoir'), isTrue);
    });

    test('handles language filtering', () async {
      final words = await GuestContentService.getBasicWords(languageCode: 'fr');
      expect(words.every((w) => w['language_code'] == 'fr'), isTrue);
    });
  });
}
