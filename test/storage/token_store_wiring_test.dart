import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';
import 'package:mocktail/mocktail.dart';

import '../fakes/fake_token_store.dart';

class _MockAdapter extends Mock implements HttpClientAdapter {}

ResponseBody _body(String json, int status) => ResponseBody.fromString(
      json,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

void main() {
  setUpAll(() => registerFallbackValue(RequestOptions(path: '/')));

  test('AuthInterceptor reads/refreshes through a real TokenStore', () async {
    final store = FakeTokenStore(accessToken: 'expired', refreshToken: 'r1');
    final adapter = _MockAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        // Token source IS the store.
        tokenProvider: store.readAccessToken,
        // Refresh persists a new token into the store, as AuthService will.
        refreshToken: () async {
          final refresh = await store.readRefreshToken();
          if (refresh == null) return false;
          await store.writeTokens(accessToken: 'fresh', refreshToken: 'r2');
          return true;
        },
      ),
    );

    when(() => adapter.fetch(any(), any(), any())).thenAnswer((invocation) async {
      final options = invocation.positionalArguments[0] as RequestOptions;
      return options.headers['Authorization'] == 'Bearer fresh'
          ? _body('{"ok":true}', 200)
          : _body('{"message":"expired"}', 401);
    });

    final res = await dio.get<dynamic>('/data');

    expect(res.statusCode, 200);
    expect(await store.readAccessToken(), 'fresh');
    expect(await store.readRefreshToken(), 'r2');
    expect(store.writeCount, 1);
  });
}
