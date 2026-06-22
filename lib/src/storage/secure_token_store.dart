import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_store.dart';

/// [TokenStore] backed by `flutter_secure_storage` (Keychain / Keystore).
///
/// Inject a custom [FlutterSecureStorage] (or platform options) for testing or
/// to tune accessibility/encryption per platform.
///
/// **Exception handling:** Keychain/Keystore operations can throw
/// [PlatformException] when the secure store is temporarily unavailable (e.g.,
/// device rebooted but not yet unlocked on iOS). Read operations degrade
/// gracefully by returning `null` — the caller sees an unauthenticated state.
/// Write and clear operations rethrow so the caller can decide how to surface
/// the failure (e.g., logout the user).
class SecureTokenStore implements TokenStore {
  SecureTokenStore({
    FlutterSecureStorage? storage,
    this.accessTokenKey = _defaultAccessKey,
    this.refreshTokenKey = _defaultRefreshKey,
  }) : _storage = storage ?? const FlutterSecureStorage();

  static const _defaultAccessKey = 'fsc_access_token';
  static const _defaultRefreshKey = 'fsc_refresh_token';

  final FlutterSecureStorage _storage;

  /// Storage key for the access token. Override to avoid collisions across apps
  /// sharing a keychain group.
  final String accessTokenKey;

  /// Storage key for the refresh token.
  final String refreshTokenKey;

  @override
  Future<String?> readAccessToken() async {
    try {
      return await _storage.read(key: accessTokenKey);
    } on PlatformException {
      return null; // Keychain unavailable (locked) → treat as unauthenticated
    }
  }

  @override
  Future<String?> readRefreshToken() async {
    try {
      return await _storage.read(key: refreshTokenKey);
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<void> writeTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: accessTokenKey, value: accessToken);
    if (refreshToken == null) return;
    if (refreshToken.isEmpty) {
      await _storage.delete(key: refreshTokenKey);
    } else {
      await _storage.write(key: refreshTokenKey, value: refreshToken);
    }
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: accessTokenKey);
    await _storage.delete(key: refreshTokenKey);
  }

  @override
  Future<bool> get hasAccessToken async =>
      (await readAccessToken())?.isNotEmpty ?? false;
}
