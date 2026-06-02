# mobilions_core

Reusable Flutter infrastructure for new client apps — networking, auth, secure
storage, theming, common widgets, validation, and routing guards. Drop it in as
a versioned dependency and skip the repetitive setup.

State-management-agnostic and DI-container-free: the package exposes services
and widgets; you wire them with plain constructor injection.

## Install

Git dependency (recommended). Pin a release tag:

```yaml
dependencies:
  mobilions_core:
    git:
      url: <private-repo-url>
      ref: v1.0.0
```

Then:

```sh
fvm flutter pub get
```

> Generated `.freezed`/`.g` files are committed, so consumers do **not** run
> `build_runner`.

## What's inside

| Area | Key types |
|------|-----------|
| Network | `ApiClient`, `ApiResult<T>` (`Success`/`Failure`), `ApiException`, `requestRunner`, `AuthInterceptor`, `ErrorInterceptor`, `NetworkLogInterceptor` |
| Storage + config | `TokenStore`, `SecureTokenStore`, `EnvConfig`, `EnvConfigs` |
| Auth | `AuthService`, `AuthEndpoints`, `User`, `AuthResponse`, `RegisterRequest` |
| Social | `SocialAuthProvider`, `SocialAuthResult`, `SocialAuthException` |
| Connectivity | `ConnectivityChecker` |
| Theming | `AppTheme`, `ThemeModeController` |
| Localization | `LocalizationConfig` |
| Widgets | `PrimaryButton`/`SecondaryButton`, `AppTextField`, `PasswordField`, `AppLoader`, `SkeletonBox`, `EmptyState`, `ErrorStateView` |
| Validation + utils | `Validators`, `PaginationState` |
| Routing | `RouteGuard` |

Import everything from the one barrel:

```dart
import 'package:mobilions_core/mobilions_core.dart';
```

## Configure → log in end to end

```dart
// 1. Environment.
final env = EnvConfigs(
  current: Environment.dev,
  configs: const {
    Environment.dev: EnvConfig(
      environment: Environment.dev,
      baseUrl: 'https://dev.api.example.com',
    ),
    Environment.prod: EnvConfig(
      environment: Environment.prod,
      baseUrl: 'https://api.example.com',
    ),
  },
);

// 2. Token store + client + auth service.
final tokenStore = SecureTokenStore();
final client = ApiClient(baseUrl: env.config.baseUrl);
final auth = AuthService(client: client, tokenStore: tokenStore);

// 3. Wire the auth interceptor (bearer inject + 401 refresh/retry).
client.dio.interceptors.insert(
  0,
  AuthInterceptor(
    dio: client.dio,
    tokenProvider: tokenStore.readAccessToken,
    refreshToken: () async => (await auth.refreshToken()).isSuccess,
    onAuthExpired: tokenStore.clear,
  ),
);

// 4. Log in and branch on the sealed result.
final result = await auth.login(email, password);
switch (result) {
  case Success(:final data):
    print('Signed in: ${data.user?.email}'); // tokens already persisted
  case Failure(:final error):
    print('Failed (${error.type}): ${error.message}');
}
```

### Adapting to your backend

Endpoint paths and model shapes are a **default** — override them per project:

```dart
// Custom paths, no AuthService changes needed.
final auth = AuthService(
  client: client,
  tokenStore: tokenStore,
  endpoints: const AuthEndpoints(login: '/v2/sessions', refresh: '/v2/token'),
);
```

The `User`/`AuthResponse`/`RegisterRequest` models and their `@JsonKey`
mappings are a starting point; fork them to match your API.

### Social login

The package defines the `SocialAuthProvider` interface only — implement it
per project with the SDK you need (so apps without social login pull nothing
extra), then exchange the returned `idToken`/`accessToken` with your backend.

## Theming

```dart
MaterialApp(
  theme: AppTheme.light(seedColor: Colors.indigo),
  darkTheme: AppTheme.dark(seedColor: Colors.indigo),
  themeMode: themeModeController.value,
);
```

## Example app

A runnable demo (configure → login → Success/Failure → empty/error states)
lives in [`example/`](example/lib/main.dart):

```sh
cd example
fvm flutter run
```

## Development

```sh
fvm flutter pub get
fvm dart run build_runner build -d   # regenerate freezed/json
fvm flutter analyze                  # must be zero issues
fvm flutter test                     # full suite
```

## Releasing

Semantic versioning. Bump `version` in `pubspec.yaml`, update `CHANGELOG.md`,
then tag:

```sh
git tag v1.0.0 && git push --tags
```
