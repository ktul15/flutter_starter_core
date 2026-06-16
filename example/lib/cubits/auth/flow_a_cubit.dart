import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import '../snack.dart';

// ── State ──────────────────────────────────────────────────────────────────────

class FlowAState extends Equatable {
  const FlowAState({
    this.loading = false,
    this.showOtp = false,
    this.email = '',
    this.currentOtp = '',
    this.statusText,
    this.snack,
  });

  final bool loading;
  final bool showOtp;
  final String email;
  final String currentOtp;
  final String? statusText;
  final Snack? snack;

  @override
  List<Object?> get props =>
      [loading, showOtp, email, currentOtp, statusText, snack];
}

// ── Cubit ──────────────────────────────────────────────────────────────────────

/// Flow A: register() → backend sends OTP → verifyOtp() returns [AuthResponse].
class FlowACubit extends Cubit<FlowAState> {
  FlowACubit(this._auth) : super(const FlowAState());

  final AuthService _auth;

  Future<void> register(String name, String email, String password) async {
    emit(FlowAState(loading: true, email: email));
    final result = await _auth.register(
      RegisterRequest(
        email: email,
        password: password,
        name: name,
        passwordConfirmation: password,
      ),
    );
    switch (result) {
      case Success():
        emit(FlowAState(
          showOtp: true,
          email: email,
          statusText: 'Registered — OTP sent to $email',
          snack: Snack('OTP sent — check your email', SnackType.info),
        ));
      case Failure(:final error):
        emit(FlowAState(
          email: email,
          statusText: 'error: ${error.message}',
          snack: Snack(error.message, SnackType.error),
        ));
    }
  }

  void updateOtp(String otp) {
    emit(FlowAState(
      showOtp: state.showOtp,
      email: state.email,
      currentOtp: otp,
      statusText: state.statusText,
    ));
  }

  Future<void> verifyOtp() async {
    emit(FlowAState(
      loading: true,
      showOtp: true,
      email: state.email,
      currentOtp: state.currentOtp,
    ));
    final result = await _auth.verifyOtp(state.email, state.currentOtp);
    switch (result) {
      case Success(:final data):
        emit(FlowAState(
          statusText: 'Verified — token: ${data.accessToken}',
          snack: Snack('Email verified', SnackType.success),
        ));
      case Failure(:final error):
        emit(FlowAState(
          showOtp: true,
          email: state.email,
          currentOtp: state.currentOtp,
          statusText: 'OTP error: ${error.message}',
          snack: Snack(error.message, SnackType.error),
        ));
    }
  }

  Future<void> resendOtp() async {
    final result = await _auth.resendOtp(state.email);
    switch (result) {
      case Success():
        emit(FlowAState(
          showOtp: state.showOtp,
          email: state.email,
          currentOtp: state.currentOtp,
          statusText: state.statusText,
          snack: Snack('OTP resent', SnackType.info),
        ));
      case Failure(:final error):
        emit(FlowAState(
          showOtp: state.showOtp,
          email: state.email,
          currentOtp: state.currentOtp,
          statusText: state.statusText,
          snack: Snack(error.message, SnackType.error),
        ));
    }
  }
}
