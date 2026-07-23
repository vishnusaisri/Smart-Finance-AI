import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this provider in ProviderScope overrides');
});

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService(ref.watch(sharedPreferencesProvider));
});

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static const String _keyThemeMode = 'themeMode';
  static const String _keyHasSeenOnboarding = 'hasSeenOnboarding';
  static const String _keyCachedDashboard = 'cachedDashboard';

  // Theme
  bool get isDarkMode => _prefs.getBool(_keyThemeMode) ?? true;
  Future<void> setDarkMode(bool isDark) async => await _prefs.setBool(_keyThemeMode, isDark);

  // Onboarding
  bool get hasSeenOnboarding => _prefs.getBool(_keyHasSeenOnboarding) ?? false;
  Future<void> setHasSeenOnboarding(bool seen) async => await _prefs.setBool(_keyHasSeenOnboarding, seen);

  // Cached Dashboard
  String? get cachedDashboardData => _prefs.getString(_keyCachedDashboard);
  Future<void> setCachedDashboardData(String json) async => await _prefs.setString(_keyCachedDashboard, json);
  Future<void> clearCache() async => await _prefs.remove(_keyCachedDashboard);
}
