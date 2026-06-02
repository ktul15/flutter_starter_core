import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobilions_core/mobilions_core.dart';

void main() {
  final config = LocalizationConfig(
    supportedLocales: const [
      Locale('en'),
      Locale('en', 'US'),
      Locale('fr'),
    ],
  );

  test('fallback defaults to the first supported locale', () {
    expect(config.fallbackLocale, const Locale('en'));
    expect(config.resolve(null), const Locale('en'));
  });

  test('exact language+country match wins', () {
    expect(config.resolve(const Locale('en', 'US')), const Locale('en', 'US'));
  });

  test('falls back to language-only match', () {
    expect(config.resolve(const Locale('fr', 'CA')), const Locale('fr'));
  });

  test('unsupported language returns fallback', () {
    expect(config.resolve(const Locale('de')), const Locale('en'));
  });

  test('asserts at least one supported locale', () {
    expect(
      () => LocalizationConfig(supportedLocales: const []),
      throwsA(isA<AssertionError>()),
    );
  });
}
