/// Persistence contract for auth tokens.
///
/// The network layer depends only on this interface (via callbacks), never on a
/// concrete implementation, so apps can swap in any backend. Default impl:
/// [SecureTokenStore].
abstract interface class TokenStore {
  /// Current access token, or `null` if unauthenticated.
  Future<String?> readAccessToken();

  /// Current refresh token, or `null` if none stored.
  Future<String?> readRefreshToken();

  /// Persists tokens. A `null` [refreshToken] leaves any existing one untouched;
  /// pass an empty string to clear just the refresh token.
  Future<void> writeTokens({required String accessToken, String? refreshToken});

  /// Removes all stored tokens (logout).
  Future<void> clear();

  /// Convenience: `true` when an access token is present.
  Future<bool> get hasAccessToken async =>
      (await readAccessToken())?.isNotEmpty ?? false;
}
