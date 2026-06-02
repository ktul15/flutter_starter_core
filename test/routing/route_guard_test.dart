import 'package:flutter_test/flutter_test.dart';
import 'package:mobilions_core/mobilions_core.dart';

void main() {
  const guard = RouteGuard(signInLocation: '/login', initialLocation: '/home');

  test('protected route while unauthenticated redirects to sign-in', () {
    final d = guard.evaluate(isAuthenticated: false, requiresAuth: true);
    expect(d.isAllowed, isFalse);
    expect(d.redirectTo, '/login');
    expect(d, isA<GuardRedirect>());
  });

  test('protected route while authenticated is allowed', () {
    final d = guard.evaluate(isAuthenticated: true, requiresAuth: true);
    expect(d.isAllowed, isTrue);
    expect(d.redirectTo, isNull);
  });

  test('auth route while authenticated redirects home', () {
    final d = guard.evaluate(
      isAuthenticated: true,
      requiresAuth: false,
      isAuthRoute: true,
    );
    expect(d.redirectTo, '/home');
  });

  test('auth route while unauthenticated is allowed', () {
    final d = guard.evaluate(
      isAuthenticated: false,
      requiresAuth: false,
      isAuthRoute: true,
    );
    expect(d.isAllowed, isTrue);
  });

  test('public route is allowed regardless of auth', () {
    expect(
      guard.evaluate(isAuthenticated: false, requiresAuth: false).isAllowed,
      isTrue,
    );
    expect(
      guard.evaluate(isAuthenticated: true, requiresAuth: false).isAllowed,
      isTrue,
    );
  });
}
