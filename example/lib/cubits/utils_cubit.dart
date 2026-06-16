import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

// ── State ──────────────────────────────────────────────────────────────────────

class UtilsState extends Equatable {
  const UtilsState({this.rawCount = 0, this.debouncedCount = 0});

  final int rawCount;
  final int debouncedCount;

  @override
  List<Object?> get props => [rawCount, debouncedCount];
}

// ── Cubit ──────────────────────────────────────────────────────────────────────

/// Demonstrates [Debouncer] — counts raw vs debounced change events.
class UtilsCubit extends Cubit<UtilsState> {
  UtilsCubit() : super(const UtilsState()) {
    _debouncer = Debouncer(delay: const Duration(milliseconds: 600));
  }

  late final Debouncer _debouncer;

  void onTextChanged() {
    emit(UtilsState(
      rawCount: state.rawCount + 1,
      debouncedCount: state.debouncedCount,
    ));
    _debouncer.run(() {
      emit(UtilsState(
        rawCount: state.rawCount,
        debouncedCount: state.debouncedCount + 1,
      ));
    });
  }

  void reset() {
    _debouncer.cancel();
    emit(const UtilsState());
  }

  @override
  Future<void> close() {
    _debouncer.dispose();
    return super.close();
  }
}
