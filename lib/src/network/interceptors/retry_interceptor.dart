import 'dart:math';

import 'package:dio/dio.dart';

/// Transparently retries failed requests on transient network errors.
///
/// Attach after [AuthInterceptor] so auth headers are re-applied on retry.
/// Only retries connection/timeout errors by default — never retries responses
/// with a status code (those are deliberate server decisions).
///
/// ```dart
/// ApiClient(
///   baseUrl: '...',
///   interceptors: [
///     AuthInterceptor(...),
///     RetryInterceptor(dio: client.dio),
///   ],
/// );
/// ```
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required Dio dio,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.useExponentialBackoff = true,
    bool Function(DioException)? retryWhen,
  })  : _dio = dio,
        _retryWhen = retryWhen ?? _defaultShouldRetry;

  final Dio _dio;

  /// Maximum number of retry attempts. Defaults to 3.
  final int maxRetries;

  /// Base delay between retries. With [useExponentialBackoff] enabled, the
  /// ceiling grows as `retryDelay × 2^attempt`; full jitter then picks a
  /// random value in `[0, ceiling]` to prevent thundering-herd retries.
  final Duration retryDelay;

  /// When true, doubles the delay on each successive attempt.
  final bool useExponentialBackoff;

  final bool Function(DioException) _retryWhen;
  final Random _rng = Random();

  /// Per-request `extra` key storing the current attempt count.
  /// Exposed so tests can inspect or seed retry state.
  static const retryCountKey = 'fsc_retry_count';

  /// Default condition: retry only on connection/timeout errors, never on
  /// responses that carry a status code (4xx/5xx are deliberate).
  static bool _defaultShouldRetry(DioException e) =>
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = err.requestOptions.extra[retryCountKey] as int? ?? 0;

    if (attempt >= maxRetries || !_retryWhen(err)) {
      handler.next(err);
      return;
    }

    final baseMs = useExponentialBackoff
        ? (retryDelay.inMilliseconds * pow(2, attempt)).toInt()
        : retryDelay.inMilliseconds;
    // Full jitter: uniform random in [0, baseMs] prevents thundering-herd
    // when many clients retry simultaneously after the same outage.
    final delayMs = _rng.nextInt(baseMs + 1);

    await Future<void>.delayed(Duration(milliseconds: delayMs));

    try {
      final response = await _dio.fetch<dynamic>(
        err.requestOptions.copyWith(
          extra: {
            ...err.requestOptions.extra,
            retryCountKey: attempt + 1,
          },
        ),
      );
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    } catch (e, s) {
      handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error: e,
          stackTrace: s,
        ),
      );
    }
  }
}
