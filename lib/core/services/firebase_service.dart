import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Firebase service for centralized Firebase operations
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late final FirebaseStorage _storage;
  late final FirebaseMessaging _messaging;
  late final FirebaseAnalytics _analytics;
  late final FirebaseCrashlytics _crashlytics;

  bool _initialized = false;

  /// Initialize Firebase services
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();

      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _messaging = FirebaseMessaging.instance;
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;

      // Configure Firestore for offline persistence
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Configure Crashlytics
      await _crashlytics.setCrashlyticsCollectionEnabled(true);

      // Request notification permissions
      await _requestNotificationPermissions();

      _initialized = true;
    } catch (e) {
      rethrow;
    }
  }

  /// Get Firebase Auth instance
  FirebaseAuth get auth => _auth;

  /// Get Firestore instance
  FirebaseFirestore get firestore => _firestore;

  /// Get Storage instance
  FirebaseStorage get storage => _storage;

  /// Get Messaging instance
  FirebaseMessaging get messaging => _messaging;

  /// Get Analytics instance
  FirebaseAnalytics get analytics => _analytics;

  /// Get Crashlytics instance
  FirebaseCrashlytics get crashlytics => _crashlytics;

  /// Request notification permissions
  Future<void> _requestNotificationPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      final token = await _messaging.getToken();

      // Save token to user profile if user is authenticated
      if (token != null && currentUser != null) {
        try {
          await _firestore.collection('users').doc(currentUser!.uid).update({
            'fcmToken': token,
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          // Silently fail if user document doesn't exist yet
          // Token will be saved on next login
        }
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        if (currentUser != null) {
          _firestore.collection('users').doc(currentUser!.uid).update({
            'fcmToken': newToken,
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    }
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
