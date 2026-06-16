import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ── State ──────────────────────────────────────────────────────────────────────

class MessengerDemoState extends Equatable {
  const MessengerDemoState({
    this.duration = const Duration(seconds: 3),
  });

  final Duration duration;

  @override
  List<Object?> get props => [duration];
}

// ── Cubit ──────────────────────────────────────────────────────────────────────

/// Holds the selected snackbar duration for the Messenger demo screen.
class MessengerCubit extends Cubit<MessengerDemoState> {
  MessengerCubit() : super(const MessengerDemoState());

  void setDuration(int seconds) =>
      emit(MessengerDemoState(duration: Duration(seconds: seconds)));
}
