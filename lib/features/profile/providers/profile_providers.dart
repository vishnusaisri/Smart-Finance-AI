import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/services/cache_service.dart';
import '../../auth/services/user_profile_service.dart';

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

    final cached = _cacheService.getUserProfile();
    if (cached != null) {
      return cached;
    }

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
      final cachedProfile = _cacheService.getUserProfile();
      if (cachedProfile != null) {
        state = cachedProfile;
      }

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null && firebaseUser.uid.isNotEmpty) {
        final remoteProfile = await ref
            .read(userProfileServiceProvider)
            .getUserProfile(firebaseUser.uid);
        if (remoteProfile != null) {
          state = remoteProfile;
          await _cacheService.saveUserProfile(remoteProfile);
        }
      }
    } catch (e) {
      debugPrint('Failed to load profile: $e');
    }
  }

  Future<void> _saveProfile(UserProfile profile) async {
    state = profile;
    await _cacheService.saveUserProfile(profile);
    try {
      if (profile.uid.isNotEmpty) {
        await ref.read(userProfileServiceProvider).saveUserProfile(profile);
      }
    } catch (e) {
      debugPrint('Failed to save profile to database: $e');
    }
  }

  Future<void> updateProfile(
    UserProfile updatedProfile,
  ) async {
    await _saveProfile(updatedProfile);
  }

  Future<void> updatePersonalInfo({
    required String name,
    required String email,
  }) async {
    final updated = state.copyWith(
      fullName: name,
      name: name,
      email: email,
      updatedAt: DateTime.now(),
    );
    await _saveProfile(updated);
  }

  Future<void> updateFinancialGoals({
    required double monthlyIncome,
    required double savingsGoal,
  }) async {
    final updated = state.copyWith(
      monthlyIncome: monthlyIncome,
      savingsGoal: savingsGoal,
      updatedAt: DateTime.now(),
    );
    await _saveProfile(updated);
  }

  Future<void> updateCurrency(
    String currency,
  ) async {
    final updated = state.copyWith(
      currency: currency,
      updatedAt: DateTime.now(),
    );
    await _saveProfile(updated);
  }

  Future<void> updateLocale(
    String locale,
  ) async {
    final updated = state.copyWith(
      locale: locale,
      updatedAt: DateTime.now(),
    );
    await _saveProfile(updated);
  }

  Future<void> updateNotifications({
    required bool notificationsEnabled,
    required bool budgetAlertsEnabled,
    required bool spendingLimitAlerts,
    required bool lowBalanceAlerts,
    required bool weeklyReports,
    required bool monthlyReports,
  }) async {
    final updated = state.copyWith(
      notificationsEnabled: notificationsEnabled,
      budgetAlertsEnabled: budgetAlertsEnabled,
      spendingLimitAlerts: spendingLimitAlerts,
      lowBalanceAlerts: lowBalanceAlerts,
      weeklyReports: weeklyReports,
      monthlyReports: monthlyReports,
      updatedAt: DateTime.now(),
    );
    await _saveProfile(updated);
  }

  Future<void> toggleDarkMode(
    bool enabled,
  ) async {
    final updated = state.copyWith(
      darkMode: enabled,
      updatedAt: DateTime.now(),
    );
    await _saveProfile(updated);
    await ref.read(themeModeProvider.notifier).setTheme(enabled ? 'dark' : 'light');
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

// Personal Info Form Notifier
class PersonalInfoFormNotifier extends Notifier<Map<String, String?>> {
  @override
  Map<String, String?> build() {
    final profile = ref.watch(userProfileProvider);
    return {
      'name': profile.name,
      'email': profile.email,
      'nameError': null,
      'emailError': null,
    };
  }

  void updateName(String name) {
    state = {...state, 'name': name, 'nameError': null};
  }

  void updateEmail(String email) {
    state = {...state, 'email': email, 'emailError': null};
  }

  Map<String, String> getFormData() {
    final profile = ref.read(userProfileProvider);
    return {
      'name': state['name'] ?? profile.name,
      'email': state['email'] ?? profile.email,
    };
  }
}

final personalInfoFormProvider = NotifierProvider<PersonalInfoFormNotifier, Map<String, String?>>(() {
  return PersonalInfoFormNotifier();
});

// Financial Goals Form Notifier
class FinancialGoalsFormNotifier extends Notifier<Map<String, String?>> {
  @override
  Map<String, String?> build() {
    final profile = ref.watch(userProfileProvider);
    return {
      'monthlyIncome': profile.monthlyIncome.toString(),
      'savingsGoal': profile.savingsGoal.toString(),
      'monthlyIncomeError': null,
      'savingsGoalError': null,
    };
  }

  void updateMonthlyIncome(String income) {
    state = {...state, 'monthlyIncome': income, 'monthlyIncomeError': null};
  }

  void updateSavingsGoal(String goal) {
    state = {...state, 'savingsGoal': goal, 'savingsGoalError': null};
  }

  Map<String, double> getFormData() {
    final profile = ref.read(userProfileProvider);
    final income = double.tryParse(state['monthlyIncome'] ?? '') ?? profile.monthlyIncome;
    final savings = double.tryParse(state['savingsGoal'] ?? '') ?? profile.savingsGoal;
    return {
      'monthlyIncome': income,
      'savingsGoal': savings,
    };
  }
}

final financialGoalsFormProvider = NotifierProvider<FinancialGoalsFormNotifier, Map<String, String?>>(() {
  return FinancialGoalsFormNotifier();
});