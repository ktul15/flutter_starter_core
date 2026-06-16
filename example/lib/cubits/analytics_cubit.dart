import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

// ── State ──────────────────────────────────────────────────────────────────────

class AnalyticsState extends Equatable {
  const AnalyticsState({this.callLog = const []});

  final List<String> callLog;

  @override
  List<Object?> get props => [callLog];
}

// ── Cubit ──────────────────────────────────────────────────────────────────────

/// Demonstrates [NoOpAnalyticsService] and [CrashReporter] / [CrashReporterWiring].
class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit() : super(const AnalyticsState()) {
    _analytics = const NoOpAnalyticsService();
    _crashReporter = _DemoCrashReporter(
      onRecord: (msg) => emit(AnalyticsState(callLog: [msg, ...state.callLog])),
    );
  }

  late final AnalyticsService _analytics;
  late final CrashReporter _crashReporter;

  void _log(String msg) =>
      emit(AnalyticsState(callLog: [msg, ...state.callLog]));

  Future<void> trackEvent() async {
    final event = AnalyticsEvent('button_tapped', params: {
      'screen': 'analytics_screen',
      'button': 'track_event',
    });
    await _analytics.trackEvent(event);
    _log('trackEvent("${event.name}", params: ${event.params})');
  }

  Future<void> setUser() async {
    await _analytics.setUser(
      userId: 'user_demo_42',
      properties: {'plan': 'pro', 'country': 'US'},
    );
    _log('setUser(userId: "user_demo_42", properties: {plan: pro})');
  }

  Future<void> resetUser() async {
    await _analytics.resetUser();
    _log('resetUser()');
  }

  Future<void> setScreen() async {
    await _analytics.setCurrentScreen('analytics_screen');
    _log('setCurrentScreen("analytics_screen")');
  }

  Future<void> trackError() async {
    final error = Exception('Demo non-fatal error');
    await _analytics.trackError(error, stack: StackTrace.current, fatal: false);
    _log('trackError(Exception("Demo non-fatal error"), fatal: false)');
  }

  Future<void> recordCrash() async {
    await _crashReporter.log('Demo breadcrumb from analytics screen');
    await _crashReporter.recordError(Exception('Demo error'), StackTrace.current);
    _log('CrashReporter: recordError + log called');
  }

  void clearLog() => emit(const AnalyticsState());
}

// ── Demo CrashReporter ─────────────────────────────────────────────────────────

/// Minimal stub that prints to console and calls [onRecord] for UI feedback.
class _DemoCrashReporter implements CrashReporter {
  _DemoCrashReporter({required this.onRecord});
  final void Function(String) onRecord;

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
  }) async {
    debugPrint('[CrashReporter] recordError: $error (fatal: $fatal)');
    onRecord('recordError($error, fatal: $fatal)');
  }

  @override
  Future<void> recordFlutterError(FlutterErrorDetails details) async =>
      debugPrint('[CrashReporter] recordFlutterError: ${details.exception}');

  @override
  Future<void> setUser(String userId) async =>
      debugPrint('[CrashReporter] setUser: $userId');

  @override
  Future<void> clearUser() async =>
      debugPrint('[CrashReporter] clearUser');

  @override
  Future<void> setCustomKey(String key, Object value) async =>
      debugPrint('[CrashReporter] setCustomKey: $key=$value');

  @override
  Future<void> log(String message) async {
    debugPrint('[CrashReporter] log: $message');
    onRecord('log("$message")');
  }
}
