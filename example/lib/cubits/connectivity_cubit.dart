import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

// ── Helper ─────────────────────────────────────────────────────────────────────

class ConnEvent {
  ConnEvent(this.online, this.time);
  final bool online;
  final DateTime time;
}

// ── State ──────────────────────────────────────────────────────────────────────

class ConnectivityState extends Equatable {
  const ConnectivityState({this.isOnline, this.events = const []});

  /// Null until the first check completes.
  final bool? isOnline;
  final List<ConnEvent> events;

  @override
  List<Object?> get props => [isOnline, events];
}

// ── Cubit ──────────────────────────────────────────────────────────────────────

/// Wraps [ConnectivityChecker] — live status banner + stream event log.
class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit() : super(const ConnectivityState()) {
    _sub = _checker.onStatusChange.listen((online) {
      emit(ConnectivityState(
        isOnline: online,
        events: [ConnEvent(online, DateTime.now()), ...state.events],
      ));
    });
    scheduleMicrotask(checkNow);
  }

  final _checker = ConnectivityChecker();
  StreamSubscription<bool>? _sub;

  Future<void> checkNow() async {
    final online = await _checker.isOnline;
    emit(ConnectivityState(isOnline: online, events: state.events));
  }

  void clearEvents() => emit(ConnectivityState(isOnline: state.isOnline));

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
