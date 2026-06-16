import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ── State ──────────────────────────────────────────────────────────────────────

class WidgetsState extends Equatable {
  const WidgetsState({this.isButtonLoading = false, this.otpValue = ''});

  final bool isButtonLoading;
  final String otpValue;

  @override
  List<Object?> get props => [isButtonLoading, otpValue];
}

// ── Cubit ──────────────────────────────────────────────────────────────────────

/// Drives interactive state for the Widgets showcase screen.
class WidgetsCubit extends Cubit<WidgetsState> {
  WidgetsCubit() : super(const WidgetsState());

  Future<void> simulateLoad() async {
    emit(WidgetsState(
      isButtonLoading: true,
      otpValue: state.otpValue,
    ));
    await Future<void>.delayed(const Duration(seconds: 2));
    emit(WidgetsState(otpValue: state.otpValue));
  }

  void updateOtp(String value) {
    emit(WidgetsState(
      isButtonLoading: state.isButtonLoading,
      otpValue: value,
    ));
  }
}
