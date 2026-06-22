import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

class _FakeReporter implements CrashReporter {
  final List<Object> errors = [];
  final List<FlutterErrorDetails> flutterErrors = [];
  String? userId;

  @override
  Future<void> recordError(Object error, StackTrace? stack,
      {bool fatal = false}) async {
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
  // Save and restore handlers around every test so they don't bleed across.
  late FlutterExceptionHandler? savedFlutterHandler;

  setUp(() {
    savedFlutterHandler = FlutterError.onError;
  });

  tearDown(() {
    FlutterError.onError = savedFlutterHandler;
  });

  group('CrashReporterWiring.attach', () {
    test('wires FlutterError.onError to reporter', () {
      final reporter = _FakeReporter();
      CrashReporterWiring.attach(reporter);

      final details = FlutterErrorDetails(exception: Exception('test'));
      FlutterError.onError!(details);

      expect(reporter.flutterErrors, hasLength(1));
    });

    test('chains existing FlutterError.onError — both handlers fire', () {
      final firstFired = <FlutterErrorDetails>[];
      FlutterError.onError = firstFired.add; // install a prior handler

      final reporter = _FakeReporter();
      CrashReporterWiring.attach(reporter); // should chain, not replace

      final details = FlutterErrorDetails(exception: Exception('chain'));
      FlutterError.onError!(details);

      expect(reporter.flutterErrors, hasLength(1),
          reason: 'reporter must receive the error');
      expect(firstFired, hasLength(1),
          reason: 'prior handler must not be discarded');
    });

    test('double attach — both reporters fire', () {
      final r1 = _FakeReporter();
      final r2 = _FakeReporter();
      CrashReporterWiring.attach(r1);
      CrashReporterWiring.attach(r2);

      final details = FlutterErrorDetails(exception: Exception('both'));
      FlutterError.onError!(details);

      expect(r1.flutterErrors, hasLength(1));
      expect(r2.flutterErrors, hasLength(1));
    });
  });

  group('CrashReporter interface', () {
    test('recordError stores error', () async {
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
