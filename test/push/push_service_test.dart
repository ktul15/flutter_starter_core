import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

/// Minimal fake — lets tests verify stream and initial-message behaviour.
class _FakePushService implements PushService {
  final _messageCtrl = StreamController<PushMessage>.broadcast();
  final _openedCtrl = StreamController<PushMessage>.broadcast();
  final _tokenCtrl = StreamController<String>.broadcast();

  @override
  Future<PushPermissionStatus> requestPermission() async =>
      PushPermissionStatus.granted;

  @override
  Future<String?> getToken() async => 'fake-token-123';

  @override
  Stream<String> get onTokenRefresh => _tokenCtrl.stream;

  @override
  Stream<PushMessage> get onMessage => _messageCtrl.stream;

  @override
  Stream<PushMessage> get onMessageOpenedApp => _openedCtrl.stream;

  @override
  Future<PushMessage?> getInitialMessage() async => null;

  @override
  Future<void> subscribeToTopic(String topic) async {}

  @override
  Future<void> unsubscribeFromTopic(String topic) async {}

  void emitMessage(PushMessage msg) => _messageCtrl.add(msg);

  Future<void> dispose() async {
    await _messageCtrl.close();
    await _openedCtrl.close();
    await _tokenCtrl.close();
  }
}

void main() {
  group('PushMessage', () {
    test('fields stored correctly', () {
      const msg = PushMessage(
        title: 'Hello',
        body: 'World',
        data: {'key': 'value'},
      );
      expect(msg.title, 'Hello');
      expect(msg.body, 'World');
      expect(msg.data['key'], 'value');
    });
  });

  group('FakePushService', () {
    late _FakePushService svc;

    setUp(() => svc = _FakePushService());
    tearDown(() => svc.dispose());

    test('getInitialMessage returns null', () async {
      expect(await svc.getInitialMessage(), isNull);
    });

    test('requestPermission returns granted', () async {
      expect(await svc.requestPermission(), PushPermissionStatus.granted);
    });

    test('getToken returns token', () async {
      expect(await svc.getToken(), 'fake-token-123');
    });

    test('onMessage emits pushed messages', () async {
      const msg = PushMessage(title: 'Test', body: 'Body');
      expectLater(svc.onMessage, emits(msg));
      svc.emitMessage(msg);
    });
  });
}
