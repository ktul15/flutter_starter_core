import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobilions_core/mobilions_core.dart';

DioException _response(int status, {dynamic data}) {
  final req = RequestOptions(path: '/x');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: req,
      statusCode: status,
      data: data,
    ),
  );
}

DioException _ofType(DioExceptionType type) =>
    DioException(requestOptions: RequestOptions(path: '/x'), type: type);

void main() {
  group('mapDioException', () {
    test('maps timeouts to timeout', () {
      for (final t in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(mapDioException(_ofType(t)).type, ApiErrorType.timeout);
      }
    });

    test('maps connectionError to network', () {
      expect(
        mapDioException(_ofType(DioExceptionType.connectionError)).type,
        ApiErrorType.network,
      );
    });

    test('maps cancel to unknown', () {
      expect(
        mapDioException(_ofType(DioExceptionType.cancel)).type,
        ApiErrorType.unknown,
      );
    });

    test('maps 401 to unauthorized', () {
      final e = mapDioException(_response(401));
      expect(e.type, ApiErrorType.unauthorized);
      expect(e.statusCode, 401);
      expect(e.isUnauthorized, isTrue);
    });

    test('maps 422 to validation with field errors', () {
      final e = mapDioException(_response(422, data: {
        'message': 'Invalid',
        'errors': {
          'email': ['is required', 'is invalid'],
          'name': 'too short',
        },
      }));
      expect(e.type, ApiErrorType.validation);
      expect(e.message, 'Invalid');
      expect(e.fieldErrors?['email'], ['is required', 'is invalid']);
      expect(e.fieldErrors?['name'], ['too short']);
    });

    test('maps 5xx to server', () {
      expect(mapDioException(_response(503)).type, ApiErrorType.server);
    });

    test('maps other status to unknown', () {
      expect(mapDioException(_response(418)).type, ApiErrorType.unknown);
    });

    test('extracts server message from body', () {
      final e = mapDioException(_response(500, data: {'error': 'down'}));
      expect(e.message, 'down');
    });
  });
}
