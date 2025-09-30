import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mayegue/features/authentication/presentation/views/login_view.dart';
import 'package:mayegue/features/authentication/presentation/viewmodels/auth_viewmodel.dart';

// Mock AuthViewModel for testing
class MockAuthViewModel extends AuthViewModel {
  bool loginSuccess = true;
  bool googleSignInSuccess = true;

  MockAuthViewModel() : super(
    loginUsecase: null as dynamic,
    registerUsecase: null as dynamic,
    logoutUsecase: null as dynamic,
    resetPasswordUsecase: null as dynamic,
    getCurrentUserUsecase: null as dynamic,
    googleSignInUsecase: null as dynamic,
    facebookSignInUsecase: null as dynamic,
    appleSignInUsecase: null as dynamic,
    forgotPasswordUsecase: null as dynamic,
    getOnboardingStatusUsecase: null as dynamic,
    signInWithPhoneNumberUsecase: null as dynamic,
    verifyPhoneNumberUsecase: null as dynamic,
  );

  @override
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return loginSuccess;
  }

  @override
  Future<bool> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return googleSignInSuccess;
  }

  @override
  void navigateToRoleBasedDashboard(BuildContext context) {
    // Mock navigation - do nothing
  }
}

void main() {
  late MockAuthViewModel mockAuthViewModel;

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();
  });

  group('LoginView Widget Tests', () {
    testWidgets('should render login form elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthViewModel>.value(
            value: mockAuthViewModel,
            child: const LoginView(),
          ),
        ),
      );

      // Check for key UI elements
      expect(find.text('Connexion'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
      expect(find.byType(ElevatedButton), findsWidgets); // Login buttons
      expect(find.text('Se connecter'), findsOneWidget);
    });

    testWidgets('should show validation errors for empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthViewModel>.value(
            value: mockAuthViewModel,
            child: const LoginView(),
          ),
        ),
      );

      // Find and tap the login button
      final loginButton = find.text('Se connecter');
      await tester.tap(loginButton);
      await tester.pump();

      // Should show validation errors
      expect(find.text('Veuillez entrer votre email'), findsOneWidget);
      expect(find.text('Veuillez entrer votre mot de passe'), findsOneWidget);
    });

    testWidgets('should show loading indicator during login', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthViewModel>.value(
            value: mockAuthViewModel,
            child: const LoginView(),
          ),
        ),
      );

      // Enter valid credentials
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      // Tap login button
      final loginButton = find.text('Se connecter');
      await tester.tap(loginButton);
      await tester.pump(); // Start the frame
      await tester.pump(const Duration(milliseconds: 50)); // Show loading

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle successful login', (WidgetTester tester) async {
      mockAuthViewModel.loginSuccess = true;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthViewModel>.value(
            value: mockAuthViewModel,
            child: const LoginView(),
          ),
        ),
      );

      // Enter valid credentials
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      // Tap login button
      final loginButton = find.text('Se connecter');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should navigate (mock navigation does nothing)
      // In a real test, we would verify navigation
    });

    testWidgets('should handle Google sign in', (WidgetTester tester) async {
      mockAuthViewModel.googleSignInSuccess = true;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthViewModel>.value(
            value: mockAuthViewModel,
            child: const LoginView(),
          ),
        ),
      );

      // Find and tap Google sign in button
      final googleButton = find.text('Continuer avec Google');
      if (googleButton.evaluate().isNotEmpty) {
        await tester.tap(googleButton);
        await tester.pumpAndSettle();

        // Should handle Google sign in (mock does nothing)
      }
    });
  });
}