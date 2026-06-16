import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

// ── State ──────────────────────────────────────────────────────────────────────

class PushState extends Equatable {
  const PushState({this.callLog = const []});

  final List<String> callLog;

  @override
  List<Object?> get props => [callLog];
}

// ── Cubit ──────────────────────────────────────────────────────────────────────

/// Demonstrates the [PushService] interface using a stub implementation.
class PushCubit extends Cubit<PushState> {
  PushCubit() : super(const PushState()) {
    _push = _DemoPushService();
    _messageSub = _push.onMessage.listen((msg) {
      _addLog('onMessage: ${msg.title ?? "(no title)"}');
    });
  }

  late final PushService _push;
  StreamSubscription<PushMessage>? _messageSub;

  void _addLog(String msg) =>
      emit(PushState(callLog: [msg, ...state.callLog]));

  Future<void> requestPermission() async {
    final status = await _push.requestPermission();
    _addLog('requestPermission() → ${status.name}');
  }

  Future<void> getToken() async {
    final token = await _push.getToken();
    _addLog('getToken() → ${token ?? "(null)"}');
  }

  Future<void> subscribeToTopic() async {
    await _push.subscribeToTopic('demo_topic');
    _addLog('subscribeToTopic("demo_topic")');
  }

  Future<void> unsubscribeFromTopic() async {
    await _push.unsubscribeFromTopic('demo_topic');
    _addLog('unsubscribeFromTopic("demo_topic")');
  }

  Future<void> getInitialMessage() async {
    final msg = await _push.getInitialMessage();
    _addLog('getInitialMessage() → ${msg?.title ?? "(null)"}');
  }

  void clearLog() => emit(const PushState());

  @override
  Future<void> close() {
    _messageSub?.cancel();
    return super.close();
  }
}

// ── Demo PushService ───────────────────────────────────────────────────────────

/// Stub implementation — replace with firebase_messaging in a real project.
class _DemoPushService implements PushService {
  final _messageController = StreamController<PushMessage>.broadcast();
  final _tokenController = StreamController<String>.broadcast();

  @override
  Future<PushPermissionStatus> requestPermission() async =>
      PushPermissionStatus.granted;

  @override
  Future<String?> getToken() async => 'demo-device-token-abc123';

  @override
  Stream<String> get onTokenRefresh => _tokenController.stream;

  @override
  Stream<PushMessage> get onMessage => _messageController.stream;

  @override
  Stream<PushMessage> get onMessageOpenedApp => const Stream.empty();

  @override
  Future<PushMessage?> getInitialMessage() async => null;

  @override
  Future<void> subscribeToTopic(String topic) async {}

  @override
  Future<void> unsubscribeFromTopic(String topic) async {}
}
