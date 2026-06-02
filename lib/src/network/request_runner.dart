import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'api_result.dart';
import 'error_mapper.dart';

/// Runs a network [call], parses its body, and returns an [ApiResult].
///
/// The single bridge between Dio's exception-based world and the package's
/// [ApiResult] world. Every service method should funnel through this so error
/// handling stays uniform.
///
/// ```dart
/// final result = await requestRunner(
///   () => apiClient.post('/login', data: body),
///   (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
/// );
/// ```
///
/// [parse] receives the raw `Response.data`. A `DioException` carrying an
/// [ApiException] (already mapped by [ErrorInterceptor]) is unwrapped; anything
/// else is mapped here so the runner is safe to use without the interceptor.
Future<ApiResult<T>> requestRunner<T>(
  Future<Response<dynamic>> Function() call,
  T Function(dynamic data) parse,
) async {
  try {
    final response = await call();
    return Success(parse(response.data));
  } on DioException catch (e) {
    final error = e.error is ApiException
        ? e.error as ApiException
        : mapDioException(e);
    return Failure(error);
  } on ApiException catch (e) {
    return Failure(e);
  } catch (e) {
    return Failure(
      ApiException(type: ApiErrorType.unknown, message: e.toString()),
    );
  }
}
