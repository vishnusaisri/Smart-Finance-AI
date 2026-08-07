import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  // Initialize Firebase Auth persistence
  Future<void> initializeAuthPersistence() async {
    try {
      await _firebaseAuth.setPersistence(Persistence.LOCAL);
    } catch (e) {
      debugPrint('Auth persistence setup: $e');
    }
  }

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      debugPrint('Firebase login for: $email');
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('Firebase login successful');
      return {'success': true, 'error': null};
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase login error: ${e.code} - ${e.message}');
      String errorMessage = _getAuthErrorMessage(e.code);
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      debugPrint('Firebase login error: $e');
      return {'success': false, 'error': 'An unexpected error occurred. Please try again.'};
    }
  }

  Future<Map<String, dynamic>> signup(String email, String password, String fullName) async {
    try {
      debugPrint('Firebase signup for: $email');
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Update display name
      await credential.user?.updateDisplayName(fullName);
      debugPrint('Firebase signup successful');
      return {'success': true, 'error': null};
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase signup error: ${e.code} - ${e.message}');
      String errorMessage = _getAuthErrorMessage(e.code);
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      debugPrint('Firebase signup error: $e');
      return {'success': false, 'error': 'An unexpected error occurred. Please try again.'};
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await _firebaseAuth.signInWithPopup(
          GoogleAuthProvider(),
        );
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          return {'success': false, 'error': 'Google Sign-In was cancelled.'};
        }
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _firebaseAuth.signInWithCredential(credential);
      }
      
      final user = userCredential.user;
      if (user != null) {
        await _storeUserProfile(user);
      }
      
      return {'success': true, 'error': null, 'userCredential': userCredential};
    } on FirebaseAuthException catch (e) {
      debugPrint('Google Sign-In Firebase error: ${e.code} - ${e.message}');
      String errorMessage = _getAuthErrorMessage(e.code);
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      return {'success': false, 'error': 'Google Sign-In failed. Please try again.'};
    }
  }

  Future<void> _storeUserProfile(User user) async {
    try {
      final profileData = {
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      await _database.ref('users/${user.uid}/profile').set(profileData);
      debugPrint('Google user profile stored for: ${user.email}');
    } catch (e) {
      debugPrint('Error storing user profile: $e');
      // Don't fail sign-in if profile storage fails
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return {'success': true, 'error': null};
    } on FirebaseAuthException catch (e) {
      debugPrint('Password reset error: ${e.code} - ${e.message}');
      String errorMessage = _getAuthErrorMessage(e.code);
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      debugPrint('Password reset error: $e');
      return {'success': false, 'error': 'Failed to send password reset email. Please try again.'};
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      case 'popup-closed-by-user':
        return 'Sign-in popup was closed.';
      case 'popup-blocked':
        return 'Sign-in popup was blocked. Please allow popups for this site.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
