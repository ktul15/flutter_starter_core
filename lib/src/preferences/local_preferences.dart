import 'package:shared_preferences/shared_preferences.dart';

import 'app_preferences.dart';

/// [AppPreferences] implementation backed by `shared_preferences`.
///
/// All keys are stored with a [keyPrefix] (default `'fsc_'`) so this
/// package's keys never collide with the host app's own SharedPreferences
/// keys. [clear] removes only keys written through this instance
/// (prefix-matched), leaving any other keys in the SharedPreferences
/// namespace untouched.
///
/// Use [SecureTokenStore] for auth tokens — this is for non-sensitive prefs
/// (onboarding state, theme choice, feature toggles, etc.).
///
/// ```dart
/// final prefs = await LocalPreferences.create();
/// await prefs.setBool('onboardingDone', true);
/// ```
class LocalPreferences implements AppPreferences {
  LocalPreferences(this._prefs, {String keyPrefix = 'fsc_'})
      : _prefix = keyPrefix;

  final SharedPreferences _prefs;
  final String _prefix;

  /// Initialises SharedPreferences and returns a ready-to-use instance.
  static Future<LocalPreferences> create({String keyPrefix = 'fsc_'}) async =>
      LocalPreferences(await SharedPreferences.getInstance(),
          keyPrefix: keyPrefix);

  String _k(String key) => '$_prefix$key';

  @override
  Future<String?> getString(String key) async => _prefs.getString(_k(key));

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(_k(key), value);

  @override
  Future<bool?> getBool(String key) async => _prefs.getBool(_k(key));

  @override
  Future<void> setBool(String key, bool value) =>
      _prefs.setBool(_k(key), value);

  @override
  Future<int?> getInt(String key) async => _prefs.getInt(_k(key));

  @override
  Future<void> setInt(String key, int value) => _prefs.setInt(_k(key), value);

  @override
  Future<void> remove(String key) => _prefs.remove(_k(key));

  /// Removes only keys written through this instance (those starting with
  /// [keyPrefix]). Keys written by other libraries or the host app directly
  /// are not affected.
  @override
  Future<void> clear() async {
    final keys =
        _prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }

  @override
  Future<bool> containsKey(String key) async => _prefs.containsKey(_k(key));
}
