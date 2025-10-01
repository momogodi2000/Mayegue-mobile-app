import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:mayegue/core/services/terms_service.dart';
import 'package:mayegue/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:mayegue/features/authentication/data/models/user_model.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {
  UserModel? _currentUser;
  void setCurrentUser(UserModel? user) => _currentUser = user;
  
  @override
  Future<UserModel?> getCurrentUser() async => _currentUser;
}

class MockTermsService extends Mock implements TermsService {
  bool _hasAccepted = false;
  void setTermsAccepted(bool accepted) => _hasAccepted = accepted;
  Future<bool> hasAcceptedTerms() async => _hasAccepted;
}

void main() {
  late GoRouter router;
  late MockAuthRemoteDataSource mockAuth;
  late MockTermsService mockTerms;

  setUp(() {
    mockAuth = MockAuthRemoteDataSource();
    mockTerms = MockTermsService();

    router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Text('Home')),
        GoRoute(
          path: '/terms',
          builder: (context, state) => const Text('Terms & Conditions'),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const Text('Admin Dashboard'),
        ),
        GoRoute(
          path: '/teacher',
          builder: (context, state) => const Text('Teacher Dashboard'),
        ),
        GoRoute(
          path: '/learner',
          builder: (context, state) => const Text('Learner Dashboard'),
        ),
        GoRoute(
          path: '/guest',
          builder: (context, state) => const Text('Guest Dashboard'),
        ),
      ],
      redirect: (context, state) {
        if (!mockTerms._hasAccepted) {
          return '/terms';
        }

        final user = mockAuth._currentUser;
        if (user == null) {
          return '/guest';
        }

        switch (user.role) {
          case 'admin':
            return '/admin';
          case 'teacher':
            return '/teacher';
          case 'learner':
            return '/learner';
          default:
            return '/guest';
        }
      },
    );
  });

  group('Router', () {
    group('Terms & Conditions Flow', () {
      testWidgets('redirects to terms when not accepted', (tester) async {
        mockAuth.setCurrentUser(null);
        mockTerms.setTermsAccepted(false);

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        expect(find.text('Terms & Conditions'), findsOneWidget);
      });

      testWidgets('redirects to guest dashboard after accepting terms', (tester) async {
        mockAuth.setCurrentUser(null);
        mockTerms.setTermsAccepted(true);

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        expect(find.text('Guest Dashboard'), findsOneWidget);
      });
    });

    group('Role-Based Redirects', () {
      testWidgets('redirects admin to admin dashboard', (tester) async {
        mockAuth.setCurrentUser(
          UserModel(
            id: 'test_uid',
            email: 'admin@example.com',
            displayName: 'Admin',
            role: 'admin',
            createdAt: DateTime.now(),
          ),
        );
        mockTerms.setTermsAccepted(true);

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        expect(find.text('Admin Dashboard'), findsOneWidget);
      });

      testWidgets('redirects teacher to teacher dashboard', (tester) async {
        mockAuth.setCurrentUser(
          UserModel(
            id: 'test_uid',
            email: 'teacher@example.com',
            displayName: 'Teacher',
            role: 'teacher',
            createdAt: DateTime.now(),
          ),
        );
        mockTerms.setTermsAccepted(true);

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        expect(find.text('Teacher Dashboard'), findsOneWidget);
      });

      testWidgets('redirects learner to learner dashboard', (tester) async {
        mockAuth.setCurrentUser(
          UserModel(
            id: 'test_uid',
            email: 'learner@example.com',
            displayName: 'Learner',
            role: 'learner',
            createdAt: DateTime.now(),
          ),
        );
        mockTerms.setTermsAccepted(true);

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        expect(find.text('Learner Dashboard'), findsOneWidget);
      });

      testWidgets('redirects guest to guest dashboard', (tester) async {
        mockAuth.setCurrentUser(null);
        mockTerms.setTermsAccepted(true);

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        expect(find.text('Guest Dashboard'), findsOneWidget);
      });
    });

    group('Role-Based Access Control', () {
      testWidgets('prevents admin access for non-admin users', (tester) async {
        mockAuth.setCurrentUser(
          UserModel(
            id: 'test_uid',
            email: 'learner@example.com',
            displayName: 'Learner',
            role: 'learner',
            createdAt: DateTime.now(),
          ),
        );
        mockTerms.setTermsAccepted(true);

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        router.go('/admin');
        await tester.pumpAndSettle();

        expect(find.text('Admin Dashboard'), findsNothing);
        expect(find.text('Learner Dashboard'), findsOneWidget);
      });

      testWidgets('prevents teacher access for non-teacher users', (
        tester,
      ) async {
        mockAuth.setCurrentUser(
          UserModel(
            id: 'test_uid',
            email: 'learner@example.com',
            displayName: 'Learner',
            role: 'learner',
            createdAt: DateTime.now(),
          ),
        );
        mockTerms.setTermsAccepted(true);

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        router.go('/teacher');
        await tester.pumpAndSettle();

        expect(find.text('Teacher Dashboard'), findsNothing);
        expect(find.text('Learner Dashboard'), findsOneWidget);
      });

      testWidgets('prevents learner access for guests', (tester) async {
        mockAuth.setCurrentUser(null);
        mockTerms.setTermsAccepted(true);

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        router.go('/learner');
        await tester.pumpAndSettle();

        expect(find.text('Learner Dashboard'), findsNothing);
        expect(find.text('Guest Dashboard'), findsOneWidget);
      });
    });
  });
}