import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import '../snack.dart';

// ── State ──────────────────────────────────────────────────────────────────────

class LoginState extends Equatable {
  const LoginState({this.loading = false, this.statusText, this.snack});

  final bool loading;
  final String? statusText;

  /// Non-null when a snackbar should be shown. Reference equality ensures
  /// [BlocConsumer.listenWhen] fires exactly once per emission.
  final Snack? snack;

  @override
  List<Object?> get props => [loading, statusText, snack];
}

// ── Cubit ──────────────────────────────────────────────────────────────────────

/// Drives the Login tab: email + password sign-in and logout.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._auth) : super(const LoginState());

  final AuthService _auth;

  Future<void> login(String email, String password) async {
    emit(const LoginState(loading: true));
    final result = await _auth.login(email, password);
    switch (result) {
      case Success(:final data):
        emit(LoginState(
          statusText: 'token: ${data.accessToken}',
          snack: Snack('Logged in', SnackType.success),
        ));
      case Failure(:final error):
        emit(LoginState(
          statusText: 'error: ${error.message}',
          snack: Snack(error.message, SnackType.error),
        ));
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    emit(LoginState(
      statusText: 'Logged out — tokens cleared',
      snack: Snack('Logged out', SnackType.info),
    ));
  }
}
