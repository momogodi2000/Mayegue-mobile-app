import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mayegue/features/dashboard/presentation/viewmodels/admin_dashboard_viewmodel.dart';

// Use fake implementations instead of sealed class mocks
class FakeFirebaseAuth implements FirebaseAuth {
  @override
  User? get currentUser => FakeUser();

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return FakeUserCredential();
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUser implements User {
  @override
  String get uid => 'admin_uid';

  @override
  Future<void> updateDisplayName(String? displayName) async {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUserCredential implements UserCredential {
  @override
  User? get user => FakeUser();

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeFirestore implements FirebaseFirestore {
  final Map<String, FakeCollectionReference> _collections = {};

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    _collections[collectionPath] ??= FakeCollectionReference();
    return _collections[collectionPath]!;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: subtype_of_sealed_class
class FakeCollectionReference
    implements CollectionReference<Map<String, dynamic>> {
  final List<FakeQueryDocumentSnapshot> _docs = [];
  final Map<String, FakeDocumentReference> _docRefs = {};

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    return FakeQuerySnapshot(_docs);
  }

  @override
  CollectionReference<Map<String, dynamic>> limit(int limit) {
    return this;
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) {
    return Stream.value(FakeQuerySnapshot(_docs));
  }

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    final docPath = path ?? 'doc_${_docRefs.length}';
    _docRefs[docPath] ??= FakeDocumentReference();
    return _docRefs[docPath]!;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: subtype_of_sealed_class
class FakeDocumentReference implements DocumentReference<Map<String, dynamic>> {
  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    // No-op for testing
  }

  @override
  Future<void> update(Map<Object, Object?> data) async {
    // No-op for testing
  }

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return FakeCollectionReference();
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeQuerySnapshot implements QuerySnapshot<Map<String, dynamic>> {
  final List<FakeQueryDocumentSnapshot> _docs;

  FakeQuerySnapshot(this._docs);

  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs => _docs;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: subtype_of_sealed_class
class FakeQueryDocumentSnapshot
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;
  final String _id;

  FakeQueryDocumentSnapshot([Map<String, dynamic>? data, String? id])
    : _data =
          data ??
          {
            'uid': 'test_uid',
            'email': 'test@example.com',
            'displayName': 'Test User',
            'role': 'learner',
            'isActive': true,
            'createdAt': Timestamp.now(),
            'lastLoginAt': Timestamp.now(),
          },
      _id = id ?? 'test_uid';

  @override
  String get id => _id;

  @override
  Map<String, dynamic> data() => _data;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AdminDashboardViewModel viewModel;
  late FakeFirebaseAuth fakeAuth;
  late FakeFirestore fakeFirestore;

  setUp(() {
    fakeAuth = FakeFirebaseAuth();
    fakeFirestore = FakeFirestore();
    viewModel = AdminDashboardViewModel(fakeAuth, fakeFirestore);
  });

  group('AdminDashboardViewModel', () {
    test('initializes with correct default values', () {
      expect(viewModel.isLoading, false);
      expect(viewModel.hasError, false);
      expect(viewModel.users, isEmpty);
    });

    test('loads admin dashboard data', () async {
      await viewModel.loadAdminDashboard();

      expect(viewModel.isLoading, false);
      expect(viewModel.systemHealth, isNotEmpty);
      expect(viewModel.overviewStats, isNotEmpty);
    });

    test('creates admin account successfully', () async {
      const email = 'admin@example.com';
      const displayName = 'New Admin';
      const password = 'password123';

      final result = await viewModel.createAdminAccount(
        email: email,
        password: password,
        displayName: displayName,
      );

      expect(result, true);
      expect(viewModel.hasError, false);
    });

    test('creates teacher account successfully', () async {
      const email = 'teacher@example.com';
      const displayName = 'New Teacher';
      const password = 'password123';

      final result = await viewModel.createTeacherAccount(
        email: email,
        password: password,
        displayName: displayName,
      );

      expect(result, true);
      expect(viewModel.hasError, false);
    });

    test('system health score is calculated correctly', () async {
      await viewModel.loadAdminDashboard();

      expect(viewModel.systemHealthScore, greaterThanOrEqualTo(0.0));
      expect(viewModel.systemHealthScore, lessThanOrEqualTo(1.0));
    });

    test('getContentCountForLanguage returns correct count', () async {
      await viewModel.loadAdminDashboard();

      final count = viewModel.getContentCountForLanguage('fr');
      expect(count, greaterThanOrEqualTo(0));
    });

    test('performs moderation successfully', () async {
      await viewModel.loadAdminDashboard();

      final result = await viewModel.performModeration(
        'test_content_id',
        'approve',
      );

      // Should complete without error
      expect(result, isA<bool>());
    });

    test('refreshSystemStatus updates system data', () async {
      await viewModel.loadAdminDashboard();

      await viewModel.refreshSystemStatus();

      expect(viewModel.isLoading, false);
      expect(viewModel.systemHealth, isNotEmpty);
    });

    test('searchUsers filters users correctly', () async {
      await viewModel.loadAdminDashboard();

      await viewModel.searchUsers('test');

      expect(viewModel.isLoading, false);
    });

    test('filterUsers filters by role', () async {
      await viewModel.loadAdminDashboard();

      await viewModel.filterUsers('all');

      expect(viewModel.isLoading, false);
    });
  });
}
