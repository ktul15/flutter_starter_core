import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

class _FakeDelegate extends LocalizationsDelegate<Object> {
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<Object> load(Locale locale) async => Object();
  @override
  bool shouldReload(covariant LocalizationsDelegate<Object> old) => false;
}

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

  test('throws ArgumentError for empty supportedLocales', () {
    expect(
      () => LocalizationConfig(supportedLocales: const []),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('allDelegates includes the three standard Material delegates', () {
    final delegates = config.allDelegates.toList();
    expect(delegates, contains(GlobalMaterialLocalizations.delegate));
    expect(delegates, contains(GlobalWidgetsLocalizations.delegate));
    expect(delegates, contains(GlobalCupertinoLocalizations.delegate));
  });

  test('allDelegates appends app-specific delegates after Material ones', () {
    final appDelegate = _FakeDelegate();
    final custom = LocalizationConfig(
      supportedLocales: const [Locale('en')],
      delegates: [appDelegate],
    );
    final list = custom.allDelegates.toList();
    expect(list.last, same(appDelegate));
    expect(list.length, 4); // 3 Material + 1 app
  });
}
