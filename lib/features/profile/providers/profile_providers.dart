import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/services/cache_service.dart';

// User Profile Provider
class UserProfileNotifier extends Notifier<UserProfile> {

  late CacheService _cacheService;

  @override
  UserProfile build() {

    _cacheService = ref.watch(
      cacheServiceProvider,
    );

    final firebaseUser =
        FirebaseAuth.instance.currentUser;

    _loadProfile();

    return UserProfile(
      uid: firebaseUser?.uid ?? '',
      fullName: firebaseUser?.displayName ?? firebaseUser?.email?.split('@')[0] ?? 'User',
      email: firebaseUser?.email ?? '',
      avatarUrl: firebaseUser?.photoURL,
      monthlyIncome: 0.0,
      savingsGoal: 0.0,
      currency: 'INR',
      locale: 'en_US',
      notificationsEnabled: true,
      budgetAlertsEnabled: true,
      spendingLimitAlerts: true,
      lowBalanceAlerts: true,
      weeklyReports: true,
      monthlyReports: true,
      darkMode: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _loadProfile() async {

    try {

      final cachedProfile =
          _cacheService.getUserProfile();

      if (cachedProfile != null) {
        state = cachedProfile;
      }

    } catch (e) {

      debugPrint(
        'Failed to load cached profile: $e',
      );
    }
  }

  Future<void> updateProfile(
    UserProfile updatedProfile,
  ) async {

    state = updatedProfile;

    await _cacheService.saveUserProfile(
      updatedProfile,
    );
  }

  Future<void> updatePersonalInfo({
    required String name,
    required String email,
  }) async {

    state = state.copyWith(
      fullName: name,
      email: email,
      updatedAt: DateTime.now(),
    );

    await _cacheService.saveUserProfile(
      state,
    );
  }

  Future<void> updateFinancialGoals({
    required double monthlyIncome,
    required double savingsGoal,
  }) async {

    state = state.copyWith(
      monthlyIncome: monthlyIncome,
      savingsGoal: savingsGoal,
      updatedAt: DateTime.now(),
    );

    await _cacheService.saveUserProfile(
      state,
    );
  }

  Future<void> updateCurrency(
    String currency,
  ) async {

    state = state.copyWith(
      currency: currency,
      updatedAt: DateTime.now(),
    );

    await _cacheService.saveUserProfile(
      state,
    );
  }

  Future<void> updateLocale(
    String locale,
  ) async {

    state = state.copyWith(
      locale: locale,
      updatedAt: DateTime.now(),
    );

    await _cacheService.saveUserProfile(
      state,
    );
  }

  Future<void> updateNotifications({
    required bool notificationsEnabled,
    required bool budgetAlertsEnabled,
    required bool spendingLimitAlerts,
    required bool lowBalanceAlerts,
    required bool weeklyReports,
    required bool monthlyReports,
  }) async {

    state = state.copyWith(
      notificationsEnabled:
          notificationsEnabled,

      budgetAlertsEnabled:
          budgetAlertsEnabled,

      spendingLimitAlerts:
          spendingLimitAlerts,

      lowBalanceAlerts:
          lowBalanceAlerts,

      weeklyReports:
          weeklyReports,

      monthlyReports:
          monthlyReports,

      updatedAt: DateTime.now(),
    );

    await _cacheService.saveUserProfile(
      state,
    );
  }

  Future<void> toggleDarkMode(
    bool enabled,
  ) async {

    state = state.copyWith(
      darkMode: enabled,
      updatedAt: DateTime.now(),
    );

    await _cacheService.saveUserProfile(
      state,
    );
  }
}

final userProfileProvider =
    NotifierProvider<
        UserProfileNotifier,
        UserProfile>(
  () {
    return UserProfileNotifier();
  },
);

// Available currencies
final availableCurrenciesProvider =
    Provider<List<Map<String, String>>>(
  (ref) {

    return [
      {
        'code': 'INR',
        'name': 'Indian Rupee',
        'symbol': '₹',
      },
      {
        'code': 'USD',
        'name': 'US Dollar',
        'symbol': '\$',
      },

      {
        'code': 'EUR',
        'name': 'Euro',
        'symbol': '€',
      },

      {
        'code': 'GBP',
        'name': 'British Pound',
        'symbol': '£',
      },

      {
        'code': 'JPY',
        'name': 'Japanese Yen',
        'symbol': '¥',
      },

      {
        'code': 'CAD',
        'name': 'Canadian Dollar',
        'symbol': 'C\$',
      },

      {
        'code': 'AUD',
        'name': 'Australian Dollar',
        'symbol': 'A\$',
      },

      {
        'code': 'CHF',
        'name': 'Swiss Franc',
        'symbol': 'Fr',
      },

      {
        'code': 'CNY',
        'name': 'Chinese Yuan',
        'symbol': '¥',
      },
    ];
  },
);

// Available locales
final availableLocalesProvider =
    Provider<List<Map<String, String>>>(
  (ref) {

    return [
      {
        'code': 'en_US',
        'name': 'English (US)',
      },

      {
        'code': 'en_GB',
        'name': 'English (UK)',
      },

      {
        'code': 'es_ES',
        'name': 'Español',
      },

      {
        'code': 'fr_FR',
        'name': 'Français',
      },

      {
        'code': 'de_DE',
        'name': 'Deutsch',
      },

      {
        'code': 'it_IT',
        'name': 'Italiano',
      },

      {
        'code': 'pt_BR',
        'name': 'Português',
      },

      {
        'code': 'ru_RU',
        'name': 'Русский',
      },

      {
        'code': 'zh_CN',
        'name': '中文',
      },

      {
        'code': 'ja_JP',
        'name': '日本語',
      },

      {
        'code': 'ko_KR',
        'name': '한국어',
      },
    ];
  },
);