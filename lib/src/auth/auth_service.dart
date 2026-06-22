import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../network/api_client.dart';
import '../network/api_exception.dart';
import '../network/api_result.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/request_runner.dart';
import '../storage/token_store.dart';
import 'auth_endpoints.dart';
import 'models/auth_response.dart';
import 'models/register_request.dart';

/// High-level auth operations over [ApiClient].
///
/// Every method funnels through `requestRunner` and returns an [ApiResult].
/// When a [TokenStore] is supplied, successful auth responses are persisted and
/// [logout] clears it — so [refreshToken] can back an [AuthInterceptor]:
///
/// ```dart
/// final auth = AuthService(client: client, tokenStore: store);
/// AuthInterceptor(
///   dio: client.dio,
///   tokenProvider: store.readAccessToken,
///   refreshToken: () async => (await auth.refreshToken()).isSuccess,
///   onAuthExpired: () => store.clear(),
/// );
/// ```
class AuthService {
  AuthService({
    required ApiClient client,
    TokenStore? tokenStore,
    AuthEndpoints endpoints = const AuthEndpoints(),
  })  : _client = client,
        _tokenStore = tokenStore,
        _endpoints = endpoints;

  final ApiClient _client;
  final TokenStore? _tokenStore;
  final AuthEndpoints _endpoints;

  static AuthResponse _parseAuth(dynamic data) =>
      AuthResponse.fromJson(data as Map<String, dynamic>);

  Future<ApiResult<AuthResponse>> login(String email, String password) async {
    final result = await requestRunner(
      () => _client.post(_endpoints.login, data: {
        'email': email,
        'password': password,
      }),
      _parseAuth,
    );
    return _persist(result);
  }

  Future<ApiResult<AuthResponse>> register(RegisterRequest request) async {
    final result = await requestRunner(
      () => _client.post(_endpoints.register, data: request.toJson()),
      _parseAuth,
    );
    return _persist(result);
  }

  Future<ApiResult<void>> forgotPassword(String email) => requestRunner(
        () => _client.post(_endpoints.forgotPassword, data: {'email': email}),
        (_) {},
      );

  Future<ApiResult<void>> resetPassword(String token, String newPassword) =>
      requestRunner(
        () => _client.post(_endpoints.resetPassword, data: {
          'token': token,
          'password': newPassword,
        }),
        (_) {},
      );

  Future<ApiResult<AuthResponse>> verifyOtp(String email, String code) async {
    final result = await requestRunner(
      () => _client.post(_endpoints.verifyOtp, data: {
        'email': email,
        'code': code,
      }),
      _parseAuth,
    );
    return _persist(result);
  }

  Future<ApiResult<void>> resendOtp(String email) => requestRunner(
        () => _client.post(_endpoints.resendOtp, data: {'email': email}),
        (_) {},
      );

  /// Requests the server to send an OTP to [email].
  ///
  /// Use for **Flow B** (OTP-first signup): call this before the user fills the
  /// registration form. Back-ends that share an endpoint for initial send and
  /// resend can substitute [resendOtp] instead.
  Future<ApiResult<void>> sendOtp(String email) => requestRunner(
        () => _client.post(_endpoints.sendOtp, data: {'email': email}),
        (_) {},
      );

  /// Verifies [code] sent to [email] without completing authentication.
  ///
  /// Use for **Flow B** (OTP-first signup): call after [sendOtp] to confirm the
  /// user owns the address, then proceed to [register]. Unlike [verifyOtp],
  /// tokens are not persisted — only the code is validated.
  Future<ApiResult<void>> verifyOtpOnly(String email, String code) =>
      requestRunner(
        () => _client.post(_endpoints.verifyOtp, data: {
          'email': email,
          'code': code,
        }),
        (_) {},
      );

  /// Exchanges the stored refresh token for a new session.
  ///
  /// Marked [AuthInterceptor.skipAuthRefreshKey] so the refresh call itself is
  /// never intercepted for a 401 (which would recurse). On success the new
  /// tokens are persisted; if no refresh token is stored, fails fast as
  /// [ApiErrorType.unauthorized] without a network call.
  Future<ApiResult<AuthResponse>> refreshToken() async {
    final refresh = await _tokenStore?.readRefreshToken();
    if (_tokenStore == null || refresh == null || refresh.isEmpty) {
      return const Failure(
        ApiException(
          type: ApiErrorType.unauthorized,
          message: 'No refresh token available.',
        ),
      );
    }

    final result = await requestRunner(
      () => _client.post(
        _endpoints.refresh,
        data: {'refresh_token': refresh},
        options: Options(extra: {AuthInterceptor.skipAuthRefreshKey: true}),
      ),
      _parseAuth,
    );
    return _persist(result);
  }

  /// Calls the logout endpoint and clears stored tokens regardless of outcome.
  ///
  /// The server session is always terminated when the request succeeds.
  /// Token clear is best-effort: if the Keychain is temporarily locked
  /// ([PlatformException]), the tokens remain on-device but the server will
  /// reject them on the next use.
  Future<ApiResult<void>> logout() async {
    final result = await requestRunner(
      () => _client.post(_endpoints.logout),
      (_) {},
    );
    try {
      await _tokenStore?.clear();
    } on PlatformException {
      // Storage unavailable — server session is terminated, tokens will be
      // rejected on next use. Do not let a storage failure break the ApiResult
      // contract.
    }
    return result;
  }

  // Persists tokens from a successful auth response.
  // If [AuthResponse.refreshToken] is null (server did not reissue one),
  // the existing refresh token in the store is preserved unchanged — this is
  // intentional for flows like OTP verify that return an access token only.
  // If the server omits the refresh token unexpectedly (a server bug), the old
  // token will silently remain. Monitor token expiry if this is a concern.
  Future<ApiResult<AuthResponse>> _persist(ApiResult<AuthResponse> result) async {
    final store = _tokenStore;
    if (store != null && result is Success<AuthResponse>) {
      final data = result.data;
      await store.writeTokens(
        accessToken: data.accessToken,
        refreshToken: data.refreshToken,
      );
    }
    return result;
  }
}
