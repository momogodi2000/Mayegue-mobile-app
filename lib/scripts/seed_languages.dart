import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
import '../core/utils/language_seeder.dart';

/// Command-line script to seed languages data
/// Run with: dart run lib/scripts/seed_languages.dart
void main() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Create seeder instance
    final seeder = LanguageSeeder(FirebaseFirestore.instance);

    // Optional: Clear existing data (uncomment if needed)
    // await seeder.clearLanguages();

    // Seed new data
    await seeder.seedLanguages();

    // Language seeding completed
  } catch (e) {
    exit(1);
  }
}
