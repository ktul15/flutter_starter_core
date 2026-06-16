import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only request/response/error logger.
///
/// Uses `dart:developer` (never `print`) and is a no-op in release/profile
/// builds via [kDebugMode], so it is safe to register unconditionally.
class NetworkLogInterceptor extends Interceptor {
  const NetworkLogInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log(
        '→ ${options.method} ${options.uri}',
        name: 'flutter_starter_core.net',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log(
        '← ${response.statusCode} ${response.requestOptions.uri}',
        name: 'flutter_starter_core.net',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      developer.log(
        '✗ ${err.response?.statusCode ?? '-'} ${err.requestOptions.uri}: ${err.message}',
        name: 'flutter_starter_core.net',
        level: 1000,
      );
    }
    handler.next(err);
  }
}
