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
    this.refresh = '/auth/refresh',
  });

  final String login;
  final String register;
  final String forgotPassword;
  final String resetPassword;
  final String logout;
  final String verifyOtp;
  final String resendOtp;
  final String refresh;
}
