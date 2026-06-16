import 'package:flutter/material.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import 'screens/home_screen.dart';

final _messengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await LocalPreferences.create();
  final themeController = await PersistentThemeModeController.create(prefs);
  runApp(ShowcaseApp(prefs: prefs, themeController: themeController));
}

/// Root app — initialises all shared services and passes them into the widget
/// tree. Demonstrates the recommended wiring pattern for a client project.
class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({
    super.key,
    required this.prefs,
    required this.themeController,
  });

  final LocalPreferences prefs;
  final PersistentThemeModeController themeController;

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  late final AppMessenger _messenger = AppMessenger(_messengerKey);

  // ── Environment config — swap `current` per build flavor ──────────────────
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

  // ── Networking + auth ──────────────────────────────────────────────────────
  late final _tokenStore = _InMemoryTokenStore();
  late final _client = ApiClient(baseUrl: _envConfigs.config.baseUrl);
  late final _auth = AuthService(client: _client, tokenStore: _tokenStore);

  // ── Localization ───────────────────────────────────────────────────────────
  final _l10n = LocalizationConfig(
    supportedLocales: const [Locale('en'), Locale('es'), Locale('fr')],
  );

  @override
  void initState() {
    super.initState();
    // Auth interceptor: inject bearer token + handle 401 refresh-retry.
    _client.dio.interceptors.insert(
      0,
      AuthInterceptor(
        dio: _client.dio,
        tokenProvider: _tokenStore.readAccessToken,
        refreshToken: () async => (await _auth.refreshToken()).isSuccess,
        onAuthExpired: _tokenStore.clear,
      ),
    );
    // Retry transient network/timeout errors with exponential backoff.
    _client.dio.interceptors.add(RetryInterceptor(dio: _client.dio));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.themeController,
      builder: (_, mode, child) => MaterialApp(
        title: 'flutter_starter_core showcase',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: _messengerKey,
        themeMode: mode,
        theme: AppTheme.light(seedColor: Colors.indigo),
        darkTheme: AppTheme.dark(seedColor: Colors.indigo),
        supportedLocales: _l10n.supportedLocales,
        localizationsDelegates: _l10n.allDelegates,
        localeResolutionCallback: _l10n.resolve,
        home: HomeScreen(
          prefs: widget.prefs,
          themeController: widget.themeController,
          tokenStore: _tokenStore,
          client: _client,
          auth: _auth,
          messenger: _messenger,
          envConfigs: _envConfigs,
        ),
      ),
    );
  }
}

/// In-memory [TokenStore] — good for demos and unit tests.
/// In production use [SecureTokenStore] backed by flutter_secure_storage.
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
