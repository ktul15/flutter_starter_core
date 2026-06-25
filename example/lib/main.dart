import 'package:flutter/material.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await LocalPreferences.create();
  runApp(ShowcaseApp(prefs: prefs));
}

/// Root app — initialises shared services and passes them into the widget tree.
class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key, required this.prefs});

  final LocalPreferences prefs;

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  late final _envConfigs = EnvConfigs(
    current: Environment.dev,
    configs: {
      Environment.dev: const EnvConfig(
        environment: Environment.dev,
        baseUrl: 'https://httpbin.org',
      ),
      Environment.staging: const EnvConfig(
        environment: Environment.staging,
        baseUrl: 'https://staging-api.example.com',
      ),
      Environment.prod: const EnvConfig(
        environment: Environment.prod,
        baseUrl: 'https://api.example.com',
      ),
    },
  );

  late final _tokenStore = _InMemoryTokenStore();
  late final _client = ApiClient(baseUrl: _envConfigs.config.baseUrl);
  late final _auth = AuthService(client: _client, tokenStore: _tokenStore);

  @override
  void initState() {
    super.initState();
    _client.dio.interceptors.insert(
      0,
      AuthInterceptor(
        dio: _client.dio,
        tokenProvider: _tokenStore.readAccessToken,
        refreshToken: () async => (await _auth.refreshToken()).isSuccess,
        onAuthExpired: _tokenStore.clear,
      ),
    );
    _client.dio.interceptors.add(RetryInterceptor(dio: _client.dio));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_starter_core showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: HomeScreen(
        prefs: widget.prefs,
        tokenStore: _tokenStore,
        client: _client,
        auth: _auth,
        envConfigs: _envConfigs,
      ),
    );
  }
}

/// In-memory [TokenStore] — good for demos and unit tests.
class _InMemoryTokenStore implements TokenStore {
  String? _access;
  String? _refresh;

  @override
  Future<String?> readAccessToken() async => _access;

  @override
  Future<String?> readRefreshToken() async => _refresh;

  @override
  Future<void> writeTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _access = accessToken;
    if (refreshToken != null) _refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }

  @override
  Future<bool> get hasAccessToken async => _access?.isNotEmpty ?? false;
}
