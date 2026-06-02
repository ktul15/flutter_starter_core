/// Named build environments.
enum Environment { dev, staging, prod }

/// Configuration for a single [Environment].
///
/// Holds the API [baseUrl] and arbitrary per-environment [extras] (feature
/// flags, third-party keys, etc.). Business-specific values stay [PER-PROJECT];
/// this is just the container.
class EnvConfig {
  const EnvConfig({
    required this.environment,
    required this.baseUrl,
    this.extras = const {},
  });

  final Environment environment;
  final String baseUrl;
  final Map<String, Object?> extras;

  bool get isProd => environment == Environment.prod;
  bool get isDev => environment == Environment.dev;

  /// Reads a typed value from [extras], or `null` if absent / wrong type.
  T? extra<T>(String key) {
    final value = extras[key];
    return value is T ? value : null;
  }
}

/// Registry of [EnvConfig]s with a selected [current] environment.
///
/// Construct once at app start and inject where config is needed (e.g. the
/// `ApiClient` base URL). Selection is immutable after construction — build a
/// new instance with [select] to switch.
class EnvConfigs {
  EnvConfigs({
    required Map<Environment, EnvConfig> configs,
    required this.current,
  }) : _configs = Map.unmodifiable(configs) {
    assert(
      _configs.containsKey(current),
      'No EnvConfig registered for $current',
    );
  }

  final Map<Environment, EnvConfig> _configs;

  /// The active environment.
  final Environment current;

  /// Config for the [current] environment.
  EnvConfig get config => _configs[current]!;

  /// Config for any registered [env], or `null` if not registered.
  EnvConfig? of(Environment env) => _configs[env];

  /// Returns a copy with a different [current] environment selected.
  EnvConfigs select(Environment env) =>
      EnvConfigs(configs: _configs, current: env);
}
