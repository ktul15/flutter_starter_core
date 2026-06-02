import 'social_auth_result.dart';

/// Contract every social provider wrapper implements.
///
/// **[PER-PROJECT] implementation.** The package intentionally does **not**
/// bundle `google_sign_in` / `sign_in_with_apple` / `flutter_facebook_auth` —
/// that would force three heavy, version-volatile native dependencies (and
/// their platform setup) on every consumer. Instead, each app implements this
/// interface with the SDK it actually needs, one file per provider, and injects
/// the instances it uses. Apps that need no social login pull nothing extra.
///
/// Implementations must throw [SocialAuthException] (never a raw SDK error) and
/// map user dismissal to [SocialAuthErrorType.cancelled].
abstract interface class SocialAuthProvider {
  /// Which provider this wraps.
  SocialProvider get provider;

  /// Launches the provider flow and returns a normalized result.
  ///
  /// Throws [SocialAuthException] on cancellation or failure.
  Future<SocialAuthResult> signIn();

  /// Signs out of the provider session (where the SDK supports it).
  Future<void> signOut();
}
