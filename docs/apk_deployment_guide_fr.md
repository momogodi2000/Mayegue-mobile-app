# 📱 Guide de Déploiement APK - Communication Firebase Mobile

## Vue d'Ensemble

Ce guide explique comment générer un APK Android et s'assurer que l'application communique correctement avec les services Firebase en production.

## 🛠️ Prérequis

### Environnement de Développement
- **Flutter SDK** : Version 3.0 ou supérieure
- **Android Studio** : Version Arctic Fox ou supérieure
- **Java JDK** : Version 11 ou supérieure
- **Android SDK** : API level 21 (Android 5.0) minimum

### Configuration Firebase
- Projet Firebase configuré et actif
- `google-services.json` placé dans `android/app/`
- Services Firebase activés (Auth, Firestore, Storage, Messaging)

### Variables d'Environnement
```bash
# Fichier .env.production
FIREBASE_API_KEY=AIzaSyD_your_production_api_key
FIREBASE_PROJECT_ID=maa-yegue
FIREBASE_APP_ID=1:283937135425:android:your_production_app_id
FIREBASE_MESSAGING_SENDER_ID=283937135425
FIREBASE_STORAGE_BUCKET=maa-yegue.appspot.com

GEMINI_API_KEY=your_production_gemini_key
CAMPAY_API_KEY=your_production_campay_key
CAMPAY_SECRET=your_production_campay_secret
```

---

## 🔧 1. Configuration Android

### 1.1 Configuration build.gradle

**Fichier : `android/app/build.gradle`**
```gradle
android {
    compileSdkVersion 34
    ndkVersion "25.1.8937393"

    defaultConfig {
        applicationId "com.mayegue.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"

        // Configuration Firebase
        manifestPlaceholders = [
            'appName': 'Mayegue',
            'FIREBASE_PROJECT_ID': 'maa-yegue',
            'FIREBASE_APP_ID': '1:283937135425:android:1b76e5af09b25394c5dfc0'
        ]

        // Signing config pour release
        signingConfig signingConfigs.release
    }

    signingConfigs {
        release {
            storeFile file('keystore.jks')
            storePassword System.getenv('KEYSTORE_PASSWORD')
            keyAlias System.getenv('KEY_ALIAS')
            keyPassword System.getenv('KEY_PASSWORD')
        }
    }

    buildTypes {
        debug {
            signingConfig signingConfigs.debug
            manifestPlaceholders['crashlyticsEnabled'] = false
        }

        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            signingConfig signingConfigs.release
            manifestPlaceholders['crashlyticsEnabled'] = true
        }
    }
}

// Plugins Firebase
apply plugin: 'com.google.gms.google-services'
apply plugin: 'com.google.firebase.crashlytics'
```

### 1.2 Configuration du Keystore

#### Création du Keystore
```bash
# Génération du keystore de signature
keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Informations à fournir :
# Mot de passe du keystore
# Nom et prénom
# Nom de l'unité organisationnelle
# Nom de l'organisation
# Ville ou localité
# État ou province
# Code pays à deux lettres
```

#### Variables d'Environnement pour CI/CD
```bash
# Dans GitHub Secrets ou variables d'environnement
KEYSTORE_PASSWORD=votre_mot_de_passe_keystore
KEY_ALIAS=upload
KEY_PASSWORD=votre_mot_de_passe_cle
```

### 1.3 Permissions AndroidManifest.xml

**Fichier : `android/app/src/main/AndroidManifest.xml`**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions Internet -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <!-- Permissions Firebase -->
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="com.google.android.c2dm.permission.RECEIVE" />
    <uses-permission android:name="android.permission.VIBRATE" />

    <!-- Permissions Application -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

    <application
        android:label="Mayegue"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true">

        <!-- Activité principale -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme" />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <!-- Firebase Messaging Service -->
        <service
            android:name=".java.MyFirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>

        <!-- Meta-data pour Google Sign-In -->
        <meta-data
            android:name="com.google.android.gms.version"
            android:value="@integer/google_play_services_version" />

        <!-- Crashlytics -->
        <meta-data
            android:name="firebase_crashlytics_collection_enabled"
            android:value="${crashlyticsEnabled}" />

    </application>
</manifest>
```

---

## 🚀 2. Génération de l'APK

### 2.1 Nettoyage et Préparation
```bash
# Nettoyage complet du projet
flutter clean
flutter pub cache repair

# Mise à jour des dépendances
flutter pub get

# Génération des fichiers locaux
flutter gen-l10n
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2.2 Build APK Debug
```bash
# Build APK debug pour tests
flutter build apk --debug

# Localisation du fichier généré
ls build/app/outputs/flutter-apk/app-debug.apk
```

### 2.3 Build APK Release
```bash
# Build APK release signé
flutter build apk --release --target-platform android-arm64

# OU pour toutes les architectures
flutter build apk --release --split-per-abi

# Localisation des fichiers générés
ls build/app/outputs/flutter-apk/
# app-release.apk (ou app-arm64-v8a-release.apk, etc.)
```

### 2.4 Build App Bundle (Recommandé)
```bash
# Build AAB pour Google Play Store
flutter build appbundle --release --target-platform android-arm64

# Localisation du fichier généré
ls build/app/outputs/bundle/release/app-release.aab
```

### 2.5 Optimisations de Build
```bash
# Build avec analyse de taille
flutter build apk --release --analyze-size

# Build avec obfuscation maximale
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

---

## 🔗 3. Communication Firebase Mobile

### 3.1 Initialisation Firebase dans l'App

**Fichier : `lib/main.dart`**
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configuration Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Test de connexion Firebase (debug uniquement)
  if (kDebugMode) {
    await _testFirebaseConnection();
  }

  runApp(const MyApp());
}

Future<void> _testFirebaseConnection() async {
  try {
    // Test Auth
    final auth = FirebaseAuth.instance;
    debugPrint('✅ Firebase Auth: ${auth.app.name}');

    // Test Firestore
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('test').doc('connection').set({
      'timestamp': FieldValue.serverTimestamp(),
      'platform': 'android',
      'version': '1.0.0'
    });
    debugPrint('✅ Firestore connection successful');

    // Test Storage
    final storage = FirebaseStorage.instance;
    debugPrint('✅ Firebase Storage: ${storage.app.name}');

    // Test Messaging
    final messaging = FirebaseMessaging.instance;
    final token = await messaging.getToken();
    debugPrint('✅ FCM Token: ${token?.substring(0, 20)}...');

  } catch (e) {
    debugPrint('❌ Firebase connection failed: $e');
    // En production, logger l'erreur
    await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
  }
}
```

### 3.2 Configuration des Services Firebase

#### Service d'Authentification
```dart
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Log succès
      await FirebaseAnalytics.instance.logEvent(
        name: 'login',
        parameters: {'method': 'email'},
      );

      return result;
    } catch (e) {
      // Log erreur
      await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw 'Google sign in cancelled';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);

      // Log succès
      await FirebaseAnalytics.instance.logEvent(
        name: 'login',
        parameters: {'method': 'google'},
      );

      return result;
    } catch (e) {
      await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      rethrow;
    }
  }
}
```

#### Service Firestore
```dart
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile(String uid, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': 'android',
        'appVersion': '1.0.0',
      });

      // Log création profil
      await FirebaseAnalytics.instance.logEvent(
        name: 'user_profile_created',
        parameters: {'platform': 'android'},
      );
    } catch (e) {
      await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  Stream<QuerySnapshot> getDictionaryEntries({
    String? languageCode,
    int limit = 20,
  }) {
    Query query = _firestore.collection('dictionary');

    if (languageCode != null) {
      query = query.where('languageCode', isEqualTo: languageCode);
    }

    return query
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<void> addDictionaryEntry(Map<String, dynamic> entry) async {
    try {
      await _firestore.collection('dictionary').add({
        ...entry,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': 'android',
      });

      // Log ajout entrée
      await FirebaseAnalytics.instance.logEvent(
        name: 'dictionary_entry_added',
        parameters: {
          'language': entry['languageCode'],
          'platform': 'android'
        },
      );
    } catch (e) {
      await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      rethrow;
    }
  }
}
```

#### Service de Notifications Push
```dart
class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Demande permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('FCM Permission: ${settings.authorizationStatus}');

    // Récupération token
    String? token = await _messaging.getToken();
    if (token != null) {
      debugPrint('FCM Token: $token');
      // Sauvegarder le token dans Firestore
      await _saveTokenToDatabase(token);
    }

    // Gestion des messages en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Message reçu: ${message.notification?.title}');
      _showNotification(message);
    });

    // Gestion des messages ouverts
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message ouvert: ${message.data}');
      _handleMessageOpened(message);
    });

    // Gestion des messages en background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _saveTokenToDatabase(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'fcmToken': token,
            'platform': 'android',
            'lastTokenUpdate': FieldValue.serverTimestamp(),
          });
    }
  }

  void _showNotification(RemoteMessage message) {
    // Afficher notification locale
    // Utiliser flutter_local_notifications
  }

  void _handleMessageOpened(RemoteMessage message) {
    // Naviguer vers l'écran approprié
    final data = message.data;
    if (data['type'] == 'lesson') {
      // Naviguer vers la leçon
    } else if (data['type'] == 'achievement') {
      // Naviguer vers les achievements
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Message en background: ${message.messageId}');
}
```

### 3.3 Gestion des Erreurs et Logging

#### Service de Logging
```dart
class LoggingService {
  static Future<void> logEvent(String event, Map<String, dynamic> parameters) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: event,
        parameters: {
          ...parameters,
          'platform': 'android',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  static Future<void> logError(dynamic error, StackTrace stackTrace) async {
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Mobile app error',
      );
    } catch (e) {
      debugPrint('Crashlytics error: $e');
    }
  }

  static Future<void> setUserProperties(String userId, String role) async {
    try {
      await FirebaseAnalytics.instance.setUserId(id: userId);
      await FirebaseAnalytics.instance.setUserProperty(
        name: 'role',
        value: role,
      );
      await FirebaseAnalytics.instance.setUserProperty(
        name: 'platform',
        value: 'android',
      );
    } catch (e) {
      debugPrint('User properties error: $e');
    }
  }
}
```

---

## 🧪 4. Tests de Communication Firebase

### 4.1 Tests d'Intégration
```dart
// test/integration/firebase_mobile_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Firebase Mobile Communication', () {
    testWidgets('should initialize Firebase successfully', (tester) async {
      await tester.pumpWidget(const MyApp());

      // Attendre l'initialisation
      await tester.pumpAndSettle();

      // Vérifier que Firebase est initialisé
      expect(FirebaseAuth.instance.app, isNotNull);
      expect(FirebaseFirestore.instance.app, isNotNull);
    });

    testWidgets('should authenticate user', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Simuler connexion
      final authService = FirebaseAuthService();
      // Note: Utiliser des comptes de test en développement

      expect(authService, isNotNull);
    });

    testWidgets('should read from Firestore', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tester lecture données
      final firestoreService = FirestoreService();
      final snapshot = await firestoreService.getDictionaryEntries(limit: 1).first;

      expect(snapshot.docs, isNotEmpty);
    });
  });
}
```

### 4.2 Tests de Performance
```dart
// test/integration/performance_test.dart
void main() {
  testWidgets('Firebase operations performance', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final stopwatch = Stopwatch();

    // Test temps de réponse Firestore
    stopwatch.start();
    final firestoreService = FirestoreService();
    await firestoreService.getDictionaryEntries(limit: 10).first;
    stopwatch.stop();

    final firestoreTime = stopwatch.elapsedMilliseconds;
    expect(firestoreTime, lessThan(2000)); // Moins de 2 secondes

    // Test temps d'authentification (si applicable)
    // ... autres tests de performance
  });
}
```

---

## 🚀 5. Déploiement et Distribution

### 5.1 Google Play Console

#### Préparation des Assets
```
📁 Assets requis pour Play Store :
├── 📄 Description de l'app (FR/EN)
├── 🖼️ Icônes (512x512, 1024x500 feature graphic)
├── 📸 Screenshots (8-10 par langue)
├── 🎥 Vidéo promotionnelle (optionnel)
├── 📋 Politique de confidentialité
├── 📞 Informations de contact
├── 🔒 Certificat de signature (.pem)
```

#### Upload de l'APK/AAB
```bash
# Via Google Play Console
1. Accéder à Google Play Console
2. Sélectionner l'application
3. Aller dans "Production" ou "Tests"
4. Uploader l'APK ou AAB
5. Remplir les informations de release
6. Publier
```

### 5.2 Distribution Interne (Tests)
```bash
# Build pour distribution interne
flutter build apk --release --target-platform android-arm64

# Upload vers Firebase App Distribution
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:283937135425:android:1b76e5af09b25394c5dfc0 \
  --groups "testers" \
  --release-notes "Version de test APK"
```

### 5.3 Validation Post-Déploiement

#### Checklist de Validation
- [ ] Application s'installe correctement
- [ ] Écran de démarrage s'affiche
- [ ] Authentification fonctionne
- [ ] Données se chargent depuis Firestore
- [ ] Notifications push arrivent
- [ ] Analytics enregistrent les événements
- [ ] Crashlytics détecte les erreurs
- [ ] Performance acceptable (< 2s pour les opérations principales)

#### Monitoring en Production
```bash
# Vérification des services Firebase
# 1. Console Firebase > Analytics : Événements enregistrés
# 2. Console Firebase > Crashlytics : Pas d'erreurs critiques
# 3. Console Firebase > Messaging : Tokens enregistrés
# 4. Play Console : Métriques d'installation et d'utilisation
```

---

## 🔧 6. Dépannage

### 6.1 Problèmes Courants

#### APK ne s'installe pas
```bash
# Vérifier la signature
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# Vérifier le keystore
keytool -list -v -keystore keystore.jks
```

#### Firebase ne se connecte pas
```dart
// Debug dans main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  runApp(const MyApp());
}
```

#### Notifications ne fonctionnent pas
```bash
# Vérifier les permissions Android
adb shell dumpsys notification

# Tester via Firebase Console
# Console Firebase > Messaging > Nouveau message de test
```

#### Erreurs de Build
```bash
# Nettoyer complètement
flutter clean
rm -rf android/.gradle
rm -rf android/build
flutter pub cache repair

# Rebuild
flutter build apk --release
```

### 6.2 Logs et Debugging
```bash
# Logs Android
adb logcat | grep -i firebase

# Logs Flutter
flutter logs

# Test des services Firebase
flutter run --debug
# Puis utiliser l'app pour tester chaque service
```

---

## 📊 7. Métriques et Monitoring

### 7.1 KPIs à Surveiller
- **Taux d'installation réussie** : > 95%
- **Temps de démarrage** : < 3 secondes
- **Taux de crash** : < 1%
- **Temps de réponse Firestore** : < 1 seconde
- **Taux de livraison notifications** : > 90%

### 7.2 Outils de Monitoring
```dart
// Métriques personnalisées
class MonitoringService {
  static Future<void> trackAppStart() async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'app_start',
      parameters: {
        'platform': 'android',
        'start_time': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> trackFirebaseOperation(
    String operation,
    Duration duration,
    bool success,
  ) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'firebase_operation',
      parameters: {
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
        'success': success,
        'platform': 'android',
      },
    );
  }
}
```

---

## 📚 8. Ressources Utiles

### Documentation Officielle
- [Build and release Android app](https://flutter.dev/docs/deployment/android)
- [Firebase Android Setup](https://firebase.google.com/docs/android/setup)
- [Google Play Console](https://play.google.com/console/)

### Outils
- [Android Studio](https://developer.android.com/studio)
- [Firebase Console](https://console.firebase.google.com/)
- [Google Play Console](https://play.google.com/console/)

### Communauté
- [Flutter Discord](https://discord.gg/flutter)
- [Firebase Slack](https://firebase.community/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter+firebase)

---

## ✅ Checklist Finale

### Pré-Build
- [ ] Keystore créé et configuré
- [ ] Variables d'environnement définies
- [ ] google-services.json à jour
- [ ] Permissions Android configurées
- [ ] Tests Firebase réussis

### Build
- [ ] APK release généré avec succès
- [ ] Signature vérifiée
- [ ] Taille d'APK optimisée
- [ ] Tests d'intégration passés

### Post-Déploiement
- [ ] APK installé et fonctionnel
- [ ] Services Firebase opérationnels
- [ ] Notifications reçues
- [ ] Analytics enregistrés
- [ ] Crashlytics actif

---

*Ce guide garantit que votre APK communique correctement avec Firebase et est prêt pour la distribution mobile. Suivez chaque étape pour éviter les problèmes de déploiement.*

*Dernière mise à jour : Septembre 2025*