import 'package:flutter/material.dart';
import 'package:mobilions_core/mobilions_core.dart';

void main() => runApp(const ExampleApp());

/// Demonstrates: configure environment + client → log in → branch on
/// Success/Failure → show empty/error states.
class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final _themeMode = ThemeModeController();

  // 1. Pick an environment.
  final _env = EnvConfigs(
    current: Environment.dev,
    configs: const {
      Environment.dev: EnvConfig(
        environment: Environment.dev,
        // Public test API that 200s any POST — stands in for a real backend.
        baseUrl: 'https://httpbin.org',
      ),
    },
  );

  late final TokenStore _tokenStore = _InMemoryTokenStore();
  late final ApiClient _client;
  late final AuthService _auth;

  @override
  void initState() {
    super.initState();
    // 2. Build the client and the auth service.
    _client = ApiClient(baseUrl: _env.config.baseUrl);
    _auth = AuthService(client: _client, tokenStore: _tokenStore);
    // 3. Wire the auth interceptor to the token store + refresh callback.
    _client.dio.interceptors.insert(
      0,
      AuthInterceptor(
        dio: _client.dio,
        tokenProvider: _tokenStore.readAccessToken,
        refreshToken: () async => (await _auth.refreshToken()).isSuccess,
        onAuthExpired: _tokenStore.clear,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _themeMode,
      builder: (context, mode, _) => MaterialApp(
        title: 'mobilions_core example',
        themeMode: mode,
        theme: AppTheme.light(seedColor: Colors.indigo),
        darkTheme: AppTheme.dark(seedColor: Colors.indigo),
        home: LoginScreen(
          auth: _auth,
          onToggleTheme: () => _themeMode.toggle(
            platformIsDark:
                MediaQuery.platformBrightnessOf(context) == Brightness.dark,
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.auth, required this.onToggleTheme});

  final AuthService auth;
  final VoidCallback onToggleTheme;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'demo@example.com');
  final _password = TextEditingController(text: 'password1');

  bool _loading = false;
  ApiResult<AuthResponse>? _result;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    // httpbin won't return real tokens — the point is to show the
    // Success/Failure branch, not a working backend.
    final result = await widget.auth.login(_email.text, _password.text);
    setState(() {
      _loading = false;
      _result = result;
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: const Icon(Icons.brightness_6_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    controller: _email,
                    label: 'Email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.compose([
                      Validators.required(),
                      Validators.email(),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    controller: _password,
                    validator: Validators.password(),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Sign in',
                    isLoading: _loading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _ResultView(result: _result),
          ],
        ),
      ),
    );
  }
}

/// Renders the Success/Failure/empty branches of the last attempt.
class _ResultView extends StatelessWidget {
  const _ResultView({this.result});

  final ApiResult<AuthResponse>? result;

  @override
  Widget build(BuildContext context) {
    final r = result;
    if (r == null) {
      return const SizedBox(
        height: 220,
        child: EmptyState(
          title: 'No attempt yet',
          message: 'Submit the form to see the Success/Failure result.',
          icon: Icons.login_outlined,
        ),
      );
    }
    return switch (r) {
      Success(:final data) => Card(
          child: ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: const Text('Success'),
            subtitle: Text('access token: ${data.accessToken}'),
          ),
        ),
      Failure(:final error) => SizedBox(
          height: 220,
          child: ErrorStateView.fromException(error),
        ),
    };
  }
}

/// Minimal in-memory [TokenStore] so the example needs no secure-storage setup.
class _InMemoryTokenStore implements TokenStore {
  String? _access;
  String? _refresh;

  @override
  Future<String?> readAccessToken() async => _access;
  @override
  Future<String?> readRefreshToken() async => _refresh;
  @override
  Future<void> writeTokens({required String accessToken, String? refreshToken}) async {
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
