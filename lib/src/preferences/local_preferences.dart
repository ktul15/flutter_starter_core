import 'package:shared_preferences/shared_preferences.dart';

import 'app_preferences.dart';

/// [AppPreferences] implementation backed by `shared_preferences`.
///
/// Stores non-sensitive user preferences (onboarding state, theme choice,
/// feature toggles). For auth tokens use [SecureTokenStore] instead.
///
/// ```dart
/// final prefs = await LocalPreferences.create();
/// await prefs.setBool('onboardingDone', true);
/// ```
class LocalPreferences implements AppPreferences {
  LocalPreferences(this._prefs);

  final SharedPreferences _prefs;

  /// Initialises SharedPreferences and returns a ready-to-use instance.
  static Future<LocalPreferences> create() async =>
      LocalPreferences(await SharedPreferences.getInstance());

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<bool?> getBool(String key) async => _prefs.getBool(key);

  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  Future<int?> getInt(String key) async => _prefs.getInt(key);

  @override
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Future<void> clear() => _prefs.clear();

  @override
  bool containsKey(String key) => _prefs.containsKey(key);
}
