import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

// ── State ──────────────────────────────────────────────────────────────────────

class RouteGuardState extends Equatable {
  const RouteGuardState({
    this.isAuthenticated = false,
    this.requiresAuth = true,
    this.isAuthRoute = false,
    this.guardResult,
  });

  final bool isAuthenticated;
  final bool requiresAuth;
  final bool isAuthRoute;
  final GuardDecision? guardResult;

  @override
  List<Object?> get props =>
      [isAuthenticated, requiresAuth, isAuthRoute, guardResult];
}

// ── Cubit ──────────────────────────────────────────────────────────────────────

/// Interactive demo of [RouteGuard.evaluate] — toggle flags and see the result.
class RouteGuardCubit extends Cubit<RouteGuardState> {
  RouteGuardCubit() : super(const RouteGuardState()) {
    _evaluateWith(); // compute initial decision
  }

  static const _guard = RouteGuard(
    signInLocation: '/login',
    initialLocation: '/home',
  );

  /// Evaluate the guard with one field overridden; emit a single new state.
  void _evaluateWith({
    bool? isAuthenticated,
    bool? requiresAuth,
    bool? isAuthRoute,
  }) {
    final auth = isAuthenticated ?? state.isAuthenticated;
    final requires = requiresAuth ?? state.requiresAuth;
    final isAuth = isAuthRoute ?? state.isAuthRoute;
    final result = _guard.evaluate(
      isAuthenticated: auth,
      requiresAuth: requires,
      isAuthRoute: isAuth,
    );
    emit(RouteGuardState(
      isAuthenticated: auth,
      requiresAuth: requires,
      isAuthRoute: isAuth,
      guardResult: result,
    ));
  }

  void setAuthenticated(bool v) => _evaluateWith(isAuthenticated: v);
  void setRequiresAuth(bool v) => _evaluateWith(requiresAuth: v);
  void setAuthRoute(bool v) => _evaluateWith(isAuthRoute: v);
}
