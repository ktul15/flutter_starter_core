import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';
import 'package:mocktail/mocktail.dart';

import '../fakes/fake_token_store.dart';

class _MockApiClient extends Mock implements ApiClient {}

Response<dynamic> _ok(dynamic data) => Response<dynamic>(
      requestOptions: RequestOptions(path: '/'),
      statusCode: 200,
      data: data,
    );

DioException _http(int status, {dynamic data}) {
  final req = RequestOptions(path: '/');
  return DioException(
    requestOptions: req,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(requestOptions: req, statusCode: status, data: data),
  );
}

const _authJson = {
  'access_token': 'AT',
  'refresh_token': 'RT',
  'user': {'id': '1', 'email': 'a@b.com', 'name': 'A'},
};

void main() {
  setUpAll(() => registerFallbackValue(Options()));

  late _MockApiClient client;
  late FakeTokenStore store;
  late AuthService auth;

  setUp(() {
    client = _MockApiClient();
    store = FakeTokenStore();
    auth = AuthService(client: client, tokenStore: store);
  });

  void stubPost(Future<Response<dynamic>> Function() answer) {
    when(() => client.post(
          any(),
          data: any(named: 'data'),
          query: any(named: 'query'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        )).thenAnswer((_) => answer());
  }

  group('login', () {
    test('success parses response and persists tokens', () async {
      stubPost(() async => _ok(_authJson));

      final result = await auth.login('a@b.com', 'pw');

      expect(result.isSuccess, isTrue);
      final data = result.dataOrNull!;
      expect(data.accessToken, 'AT');
      expect(data.user?.email, 'a@b.com');
      expect(await store.readAccessToken(), 'AT');
      expect(await store.readRefreshToken(), 'RT');
      expect(store.writeCount, 1);

      final captured = verify(() => client.post(
            captureAny(),
            data: captureAny(named: 'data'),
            query: any(named: 'query'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
          )).captured;
      expect(captured[0], '/auth/login');
      expect(captured[1], {'email': 'a@b.com', 'password': 'pw'});
    });

    test('failure does not persist tokens', () async {
      stubPost(() async => throw _http(401, data: {'message': 'bad creds'}));

      final result = await auth.login('a@b.com', 'pw');

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.type, ApiErrorType.unauthorized);
      expect(await store.readAccessToken(), isNull);
      expect(store.writeCount, 0);
    });
  });

  test('register posts the request JSON and persists', () async {
    stubPost(() async => _ok(_authJson));

    final result = await auth.register(
      const RegisterRequest(email: 'a@b.com', password: 'pw', name: 'A'),
    );

    expect(result.isSuccess, isTrue);
    expect(store.writeCount, 1);
    final data = verify(() => client.post(
          '/auth/register',
          data: captureAny(named: 'data'),
          query: any(named: 'query'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
        )).captured.single as Map;
    expect(data['email'], 'a@b.com');
    expect(data['password'], 'pw');
  });

  test('verifyOtp success persists tokens', () async {
    stubPost(() async => _ok(_authJson));
    final result = await auth.verifyOtp('a@b.com', '123456');
    expect(result.isSuccess, isTrue);
    expect(store.writeCount, 1);
  });

  group('void endpoints return Success<void>', () {
    setUp(() => stubPost(() async => _ok(null)));

    test('forgotPassword', () async {
      expect((await auth.forgotPassword('a@b.com')).isSuccess, isTrue);
    });
    test('resetPassword', () async {
      expect((await auth.resetPassword('tok', 'new')).isSuccess, isTrue);
    });
    test('resendOtp', () async {
      expect((await auth.resendOtp('a@b.com')).isSuccess, isTrue);
    });
  });

  test('logout clears the store even on success', () async {
    store = FakeTokenStore(accessToken: 'AT', refreshToken: 'RT');
    auth = AuthService(client: client, tokenStore: store);
    stubPost(() async => _ok(null));

    final result = await auth.logout();

    expect(result.isSuccess, isTrue);
    expect(store.clearCount, 1);
    expect(await store.readAccessToken(), isNull);
  });

  test('logout absorbs PlatformException from token clear — ApiResult contract preserved', () async {
    final throwingStore =
        FakeTokenStore(accessToken: 'AT', throwOnClear: true);
    final auth = AuthService(client: client, tokenStore: throwingStore);
    stubPost(() async => _ok(null));

    // Must not throw — PlatformException must be absorbed inside logout().
    final result = await auth.logout();
    expect(result.isSuccess, isTrue);
  });

  group('refreshToken', () {
    test('fails fast without a network call when no refresh token', () async {
      final result = await auth.refreshToken();

      expect(result.errorOrNull?.type, ApiErrorType.unauthorized);
      verifyNever(() => client.post(
            any(),
            data: any(named: 'data'),
            query: any(named: 'query'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
          ));
    });

    test('success persists and marks request to skip auth refresh', () async {
      store = FakeTokenStore(refreshToken: 'RT');
      auth = AuthService(client: client, tokenStore: store);
      stubPost(() async => _ok(_authJson));

      final result = await auth.refreshToken();

      expect(result.isSuccess, isTrue);
      expect(await store.readAccessToken(), 'AT');

      final options = verify(() => client.post(
            '/auth/refresh',
            data: any(named: 'data'),
            query: any(named: 'query'),
            options: captureAny(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
          )).captured.single as Options;
      expect(options.extra?[AuthInterceptor.skipAuthRefreshKey], isTrue);
    });
  });
}
