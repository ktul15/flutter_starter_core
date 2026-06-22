import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

void main() {
  group('AnalyticsEvent', () {
    test('params preserved', () {
      const e = AnalyticsEvent('login', params: {'method': 'email'});
      expect(e.name, 'login');
      expect(e.params['method'], 'email');
    });

    test('default params empty', () {
      const e = AnalyticsEvent('page_view');
      expect(e.params, isEmpty);
    });
  });

  group('AnalyticsEvent.checked', () {
    test('accepts String, num, and bool values', () {
      expect(
        () => AnalyticsEvent.checked('e', params: {
          'str': 'hello',
          'int': 1,
          'double': 3.14,
          'bool': false,
        }),
        returnsNormally,
      );
    });

    test('throws ArgumentError for DateTime value', () {
      expect(
        () => AnalyticsEvent.checked('e', params: {'ts': DateTime(2024)}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for List value', () {
      expect(
        () => AnalyticsEvent.checked('e', params: {'ids': <int>[1, 2]}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws ArgumentError for custom object value', () {
      expect(
        () => AnalyticsEvent.checked('e', params: {'obj': Object()}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('error message names the offending key', () {
      expect(
        () => AnalyticsEvent.checked('e', params: {'bad_key': DateTime(2024)}),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('bad_key'),
          ),
        ),
      );
    });
  });

  group('NoOpAnalyticsService', () {
    const svc = NoOpAnalyticsService();

    test('trackEvent does not throw', () async {
      await expectLater(
        svc.trackEvent(const AnalyticsEvent('test')),
        completes,
      );
    });

    test('setUser does not throw', () async {
      await expectLater(
        svc.setUser(userId: 'u1'),
        completes,
      );
    });

    test('resetUser does not throw', () async {
      await expectLater(svc.resetUser(), completes);
    });

    test('setCurrentScreen does not throw', () async {
      await expectLater(svc.setCurrentScreen('Home'), completes);
    });

    test('trackError does not throw', () async {
      await expectLater(
        svc.trackError(Exception('e')),
        completes,
      );
    });
  });
}
