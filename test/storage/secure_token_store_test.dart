import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockStorage storage;
  late SecureTokenStore store;

  setUp(() {
    storage = _MockStorage();
    store = SecureTokenStore(storage: storage);
    when(() => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        )).thenAnswer((_) async {});
    when(() => storage.delete(key: any(named: 'key')))
        .thenAnswer((_) async {});
  });

  test('reads access and refresh tokens by their keys', () async {
    when(() => storage.read(key: 'mobilions_access_token'))
        .thenAnswer((_) async => 'A');
    when(() => storage.read(key: 'mobilions_refresh_token'))
        .thenAnswer((_) async => 'R');

    expect(await store.readAccessToken(), 'A');
    expect(await store.readRefreshToken(), 'R');
  });

  test('writeTokens persists both when refresh provided', () async {
    await store.writeTokens(accessToken: 'A', refreshToken: 'R');

    verify(() => storage.write(key: 'mobilions_access_token', value: 'A'))
        .called(1);
    verify(() => storage.write(key: 'mobilions_refresh_token', value: 'R'))
        .called(1);
  });

  test('writeTokens leaves refresh untouched when null', () async {
    await store.writeTokens(accessToken: 'A');

    verify(() => storage.write(key: 'mobilions_access_token', value: 'A'))
        .called(1);
    verifyNever(() => storage.write(
          key: 'mobilions_refresh_token',
          value: any(named: 'value'),
        ));
    verifyNever(() => storage.delete(key: 'mobilions_refresh_token'));
  });

  test('writeTokens with empty refresh deletes the refresh token', () async {
    await store.writeTokens(accessToken: 'A', refreshToken: '');

    verify(() => storage.delete(key: 'mobilions_refresh_token')).called(1);
  });

  test('clear deletes both tokens', () async {
    await store.clear();

    verify(() => storage.delete(key: 'mobilions_access_token')).called(1);
    verify(() => storage.delete(key: 'mobilions_refresh_token')).called(1);
  });

  test('hasAccessToken reflects presence', () async {
    when(() => storage.read(key: 'mobilions_access_token'))
        .thenAnswer((_) async => null);
    expect(await store.hasAccessToken, isFalse);

    when(() => storage.read(key: 'mobilions_access_token'))
        .thenAnswer((_) async => 'A');
    expect(await store.hasAccessToken, isTrue);
  });

  test('custom keys are honored', () async {
    final custom = SecureTokenStore(
      storage: storage,
      accessTokenKey: 'acc',
      refreshTokenKey: 'ref',
    );
    when(() => storage.read(key: 'acc')).thenAnswer((_) async => 'X');

    expect(await custom.readAccessToken(), 'X');
    await custom.writeTokens(accessToken: 'Y', refreshToken: 'Z');
    verify(() => storage.write(key: 'acc', value: 'Y')).called(1);
    verify(() => storage.write(key: 'ref', value: 'Z')).called(1);
  });
}
