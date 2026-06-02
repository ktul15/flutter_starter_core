import 'social_auth_result.dart';

/// Why a social sign-in did not produce a result.
enum SocialAuthErrorType {
  /// User dismissed the provider UI.
  cancelled,

  /// Provider/native SDK not configured for this platform.
  notConfigured,

  /// Network or provider-side failure.
  failed,
}

/// Raised by a [SocialAuthProvider] when sign-in cannot complete.
class SocialAuthException implements Exception {
  const SocialAuthException({
    required this.provider,
    required this.type,
    required this.message,
  });

  final SocialProvider provider;
  final SocialAuthErrorType type;
  final String message;

  bool get isCancelled => type == SocialAuthErrorType.cancelled;

  @override
  String toString() =>
      'SocialAuthException($provider, $type): $message';
}
