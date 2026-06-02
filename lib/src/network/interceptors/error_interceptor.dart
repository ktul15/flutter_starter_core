import 'package:dio/dio.dart';

import '../error_mapper.dart';

/// Converts every [DioException] into one carrying a normalized `ApiException`
/// in its `error` field, leaving the rest of the exception intact.
///
/// `requestRunner` then unwraps that `ApiException` directly. Register this
/// last so other interceptors (e.g. [AuthInterceptor] retrying a 401) run
/// before the error is finalized.
class ErrorInterceptor extends Interceptor {
  const ErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Don't re-map if a prior interceptor already attached an ApiException.
    final mapped = err.copyWith(error: mapDioException(err));
    handler.next(mapped);
  }
}
