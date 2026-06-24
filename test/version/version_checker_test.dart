import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiClient extends Mock implements ApiClient {}

Response<dynamic> _ok(dynamic data) => Response<dynamic>(
      requestOptions: RequestOptions(path: '/'),
      statusCode: 200,
      data: data,
    );

const _versionJson = {
  'latest_version': '2.0.0',
  'min_required_version': '1.5.0',
  'update_url': 'https://play.google.com/store/apps/details?id=com.example',
};

void main() {
  setUpAll(() => registerFallbackValue(Options()));

  // ---------------------------------------------------------------------------
  // AppVersionInfo.status — pure semver logic
  // ---------------------------------------------------------------------------
  group('AppVersionInfo.status', () {
    test('upToDate when current == latest', () {
      const info = AppVersionInfo(
        currentVersion: '2.0.0',
        latestVersion: '2.0.0',
        minRequiredVersion: '1.0.0',
      );
      expect(info.status, VersionStatus.upToDate);
    });

    test('updateAvailable when current < latest but >= min', () {
      const info = AppVersionInfo(
        currentVersion: '1.5.0',
        latestVersion: '2.0.0',
        minRequiredVersion: '1.0.0',
      );
      expect(info.status, VersionStatus.updateAvailable);
    });

    test('updateRequired when current < min', () {
      const info = AppVersionInfo(
        currentVersion: '0.9.0',
        latestVersion: '2.0.0',
        minRequiredVersion: '1.0.0',
      );
      expect(info.status, VersionStatus.updateRequired);
    });

    test('upToDate when current > latest (dev build ahead of store)', () {
      const info = AppVersionInfo(
        currentVersion: '2.1.0',
        latestVersion: '2.0.0',
        minRequiredVersion: '1.0.0',
      );
      expect(info.status, VersionStatus.upToDate);
    });

    test('patch version comparison correct', () {
      const info = AppVersionInfo(
        currentVersion: '1.0.1',
        latestVersion: '1.0.2',
        minRequiredVersion: '1.0.0',
      );
      expect(info.status, VersionStatus.updateAvailable);
    });

    test('updateRequired on exact min boundary minus one patch', () {
      const info = AppVersionInfo(
        currentVersion: '1.0.0',
        latestVersion: '2.0.0',
        minRequiredVersion: '1.0.1',
      );
      expect(info.status, VersionStatus.updateRequired);
    });

    test('pre-release suffix stripped — beta equals release', () {
      const info = AppVersionInfo(
        currentVersion: '2.0.0-beta.1',
        latestVersion: '2.0.0',
        minRequiredVersion: '1.0.0',
      );
      expect(info.status, isNot(VersionStatus.updateRequired));
    });

    test('build metadata stripped — 2.0.0+42 equals 2.0.0', () {
      const info = AppVersionInfo(
        currentVersion: '2.0.0+42',
        latestVersion: '2.0.0',
        minRequiredVersion: '1.0.0',
      );
      expect(info.status, VersionStatus.upToDate);
    });

    test('pre-release below min triggers updateRequired', () {
      const info = AppVersionInfo(
        currentVersion: '1.0.0-rc',
        latestVersion: '2.0.0',
        minRequiredVersion: '1.0.1',
      );
      expect(info.status, VersionStatus.updateRequired);
    });
  });

  // ---------------------------------------------------------------------------
  // AppVersionInfo.fromJson
  // ---------------------------------------------------------------------------
  group('AppVersionInfo.fromJson', () {
    test('parses valid response', () {
      final info = AppVersionInfo.fromJson(_versionJson, '1.0.0');
      expect(info.currentVersion, '1.0.0');
      expect(info.latestVersion, '2.0.0');
      expect(info.minRequiredVersion, '1.5.0');
      expect(info.updateUrl, contains('play.google.com'));
    });

    test('updateUrl null when absent', () {
      final info = AppVersionInfo.fromJson({
        'latest_version': '2.0.0',
        'min_required_version': '1.0.0',
      }, '1.0.0');
      expect(info.updateUrl, isNull);
    });

    test('throws parseFailure when latest_version missing', () {
      expect(
        () => AppVersionInfo.fromJson({'min_required_version': '1.0.0'}, '1.0.0'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.type,
            'type',
            ApiErrorType.parseFailure,
          ),
        ),
      );
    });

    test('throws parseFailure when min_required_version is int not String', () {
      expect(
        () => AppVersionInfo.fromJson({
          'latest_version': '2.0.0',
          'min_required_version': 150,
        }, '1.0.0'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.type, 'type', ApiErrorType.parseFailure)
              .having((e) => e.message, 'message',
                  contains('min_required_version')),
        ),
      );
    });

    test('error message names the missing field', () {
      expect(
        () => AppVersionInfo.fromJson({'min_required_version': '1.0.0'}, '1.0.0'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', contains('latest_version')),
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // AppVersionChecker.check() — network + caching + provider injection
  // ---------------------------------------------------------------------------
  group('AppVersionChecker.check', () {
    late _MockApiClient client;

    setUp(() => client = _MockApiClient());

    void stubGet(Future<Response<dynamic>> Function() answer) {
      when(() => client.get(
            any(),
            query: any(named: 'query'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
          )).thenAnswer((_) => answer());
    }

    AppVersionChecker makeChecker({Duration cache = Duration.zero}) =>
        AppVersionChecker(
          client: client,
          endpoint: '/app/version',
          cacheDuration: cache,
          versionProvider: () async => '1.0.0',
        );

    test('success returns AppVersionInfo with injected current version', () async {
      stubGet(() async => _ok(_versionJson));
      final result = await makeChecker().check();
      expect(result.isSuccess, isTrue);
      final info = result.dataOrNull!;
      expect(info.currentVersion, '1.0.0');
      expect(info.latestVersion, '2.0.0');
      expect(info.status, VersionStatus.updateRequired);
    });

    test('network failure returns Failure', () async {
      stubGet(() async => throw DioException(
            requestOptions: RequestOptions(path: '/'),
            type: DioExceptionType.connectionError,
          ));
      final result = await makeChecker().check();
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.type, ApiErrorType.network);
    });

    test('versionProvider throwing returns Failure(unknown)', () async {
      final checker = AppVersionChecker(
        client: client,
        endpoint: '/app/version',
        versionProvider: () async => throw Exception('platform unavailable'),
      );
      final result = await checker.check();
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.type, ApiErrorType.unknown);
      expect(result.errorOrNull?.message, contains('platform unavailable'));
    });

    test('second call within cacheDuration returns cached result — no network', () async {
      stubGet(() async => _ok(_versionJson));
      final checker = makeChecker(cache: const Duration(hours: 4));

      await checker.check();
      await checker.check(); // should hit cache

      // Only one network call made
      verify(() => client.get(any(),
            query: any(named: 'query'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
          )).called(1);
    });

    test('cacheDuration zero — every call hits network', () async {
      stubGet(() async => _ok(_versionJson));
      final checker = makeChecker(cache: Duration.zero);

      await checker.check();
      await checker.check();

      verify(() => client.get(any(),
            query: any(named: 'query'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
          )).called(2);
    });

    test('forceRefresh bypasses valid cache', () async {
      stubGet(() async => _ok(_versionJson));
      final checker = makeChecker(cache: const Duration(hours: 4));

      await checker.check();
      await checker.check(forceRefresh: true); // must bypass cache

      verify(() => client.get(any(),
            query: any(named: 'query'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
          )).called(2);
    });

    test('invalidateCache forces next call to hit network', () async {
      stubGet(() async => _ok(_versionJson));
      final checker = makeChecker(cache: const Duration(hours: 4));

      await checker.check();
      checker.invalidateCache();
      await checker.check();

      verify(() => client.get(any(),
            query: any(named: 'query'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
          )).called(2);
    });

    test('failed response not cached — next call retries network', () async {
      var callCount = 0;
      when(() => client.get(any(),
            query: any(named: 'query'),
            options: any(named: 'options'),
            cancelToken: any(named: 'cancelToken'),
          )).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw DioException(
            requestOptions: RequestOptions(path: '/'),
            type: DioExceptionType.connectionError,
          );
        }
        return _ok(_versionJson);
      });

      final checker = makeChecker(cache: const Duration(hours: 4));
      final first = await checker.check();
      final second = await checker.check();

      expect(first.isFailure, isTrue);
      expect(second.isSuccess, isTrue); // retry succeeded
      expect(callCount, 2); // both calls hit network (failure not cached)
    });
  });
}
