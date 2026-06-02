/// Error categories surfaced by the network layer.
///
/// Every [DioException] is mapped to one of these so consumers can branch on a
/// stable, transport-agnostic category instead of inspecting raw Dio internals.
enum ApiErrorType {
  /// No connectivity / DNS / socket failure.
  network,

  /// Connect, send, or receive timed out.
  timeout,

  /// HTTP 401 — authentication required or token rejected.
  unauthorized,

  /// HTTP 5xx — server-side failure.
  server,

  /// HTTP 422/400 with field-level errors.
  validation,

  /// Cancelled requests or anything unclassified.
  unknown,
}

/// Normalized, framework-agnostic error raised by the network layer.
///
/// Produced by [ErrorInterceptor]/`mapDioException` and carried inside a
/// `Failure<T>`. Consumers never see a raw `DioException`.
class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
    this.fieldErrors,
  });

  /// Stable error category for branching.
  final ApiErrorType type;

  /// Human-readable message safe to surface to logs (not necessarily to users).
  final String message;

  /// Originating HTTP status code, when the failure came from a response.
  final int? statusCode;

  /// Field-level validation errors keyed by field name.
  ///
  /// Populated only for [ApiErrorType.validation] when the server returns them.
  final Map<String, List<String>>? fieldErrors;

  bool get isUnauthorized => type == ApiErrorType.unauthorized;

  @override
  String toString() =>
      'ApiException(type: $type, statusCode: $statusCode, message: $message)';
}
