import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to manage global Firebase and Auth initialization
final firebaseInitProvider = FutureProvider<bool>((ref) async {
  try {
    final auth = FirebaseAuth.instance;
    
    if (kIsWeb) {
      await auth.setPersistence(Persistence.LOCAL);
    }
    
    await auth.authStateChanges().first.timeout(
      const Duration(seconds: 3),
      onTimeout: () => auth.currentUser,
    );
    
    return true;
  } catch (e) {
    debugPrint('Firebase init check error: $e');
    return false;
  }
});
