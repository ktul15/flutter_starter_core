import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

void main() {
  group('requestRunner', () {
    test('returns Success with parsed data', () async {
      final result = await requestRunner<int>(
        () async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/x'),
          data: {'value': 7},
        ),
        (data) => (data as Map)['value'] as int,
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, 7);
    });

    test('unwraps an ApiException already attached to a DioException', () async {
      const attached = ApiException(
        type: ApiErrorType.unauthorized,
        message: 'nope',
        statusCode: 401,
      );
      final result = await requestRunner<int>(
        () async => throw DioException(
          requestOptions: RequestOptions(path: '/x'),
          error: attached,
        ),
        (data) => data as int,
      );

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, same(attached));
    });

    test('maps a raw DioException when no ApiException attached', () async {
      final result = await requestRunner<int>(
        () async => throw DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.connectionError,
        ),
        (data) => data as int,
      );

      expect(result.errorOrNull?.type, ApiErrorType.network);
    });

    test('wraps a parse/throw as parseFailure', () async {
      final result = await requestRunner<int>(
        () async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/x'),
          data: 'not-a-number',
        ),
        (data) => data as int, // throws TypeError
      );

      expect(result.errorOrNull?.type, ApiErrorType.parseFailure);
    });

    test('unwrap extracts envelope before parse', () async {
      final result = await requestRunner<int>(
        () async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/x'),
          data: {'data': 42},
        ),
        (data) => data as int,
        unwrap: (body) => (body as Map<String, dynamic>)['data'],
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, 42);
    });

    test('unwrap failure returns parseFailure', () async {
      final result = await requestRunner<int>(
        () async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/x'),
          data: 'not-a-map',
        ),
        (data) => data as int,
        unwrap: (body) => (body as Map<String, dynamic>)['data'], // throws cast
      );

      expect(result.errorOrNull?.type, ApiErrorType.parseFailure);
    });

    test('ApiException thrown by parse propagates with original type', () async {
      const original = ApiException(
        type: ApiErrorType.unauthorized,
        message: 'token expired in body',
        statusCode: 200,
      );
      final result = await requestRunner<int>(
        () async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/x'),
          data: {},
        ),
        (_) => throw original,
      );

      expect(result.errorOrNull, same(original));
      expect(result.errorOrNull?.type, ApiErrorType.unauthorized);
    });

    test('ApiException thrown by unwrap propagates with original type', () async {
      const original = ApiException(
        type: ApiErrorType.server,
        message: 'envelope missing',
      );
      final result = await requestRunner<int>(
        () async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/x'),
          data: {},
        ),
        (data) => data as int,
        unwrap: (_) => throw original,
      );

      expect(result.errorOrNull, same(original));
      expect(result.errorOrNull?.type, ApiErrorType.server);
    });
  });
}
