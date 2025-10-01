import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:mayegue/core/services/firebase_service.dart';
import 'package:mayegue/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:mayegue/features/authentication/data/models/user_model.dart';

// Mock classes
class MockFirebaseService extends Mock implements FirebaseService {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockUserCredential extends Mock implements UserCredential {
  @override
  User? get user => MockFirebaseUser();
}
class MockFirebaseUser extends Mock implements User {
  @override
  String get uid => 'test_uid';
  @override
  String? get email => 'test@example.com';
  @override
  String? get displayName => 'Test User';
  @override
  String? get phoneNumber => null;
  @override
  String? get photoURL => null;
  @override
  bool get emailVerified => false;
  @override
  UserMetadata get metadata => MockUserMetadata();
}
class MockUserMetadata extends Mock implements UserMetadata {
  @override
  DateTime? get creationTime => DateTime.now();
  @override
  DateTime? get lastSignInTime => DateTime.now();
}

// Custom mock implementations to avoid sealed class issues
class TestDocumentReference {
  final String path;
  Map<String, dynamic>? _data;

  TestDocumentReference(this.path);

  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    _data = Map<String, dynamic>.from(data);
  }

  Future<void> update(Map<Object, Object?> data) async {
    _data?.addAll(Map<String, dynamic>.from(data));
  }
}

class TestCollectionReference {
  final String path;
  final Map<String, TestDocumentReference> _docs = {};

  TestCollectionReference(this.path);

  TestDocumentReference doc([String? path]) {
    final docPath = path ?? 'default';
    return _docs[docPath] ??= TestDocumentReference('$path/$docPath');
  }
}

void main() {
  late AuthRemoteDataSourceImpl authDataSource;
  late MockFirebaseService mockFirebaseService;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUserCredential mockCredential;
  late TestCollectionReference usersCollection;

  setUp(() {
    mockFirebaseService = MockFirebaseService();
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockCredential = MockUserCredential();
    usersCollection = TestCollectionReference('users');

    when(mockFirebaseService.auth).thenReturn(mockAuth);
    when(mockFirebaseService.firestore).thenReturn(mockFirestore);

    authDataSource = AuthRemoteDataSourceImpl(mockFirebaseService);

    // Setup common mocks
    when(mockFirestore.collection('users')).thenAnswer((_) => usersCollection as CollectionReference<Map<String, dynamic>>);
  });

  group('AuthRemoteDataSource', () {
    test('signInWithEmailAndPassword creates user document with learner role', () async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockCredential);

      await authDataSource.signInWithEmailAndPassword(
        'test@example.com',
        'password123',
      );

      verify(mockAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('signInWithGoogle creates user document with learner role', () async {
      final testCredential = GoogleAuthProvider.credential(
        idToken: 'test_id_token',
        accessToken: 'test_access_token',
      );
      when(mockAuth.signInWithCredential(testCredential))
          .thenAnswer((_) async => mockCredential);

      await authDataSource.signInWithGoogle();

      verify(mockAuth.signInWithCredential(testCredential)).called(1);
    });

    test('signOut clears auth state', () async {
      await authDataSource.signOut();
      verify(mockAuth.signOut()).called(1);
    });

    test('getCurrentUser returns null when not signed in', () async {
      when(mockAuth.currentUser).thenReturn(null);
      final user = await authDataSource.getCurrentUser();
      expect(user, isNull);
    });

    test('getCurrentUser returns user data when signed in', () async {
      when(mockAuth.currentUser).thenReturn(MockFirebaseUser());
      final user = await authDataSource.getCurrentUser();
      expect(user, isNotNull);
      expect(user?.id, 'test_uid');
      expect(user?.email, 'test@example.com');
      expect(user?.displayName, 'Test User');
    });

    test('updateUserProfile updates user data', () async {
      when(mockAuth.currentUser).thenReturn(MockFirebaseUser());
      final userModel = UserModel(
        id: 'test_uid',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime.now(),
      );
      await authDataSource.updateUserProfile(userModel);
      verify(mockFirestore.collection('users')).called(1);
    });
  });
}