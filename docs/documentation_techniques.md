# Documentation Technique - Mayegue App

## Vue d'Ensemble

Cette documentation détaille l'écosystème technique de l'application Mayegue, incluant les technologies, dépendances, configurations et bonnes pratiques de développement.

## 🛠️ Stack Technologique

### Framework Principal
- **Flutter** : 3.0.0+ - Framework cross-platform pour iOS, Android et Web
- **Dart** : 3.0.0+ - Langage de programmation moderne et performant

### Architecture
- **MVVM Pattern** : Séparation claire Vue-Modèle-VueModèle
- **Clean Architecture** : Organisation en couches indépendantes
- **Provider** : Gestion d'état réactive et légère

### Backend & Services
- **Firebase Suite** :
  - **Authentication** : Gestion des utilisateurs et sécurité
  - **Firestore** : Base de données NoSQL en temps réel
  - **Storage** : Stockage de fichiers (audio, vidéo, images)
  - **Functions** : Logique serverless (optionnel)
  - **Messaging** : Notifications push
  - **Analytics** : Suivi d'utilisation et métriques

### Services Externes
- **Gemini AI** : Assistant conversationnel intelligent (Google AI)
- **CamPay** : Passerelle de paiement mobile camerounais
- **NouPai** : Passerelle de paiement alternative

## 📦 Dépendances Principales

### Gestion d'État & Architecture
```yaml
provider: ^6.1.1              # Gestion d'état réactive
equatable: ^2.0.5             # Comparaison d'objets
dartz: ^0.10.1                # Programmation fonctionnelle (Either, Option)
```

### Navigation & Routing
```yaml
go_router: ^14.0.0            # Navigation type-safe
```

### Réseau & HTTP
```yaml
dio: ^5.4.0                   # Client HTTP avancé
http: ^0.13.6                 # Client HTTP standard
connectivity_plus: ^5.0.2     # Vérification connectivité
```

### Stockage Local
```yaml
hive: ^2.2.3                  # Base de données NoSQL locale
hive_flutter: ^1.1.0          # Intégration Flutter
shared_preferences: ^2.2.2    # Stockage clé-valeur simple
sqflite: ^2.3.0               # SQLite pour données complexes
path: ^1.8.3                  # Manipulation des chemins
```

### Firebase
```yaml
firebase_core: ^2.32.0        # Core Firebase
firebase_auth: ^4.20.0        # Authentification
cloud_firestore: ^4.17.5      # Base de données
firebase_storage: ^11.7.7     # Stockage fichiers
firebase_messaging: ^14.7.10  # Notifications push
firebase_analytics: ^10.8.0   # Analytics
firebase_crashlytics: ^3.4.9  # Crash reporting
flutter_local_notifications: ^17.1.0  # Notifications locales
```

### Authentification Sociale
```yaml
google_sign_in: ^6.2.1        # Connexion Google
flutter_facebook_auth: ^6.0.4 # Connexion Facebook
sign_in_with_apple: ^5.0.0    # Connexion Apple
```

### Multimédia
```yaml
audioplayers: ^3.0.1          # Lecture audio
video_player: ^2.5.1          # Lecture vidéo
```

### Utilitaires
```yaml
crypto: ^3.0.3                # Cryptographie
intl: ^0.20.2                 # Internationalisation
flutter_dotenv: ^5.1.0        # Variables d'environnement
file_picker: ^8.0.0           # Sélection de fichiers
permission_handler: ^11.3.0   # Gestion des permissions
lottie: ^3.0.0                # Animations Lottie
```

### Développement & Tests
```yaml
flutter_lints: ^2.0.3          # Règles de linting
build_runner: ^2.4.8          # Génération de code
hive_generator: ^2.0.1        # Génération Hive
mockito: ^5.4.4               # Mocks pour tests
bloc_test: ^9.1.4             # Tests BLoC
intl_utils: ^2.8.7            # Utilitaires i18n
flutter_launcher_icons: ^0.13.1 # Icônes d'application
```

## 🔧 Configuration Firebase

### 1. Création du Projet
```bash
# Installation Firebase CLI
npm install -g firebase-tools

# Connexion
firebase login

# Création projet
firebase projects:create mayegue-app
```

### 2. Configuration des Services

#### Firestore Security Rules
```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Règles d'accès par rôle
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function hasRole(role) {
      return isAuthenticated() &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == role;
    }

    // Collection utilisateurs
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId) || hasRole('admin');
    }

    // Collection langues (publique en lecture)
    match /languages/{languageId} {
      allow read: if true;
      allow write: if hasRole('admin') || hasRole('teacher');
    }

    // Collection leçons
    match /lessons/{lessonId} {
      allow read: if isAuthenticated();
      allow write: if hasRole('admin') || hasRole('teacher');
    }

    // Collection paiements (privée)
    match /payments/{paymentId} {
      allow read, write: if hasRole('admin') || isOwner(resource.data.userId);
    }
  }
}
```

#### Storage Security Rules
```javascript
// storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Images de profil
    match /profile_images/{userId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Médias pédagogiques
    match /lesson_media/{lessonId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null &&
                   (request.auth.token.role == 'admin' ||
                    request.auth.token.role == 'teacher');
    }

    // Audio dictionnaire
    match /dictionary_audio/{languageId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null &&
                   request.auth.token.role == 'admin';
    }
  }
}
```

### 3. Configuration Flutter
```dart
// lib/firebase_options.dart (généré automatiquement)
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidOptions;
      case TargetPlatform.iOS:
        return iosOptions;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions androidOptions = FirebaseOptions(
    apiKey: '...',
    appId: '...',
    messagingSenderId: '...',
    projectId: 'mayegue-app',
    storageBucket: 'mayegue-app.appspot.com',
  );
}
```

## 🔐 Configuration de Sécurité

### Variables d'Environnement
```env
# .env
# Firebase
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_PROJECT_ID=mayegue-app
FIREBASE_APP_ID=your_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id

# IA
GEMINI_API_KEY=your_gemini_api_key

# Paiements
CAMPAY_API_KEY=your_campay_api_key
CAMPAY_SECRET=your_campay_secret
CAMPAY_ENVIRONMENT=sandbox

NOUPAI_API_KEY=your_noupai_api_key
NOUPAI_SECRET=your_noupai_secret

# Application
APP_ENVIRONMENT=development
APP_VERSION=1.0.0
```

### Utilitaires de Sécurité
```dart
// lib/core/utils/security_utils.dart
class SecurityUtils {
  static final _key = Key.fromSecureRandom(32);
  static final _iv = IV.fromSecureRandom(16);

  // Hachage PBKDF2 pour mots de passe
  static String hashPassword(String password) {
    final salt = generateSalt();
    final pbkdf2 = PBKDF2(
      macAlgorithm: Hmac.sha256(),
      iterations: 10000,
      bits: 256,
    );
    final hash = pbkdf2.generateKey(
      secretKey: SecretKey(password.codeUnits),
      nonce: salt,
    );
    return '${base64.encode(salt)}:${base64.encode(hash)}';
  }

  // Chiffrement AES-256 pour données sensibles
  static String encryptData(String data) {
    final encrypter = Encrypter(AES(_key));
    final encrypted = encrypter.encrypt(data, iv: _iv);
    return '${base64.encode(_iv.bytes)}:${encrypted.base64}';
  }

  // Génération de tokens CSRF
  static String generateCsrfToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  // Validation et sanitisation des entrées
  static String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .trim();
  }
}
```

### Validation des Entrées
```dart
// lib/core/utils/validators.dart
class Validators {
  // Validation email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email invalide';
    }
    return null;
  }

  // Validation mot de passe fort
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }
    if (value.length < 8) {
      return 'Minimum 8 caractères';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Au moins une majuscule';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Au moins une minuscule';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Au moins un chiffre';
    }
    return null;
  }

  // Validation numéro téléphone camerounais
  static String? validateCameroonianPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Numéro de téléphone requis';
    }
    // Formats: +237XXXXXXXXX, 6XXXXXXXX, etc.
    final phoneRegex = RegExp(r'^(\+237|237)?[2368]\d{8}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Numéro camerounais invalide';
    }
    return null;
  }

  // Validation montant paiement
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Montant requis';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Montant invalide';
    }
    if (amount > 1000000) { // 1M FCFA max
      return 'Montant trop élevé';
    }
    return null;
  }
}
```

## 🔄 Configuration des APIs Externes

### Gemini AI Integration
```dart
// lib/core/services/ai_service.dart
class AIService {
  final Dio _dio;
  final String _apiKey;

  AIService(this._dio, this._apiKey);

  Future<String> generateResponse(String prompt) async {
    try {
      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        }),
        data: {
          'contents': [{
            'parts': [{
              'text': prompt
            }]
          }]
        },
      );

      return response.data['candidates'][0]['content']['parts'][0]['text'];
    } catch (e) {
      throw AIServiceException('Erreur IA: $e');
    }
  }
}
```

### CamPay Integration
```dart
// lib/core/payment/campay_service.dart
class CamPayService {
  final Dio _dio;
  final String _apiKey;
  final String _secret;

  Future<PaymentResponse> initiatePayment({
    required double amount,
    required String phoneNumber,
    required String description,
  }) async {
    final auth = base64.encode(utf8.encode('$_apiKey:$_secret'));

    final response = await _dio.post(
      'https://api.campay.net/api/collect/',
      options: Options(headers: {
        'Authorization': 'Basic $auth',
        'Content-Type': 'application/json',
      }),
      data: {
        'amount': amount.toString(),
        'currency': 'XAF',
        'from': phoneNumber,
        'description': description,
      },
    );

    return PaymentResponse.fromJson(response.data);
  }
}
```

## 📱 Configuration Platforme

### Android
```gradle
// android/app/build.gradle
android {
    compileSdkVersion 34
    defaultConfig {
        applicationId "com.mayegue.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}

// Configuration Firebase
apply plugin: 'com.google.gms.google-services'
```

### iOS
```swift
// ios/Runner/AppDelegate.swift
import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Web
```html
<!-- web/index.html -->
<!DOCTYPE html>
<html>
<head>
  <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-app.js"></script>
  <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-auth.js"></script>
  <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-firestore.js"></script>
</head>
<body>
  <script>
    // Configuration Firebase Web
    const firebaseConfig = {
      apiKey: "...",
      authDomain: "mayegue-app.firebaseapp.com",
      projectId: "mayegue-app",
      storageBucket: "mayegue-app.appspot.com",
    };
    firebase.initializeApp(firebaseConfig);
  </script>
</body>
</html>
```

## 🧪 Configuration des Tests

### Tests Unitaires
```dart
// test/widget_test.dart
void main() {
  group('AuthViewModel', () {
    late AuthViewModel viewModel;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      viewModel = AuthViewModel(mockRepository);
    });

    test('should login successfully', () async {
      // Arrange
      when(mockRepository.login(any, any))
          .thenAnswer((_) async => const User(id: '1', email: 'test@test.com'));

      // Act
      await viewModel.login('test@test.com', 'password');

      // Assert
      expect(viewModel.state.isAuthenticated, true);
    });
  });
}
```

### Tests d'Intégration
```dart
// integration_test/app_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('complete user flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test du flux complet
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('email_field')), 'test@test.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password');
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Bienvenue'), findsOneWidget);
    });
  });
}
```

## 🚀 Configuration CI/CD

### GitHub Actions
```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.0.0'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3

  build:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.0.0'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

## 📊 Monitoring & Analytics

### Firebase Analytics
```dart
// lib/core/services/analytics_service.dart
class AnalyticsService {
  static void logEvent(String name, Map<String, dynamic> parameters) {
    FirebaseAnalytics.instance.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  static void logLessonStarted(String lessonId, String languageId) {
    logEvent('lesson_started', {
      'lesson_id': lessonId,
      'language_id': languageId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static void logPaymentCompleted(double amount, String currency) {
    logEvent('payment_completed', {
      'amount': amount,
      'currency': currency,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
```

### Crash Reporting
```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation Crashlytics
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}
```

Cette configuration technique assure une base solide pour le développement, le déploiement et la maintenance de l'application Mayegue.