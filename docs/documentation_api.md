# Documentation des APIs - Mayegue App

## Vue d'Ensemble

L'application Mayegue intègre plusieurs services externes pour fournir une expérience complète d'apprentissage des langues. Cette documentation détaille l'intégration et l'utilisation de chaque API externe.

## 🔥 Firebase Suite

### Authentication
Service d'authentification multi-fournisseurs avec gestion des utilisateurs.

#### Configuration
```dart
// Initialisation
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

// Fournisseurs supportés
final GoogleSignIn googleSignIn = GoogleSignIn();
final FacebookAuth facebookAuth = FacebookAuth.instance;
```

#### Méthodes d'Authentification
```dart
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Email/Mot de passe
  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Google Sign-In
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  // Facebook Sign-In
  Future<UserCredential> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();

    final OAuthCredential credential = FacebookAuthProvider.credential(
      result.accessToken!.token,
    );

    return _auth.signInWithCredential(credential);
  }

  // Apple Sign-In
  Future<UserCredential> signInWithApple() async {
    final AuthorizationCredentialAppleID credential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email],
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: credential.identityToken,
    );

    return _auth.signInWithCredential(oauthCredential);
  }

  // Authentification téléphone
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        // Sauvegarder verificationId pour utilisation ultérieure
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}
```

#### Gestion des Utilisateurs
```dart
class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Création profil utilisateur
  Future<void> createUserProfile(User user, Map<String, dynamic> profileData) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'role': 'learner', // learner, teacher, admin
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      ...profileData,
    });
  }

  // Mise à jour profil
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    await _firestore.collection('users').doc(userId).update({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Récupération profil
  Future<DocumentSnapshot> getUserProfile(String userId) {
    return _firestore.collection('users').doc(userId).get();
  }
}
```

### Firestore Database
Base de données NoSQL en temps réel pour les données structurées.

#### Structure des Collections
```
firestore/
├── users/                    # Profils utilisateurs
│   └── {userId}/
├── languages/                # Langues disponibles
│   └── {languageId}/
├── lessons/                  # Leçons
│   └── {lessonId}/
├── dictionary/               # Entrées dictionnaire
│   └── {entryId}/
├── progress/                 # Progression utilisateurs
│   └── {userId}/
├── payments/                 # Transactions paiement
│   └── {paymentId}/
├── gamification/             # Données gamification
│   └── {userId}/
└── community/                # Posts communautaires
    └── {postId}/
```

#### Opérations CRUD
```dart
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupération avec cache
  Future<List<Lesson>> getLessons(String languageId) async {
    final query = _firestore
        .collection('lessons')
        .where('languageId', isEqualTo: languageId)
        .orderBy('order')
        .limit(20);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Lesson.fromFirestore(doc)).toList();
  }

  // Écriture avec gestion d'erreurs
  Future<void> saveProgress(String userId, String lessonId, Map<String, dynamic> progress) async {
    try {
      await _firestore
          .collection('progress')
          .doc('${userId}_${lessonId}')
          .set({
            'userId': userId,
            'lessonId': lessonId,
            'completedAt': FieldValue.serverTimestamp(),
            'score': progress['score'],
            'timeSpent': progress['timeSpent'],
          }, SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Erreur sauvegarde progression: $e');
    }
  }

  // Écoute temps réel
  Stream<List<CommunityPost>> watchCommunityPosts(String languageId) {
    return _firestore
        .collection('community')
        .where('languageId', isEqualTo: languageId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CommunityPost.fromFirestore(doc)).toList());
  }

  // Transactions pour atomicité
  Future<void> completeLessonAndUpdateStats(String userId, String lessonId) async {
    await _firestore.runTransaction((transaction) async {
      // Marquer leçon comme complétée
      final lessonRef = _firestore.collection('progress').doc('${userId}_${lessonId}');
      transaction.set(lessonRef, {
        'completed': true,
        'completedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Mettre à jour statistiques utilisateur
      final userStatsRef = _firestore.collection('user_stats').doc(userId);
      final userStats = await transaction.get(userStatsRef);

      final currentLessons = userStats.data()?['completedLessons'] ?? 0;
      transaction.update(userStatsRef, {
        'completedLessons': currentLessons + 1,
        'lastActivity': FieldValue.serverTimestamp(),
      });
    });
  }
}
```

### Firebase Storage
Stockage de fichiers pour médias et documents.

#### Gestion des Fichiers
```dart
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload d'image de profil
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child('profile_images/$userId/profile.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw StorageException('Erreur upload image: $e');
    }
  }

  // Upload audio dictionnaire
  Future<String> uploadDictionaryAudio(String languageId, String wordId, File audioFile) async {
    final ref = _storage.ref().child('dictionary_audio/$languageId/$wordId.mp3');
    await ref.putFile(audioFile, SettableMetadata(contentType: 'audio/mpeg'));
    return await ref.getDownloadURL();
  }

  // Téléchargement avec progression
  Future<void> downloadLessonMedia(String lessonId, Function(double) onProgress) async {
    final ref = _storage.ref().child('lesson_media/$lessonId/content.zip');

    final downloadTask = ref.writeToFile(File('path/to/local/file.zip'));

    downloadTask.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      onProgress(progress);
    });

    await downloadTask;
  }

  // Gestion du cache local
  Future<File> getCachedFile(String fileName) async {
    final localFile = File('${await _getCacheDir()}/$fileName');

    if (await localFile.exists()) {
      return localFile;
    }

    // Télécharger depuis Storage
    final ref = _storage.ref().child(fileName);
    await ref.writeToFile(localFile);

    return localFile;
  }
}
```

### Firebase Messaging
Notifications push pour engagement utilisateur.

#### Configuration
```dart
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Demander permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Récupérer token
    final token = await _messaging.getToken();
    await _saveTokenToDatabase(token);

    // Gestion des messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  Future<void> _saveTokenToDatabase(String? token) async {
    if (token != null) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'fcmToken': token});
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Afficher notification locale
    LocalNotifications.showNotification(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Traiter message en arrière-plan
    await Firebase.initializeApp();

    switch (message.data['type']) {
      case 'lesson_reminder':
        await _scheduleLessonReminder();
        break;
      case 'achievement_unlocked':
        await _showAchievementNotification(message.data);
        break;
    }
  }
}
```

## 🤖 Gemini AI

### Configuration
Assistant IA pour génération de contenu pédagogique et assistance interactive.

#### Initialisation
```dart
class GeminiAIService {
  final Dio _dio;
  final String _apiKey;

  GeminiAIService(this._dio, this._apiKey);

  Future<String> generateContent(String prompt, {
    String model = 'gemini-pro',
    double temperature = 0.7,
  }) async {
    try {
      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        }),
        data: {
          'contents': [{
            'parts': [{
              'text': prompt
            }]
          }],
          'generationConfig': {
            'temperature': temperature,
            'maxOutputTokens': 2048,
          }
        },
      );

      return response.data['candidates'][0]['content']['parts'][0]['text'];
    } catch (e) {
      throw AIServiceException('Erreur IA: $e');
    }
  }
}
```

#### Cas d'Usage Pédagogiques
```dart
class AIEducationService {
  final GeminiAIService _aiService;

  // Génération de leçons personnalisées
  Future<Lesson> generateCustomLesson({
    required String language,
    required String topic,
    required String level,
    required String userBackground,
  }) async {
    final prompt = '''
    Génère une leçon en $language sur le thème "$topic" pour un niveau $level.
    Contexte utilisateur: $userBackground

    Structure la leçon avec:
    1. Objectifs d'apprentissage
    2. Vocabulaire clé
    3. Explications grammaticales
    4. Exercices pratiques
    5. Évaluation

    Formate en JSON structuré.
    ''';

    final response = await _aiService.generateContent(prompt);
    return Lesson.fromJson(json.decode(response));
  }

  // Correction d'exercices
  Future<CorrectionResult> correctExercise({
    required String userAnswer,
    required String correctAnswer,
    required String language,
  }) async {
    final prompt = '''
    Corrige cette réponse d'exercice en $language:

    Réponse utilisateur: "$userAnswer"
    Réponse correcte: "$correctAnswer"

    Fournis:
    1. Score (0-100)
    2. Feedback détaillé
    3. Explication de l'erreur
    4. Suggestions d'amélioration
    ''';

    final response = await _aiService.generateContent(prompt);
    return CorrectionResult.fromJson(json.decode(response));
  }

  // Génération de conversations
  Future<List<Message>> generateConversation({
    required String language,
    required String scenario,
    required String difficulty,
  }) async {
    final prompt = '''
    Génère une conversation en $language pour le scénario: $scenario
    Niveau de difficulté: $difficulty

    Crée 5-7 échanges entre 2 personnages.
    Inclue des notes culturelles et des explications de vocabulaire.
    ''';

    final response = await _aiService.generateContent(prompt);
    final data = json.decode(response);
    return (data['conversation'] as List)
        .map((msg) => Message.fromJson(msg))
        .toList();
  }

  // Analyse de prononciation (avec audio)
  Future<PronunciationAnalysis> analyzePronunciation({
    required String audioBase64,
    required String targetText,
    required String language,
  }) async {
    final prompt = '''
    Analyse cette prononciation en $language.
    Texte cible: "$targetText"

    [Audio fourni en base64]

    Évalue:
    1. Exactitude phonétique (0-100)
    2. Erreurs spécifiques
    3. Score global
    4. Conseils d'amélioration
    ''';

    final response = await _aiService.generateContent(prompt);
    return PronunciationAnalysis.fromJson(json.decode(response));
  }
}
```

## 💳 CamPay

### Configuration
Passerelle de paiement mobile camerounais (MTN, Orange).

#### Initialisation
```dart
class CamPayService {
  final Dio _dio;
  final String _apiKey;
  final String _secret;
  final String _environment; // 'sandbox' ou 'production'

  String get _baseUrl => _environment == 'production'
      ? 'https://api.campay.net'
      : 'https://demo.campay.net';

  Future<String> _getAccessToken() async {
    final auth = base64.encode(utf8.encode('$_apiKey:$_secret'));

    final response = await _dio.post(
      '$_baseUrl/token/',
      options: Options(headers: {
        'Authorization': 'Basic $auth',
        'Content-Type': 'application/x-www-form-urlencoded',
      }),
      data: 'grant_type=client_credentials',
    );

    return response.data['access_token'];
  }
}
```

#### Collecte de Paiement
```dart
class CamPayService {
  // Initiation de paiement
  Future<CamPayPaymentResponse> collectPayment({
    required double amount,
    required String currency, // 'XAF'
    required String from, // numéro téléphone
    required String description,
    required String externalReference,
  }) async {
    final token = await _getAccessToken();

    final response = await _dio.post(
      '$_baseUrl/api/collect/',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
      data: {
        'amount': amount.toString(),
        'currency': currency,
        'from': from,
        'description': description,
        'external_reference': externalReference,
      },
    );

    return CamPayPaymentResponse.fromJson(response.data);
  }

  // Vérification statut paiement
  Future<CamPayStatusResponse> checkPaymentStatus(String reference) async {
    final token = await _getAccessToken();

    final response = await _dio.get(
      '$_baseUrl/api/transaction/$reference/',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
    );

    return CamPayStatusResponse.fromJson(response.data);
  }

  // Webhook pour confirmations
  Future<void> handleWebhook(Map<String, dynamic> webhookData) async {
    final reference = webhookData['external_reference'];
    final status = webhookData['status'];

    // Mettre à jour statut dans Firestore
    await FirebaseFirestore.instance
        .collection('payments')
        .doc(reference)
        .update({
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
          'webhookData': webhookData,
        });

    // Traiter selon statut
    switch (status) {
      case 'SUCCESSFUL':
        await _processSuccessfulPayment(reference);
        break;
      case 'FAILED':
        await _processFailedPayment(reference);
        break;
    }
  }
}
```

#### Modèles de Données
```dart
class CamPayPaymentResponse {
  final String reference;
  final String status;
  final String? ussdCode;
  final String? operator; // 'MTN' ou 'ORANGE'

  CamPayPaymentResponse({
    required this.reference,
    required this.status,
    this.ussdCode,
    this.operator,
  });

  factory CamPayPaymentResponse.fromJson(Map<String, dynamic> json) {
    return CamPayPaymentResponse(
      reference: json['reference'],
      status: json['status'],
      ussdCode: json['ussd_code'],
      operator: json['operator'],
    );
  }
}

class CamPayStatusResponse {
  final String reference;
  final String status;
  final double amount;
  final String currency;
  final String? operatorReference;

  CamPayStatusResponse({
    required this.reference,
    required this.status,
    required this.amount,
    required this.currency,
    this.operatorReference,
  });

  factory CamPayStatusResponse.fromJson(Map<String, dynamic> json) {
    return CamPayStatusResponse(
      reference: json['reference'],
      status: json['status'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      operatorReference: json['operator_reference'],
    );
  }
}
```

## 🔄 NouPai

### Configuration
Passerelle de paiement alternative pour redondance.

#### Structure Similaire à CamPay
```dart
class NouPaiService {
  final Dio _dio;
  final String _apiKey;
  final String _secret;

  Future<NouPaiPaymentResponse> initiatePayment({
    required double amount,
    required String phoneNumber,
    required String description,
  }) async {
    // Implémentation similaire à CamPay
    // Adaptée à l'API NouPai
  }

  Future<NouPaiStatusResponse> checkPaymentStatus(String transactionId) async {
    // Vérification statut paiement
  }
}
```

## 🔄 Intégration et Gestion d'Erreurs

### Service de Paiement Unifié
```dart
class PaymentService {
  final CamPayService _camPayService;
  final NouPaiService _nouPaiService;

  Future<PaymentResult> processPayment({
    required double amount,
    required String phoneNumber,
    required String description,
    required PaymentProvider preferredProvider,
  }) async {
    try {
      // Essayer le fournisseur préféré
      switch (preferredProvider) {
        case PaymentProvider.camPay:
          return await _tryCamPayPayment(amount, phoneNumber, description);
        case PaymentProvider.nouPai:
          return await _tryNouPaiPayment(amount, phoneNumber, description);
      }
    } catch (e) {
      // Fallback vers l'autre fournisseur
      try {
        final fallbackProvider = preferredProvider == PaymentProvider.camPay
            ? PaymentProvider.nouPai
            : PaymentProvider.camPay;

        return await processPayment(
          amount: amount,
          phoneNumber: phoneNumber,
          description: description,
          preferredProvider: fallbackProvider,
        );
      } catch (fallbackError) {
        throw PaymentException('Échec des deux passerelles: $e, $fallbackError');
      }
    }
  }

  Future<PaymentResult> _tryCamPayPayment(
    double amount,
    String phoneNumber,
    String description,
  ) async {
    final response = await _camPayService.collectPayment(
      amount: amount,
      currency: 'XAF',
      from: phoneNumber,
      description: description,
      externalReference: _generateReference(),
    );

    return PaymentResult(
      provider: PaymentProvider.camPay,
      reference: response.reference,
      status: _mapCamPayStatus(response.status),
      ussdCode: response.ussdCode,
    );
  }
}
```

### Gestion d'Erreurs Robuste
```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class FirebaseException extends ApiException {
  FirebaseException(String message) : super(message);
}

class AIServiceException extends ApiException {
  AIServiceException(String message) : super(message);
}

class PaymentException extends ApiException {
  PaymentException(String message) : super(message);
}

// Gestion centralisée d'erreurs
class ErrorHandler {
  static String getUserFriendlyMessage(dynamic error) {
    if (error is FirebaseException) {
      return 'Erreur de connexion. Vérifiez votre connexion internet.';
    } else if (error is AIServiceException) {
      return 'Service IA temporairement indisponible.';
    } else if (error is PaymentException) {
      return 'Erreur de paiement. Réessayez ou contactez le support.';
    } else if (error is DioError) {
      switch (error.type) {
        case DioErrorType.connectTimeout:
          return 'Connexion lente. Réessayez.';
        case DioErrorType.receiveTimeout:
          return 'Réponse lente du serveur.';
        default:
          return 'Erreur réseau. Vérifiez votre connexion.';
      }
    }

    return 'Une erreur inattendue s\'est produite.';
  }

  static void logError(dynamic error, StackTrace? stackTrace) {
    // Log vers Firebase Crashlytics
    FirebaseCrashlytics.instance.recordError(error, stackTrace);

    // Log vers service de monitoring personnalisé
    AnalyticsService.logError(error.toString(), stackTrace: stackTrace);
  }
}
```

Cette documentation couvre l'intégration complète des APIs externes utilisées dans Mayegue, assurant une compréhension approfondie de leur fonctionnement et de leur gestion.