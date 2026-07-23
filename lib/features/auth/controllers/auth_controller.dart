import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_profile_service.dart';

// Auth state enum
enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

// Auth provider
final authStateProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});

// Current user ID provider - Simple Provider with a class
class UserIdState {
  String? userId;
  String? email;
  String? displayName;
  String? photoURL;
  UserIdState({this.userId, this.email, this.displayName, this.photoURL});
}

class UserIdController {
  UserIdState _state = UserIdState();
  final _listeners = <VoidCallback>{};
  
  UserIdState get state => _state;
  
  void setUserId(String? id, {String? email, String? displayName, String? photoURL}) {
    _state = UserIdState(
      userId: id,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
    );
    _notifyListeners();
  }
  
  void clear() {
    _state = UserIdState();
    _notifyListeners();
  }
  
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}

final userIdControllerProvider = Provider<UserIdController>((ref) {
  return UserIdController();
});

// Backwards compatibility alias  
final currentUserIdProvider = Provider<String?>((ref) {
  final controller = ref.watch(userIdControllerProvider);
  return controller.state.userId;
});

class AuthController extends Notifier<AuthState> {
  late AuthService _authService;
  late UserIdController _userIdController;
  late UserProfileService _userProfileService;

  @override
  AuthState build() {
    _authService = ref.watch(authServiceProvider);
    _userIdController = ref.watch(userIdControllerProvider);
    _userProfileService = ref.watch(userProfileServiceProvider);
    
    // Initialize auth persistence
    _authService.initializeAuthPersistence();
    
    _checkAuthStatus();
    return AuthState.initial;
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Listen to Firebase auth state changes
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user != null) {
          _userIdController.setUserId(
            user.uid,
            email: user.email,
            displayName: user.displayName,
            photoURL: user.photoURL,
          );
          
          // Ensure user profile exists in database
          final profile = await _userProfileService.getUserProfile(user.uid);
          if (profile == null) {
            await _userProfileService.createProfileFromAuth(user);
          }
          
          state = AuthState.authenticated;
        } else {
          _userIdController.clear();
          state = AuthState.unauthenticated;
        }
      });
    } catch (e) {
      debugPrint('Auth check error: $e');
      state = AuthState.unauthenticated;
    }
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    try {
      state = AuthState.loading;
      
      final result = await _authService.login(email, password);
      
      if (result['success'] == true) {
        state = AuthState.authenticated;
        return result;
      }
      
      state = AuthState.unauthenticated;
      return result;
    } catch (e) {
      debugPrint('Login controller error: $e');
      state = AuthState.error;
      return {'success': false, 'error': 'An unexpected error occurred. Please try again.'};
    }
  }

  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      state = AuthState.loading;
      
      final result = await _authService.signup(email, password, fullName);
      
      if (result['success'] == true) {
        // Create user profile in Realtime Database
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await _userProfileService.createProfileFromAuth(user, fullName: fullName);
        }
        state = AuthState.authenticated;
        return result;
      }
      
      state = AuthState.unauthenticated;
      return result;
    } catch (e) {
      debugPrint('Signup controller error: $e');
      state = AuthState.error;
      return {'success': false, 'error': 'An unexpected error occurred. Please try again.'};
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      state = AuthState.loading;
      final result = await _authService.signInWithGoogle();
      if (result['success'] == true) {
        // Create user profile in Realtime Database if it doesn't exist
        final userCredential = result['userCredential'] as UserCredential?;
        final user = userCredential?.user;
        if (user != null) {
          final existingProfile = await _userProfileService.getUserProfile(user.uid);
          if (existingProfile == null) {
            await _userProfileService.createProfileFromAuth(user);
          }
        }
        state = AuthState.authenticated;
        return result;
      }
      state = AuthState.unauthenticated;
      return result;
    } catch (e) {
      debugPrint('Google sign-in controller error: $e');
      state = AuthState.error;
      return {'success': false, 'error': 'Google Sign-In failed. Please try again.'};
    }
  }

  Future<void> logout() async {
    state = AuthState.loading;
    await _authService.logout();
    _userIdController.clear();
    state = AuthState.unauthenticated;
  }

  Future<Map<String, dynamic>> resetPassword({required String email}) async {
    try {
      return await _authService.resetPassword(email);
    } catch (e) {
      return {'success': false, 'error': 'Failed to send password reset email. Please try again.'};
    }
  }
}
