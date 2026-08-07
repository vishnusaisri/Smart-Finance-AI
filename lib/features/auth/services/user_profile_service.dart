import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_profile.dart';

// User Profile Service - handles Firebase Realtime Database user profile operations
class UserProfileService {
  final FirebaseDatabase? _database;
  final FirebaseAuth? _auth;

  UserProfileService() 
      : _database = _getDatabase(),
        _auth = _getFirebaseAuth();

  static FirebaseDatabase? _getDatabase() {
    try {
      return FirebaseDatabase.instance;
    } catch (e) {
      return null;
    }
  }

  static FirebaseAuth? _getFirebaseAuth() {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      return null;
    }
  }

  bool get isAvailable => _auth != null && _database != null;

  // Helper to convert dynamic Maps from RTDB to String keys
  Map<String, dynamic>? _convertToMap(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      return data.map((key, value) {
        final keyString = key.toString();
        if (value is Map) {
          return MapEntry(keyString, _convertToMap(value));
        } else if (value is List) {
          return MapEntry(keyString, value.map((item) {
            if (item is Map) {
              return _convertToMap(item);
            }
            return item;
          }).toList());
        }
        return MapEntry(keyString, value);
      });
    }
    return null;
  }

  // Get user profile from Realtime Database
  Future<UserProfile?> getUserProfile(String userId) async {
    if (!isAvailable) return null;

    try {
      final snapshot = await _database!.ref('users/$userId').get();
      if (snapshot.exists && snapshot.value != null && snapshot.value is Map) {
        final Map<String, dynamic> data = _convertToMap(snapshot.value) ?? {};
        return UserProfile.fromMap(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // Create or update user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    if (!isAvailable) return;

    try {
      await _database!.ref('users/${profile.uid}').set(profile.toMap());
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      rethrow;
    }
  }

  // Create user profile from Firebase Auth user
  Future<UserProfile> createProfileFromAuth(User user, {
    String? fullName,
    double monthlyIncome = 0,
    double savingsGoal = 0,
  }) async {
    final profile = UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      fullName: fullName ?? user.displayName ?? '',
      monthlyIncome: monthlyIncome,
      savingsGoal: savingsGoal,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await saveUserProfile(profile);
    return profile;
  }

  // Update user profile fields
  Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    if (!isAvailable) return;

    try {
      updates['updatedAt'] = DateTime.now().toIso8601String();
      await _database!.ref('users/$userId').update(updates);
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  // Stream user profile changes
  Stream<UserProfile?> watchUserProfile(String userId) {
    if (!isAvailable) {
      return Stream.value(null);
    }

    return _database!.ref('users/$userId').onValue.map((event) {
      final val = event.snapshot.value;
      if (val != null && val is Map) {
        final Map<String, dynamic> data = _convertToMap(val) ?? {};
        return UserProfile.fromMap(data);
      }
      return null;
    });
  }

  // Delete user profile
  Future<void> deleteProfile(String userId) async {
    if (!isAvailable) return;

    try {
      await _database!.ref('users/$userId').remove();
    } catch (e) {
      debugPrint('Error deleting user profile: $e');
      rethrow;
    }
  }
}

// Provider
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});

// Current user profile provider (stream-based)
final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final auth = FirebaseAuth.instance.currentUser;
  if (auth == null) {
    return Stream.value(null);
  }
  return ref.watch(userProfileServiceProvider).watchUserProfile(auth.uid);
});
