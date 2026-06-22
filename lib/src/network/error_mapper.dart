import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Maps a raw [DioException] to a normalized [ApiException].
///
/// Single source of truth for error categorization, shared by
/// [ErrorInterceptor] and `requestRunner` so both classify identically.
ApiException mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return ApiException(
        type: ApiErrorType.timeout,
        message: 'Request timed out. Please try again.',
      );
    case DioExceptionType.connectionError:
      return ApiException(
        type: ApiErrorType.network,
        message: 'No internet connection.',
      );
    case DioExceptionType.cancel:
      return ApiException(
        type: ApiErrorType.cancelled,
        message: 'Request was cancelled.',
      );
    case DioExceptionType.badCertificate:
      return ApiException(
        type: ApiErrorType.network,
        message: 'Bad SSL certificate.',
      );
    case DioExceptionType.unknown:
      return ApiException(
        type: ApiErrorType.network,
        message: e.message ?? 'Unexpected network error.',
      );
    case DioExceptionType.badResponse:
      return _mapBadResponse(e);
  }
}

/// Maps an HTTP error response to a normalized [ApiException].
///
/// Status codes and their [ApiErrorType] mappings:
/// - 401 → [ApiErrorType.unauthorized]
/// - 400, 422 → [ApiErrorType.validation]
/// - 5xx → [ApiErrorType.server]
/// - **404, 403, and all others** → [ApiErrorType.unknown]; inspect
///   [ApiException.statusCode] to distinguish (e.g. `e.statusCode == 404`
///   for "not found", `e.statusCode == 403` for "forbidden").
ApiException _mapBadResponse(DioException e) {
  final status = e.response?.statusCode;
  final data = e.response?.data;
  final serverMessage = _extractMessage(data);

  if (status == 401) {
    return ApiException(
      type: ApiErrorType.unauthorized,
      message: serverMessage ?? 'Unauthorized.',
      statusCode: status,
    );
  }
  if (status == 422 || status == 400) {
    return ApiException(
      type: ApiErrorType.validation,
      message: serverMessage ?? 'Validation failed.',
      statusCode: status,
      fieldErrors: _extractFieldErrors(data),
    );
  }
  if (status != null && status >= 500) {
    return ApiException(
      type: ApiErrorType.server,
      message: serverMessage ?? 'Server error. Please try again later.',
      statusCode: status,
    );
  }
  return ApiException(
    type: ApiErrorType.unknown,
    message: serverMessage ?? 'Request failed.',
    statusCode: status,
  );
}

/// Best-effort extraction of a `message`/`error` string from a JSON body.
String? _extractMessage(dynamic data) {
  if (data is Map) {
    final value = data['message'] ?? data['error'] ?? data['detail'];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

/// Best-effort extraction of `{field: [errors]}` from a JSON body.
///
/// Accepts both `{field: [..]}` and `{field: "single error"}` shapes under an
/// `errors` key or at the top level.
Map<String, List<String>>? _extractFieldErrors(dynamic data) {
  if (data is! Map) return null;
  final raw = data['errors'] ?? data['fieldErrors'];
  if (raw is! Map) return null;

  final result = <String, List<String>>{};
  raw.forEach((key, value) {
    if (value is List) {
      result['$key'] = value.map((e) => '$e').toList();
    } else if (value is String) {
      result['$key'] = [value];
    }
  });
  return result.isEmpty ? null : result;
}
