import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobilions_core/mobilions_core.dart';

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

    test('wraps a parse/throw as unknown', () async {
      final result = await requestRunner<int>(
        () async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/x'),
          data: 'not-a-number',
        ),
        (data) => data as int, // throws TypeError
      );

      expect(result.errorOrNull?.type, ApiErrorType.unknown);
    });
  });
}
