import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../config/environment_config.dart';
import 'firebase_service.dart';

/// Service for setting up the default admin user
class AdminSetupService {
  final FirebaseService _firebaseService;

  AdminSetupService(this._firebaseService);

  /// Check if default admin exists
  Future<bool> defaultAdminExists() async {
    try {
      final adminEmail = EnvironmentConfig.defaultAdminEmail;

      // Check in Firestore
      final querySnapshot = await _firebaseService.firestore
          .collection('users')
          .where('email', isEqualTo: adminEmail)
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if admin exists: $e');
      }
      return false;
    }
  }

  /// Create the default admin user
  Future<Map<String, dynamic>> createDefaultAdmin() async {
    try {
      final adminEmail = EnvironmentConfig.defaultAdminEmail;
      final adminPassword = EnvironmentConfig.defaultAdminPassword;
      final adminName = EnvironmentConfig.defaultAdminName;

      // Validate credentials
      if (adminEmail.isEmpty || adminPassword.isEmpty) {
        throw Exception(
          'Default admin credentials not set in environment configuration',
        );
      }

      if (adminPassword.length < 8) {
        throw Exception(
          'Default admin password must be at least 8 characters long',
        );
      }

      // Check if admin already exists
      if (await defaultAdminExists()) {
        throw Exception('Default admin user already exists');
      }

      // Create Firebase Auth user
      final userCredential = await _firebaseService.auth
          .createUserWithEmailAndPassword(
            email: adminEmail,
            password: adminPassword,
          );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create admin user');
      }

      // Update display name
      await user.updateDisplayName(adminName);

      // Create admin profile in Firestore with all privileges
      final now = FieldValue.serverTimestamp();
      await _firebaseService.firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': adminEmail,
        'displayName': adminName,
        'role': 'admin',
        'photoURL': null,
        'phoneNumber': null,
        'isEmailVerified': false,
        'isActive': true,
        'isDefaultAdmin': true,
        'createdAt': now,
        'lastLoginAt': now,
        'authProvider': 'email',
        'twoFactorEnabled': false,
        'permissions': [
          'view_lessons',
          'create_lessons',
          'edit_lessons',
          'delete_lessons',
          'view_dictionary',
          'add_dictionary_entries',
          'edit_dictionary_entries',
          'delete_dictionary_entries',
          'review_dictionary_entries',
          'take_assessments',
          'create_assessments',
          'view_assessment_results',
          'participate_in_community',
          'moderate_community',
          'use_ai_assistant',
          'configure_ai_settings',
          'play_games',
          'create_games',
          'manage_users',
          'view_analytics',
          'system_configuration',
          'content_moderation',
          'process_payments',
          'view_payment_history',
        ],
        'profile': {
          'bio': 'Administrateur par défaut de la plateforme Ma\'a yegue',
          'preferredLanguage': 'fr',
          'timezone': 'Africa/Douala',
        },
        'stats': {
          'lessonsCreated': 0,
          'dictionaryEntriesAdded': 0,
          'usersManaged': 0,
        },
      });

      // Send email verification
      await user.sendEmailVerification();

      if (kDebugMode) {
        print('Default admin user created successfully: $adminEmail');
      }

      return {
        'success': true,
        'uid': user.uid,
        'email': adminEmail,
        'message': 'Admin par défaut créé avec succès',
      };
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth error creating admin: ${e.code} - ${e.message}');
      }

      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'L\'email est déjà utilisé';
          break;
        case 'invalid-email':
          errorMessage = 'Email invalide';
          break;
        case 'weak-password':
          errorMessage = 'Mot de passe trop faible';
          break;
        default:
          errorMessage = 'Erreur lors de la création: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating default admin: $e');
      }
      throw Exception('Erreur inattendue lors de la création de l\'admin: $e');
    }
  }

  /// Reset admin password (for recovery)
  Future<void> resetAdminPassword() async {
    try {
      final adminEmail = EnvironmentConfig.defaultAdminEmail;
      await _firebaseService.auth.sendPasswordResetEmail(email: adminEmail);

      if (kDebugMode) {
        print('Password reset email sent to admin: $adminEmail');
      }
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Get admin users count
  Future<int> getAdminCount() async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting admin count: $e');
      }
      return 0;
    }
  }

  /// Promote a user to admin
  Future<void> promoteToAdmin(
    String userId, {
    required String promotedBy,
  }) async {
    try {
      await _firebaseService.firestore.collection('users').doc(userId).update({
        'role': 'admin',
        'promotedToAdminAt': FieldValue.serverTimestamp(),
        'promotedBy': promotedBy,
        'permissions': FieldValue.arrayUnion([
          'manage_users',
          'view_analytics',
          'system_configuration',
          'content_moderation',
          'process_payments',
        ]),
      });

      // Log the action
      await _firebaseService.firestore.collection('admin_logs').add({
        'action': 'promote_to_admin',
        'userId': userId,
        'performedBy': promotedBy,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('User $userId promoted to admin by $promotedBy');
      }
    } catch (e) {
      throw Exception('Failed to promote user to admin: $e');
    }
  }

  /// Demote an admin to regular user
  Future<void> demoteAdmin(String userId, {required String demotedBy}) async {
    try {
      // Check if it's the default admin
      final userDoc = await _firebaseService.firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.data()?['isDefaultAdmin'] == true) {
        throw Exception('Cannot demote the default admin');
      }

      await _firebaseService.firestore.collection('users').doc(userId).update({
        'role': 'learner',
        'demotedFromAdminAt': FieldValue.serverTimestamp(),
        'demotedBy': demotedBy,
        'permissions': [
          'view_lessons',
          'view_dictionary',
          'take_assessments',
          'view_assessment_results',
          'participate_in_community',
          'use_ai_assistant',
          'play_games',
          'view_payment_history',
        ],
      });

      // Log the action
      await _firebaseService.firestore.collection('admin_logs').add({
        'action': 'demote_from_admin',
        'userId': userId,
        'performedBy': demotedBy,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('User $userId demoted from admin by $demotedBy');
      }
    } catch (e) {
      throw Exception('Failed to demote admin: $e');
    }
  }

  /// Get all admin users
  Future<List<Map<String, dynamic>>> getAllAdmins() async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting all admins: $e');
      }
      return [];
    }
  }
}
