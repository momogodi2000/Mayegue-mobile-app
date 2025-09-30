# 🚀 Guide Complet de Configuration Firebase - Mayegue App

## Vue d'Ensemble

Ce guide détaille la configuration complète de Firebase pour l'application Mayegue, incluant tous les services nécessaires et leur intégration dans le projet Flutter.

## 📋 Prérequis

### Outils Nécessaires
- **Node.js** (version 16 ou supérieure)
- **Flutter SDK** (version 3.0 ou supérieure)
- **Android Studio** (pour Android)
- **Xcode** (pour iOS, macOS uniquement)
- **Navigateur web** (pour la console Firebase)

### Compte Développeur
- **Google Account** actif
- **Apple Developer Account** (pour iOS)
- **Google Play Console** (pour Android)

---

## 🔥 1. Création du Projet Firebase

### Étape 1: Accès à la Console Firebase
1. Rendez-vous sur [https://console.firebase.google.com/](https://console.firebase.google.com/)
2. Cliquez sur **"Créer un projet"** ou **"Add project"**
3. Nommez votre projet : `maa-yegue`
4. Activez **Google Analytics** (recommandé)
5. Choisissez un compte Google Analytics existant ou créez-en un nouveau

### Étape 2: Configuration des Services

#### 1.1 Firebase Authentication
Activez les méthodes d'authentification suivantes :
- ✅ **Email/Password**
- ✅ **Google**
- ✅ **Facebook**
- ✅ **Apple**
- ✅ **Phone**

**Configuration spécifique :**
```javascript
// Dans Authentication > Sign-in method
// Pour Apple Sign-In :
// - Service ID : com.mayegue.app
// - Team ID : Votre Team ID Apple Developer
```

#### 1.2 Cloud Firestore
1. Créez la base de données en mode **"Production"**
2. Choisissez une région : `nam5 (us-central)` ou `eur3 (europe-west)`
3. Configurez les règles de sécurité (voir section dédiée)

#### 1.3 Firebase Storage
1. Créez un bucket par défaut
2. Configurez les règles de sécurité (voir section dédiée)

#### 1.4 Firebase Cloud Messaging (FCM)
Activé automatiquement avec Firebase. Configuration supplémentaire requise pour iOS.

#### 1.5 Firebase Analytics
Activé automatiquement lors de la création du projet.

#### 1.6 Firebase Crashlytics
1. Allez dans **Crashlytics**
2. Cliquez sur **"Activer Crashlytics"**
3. Suivez les instructions pour Android et iOS

---

## 📱 2. Configuration des Applications

### 2.1 Application Android

#### Étape 1: Ajout de l'App Android
1. Dans la console Firebase, cliquez sur **"Ajouter une app"**
2. Sélectionnez **Android**
3. Package name : `com.mayegue.app`
4. Surnom : `Mayegue Android`
5. Certificat de signature : Laissez vide pour le développement

#### Étape 2: Téléchargement des Fichiers de Configuration
1. Téléchargez `google-services.json`
2. Placez-le dans `android/app/google-services.json`

#### Étape 3: Configuration build.gradle
**Fichier : `android/build.gradle`**
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
        classpath 'com.google.firebase:firebase-crashlytics-gradle:2.9.9'
    }
}
```

**Fichier : `android/app/build.gradle`**
```gradle
plugins {
    id 'com.google.gms.google-services'
    id 'com.google.firebase.crashlytics'
}

android {
    defaultConfig {
        applicationId "com.mayegue.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

### 2.2 Application iOS

#### Étape 1: Ajout de l'App iOS
1. Dans la console Firebase, cliquez sur **"Ajouter une app"**
2. Sélectionnez **iOS**
3. Bundle ID : `com.mayegue.app`
4. Surnom : `Mayegue iOS`

#### Étape 2: Téléchargement des Fichiers de Configuration
1. Téléchargez `GoogleService-Info.plist`
2. Placez-le dans `ios/Runner/GoogleService-Info.plist`

#### Étape 3: Configuration des Capabilities
Dans Xcode, activez :
- **Push Notifications**
- **Background Modes** > **Remote notifications**

---

## 🔧 3. Configuration Technique Flutter

### 3.1 Installation des Dépendances
Ajoutez ces dépendances dans `pubspec.yaml` :
```yaml
dependencies:
  # Firebase Core
  firebase_core: ^2.32.0

  # Authentication
  firebase_auth: ^4.20.0

  # Database
  cloud_firestore: ^4.17.5

  # Storage
  firebase_storage: ^11.7.7

  # Messaging
  firebase_messaging: ^14.7.10

  # Analytics
  firebase_analytics: ^10.8.0

  # Crash Reporting
  firebase_crashlytics: ^3.4.9

  # Dynamic Links (optionnel)
  firebase_dynamic_links: ^5.4.9
```

### 3.2 Configuration Firebase dans le Code

#### Fichier : `lib/firebase_options.dart`
```dart
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'your_api_key_here',
      appId: '1:283937135425:android:1b76e5af09b25394c5dfc0',
      messagingSenderId: '283937135425',
      projectId: 'maa-yegue',
      storageBucket: 'maa-yegue.appspot.com',
    );
  }
}
```

#### Fichier : `lib/main.dart`
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}
```

### 3.3 Configuration des Services Firebase

#### Authentication Service
```dart
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }
}
```

#### Firestore Service
```dart
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile(String uid, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(uid).set(userData);
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  Stream<QuerySnapshot> getDictionaryEntries() {
    return _firestore.collection('dictionary').snapshots();
  }
}
```

#### Storage Service
```dart
class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(String filePath, String fileName) async {
    final ref = _storage.ref().child('uploads/$fileName');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }

  Future<void> deleteFile(String fileName) async {
    final ref = _storage.ref().child('uploads/$fileName');
    await ref.delete();
  }
}
```

#### Messaging Service
```dart
class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _messaging.requestPermission();

    // Get token
    String? token = await _messaging.getToken();

    // Handle messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground messages
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle background messages
    });
  }
}
```

---

## 🔒 4. Règles de Sécurité

### 4.1 Firestore Security Rules
**Fichier : `firestore.rules`**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function getUserRole() {
      return isAuthenticated() ?
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role : null;
    }

    function isAdmin() {
      return getUserRole() == 'admin';
    }

    function isTeacher() {
      return getUserRole() in ['teacher', 'instructor'];
    }

    function isLearner() {
      return getUserRole() in ['learner', 'student'];
    }

    function isTeacherOrAdmin() {
      return isTeacher() || isAdmin();
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Users collection
    match /users/{userId} {
      allow read, write: if isAuthenticated() && request.auth.uid == userId;
      allow read: if isAdmin();
      allow update: if isAdmin() || (isAuthenticated() && request.auth.uid == userId);
    }

    // Dictionary collection
    match /dictionary/{entryId} {
      allow read: if true; // Public read access
      allow write: if isTeacherOrAdmin() ||
        (isAuthenticated() && isOwner(resource.data.contributorId));
      allow update: if isTeacherOrAdmin() ||
        (isAuthenticated() && isOwner(resource.data.contributorId));
    }

    // Lessons collection
    match /lessons/{lessonId} {
      allow read: if true; // Public read access
      allow write: if isTeacherOrAdmin();
      allow update: if isTeacherOrAdmin();
    }

    // Progress collection
    match /progress/{progressId} {
      allow read, write: if isAuthenticated() && request.auth.uid == progressId;
      allow read: if isTeacherOrAdmin();
    }

    // Reviews collection
    match /reviews/{reviewId} {
      allow read: if true;
      allow write: if isTeacherOrAdmin();
      allow update: if isTeacherOrAdmin();
    }
  }
}
```

### 4.2 Storage Security Rules
**Fichier : `storage.rules`**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function getUserRole() {
      return isAuthenticated() ?
        firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.role : null;
    }

    function isAdmin() {
      return getUserRole() == 'admin';
    }

    function isTeacher() {
      return getUserRole() in ['teacher', 'instructor'];
    }

    function isTeacherOrAdmin() {
      return isTeacher() || isAdmin();
    }

    // Lesson media
    match /lessons/{lessonId}/{allPaths=**} {
      allow read: if true;
      allow write: if isTeacherOrAdmin();
      allow delete: if isTeacherOrAdmin();
    }

    // User avatars
    match /users/{userId}/avatar/{fileName} {
      allow read: if true;
      allow write: if isAuthenticated() && request.auth.uid == userId;
      allow delete: if isAuthenticated() && request.auth.uid == userId;
    }

    // Dictionary media
    match /dictionary/{entryId}/{allPaths=**} {
      allow read: if true;
      allow write: if isTeacherOrAdmin();
      allow delete: if isTeacherOrAdmin();
    }

    // Temporary uploads
    match /temp/{userId}/{allPaths=**} {
      allow read, write: if isAuthenticated() && request.auth.uid == userId;
      allow delete: if isAuthenticated() && request.auth.uid == userId;
    }
  }
}
```

---

## 📊 5. Données de Seed et Migration

### 5.1 Structure des Collections

#### Users Collection
```json
{
  "userId": {
    "email": "user@example.com",
    "displayName": "John Doe",
    "role": "learner", // learner, teacher, admin
    "createdAt": "2025-01-01T00:00:00Z",
    "lastLoginAt": "2025-01-01T00:00:00Z",
    "preferences": {
      "language": "fr",
      "notifications": true
    }
  }
}
```

#### Dictionary Collection
```json
{
  "entryId": {
    "canonicalForm": "salut",
    "languageCode": "fr",
    "translations": {
      "ewondo": "məbɔŋ",
      "duala": "mbɔ́ŋ"
    },
    "contributorId": "teacher123",
    "reviewStatus": "verified",
    "difficultyLevel": "beginner",
    "tags": ["greeting", "formal"],
    "createdAt": "2025-01-01T00:00:00Z",
    "updatedAt": "2025-01-01T00:00:00Z"
  }
}
```

#### Lessons Collection
```json
{
  "lessonId": {
    "title": "Introduction à l'Ewondo",
    "description": "Première leçon de langue Ewondo",
    "languageCode": "ewondo",
    "level": "beginner",
    "order": 1,
    "content": "Contenu de la leçon...",
    "audioUrl": "https://storage.googleapis.com/...",
    "videoUrl": "https://storage.googleapis.com/...",
    "createdBy": "teacher123",
    "createdAt": "2025-01-01T00:00:00Z"
  }
}
```

### 5.2 Scripts de Seed
```dart
// lib/scripts/seed_database.dart
class DatabaseSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedLanguages() async {
    final languages = [
      {
        'code': 'ewondo',
        'name': 'Ewondo',
        'group': 'Beti-Pahuin',
        'region': 'Central',
        'type': 'Primary'
      },
      // ... autres langues
    ];

    for (final language in languages) {
      await _firestore.collection('languages').add(language);
    }
  }

  Future<void> seedDictionary() async {
    // Import depuis les fichiers JSON existants
    final dictionaryData = await rootBundle.loadString('assets/seed/dictionary.json');
    final entries = json.decode(dictionaryData) as List;

    for (final entry in entries) {
      await _firestore.collection('dictionary').add(entry);
    }
  }
}
```

---

## 🧪 6. Tests et Validation

### 6.1 Tests d'Intégration Firebase
```dart
// test/integration/firebase_auth_test.dart
void main() {
  group('Firebase Auth Integration', () {
    testWidgets('should sign in with email and password', (tester) async {
      // Test d'authentification
      final authService = FirebaseAuthService();
      final result = await authService.signInWithEmailAndPassword(
        'test@example.com',
        'password123'
      );

      expect(result.user, isNotNull);
      expect(result.user!.email, 'test@example.com');
    });
  });
}
```

### 6.2 Tests Firestore
```dart
// test/integration/firestore_test.dart
void main() {
  group('Firestore Integration', () {
    test('should create and read user profile', () async {
      final firestoreService = FirestoreService();

      // Create profile
      await firestoreService.createUserProfile('testUser', {
        'name': 'Test User',
        'role': 'learner'
      });

      // Read profile
      final profile = await firestoreService.getUserProfile('testUser');
      expect(profile.exists, true);
      expect(profile.data()!['name'], 'Test User');
    });
  });
}
```

---

## 🚀 7. Déploiement et Production

### 7.1 Variables d'Environnement
```bash
# .env.production
FIREBASE_API_KEY=AIzaSyD_your_production_key
FIREBASE_PROJECT_ID=maa-yegue
FIREBASE_APP_ID=1:283937135425:android:your_production_app_id
FIREBASE_MESSAGING_SENDER_ID=283937135425
FIREBASE_STORAGE_BUCKET=maa-yegue.appspot.com

# Autres services
GEMINI_API_KEY=your_production_gemini_key
CAMPAY_API_KEY=your_production_campay_key
```

### 7.2 Déploiement des Règles
```bash
# Installation Firebase CLI
npm install -g firebase-tools

# Connexion
firebase login

# Déploiement des règles
firebase deploy --only firestore:rules,storage:rules --project maa-yegue

# Vérification
firebase deploy --only firestore:rules,storage:rules --project maa-yegue --dry-run
```

### 7.3 Monitoring et Analytics
```dart
// lib/services/analytics_service.dart
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  static Future<void> setUserRole(String role) async {
    await _analytics.setUserProperty(
      name: 'role',
      value: role,
    );
  }
}
```

---

## 🔧 8. Dépannage

### 8.1 Problèmes Courants

#### Erreur "google-services.json not found"
- Vérifiez que le fichier est dans `android/app/`
- Redémarrez Android Studio
- Clean et rebuild le projet

#### Erreur "Firebase app not initialized"
```dart
// Vérifiez l'initialisation dans main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

#### Erreur de Permissions Firestore
- Vérifiez les règles de sécurité
- Testez avec l'émulateur Firebase
- Vérifiez les rôles utilisateur

#### Problèmes de Notifications Push
- Vérifiez les permissions iOS/Android
- Testez avec Firebase Console
- Vérifiez le token FCM

### 8.2 Outils de Debug
```bash
# Test des règles Firestore
firebase emulators:start --only firestore

# Debug des notifications
firebase functions:log

# Vérification des analytics
firebase analytics:events:list
```

---

## 📚 9. Ressources Utiles

### Documentation Officielle
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.google.com/docs/flutter)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

### Outils et Libraries
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [Firebase Emulators](https://firebase.google.com/docs/emulator-suite)
- [FlutterFire Plugins](https://pub.dev/publishers/firebase.google.com/packages)

### Communauté
- [Firebase Slack Community](https://firebase.community/)
- [Stack Overflow - Firebase](https://stackoverflow.com/questions/tagged/firebase)
- [Reddit r/Firebase](https://www.reddit.com/r/Firebase/)

---

## ✅ Checklist de Validation

### Configuration Firebase
- [ ] Projet créé dans Firebase Console
- [ ] Toutes les apps (Android/iOS/Web) ajoutées
- [ ] Fichiers de configuration téléchargés et placés
- [ ] Services activés (Auth, Firestore, Storage, Messaging, Analytics, Crashlytics)

### Code Flutter
- [ ] Dépendances Firebase ajoutées dans pubspec.yaml
- [ ] Firebase initialisé dans main.dart
- [ ] Services Firebase configurés et testés
- [ ] Règles de sécurité déployées

### Sécurité
- [ ] Règles Firestore configurées et testées
- [ ] Règles Storage configurées et testées
- [ ] Authentification fonctionnelle
- [ ] Permissions appropriées

### Données
- [ ] Scripts de seed créés et testés
- [ ] Données de base importées
- [ ] Migrations planifiées

### Tests
- [ ] Tests d'intégration Firebase créés
- [ ] Tests de sécurité effectués
- [ ] Tests de performance validés

### Production
- [ ] Variables d'environnement configurées
- [ ] Monitoring et analytics actifs
- [ ] Plan de backup en place
- [ ] Procédures de rollback définies

---

*Ce guide constitue la référence complète pour la configuration et l'utilisation de Firebase dans l'application Mayegue. Suivez chaque étape attentivement pour assurer une intégration réussie.*

*Dernière mise à jour : Septembre 2025*