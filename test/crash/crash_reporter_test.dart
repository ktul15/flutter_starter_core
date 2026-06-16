import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

class _FakeReporter implements CrashReporter {
  final List<Object> errors = [];
  final List<FlutterErrorDetails> flutterErrors = [];
  String? userId;

  @override
  Future<void> recordError(Object error, StackTrace? stack, {bool fatal = false}) async {
    errors.add(error);
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    flutterErrors.add(details);
  }

  @override
  Future<void> setUser(String userId) async => this.userId = userId;

  @override
  Future<void> clearUser() async => userId = null;

  @override
  Future<void> setCustomKey(String key, Object value) async {}

  @override
  Future<void> log(String message) async {}
}

void main() {
  group('CrashReporterWiring', () {
    test('attach wires FlutterError.onError', () {
      final reporter = _FakeReporter();
      CrashReporterWiring.attach(reporter);

      final details = FlutterErrorDetails(exception: Exception('test'));
      FlutterError.onError!(details);

      expect(reporter.flutterErrors, hasLength(1));
    });

    test('FakeReporter records errors', () async {
      final reporter = _FakeReporter();
      await reporter.recordError(Exception('boom'), null);
      expect(reporter.errors, hasLength(1));
    });

    test('setUser / clearUser', () async {
      final reporter = _FakeReporter();
      await reporter.setUser('u123');
      expect(reporter.userId, 'u123');
      await reporter.clearUser();
      expect(reporter.userId, isNull);
    });
  });
}
