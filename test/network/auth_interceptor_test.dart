import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';
import 'package:mocktail/mocktail.dart';

class _MockAdapter extends Mock implements HttpClientAdapter {}

ResponseBody _body(String json, int status) => ResponseBody.fromString(
      json,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
  });

  late Dio dio;
  late _MockAdapter adapter;

  setUp(() {
    adapter = _MockAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
  });

  test('401 → refresh → retry succeeds (happy path)', () async {
    var serverCalls = 0;
    var refreshCalls = 0;
    var token = 'expired';

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        tokenProvider: () async => token,
        refreshToken: () async {
          refreshCalls++;
          token = 'fresh';
          return true;
        },
      ),
    );

    when(() => adapter.fetch(any(), any(), any())).thenAnswer((invocation) async {
      serverCalls++;
      final options = invocation.positionalArguments[0] as RequestOptions;
      // First hit: expired token → 401. After refresh: fresh token → 200.
      if (options.headers['Authorization'] == 'Bearer fresh') {
        return _body('{"ok":true}', 200);
      }
      return _body('{"message":"expired"}', 401);
    });

    final res = await dio.get<dynamic>('/data');

    expect(res.statusCode, 200);
    expect(res.data, {'ok': true});
    expect(refreshCalls, 1, reason: 'refresh exactly once');
    expect(serverCalls, 2, reason: 'original + one retry');
  });

  test('401 → refresh fails → onAuthExpired and error propagates', () async {
    var expiredFired = false;

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        tokenProvider: () async => 'expired',
        refreshToken: () async => false,
        onAuthExpired: () => expiredFired = true,
      ),
    );

    when(() => adapter.fetch(any(), any(), any()))
        .thenAnswer((_) async => _body('{"message":"expired"}', 401));

    await expectLater(
      dio.get<dynamic>('/data'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'statusCode',
          401,
        ),
      ),
    );
    expect(expiredFired, isTrue);
  });

  test('retry still 401 → onAuthExpired, no infinite loop', () async {
    var refreshCalls = 0;
    var serverCalls = 0;
    var expiredFired = false;

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        tokenProvider: () async => 'expired',
        refreshToken: () async {
          refreshCalls++;
          return true; // claims success but token still rejected
        },
        onAuthExpired: () => expiredFired = true,
      ),
    );

    when(() => adapter.fetch(any(), any(), any())).thenAnswer((_) async {
      serverCalls++;
      return _body('{"message":"expired"}', 401);
    });

    await expectLater(dio.get<dynamic>('/data'), throwsA(isA<DioException>()));
    expect(refreshCalls, 1, reason: 'refresh attempted once');
    expect(serverCalls, 2, reason: 'original + single retry, no loop');
    expect(expiredFired, isTrue);
  });
}
