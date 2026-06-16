/// Generic key-value storage interface.
///
/// Separates non-sensitive user preferences from the secure [TokenStore].
/// Use [LocalPreferences] (backed by `shared_preferences`) for most needs; swap
/// the impl behind this interface for testing or alternative backends.
abstract interface class AppPreferences {
  /// Returns the string stored at [key], or `null` if absent.
  Future<String?> getString(String key);

  /// Stores [value] at [key], replacing any previous value.
  Future<void> setString(String key, String value);

  /// Returns the bool stored at [key], or `null` if absent.
  Future<bool?> getBool(String key);

  /// Stores [value] at [key].
  Future<void> setBool(String key, bool value);

  /// Returns the int stored at [key], or `null` if absent.
  Future<int?> getInt(String key);

  /// Stores [value] at [key].
  Future<void> setInt(String key, int value);

  /// Removes the value at [key]. No-op if absent.
  Future<void> remove(String key);

  /// Clears all stored values.
  Future<void> clear();

  /// Returns `true` if a value exists at [key].
  bool containsKey(String key);
}
