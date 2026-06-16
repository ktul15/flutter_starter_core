# Changelog

## 1.1.0

Modules 11–22: retry, utilities, preferences, crash reporting, analytics, push notifications,
permissions, media picking, OTP widget, in-app messaging, network image, version checking.
148 tests, analyze clean.

### Added

- **RetryInterceptor** — Dio interceptor with configurable max retries, exponential backoff,
  and a `retryWhen` predicate. Defaults to retrying connection/timeout errors only; never retries
  4xx/5xx. Tracks attempt count via `requestOptions.extra`.
- **Utilities** — `Debouncer` (timer-based with `isPending`), `DateFormatter` (pure Dart relative
  and absolute formatting), `HapticService` (static wrappers for all `HapticFeedback` patterns).
- **AppPreferences** — `AppPreferences` interface + `LocalPreferences` (`shared_preferences`
  backed). Covers string/bool/int read-write, `remove`, `clear`, `containsKey`.
- **CrashReporter** — `CrashReporter` interface (recordError, recordFlutterError, user identity,
  breadcrumbs) + `CrashReporterWiring.attach()` that hooks `FlutterError.onError` and
  `PlatformDispatcher.instance.onError` in one call.
- **AnalyticsService** — `AnalyticsService` interface + `NoOpAnalyticsService` (safe default
  before a real backend is wired). `AnalyticsEvent` carries name + typed param map.
- **PushService** — `PushService` interface covering permission, token, foreground/background
  message streams, initial-message, and topic subscribe/unsubscribe. `PushMessage` + 
  `PushPermissionStatus` are provider-agnostic.
- **AppPermissions** — `AppPermissions` class wrapping `permission_handler`; consumers depend only
  on `AppPermission` enum and sealed `PermissionStatus` — the underlying SDK is never re-exported.
- **MediaPicker** — `MediaPicker` wrapping `image_picker` with `pickImage`/`pickImages`/`pickVideo`.
  `MediaFile.toMultipartFile()` bridges directly to `ApiClient.postFormData`.
- **OtpField** — `OtpField` widget: per-cell auto-advance, backspace retreat, paste distribution,
  obscure mode. Styled entirely from `inputDecorationTheme` — no hardcoded colours.
- **AppMessenger** — `AppMessenger` (context-free snackbar helper keyed to a
  `GlobalKey<ScaffoldMessengerState>`). Four semantic levels (success/error/info/warning) mapped
  to `ColorScheme` slots; custom `SnackBar` escape hatch.
- **AppNetworkImage** — `AppNetworkImage` widget (`cached_network_image` backed). Defaults:
  `SkeletonBox` placeholder, `Icons.broken_image_outlined` error icon. Optional `borderRadius`
  and `headers`.
- **AppVersionChecker** — `AppVersionChecker` + `AppVersionInfo` with pure-Dart semver comparison.
  Reads current version from `package_info_plus`; compares against server-supplied
  `latest_version`/`min_required_version`. Returns `VersionStatus` enum.

### New dependencies

- `shared_preferences: ^2.3.0`
- `permission_handler: ^11.3.0`
- `image_picker: ^1.1.0`
- `cached_network_image: ^3.4.0`
- `package_info_plus: ^8.1.0`

### Notes

- Crash, analytics, and push modules ship **interfaces only** — no native SDK is forced on
  consumers. Wire your own Crashlytics/Sentry/FCM/OneSignal implementation behind the interface.
- `AppPermissions` and `MediaPicker` expose normalised types (`AppPermission`, `MediaFile`) so
  consumers never import `permission_handler` or `image_picker` directly.

---

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
