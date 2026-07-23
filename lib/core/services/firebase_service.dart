import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to manage global Firebase and Auth initialization
final firebaseInitProvider = FutureProvider<bool>((ref) async {
  try {
    // Note: Firebase.initializeApp is already called in main.dart
    // We just ensure we have access to it here
    final auth = FirebaseAuth.instance;
    
    // Set proper web auth persistence
    if (kIsWeb) {
      await auth.setPersistence(Persistence.LOCAL);
    }
    
    // Wait for the first auth state to settle for hydration
    await auth.authStateChanges().first;
    
    return true;
  } catch (e) {
    // If it fails (e.g., no configuration found), return false to use mock services
    return false;
  }
});
