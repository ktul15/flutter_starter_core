import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

/// Example per-project provider implementation, here faked.
class _FakeGoogleProvider implements SocialAuthProvider {
  _FakeGoogleProvider({this.shouldCancel = false});

  final bool shouldCancel;
  bool signedOut = false;

  @override
  SocialProvider get provider => SocialProvider.google;

  @override
  Future<SocialAuthResult> signIn() async {
    if (shouldCancel) {
      throw const SocialAuthException(
        provider: SocialProvider.google,
        type: SocialAuthErrorType.cancelled,
        message: 'User cancelled',
      );
    }
    return const SocialAuthResult(
      provider: SocialProvider.google,
      idToken: 'id-token',
      email: 'a@b.com',
      nonce: 'abc123',
    );
  }

  @override
  Future<void> signOut() async => signedOut = true;
}

void main() {
  test('provider returns a normalized result', () async {
    final result = await _FakeGoogleProvider().signIn();
    expect(result.provider, SocialProvider.google);
    expect(result.idToken, 'id-token');
    expect(result.email, 'a@b.com');
    expect(result.nonce, 'abc123');
  });

  test('cancellation surfaces a typed exception', () async {
    await expectLater(
      _FakeGoogleProvider(shouldCancel: true).signIn(),
      throwsA(
        isA<SocialAuthException>()
            .having((e) => e.isCancelled, 'isCancelled', isTrue)
            .having((e) => e.provider, 'provider', SocialProvider.google),
      ),
    );
  });

  test('signOut is honored', () async {
    final p = _FakeGoogleProvider();
    await p.signOut();
    expect(p.signedOut, isTrue);
  });
}
