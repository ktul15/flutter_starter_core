# Changelog

## 1.0.0

First release. Modules 1–10 from the build plan, all tested (80 package tests, analyze clean).

### Added

- **Network** — `ApiClient` (Dio wrapper), sealed `ApiResult<T>` (`Success`/`Failure`),
  `ApiException` with categories, `requestRunner`, and auth/error/log interceptors.
  `AuthInterceptor` does 401 → refresh-once → retry with loop guard and concurrent-refresh coalescing.
- **Storage + Config** — `TokenStore` interface, `SecureTokenStore` (flutter_secure_storage),
  `EnvConfig`/`EnvConfigs` with dev/staging/prod selection.
- **Auth** — `AuthService` (login/register/forgot/reset/logout/verifyOtp/resendOtp/refreshToken),
  freezed `User`/`AuthResponse`/`RegisterRequest`, overridable `AuthEndpoints`.
- **Social login** — `SocialAuthProvider` interface + `SocialAuthResult`/`SocialAuthException`.
- **Connectivity** — `ConnectivityChecker` (online bool + de-duped status stream).
- **Theming** — `AppTheme` (seed-based light/dark) + `ThemeModeController`.
- **Localization** — `LocalizationConfig` with delegate/locale plumbing and a resolver.
- **Widgets** — primary/secondary buttons (loading), `AppTextField`, `PasswordField`,
  `AppLoader`, `SkeletonBox`, `EmptyState`, `ErrorStateView`.
- **Validation + utils** — composable `Validators`, `PaginationState`.
- **Routing** — `RouteGuard` allow/redirect decision logic.

### Notes / deviations from the build plan

- `ApiResult` is a hand-written native Dart 3 sealed class rather than freezed —
  cleaner exhaustive matching for a generic union with no JSON.
- Social login ships the **abstraction only**; native provider SDKs
  (`google_sign_in`, etc.) are implemented per-project so they are not forced on every consumer.
- Generated `.freezed`/`.g` files are committed (required for git-dependency consumers).
