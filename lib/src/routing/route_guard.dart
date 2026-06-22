/// Outcome of a guard check: either allow navigation or redirect.
sealed class GuardDecision {
  const GuardDecision();

  /// `true` when navigation should proceed.
  bool get isAllowed => this is GuardAllow;

  /// The redirect target, or `null` when allowed.
  String? get redirectTo =>
      this is GuardRedirect ? (this as GuardRedirect).location : null;
}

/// Navigation permitted.
final class GuardAllow extends GuardDecision {
  const GuardAllow();
}

/// Navigation blocked; send the user to [location].
final class GuardRedirect extends GuardDecision {
  const GuardRedirect(this.location);

  final String location;
}

/// Framework-agnostic auth routing decision.
///
/// Decides allow/redirect from auth state and per-route requirements; the
/// concrete route table and how the decision is applied (go_router redirect,
/// Navigator, auto_route guard) are [PER-PROJECT].
///
/// ```dart
/// final guard = RouteGuard(signInLocation: '/login', initialLocation: '/home');
/// final decision = guard.evaluate(
///   isAuthenticated: await store.hasAccessToken,  // Future<bool> — must await
///   requiresAuth: route.requiresAuth,
///   isAuthRoute: route.isAuthScreen,
/// );
/// ```
class RouteGuard {
  const RouteGuard({
    required this.signInLocation,
    required this.initialLocation,
  });

  /// Where unauthenticated users are sent for protected routes.
  final String signInLocation;

  /// Where authenticated users are sent if they hit an auth-only route (login).
  final String initialLocation;

  /// Resolves a navigation attempt.
  ///
  /// - Protected route + not authenticated → redirect to [signInLocation].
  /// - Auth route (login/register) + already authenticated → redirect to
  ///   [initialLocation].
  /// - Otherwise → allow.
  GuardDecision evaluate({
    required bool isAuthenticated,
    required bool requiresAuth,
    bool isAuthRoute = false,
  }) {
    if (requiresAuth && !isAuthenticated) {
      return GuardRedirect(signInLocation);
    }
    if (isAuthRoute && isAuthenticated) {
      return GuardRedirect(initialLocation);
    }
    return const GuardAllow();
  }
}
