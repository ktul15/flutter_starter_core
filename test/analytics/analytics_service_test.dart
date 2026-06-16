import 'package:flutter_test/flutter_test.dart';
import 'package:mobilions_core/mobilions_core.dart';

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
