/// Supported social identity providers.
enum SocialProvider { google, apple, facebook }

/// Uniform result of a social sign-in, regardless of provider.
///
/// Concrete provider wrappers normalize their SDK's payload into this shape so
/// downstream code (e.g. exchanging [idToken] with the backend) is
/// provider-agnostic.
///
/// **Per-provider field availability:**
///
/// | Field | Google | Apple | Facebook |
/// |-------|--------|-------|----------|
/// | [idToken] | ✅ always | ✅ first sign-in only | ❌ |
/// | [accessToken] | ✅ always | ❌ | ✅ always |
/// | [authorizationCode] | ❌ | ✅ first sign-in only | ❌ |
/// | [userId] | ✅ | ✅ always (use for returning users) | ✅ |
/// | [nonce] | when requested | when requested | ❌ |
///
/// **Apple caveat:** Apple only returns [idToken] and [authorizationCode] on
/// the very first sign-in for a given user. Subsequent sign-ins return only
/// [userId]. Your backend must persist the Apple user on first sign-in and
/// look them up by [userId] on subsequent ones.
class SocialAuthResult {
  const SocialAuthResult({
    required this.provider,
    this.idToken,
    this.accessToken,
    this.authorizationCode,
    this.userId,
    this.email,
    this.displayName,
    this.nonce,
    this.raw = const {},
  });

  final SocialProvider provider;

  /// OIDC ID token — what the backend typically verifies.
  ///
  /// Always present for Google. Present on **first Apple sign-in only**.
  /// Not provided by Facebook.
  final String? idToken;

  /// OAuth2 access token.
  ///
  /// Present for Google and Facebook. Not provided by Apple.
  final String? accessToken;

  /// Authorization code for server-side token exchange.
  ///
  /// Present on **first Apple sign-in only**. Not provided by Google/Facebook.
  final String? authorizationCode;

  /// Provider-scoped user ID.
  ///
  /// For Apple, this is the only persistent identifier across sign-ins —
  /// use it to identify returning users when [idToken] is null.
  final String? userId;

  final String? email;
  final String? displayName;

  /// Cryptographic nonce used when initiating the sign-in flow.
  ///
  /// Required for Apple Sign In and recommended for Google to prevent replay
  /// attacks. Generate a secure random string before launching the provider
  /// UI, pass it to the SDK, and store it here. The backend verifies the
  /// nonce claim inside the [idToken] against this value.
  ///
  /// **Omitting the nonce for Apple Sign In is a security vulnerability.**
  final String? nonce;

  /// Untouched provider payload for fields not normalized above.
  final Map<String, Object?> raw;
}
