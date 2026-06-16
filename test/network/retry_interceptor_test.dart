import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobilions_core/mobilions_core.dart';

class _MockAdapter extends Mock implements HttpClientAdapter {}

ResponseBody _body(int status) => ResponseBody.fromString(
      '{"ok":true}',
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

/// Builds a Dio instance with a RetryInterceptor wired to [adapter].
Dio _dio(
  _MockAdapter adapter, {
  int maxRetries = 2,
  bool Function(DioException)? retryWhen,
}) {
  final d = Dio(BaseOptions(baseUrl: 'https://api.test'))
    ..httpClientAdapter = adapter;
  d.interceptors.add(
    RetryInterceptor(
      dio: d,
      maxRetries: maxRetries,
      retryDelay: Duration.zero,
      useExponentialBackoff: false,
      retryWhen: retryWhen,
    ),
  );
  return d;
}

void main() {
  setUpAll(() => registerFallbackValue(RequestOptions(path: '/')));

  late _MockAdapter adapter;
  setUp(() => adapter = _MockAdapter());

  test('retries connectionError and resolves on 2nd attempt', () async {
    var calls = 0;
    when(() => adapter.fetch(any(), any(), any())).thenAnswer((inv) async {
      calls++;
      final opts = inv.positionalArguments.first as RequestOptions;
      if (calls == 1) {
        throw DioException(
          requestOptions: opts,
          type: DioExceptionType.connectionError,
        );
      }
      return _body(200);
    });

    final res = await _dio(adapter).get<dynamic>('/test');
    expect(res.statusCode, 200);
    expect(calls, 2);
  });

  test('exhausts maxRetries and propagates error', () async {
    var calls = 0;
    when(() => adapter.fetch(any(), any(), any())).thenAnswer((inv) async {
      calls++;
      final opts = inv.positionalArguments.first as RequestOptions;
      throw DioException(
        requestOptions: opts,
        type: DioExceptionType.connectionError,
      );
    });

    await expectLater(
      _dio(adapter, maxRetries: 2).get<dynamic>('/test'),
      throwsA(isA<DioException>()),
    );
    // 1 original + 2 retries = 3 total adapter calls
    expect(calls, 3);
  });

  test('does not retry 4xx response', () async {
    var calls = 0;
    when(() => adapter.fetch(any(), any(), any())).thenAnswer((_) async {
      calls++;
      return _body(400);
    });

    await expectLater(
      _dio(adapter).get<dynamic>('/test'),
      throwsA(isA<DioException>().having(
        (e) => e.response?.statusCode,
        'statusCode',
        400,
      )),
    );
    expect(calls, 1);
  });

  test('does not retry 5xx by default', () async {
    var calls = 0;
    when(() => adapter.fetch(any(), any(), any())).thenAnswer((_) async {
      calls++;
      return _body(500);
    });

    await expectLater(
      _dio(adapter).get<dynamic>('/test'),
      throwsA(isA<DioException>()),
    );
    expect(calls, 1);
  });

  test('custom retryWhen retries 500 and succeeds on 2nd attempt', () async {
    var calls = 0;
    when(() => adapter.fetch(any(), any(), any())).thenAnswer((_) async {
      calls++;
      return calls == 1 ? _body(500) : _body(200);
    });

    final res = await _dio(
      adapter,
      maxRetries: 1,
      retryWhen: (e) => e.response?.statusCode == 500,
    ).get<dynamic>('/test');

    expect(res.statusCode, 200);
    expect(calls, 2);
  });
}
