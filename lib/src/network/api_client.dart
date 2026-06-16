import 'package:dio/dio.dart';

import 'interceptors/error_interceptor.dart';
import 'interceptors/log_interceptor.dart';

/// Thin, configurable wrapper around [Dio].
///
/// Owns a single [Dio] instance, applies sane timeouts, and registers the
/// package interceptors. Exposes verb methods that return the raw [Response];
/// pair them with `requestRunner` to get an `ApiResult`.
///
/// The package enforces no state management or DI container — construct this
/// once and inject it wherever needed.
class ApiClient {
  /// Creates a client for [baseUrl].
  ///
  /// [interceptors] are inserted **before** the built-in [ErrorInterceptor]
  /// (registered last) so an `AuthInterceptor` can retry a 401 before the error
  /// is finalized. Pass [enableLogging] to add the debug-only [NetworkLogInterceptor].
  /// A custom [dio] can be supplied for testing.
  ApiClient({
    required String baseUrl,
    List<Interceptor> interceptors = const [],
    bool enableLogging = true,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 20),
    Map<String, dynamic>? defaultHeaders,
    Dio? dio,
  }) : dio = dio ?? Dio() {
    this.dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = connectTimeout
      ..receiveTimeout = receiveTimeout
      ..headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?defaultHeaders,
      };

    this.dio.interceptors.addAll([
      ...interceptors,
      if (enableLogging) const NetworkLogInterceptor(),
      const ErrorInterceptor(),
    ]);
  }

  /// The underlying Dio instance. Exposed for advanced configuration; prefer
  /// the verb methods below for ordinary calls.
  final Dio dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) => dio.get<dynamic>(
    path,
    queryParameters: query,
    options: options,
    cancelToken: cancelToken,
  );

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) => dio.post<dynamic>(
    path,
    data: data,
    queryParameters: query,
    options: options,
    cancelToken: cancelToken,
  );

  Future<Response<dynamic>> put(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) => dio.put<dynamic>(
    path,
    data: data,
    queryParameters: query,
    options: options,
    cancelToken: cancelToken,
  );

  Future<Response<dynamic>> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) => dio.patch<dynamic>(
    path,
    data: data,
    queryParameters: query,
    options: options,
    cancelToken: cancelToken,
  );

  Future<Response<dynamic>> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) => dio.delete<dynamic>(
    path,
    data: data,
    queryParameters: query,
    options: options,
    cancelToken: cancelToken,
  );

  /// Sends a multipart [FormData] body via POST (file upload, mixed fields).
  ///
  /// [onSendProgress] reports `(sent, total)` bytes for upload progress UI.
  Future<Response<dynamic>> postFormData(
    String path, {
    required FormData data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) => dio.post<dynamic>(
    path,
    data: data,
    queryParameters: query,
    options: _multipartOptions(options),
    cancelToken: cancelToken,
    onSendProgress: onSendProgress,
  );

  /// Sends a multipart [FormData] body via PUT (full resource replace with file).
  Future<Response<dynamic>> putFormData(
    String path, {
    required FormData data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) => dio.put<dynamic>(
    path,
    data: data,
    queryParameters: query,
    options: _multipartOptions(options),
    cancelToken: cancelToken,
    onSendProgress: onSendProgress,
  );

  /// Sends a multipart [FormData] body via PATCH (partial update with file).
  Future<Response<dynamic>> patchFormData(
    String path, {
    required FormData data,
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) => dio.patch<dynamic>(
    path,
    data: data,
    queryParameters: query,
    options: _multipartOptions(options),
    cancelToken: cancelToken,
    onSendProgress: onSendProgress,
  );

  /// Builds [Options] with [contentType] forced to `multipart/form-data`,
  /// preserving any other fields the caller supplied.
  static Options _multipartOptions(Options? incoming) => Options(
    method: incoming?.method,
    sendTimeout: incoming?.sendTimeout,
    receiveTimeout: incoming?.receiveTimeout,
    extra: incoming?.extra,
    headers: incoming?.headers,
    responseType: incoming?.responseType,
    contentType: incoming?.contentType ?? 'multipart/form-data',
    validateStatus: incoming?.validateStatus,
    receiveDataWhenStatusError: incoming?.receiveDataWhenStatusError,
    followRedirects: incoming?.followRedirects,
    maxRedirects: incoming?.maxRedirects,
    requestEncoder: incoming?.requestEncoder,
    responseDecoder: incoming?.responseDecoder,
    listFormat: incoming?.listFormat,
  );
}
