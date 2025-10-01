import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Service to initialize default admin account on first app launch
class AdminInitializationService {
  static const String _adminInitializedKey = 'admin_initialized';
  static const String _defaultAdminEmail = 'admin@mayegue.app';

  /// Check if default admin has been created
  static Future<bool> isAdminInitialized() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_adminInitializedKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Check if any admin exists in Firestore
  static Future<bool> adminExists() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking admin existence: $e');
      return false;
    }
  }

  /// Create default admin user
  /// Returns the admin user data if successful, null otherwise
  static Future<Map<String, dynamic>?> createDefaultAdmin({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Check if admin already exists
      if (await adminExists()) {
        debugPrint('Admin already exists, skipping creation');
        return null;
      }

      // Create admin user in Firebase Auth
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create admin user');
      }

      // Update display name
      await user.updateDisplayName(displayName);

      // Create admin document in Firestore
      final adminData = {
        'uid': user.uid,
        'email': email,
        'displayName': displayName,
        'role': 'admin',
        'authProvider': 'email',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'isSuperAdmin': true, // First admin is super admin
        'permissions': [
          'manage_users',
          'manage_content',
          'manage_teachers',
          'manage_admins',
          'view_analytics',
          'system_settings',
        ],
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(adminData);

      // Mark admin as initialized
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_adminInitializedKey, true);
      await prefs.setString('default_admin_email', email);
      await prefs.setString(
        'admin_created_at',
        DateTime.now().toIso8601String(),
      );

      debugPrint('✅ Default admin created successfully: $email');

      return {
        ...adminData,
        'uid': user.uid,
        'createdAt': DateTime.now(),
        'lastLoginAt': DateTime.now(),
      };
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth error creating admin: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Error creating default admin: $e');
      rethrow;
    }
  }

  /// Initialize admin if needed (called on app startup)
  /// Returns true if admin setup is required, false if already initialized
  static Future<bool> checkAndInitializeAdmin() async {
    try {
      // Check if admin initialization has been done
      if (await isAdminInitialized()) {
        debugPrint('✅ Admin already initialized');
        return false;
      }

      // Check if any admin exists in database
      if (await adminExists()) {
        debugPrint('✅ Admin exists in database');
        // Mark as initialized
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_adminInitializedKey, true);
        return false;
      }

      // No admin exists - setup required
      debugPrint('⚠️ No admin found - admin setup required');
      return true;
    } catch (e) {
      debugPrint('❌ Error checking admin initialization: $e');
      return false;
    }
  }

  /// Get default admin email
  static String getDefaultAdminEmail() {
    return _defaultAdminEmail;
  }

  /// Reset admin initialization (for testing/dev only)
  static Future<void> resetAdminInitialization() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_adminInitializedKey);
      await prefs.remove('default_admin_email');
      await prefs.remove('admin_created_at');
      debugPrint('⚠️ Admin initialization reset');
    } catch (e) {
      debugPrint('Error resetting admin initialization: $e');
    }
  }

  /// Create additional admin (can only be done by existing admin)
  static Future<Map<String, dynamic>?> createAdminUser({
    required String email,
    required String password,
    required String displayName,
    required String creatorAdminUid,
  }) async {
    try {
      // Verify creator is an admin
      final creatorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(creatorAdminUid)
          .get();

      if (!creatorDoc.exists || creatorDoc.data()?['role'] != 'admin') {
        throw Exception('Only admins can create other admin accounts');
      }

      // Create new admin
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create admin user');
      }

      await user.updateDisplayName(displayName);

      // Create admin document
      final adminData = {
        'uid': user.uid,
        'email': email,
        'displayName': displayName,
        'role': 'admin',
        'authProvider': 'email',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': creatorAdminUid,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'isSuperAdmin': false, // Only first admin is super admin
        'permissions': [
          'manage_users',
          'manage_content',
          'manage_teachers',
          'view_analytics',
        ],
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(adminData);

      debugPrint('✅ Admin user created: $email');

      return {
        ...adminData,
        'uid': user.uid,
      };
    } catch (e) {
      debugPrint('❌ Error creating admin user: $e');
      rethrow;
    }
  }

  /// Create teacher account (can only be done by admin)
  static Future<Map<String, dynamic>?> createTeacherUser({
    required String email,
    required String password,
    required String displayName,
    required String creatorAdminUid,
  }) async {
    try {
      // Verify creator is an admin
      final creatorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(creatorAdminUid)
          .get();

      if (!creatorDoc.exists || creatorDoc.data()?['role'] != 'admin') {
        throw Exception('Only admins can create teacher accounts');
      }

      // Create teacher
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create teacher user');
      }

      await user.updateDisplayName(displayName);

      // Create teacher document
      final teacherData = {
        'uid': user.uid,
        'email': email,
        'displayName': displayName,
        'role': 'teacher',
        'authProvider': 'email',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': creatorAdminUid,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'isApproved': true, // Auto-approved since created by admin
        'permissions': [
          'create_content',
          'edit_own_content',
          'view_students',
          'grade_assignments',
        ],
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(teacherData);

      debugPrint('✅ Teacher user created: $email');

      return {
        ...teacherData,
        'uid': user.uid,
      };
    } catch (e) {
      debugPrint('❌ Error creating teacher user: $e');
      rethrow;
    }
  }
}
