import 'package:flutter_test/flutter_test.dart';
import 'package:mobilions_core/mobilions_core.dart';

void main() {
  test('required fails on null/empty/whitespace, passes otherwise', () {
    final v = Validators.required();
    expect(v(null), isNotNull);
    expect(v(''), isNotNull);
    expect(v('   '), isNotNull);
    expect(v('x'), isNull);
  });

  test('email validates format, empty passes', () {
    final v = Validators.email();
    expect(v(''), isNull);
    expect(v('a@b.com'), isNull);
    expect(v('a.b+c@sub.domain.io'), isNull);
    expect(v('nope'), isNotNull);
    expect(v('a@b'), isNotNull);
  });

  test('minLength / maxLength', () {
    expect(Validators.minLength(3)('ab'), isNotNull);
    expect(Validators.minLength(3)('abc'), isNull);
    expect(Validators.maxLength(3)('abcd'), isNotNull);
    expect(Validators.maxLength(3)('abc'), isNull);
  });

  test('password requires length + letter + digit', () {
    final v = Validators.password();
    expect(v('short1'), isNotNull);
    expect(v('allletters'), isNotNull);
    expect(v('12345678'), isNotNull);
    expect(v('abcd1234'), isNull);
  });

  test('match compares against a live callback value', () {
    var other = 'secret';
    final v = Validators.match(() => other);
    expect(v('secret'), isNull);
    other = 'changed';
    expect(v('secret'), isNotNull);
  });

  test('compose returns the first error in order', () {
    final v = Validators.compose([
      Validators.required(),
      Validators.email(),
    ]);
    expect(v(''), Validators.required()(''));
    expect(v('bad'), isNotNull);
    expect(v('a@b.com'), isNull);
  });
}
