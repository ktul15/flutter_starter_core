import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ── State ──────────────────────────────────────────────────────────────────────

class ValidationState extends Equatable {
  const ValidationState({this.autovalidate = false});

  final bool autovalidate;

  @override
  List<Object?> get props => [autovalidate];
}

// ── Cubit ──────────────────────────────────────────────────────────────────────

/// Drives the validation mode toggle for the Validation form screen.
class ValidationCubit extends Cubit<ValidationState> {
  ValidationCubit() : super(const ValidationState());

  void enableAutovalidate() => emit(const ValidationState(autovalidate: true));
}
