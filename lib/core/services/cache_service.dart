import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/user_profile.dart';

import 'preferences_service.dart';

class CacheService {
  static const String _themeKey = 'theme_mode';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _financialSetupKey = 'financial_setup_completed';
  static const String _currencyKey = 'preferred_currency';
  static const String _localeKey = 'preferred_locale';
  static const String _lastDashboardRefreshKey = 'last_dashboard_refresh';
  static const String _cachedDashboardDataKey = 'cached_dashboard_data';
  static const String _recentAIChatsKey = 'recent_ai_chats';
  static const String _userProfileKey = 'cached_user_profile';
  static const String _notificationsKey = 'notifications_enabled';

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  CacheService([SharedPreferences? prefs])
      : _prefs = prefs,
        _isInitialized = prefs != null;

  Future<void> init() async {
    if (_prefs != null) {
      _isInitialized = true;
      return;
    }
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  bool get isInitialized => _isInitialized;

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('CacheService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // User Profile cache
  Future<bool> saveUserProfile(UserProfile profile) async {
    if (_prefs == null) return false;
    return await _prefs!.setString(_userProfileKey, jsonEncode(profile.toMap()));
  }

  UserProfile? getUserProfile() {
    if (_prefs == null) return null;
    final jsonStr = _prefs!.getString(_userProfileKey);
    if (jsonStr == null) return null;
    try {
      return UserProfile.fromMap(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  // Theme preferences
  Future<bool> saveThemeMode(String themeMode) async {
    if (_prefs == null) return false;
    return await _prefs!.setString(_themeKey, themeMode);
  }

  String getThemeMode() {
    return _prefs?.getString(_themeKey) ?? 'dark';
  }

  // Notifications
  Future<bool> saveNotificationsEnabled(bool enabled) async {
    if (_prefs == null) return false;
    return await _prefs!.setBool(_notificationsKey, enabled);
  }

  bool getNotificationsEnabled() {
    return _prefs?.getBool(_notificationsKey) ?? true;
  }

  // Onboarding
  Future<bool> markOnboardingComplete() async {
    if (_prefs == null) return false;
    return await _prefs!.setBool(_onboardingKey, true);
  }

  bool isOnboardingComplete() {
    return _prefs?.getBool(_onboardingKey) ?? false;
  }

  Future<bool> resetOnboarding() async {
    if (_prefs == null) return false;
    return await _prefs!.setBool(_onboardingKey, false);
  }

  // Financial Setup
  Future<bool> markFinancialSetupComplete() async {
    if (_prefs == null) return false;
    return await _prefs!.setBool(_financialSetupKey, true);
  }

  bool isFinancialSetupComplete() {
    return _prefs?.getBool(_financialSetupKey) ?? false;
  }

  Future<bool> resetFinancialSetup() async {
    if (_prefs == null) return false;
    return await _prefs!.setBool(_financialSetupKey, false);
  }

  // Currency preference
  Future<bool> saveCurrency(String currency) async {
    if (_prefs == null) return false;
    return await _prefs!.setString(_currencyKey, currency);
  }

  String getCurrency() {
    return _prefs?.getString(_currencyKey) ?? 'USD';
  }

  // Locale preference
  Future<bool> saveLocale(String locale) async {
    if (_prefs == null) return false;
    return await _prefs!.setString(_localeKey, locale);
  }

  String getLocale() {
    return _prefs?.getString(_localeKey) ?? 'en_US';
  }

  // Dashboard cache
  Future<bool> saveLastDashboardRefresh() async {
    if (_prefs == null) return false;
    return await _prefs!.setInt(_lastDashboardRefreshKey, DateTime.now().millisecondsSinceEpoch);
  }

  DateTime? getLastDashboardRefresh() {
    final timestamp = _prefs?.getInt(_lastDashboardRefreshKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  Future<bool> saveDashboardData(String jsonData) async {
    if (_prefs == null) return false;
    return await _prefs!.setString(_cachedDashboardDataKey, jsonData);
  }

  String? getDashboardData() {
    return _prefs?.getString(_cachedDashboardDataKey);
  }

  Future<bool> clearDashboardCache() async {
    if (_prefs == null) return false;
    return await _prefs!.remove(_cachedDashboardDataKey);
  }

  // Recent AI chats
  Future<bool> saveRecentAIChats(List<String> chats) async {
    if (_prefs == null) return false;
    return await _prefs!.setStringList(_recentAIChatsKey, chats);
  }

  List<String> getRecentAIChats() {
    return _prefs?.getStringList(_recentAIChatsKey) ?? [];
  }

  Future<bool> addRecentAIChat(String chatId) async {
    final chats = getRecentAIChats();
    chats.insert(0, chatId);
    // Keep only last 10
    if (chats.length > 10) {
      chats.removeRange(10, chats.length);
    }
    return await saveRecentAIChats(chats);
  }

  // Generic methods
  Future<bool> setString(String key, String value) async {
    if (_prefs == null) return false;
    return await _prefs!.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<bool> setInt(String key, int value) async {
    if (_prefs == null) return false;
    return await _prefs!.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  Future<bool> setBool(String key, bool value) async {
    if (_prefs == null) return false;
    return await _prefs!.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  Future<bool> remove(String key) async {
    if (_prefs == null) return false;
    return await _prefs!.remove(key);
  }

  Future<bool> clear() async {
    if (_prefs == null) return false;
    return await _prefs!.clear();
  }
}

final cacheServiceProvider = Provider<CacheService>((ref) {
  try {
    final prefs = ref.watch(sharedPreferencesProvider);
    return CacheService(prefs);
  } catch (_) {
    final service = CacheService();
    service.init().catchError((e) {
      debugPrint('CacheService initialization error: $e');
    });
    return service;
  }
});

// Provider for onboarding status
class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() {
    final cacheService = ref.watch(cacheServiceProvider);
    return cacheService.isOnboardingComplete();
  }

  Future<void> markComplete() async {
    final cacheService = ref.read(cacheServiceProvider);
    await cacheService.markOnboardingComplete();
    state = true;
  }

  Future<void> reset() async {
    final cacheService = ref.read(cacheServiceProvider);
    await cacheService.resetOnboarding();
    state = false;
  }
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, bool>(() {
  return OnboardingNotifier();
});

// Provider for theme mode
class ThemeModeNotifier extends Notifier<String> {
  @override
  String build() {
    final cacheService = ref.watch(cacheServiceProvider);
    return cacheService.getThemeMode();
  }

  Future<void> setTheme(String theme) async {
    final cacheService = ref.read(cacheServiceProvider);
    await cacheService.saveThemeMode(theme);
    state = theme;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, String>(() {
  return ThemeModeNotifier();
});

// Provider for currency
class CurrencyNotifier extends Notifier<String> {
  @override
  String build() {
    final cacheService = ref.watch(cacheServiceProvider);
    return cacheService.getCurrency();
  }

  Future<void> setCurrency(String currency) async {
    final cacheService = ref.read(cacheServiceProvider);
    await cacheService.saveCurrency(currency);
    state = currency;
  }
}

final currencyProvider = NotifierProvider<CurrencyNotifier, String>(() {
  return CurrencyNotifier();
});
