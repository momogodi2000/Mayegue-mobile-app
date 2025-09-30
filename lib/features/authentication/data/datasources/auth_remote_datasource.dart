import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/user_model.dart';
import '../models/auth_response_model.dart';

/// Remote data source for authentication
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> signInWithEmailAndPassword(String email, String password);
  Future<AuthResponseModel> signUpWithEmailAndPassword(String email, String password, String displayName);
  Future<AuthResponseModel> signInWithGoogle();
  Future<AuthResponseModel> signInWithFacebook();
  Future<AuthResponseModel> signInWithApple();
  Future<String> signInWithPhoneNumber(String phoneNumber);
  Future<AuthResponseModel> verifyPhoneNumber(String verificationId, String smsCode);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<bool> isAuthenticated();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel> updateUserProfile(UserModel user);
  Future<void> deleteUserAccount();
  Stream<UserModel?> get authStateChanges;
}

/// Firebase implementation of AuthRemoteDataSource
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseService firebaseService;

  AuthRemoteDataSourceImpl(this.firebaseService);

  @override
  Future<AuthResponseModel> signInWithEmailAndPassword(String email, String password) async {
    final userCredential = await firebaseService.auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = UserModel.fromFirebaseUser(userCredential.user!);
    return AuthResponseModel(user: user);
  }

  @override
  Future<AuthResponseModel> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    final userCredential = await firebaseService.auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await userCredential.user?.updateDisplayName(displayName);

    final user = UserModel.fromFirebaseUser(userCredential.user!);
    return AuthResponseModel(user: user);
  }

  @override
  Future<AuthResponseModel> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Google sign in cancelled');

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await firebaseService.auth.signInWithCredential(credential);
    final user = UserModel.fromFirebaseUser(userCredential.user!);
    return AuthResponseModel(user: user);
  }

  @override
  Future<AuthResponseModel> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status != LoginStatus.success) {
      throw Exception('Facebook sign in failed: ${result.message}');
    }

    final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);
    final userCredential = await firebaseService.auth.signInWithCredential(credential);
    final user = UserModel.fromFirebaseUser(userCredential.user!);
    return AuthResponseModel(user: user);
  }

  @override
  Future<AuthResponseModel> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await firebaseService.auth.signInWithCredential(oauthCredential);

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Apple sign-in failed: No user returned');
      }

      // Create or update user profile
      final userDoc = firebaseService.firestore.collection('users').doc(user.uid);
      final userData = await userDoc.get();

      if (!userData.exists) {
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? appleCredential.givenName ?? 'Apple User',
          'photoURL': user.photoURL,
          'role': 'learner', // Default role
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'authProvider': 'apple',
        });
      } else {
        await userDoc.update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }

      return AuthResponseModel(
        success: true,
        user: UserModel.fromFirebaseUser(user),
        message: 'Connexion avec Apple réussie',
      );
    } catch (e) {
      throw Exception('Échec de connexion avec Apple: $e');
    }
  }

  @override
  Future<String> signInWithPhoneNumber(String phoneNumber) async {
    // Completer to handle the async nature of verifyPhoneNumber
    final completer = Completer<String>();

    await firebaseService.auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval or instant verification on Android
        // This callback is called when SMS is automatically retrieved
        // We don't complete here as we want to return the verificationId
        // for manual verification flow
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          completer.completeError(
            Exception('The phone number entered is invalid.'),
          );
        } else {
          completer.completeError(
            Exception('Phone verification failed: ${e.message}'),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        // SMS code sent successfully, return the verificationId
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-retrieval timeout, but we already have the verificationId
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
    );

    return completer.future;
  }

  @override
  Future<AuthResponseModel> verifyPhoneNumber(String verificationId, String smsCode) async {
    try {
      // Create credential with verification ID and SMS code
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in with the credential
      final userCredential = await firebaseService.auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Phone verification failed: No user returned');
      }

      final user = userCredential.user!;

      // Create or update user profile in Firestore
      final userDoc = firebaseService.firestore.collection('users').doc(user.uid);
      final userData = await userDoc.get();

      if (!userData.exists) {
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? user.phoneNumber ?? 'Phone User',
          'phoneNumber': user.phoneNumber,
          'photoURL': user.photoURL,
          'role': 'learner', // Default role
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'authProvider': 'phone',
          'isEmailVerified': false,
        });
      } else {
        await userDoc.update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }

      return AuthResponseModel(
        success: true,
        user: UserModel.fromFirebaseUser(user),
        message: 'Phone verification successful',
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        throw Exception('The verification code entered is invalid.');
      } else if (e.code == 'session-expired') {
        throw Exception('The verification code has expired. Please request a new code.');
      } else {
        throw Exception('Phone verification failed: ${e.message}');
      }
    }
  }

  @override
  Future<void> signOut() async {
    await firebaseService.auth.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = firebaseService.auth.currentUser;
    return firebaseUser != null ? UserModel.fromFirebaseUser(firebaseUser) : null;
  }

  @override
  Future<bool> isAuthenticated() async {
    return firebaseService.auth.currentUser != null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await firebaseService.auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    final firebaseUser = firebaseService.auth.currentUser;
    if (firebaseUser == null) throw Exception('No authenticated user');

    await firebaseUser.updateDisplayName(user.displayName);
    if (user.photoUrl != null) {
      await firebaseUser.updatePhotoURL(user.photoUrl);
    }

    // Update in Firestore
    await firebaseService.firestore
        .collection('users')
        .doc(user.id)
        .update(user.toFirestore());

    return user;
  }

  @override
  Future<void> deleteUserAccount() async {
    final firebaseUser = firebaseService.auth.currentUser;
    if (firebaseUser == null) throw Exception('No authenticated user');

    // Delete from Firestore
    await firebaseService.firestore.collection('users').doc(firebaseUser.uid).delete();

    // Delete from Auth
    await firebaseUser.delete();
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseService.auth.authStateChanges().map((firebaseUser) {
      return firebaseUser != null ? UserModel.fromFirebaseUser(firebaseUser) : null;
    });
  }
}
