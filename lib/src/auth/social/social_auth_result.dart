/// Supported social identity providers.
enum SocialProvider { google, apple, facebook }

/// Uniform result of a social sign-in, regardless of provider.
///
/// Concrete provider wrappers normalize their SDK's payload into this shape so
/// downstream code (e.g. exchanging [idToken] with your backend) is
/// provider-agnostic.
class SocialAuthResult {
  const SocialAuthResult({
    required this.provider,
    this.idToken,
    this.accessToken,
    this.authorizationCode,
    this.userId,
    this.email,
    this.displayName,
    this.raw = const {},
  });

  final SocialProvider provider;

  /// OIDC ID token (Google/Apple). Usually what the backend verifies.
  final String? idToken;

  /// OAuth access token (Google/Facebook).
  final String? accessToken;

  /// Authorization code (Apple), when using code exchange.
  final String? authorizationCode;

  /// Provider-scoped user id, when available.
  final String? userId;
  final String? email;
  final String? displayName;

  /// Untouched provider payload for fields not normalized above.
  final Map<String, Object?> raw;
}
