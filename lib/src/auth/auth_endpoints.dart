/// Centralized auth endpoint paths.
///
/// **[PER-PROJECT] override point.** Every path lives here so a consumer can
/// adapt to their backend by constructing with overrides, without touching
/// [AuthService]:
///
/// ```dart
/// const endpoints = AuthEndpoints(login: '/v2/sessions', refresh: '/v2/token');
/// ```
class AuthEndpoints {
  const AuthEndpoints({
    this.login = '/auth/login',
    this.register = '/auth/register',
    this.forgotPassword = '/auth/forgot-password',
    this.resetPassword = '/auth/reset-password',
    this.logout = '/auth/logout',
    this.verifyOtp = '/auth/verify-otp',
    this.resendOtp = '/auth/resend-otp',
    this.sendOtp = '/auth/send-otp',
    this.refresh = '/auth/refresh',
  });

  final String login;
  final String register;
  final String forgotPassword;
  final String resetPassword;
  final String logout;
  final String verifyOtp;
  final String resendOtp;

  /// Endpoint for **Flow B** (OTP-first signup): triggers an OTP send before
  /// the user fills the registration form. Override per project if the backend
  /// uses a different path, or leave blank if it shares [resendOtp].
  final String sendOtp;
  final String refresh;
}
