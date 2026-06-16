import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import '../snack.dart';

// ── State ──────────────────────────────────────────────────────────────────────

class FlowBState extends Equatable {
  const FlowBState({
    this.step = 0,
    this.loading = false,
    this.email = '',
    this.currentOtp = '',
    this.statusText,
    this.snack,
  });

  /// 0 = enter email, 1 = verify OTP, 2 = complete registration.
  final int step;
  final bool loading;
  final String email;
  final String currentOtp;
  final String? statusText;
  final Snack? snack;

  @override
  List<Object?> get props =>
      [step, loading, email, currentOtp, statusText, snack];
}

// ── Cubit ──────────────────────────────────────────────────────────────────────

/// Flow B: sendOtp() → verifyOtpOnly() → register().
/// Use when email ownership must be confirmed before the user fills in a form.
class FlowBCubit extends Cubit<FlowBState> {
  FlowBCubit(this._auth) : super(const FlowBState());

  final AuthService _auth;

  Future<void> sendOtp(String email) async {
    emit(FlowBState(loading: true, email: email));
    final result = await _auth.sendOtp(email);
    switch (result) {
      case Success():
        emit(FlowBState(
          step: 1,
          email: email,
          snack: Snack('OTP sent to $email', SnackType.info),
        ));
      case Failure(:final error):
        emit(FlowBState(
          email: email,
          statusText: 'error: ${error.message}',
          snack: Snack(error.message, SnackType.error),
        ));
    }
  }

  void updateOtp(String otp) {
    emit(FlowBState(
      step: state.step,
      email: state.email,
      currentOtp: otp,
      statusText: state.statusText,
    ));
  }

  Future<void> verifyOtpOnly() async {
    emit(FlowBState(
      loading: true,
      step: 1,
      email: state.email,
      currentOtp: state.currentOtp,
    ));
    final result = await _auth.verifyOtpOnly(state.email, state.currentOtp);
    switch (result) {
      case Success():
        emit(FlowBState(
          step: 2,
          email: state.email,
          snack: Snack('OTP verified — complete registration', SnackType.success),
        ));
      case Failure(:final error):
        emit(FlowBState(
          step: 1,
          email: state.email,
          currentOtp: state.currentOtp,
          statusText: 'error: ${error.message}',
          snack: Snack(error.message, SnackType.error),
        ));
    }
  }

  Future<void> register(String name, String password) async {
    emit(FlowBState(loading: true, step: 2, email: state.email));
    final result = await _auth.register(
      RegisterRequest(
        email: state.email,
        password: password,
        name: name,
        passwordConfirmation: password,
      ),
    );
    switch (result) {
      case Success(:final data):
        emit(FlowBState(
          statusText: 'Registered — token: ${data.accessToken}',
          snack: Snack('Registration complete', SnackType.success),
        ));
      case Failure(:final error):
        emit(FlowBState(
          step: 2,
          email: state.email,
          statusText: 'error: ${error.message}',
          snack: Snack(error.message, SnackType.error),
        ));
    }
  }
}
