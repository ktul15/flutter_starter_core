import 'dart:async';

import 'package:dio/dio.dart';

/// Injects a bearer token and transparently recovers from expired sessions.
///
/// Flow:
/// 1. On each request, attach `Authorization: Bearer <token>` if [tokenProvider]
///    yields a non-null token.
/// 2. On a `401`, call [refreshToken] **once**. If it succeeds, retry the
///    original request with the new token and resolve with that response.
/// 3. If refresh fails (or the retry still 401s), invoke [onAuthExpired] and
///    let the original error propagate.
///
/// Kept free of any storage/auth module dependency: callers wire real token
/// reads and refresh logic via constructor callbacks (constructor injection).
/// Concurrent 401s share a single in-flight refresh so the token is refreshed
/// only once.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required this.tokenProvider,
    required this.refreshToken,
    this.onAuthExpired,
    this.scheme = 'Bearer',
  }) : _dio = dio;

  /// Dio instance used to retry the original request after a refresh.
  final Dio _dio;

  /// Returns the current access token, or `null` if unauthenticated.
  final Future<String?> Function() tokenProvider;

  /// Attempts to refresh the session. Returns `true` on success.
  ///
  /// Must not itself route through this interceptor's 401 handling for the
  /// refresh call, or it will recurse. Mark that request with
  /// [skipAuthRefreshKey] in its `extra` if it shares the same [Dio].
  final Future<bool> Function() refreshToken;

  /// Invoked when the session cannot be recovered (refresh failed / retry 401).
  final void Function()? onAuthExpired;

  /// Authorization scheme prefix. Defaults to `Bearer`.
  final String scheme;

  /// Per-request `extra` flag: skip token injection and refresh handling.
  static const String skipAuthRefreshKey = 'mobilions_skip_auth_refresh';

  /// Per-request `extra` flag (set internally) marking an already-retried call,
  /// preventing infinite refresh→retry→401 loops.
  static const String _retriedKey = 'mobilions_auth_retried';

  Future<bool>? _ongoingRefresh;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuthRefreshKey] == true) {
      handler.next(options);
      return;
    }
    final token = await tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = '$scheme $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final isUnauthorized = err.response?.statusCode == 401;
    final skip = request.extra[skipAuthRefreshKey] == true;
    final alreadyRetried = request.extra[_retriedKey] == true;

    if (!isUnauthorized || skip || alreadyRetried) {
      handler.next(err);
      return;
    }

    final refreshed = await _refreshOnce();
    if (!refreshed) {
      onAuthExpired?.call();
      handler.next(err);
      return;
    }

    try {
      final response = await _retry(request);
      handler.resolve(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        onAuthExpired?.call();
      }
      handler.next(e);
    }
  }

  /// Coalesces concurrent refreshes into a single in-flight call.
  Future<bool> _refreshOnce() {
    final ongoing = _ongoingRefresh;
    if (ongoing != null) return ongoing;

    final future = refreshToken().whenComplete(() => _ongoingRefresh = null);
    _ongoingRefresh = future;
    return future;
  }

  /// Re-issues [request] with a fresh token, flagged so it won't loop.
  Future<Response<dynamic>> _retry(RequestOptions request) async {
    final token = await tokenProvider();
    final headers = Map<String, dynamic>.from(request.headers);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = '$scheme $token';
    }
    return _dio.fetch<dynamic>(
      request.copyWith(
        headers: headers,
        extra: {...request.extra, _retriedKey: true},
      ),
    );
  }
}
