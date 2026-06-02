/// mobilions_core — reusable Flutter infrastructure.
///
/// Public API barrel. Import this; everything under `src/` is private.
library;

// Module 1 — Network Core
export 'src/network/api_client.dart';
export 'src/network/api_exception.dart';
export 'src/network/api_result.dart';
export 'src/network/error_mapper.dart' show mapDioException;
export 'src/network/request_runner.dart';
export 'src/network/interceptors/auth_interceptor.dart';
export 'src/network/interceptors/error_interceptor.dart';
export 'src/network/interceptors/log_interceptor.dart';

// Module 2 — Storage + Config
export 'src/storage/token_store.dart';
export 'src/storage/secure_token_store.dart';
export 'src/config/env_config.dart';

// Module 3 — Auth Service
export 'src/auth/auth_service.dart';
export 'src/auth/auth_endpoints.dart';
export 'src/auth/models/user.dart';
export 'src/auth/models/auth_response.dart';
export 'src/auth/models/register_request.dart';

// Re-export Dio types consumers need when wiring the client.
export 'package:dio/dio.dart'
    show Dio, Interceptor, Options, Response, CancelToken, DioException;
