import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

void main() {
  final configs = EnvConfigs(
    current: Environment.dev,
    configs: {
      Environment.dev: const EnvConfig(
        environment: Environment.dev,
        baseUrl: 'https://dev.api',
        extras: {'analytics': false, 'apiKey': 'dev-key'},
      ),
      Environment.staging: const EnvConfig(
        environment: Environment.staging,
        baseUrl: 'https://staging.api',
      ),
      Environment.prod: const EnvConfig(
        environment: Environment.prod,
        baseUrl: 'https://api',
      ),
    },
  );

  test('current resolves to the selected config', () {
    expect(configs.config.baseUrl, 'https://dev.api');
    expect(configs.config.isDev, isTrue);
    expect(configs.config.isProd, isFalse);
  });

  test('of returns any registered env, null otherwise', () {
    expect(configs.of(Environment.prod)?.baseUrl, 'https://api');
  });

  test('select returns a copy with a new current, original unchanged', () {
    final prod = configs.select(Environment.prod);
    expect(prod.config.baseUrl, 'https://api');
    expect(prod.config.isProd, isTrue);
    expect(configs.current, Environment.dev, reason: 'original untouched');
  });

  test('extra reads typed values, null on missing or wrong type', () {
    final dev = configs.config;
    expect(dev.extra<bool>('analytics'), false);
    expect(dev.extra<String>('apiKey'), 'dev-key');
    expect(dev.extra<int>('apiKey'), isNull, reason: 'wrong type');
    expect(dev.extra<String>('missing'), isNull);
  });

  test('throws ArgumentError when current is not registered', () {
    expect(
      () => EnvConfigs(current: Environment.prod, configs: const {}),
      throwsA(isA<ArgumentError>()),
    );
  });
}
