# Changelog

## 2.0.0

Multi-round audit: correctness fixes, new API, one breaking change, one removal.
200 tests, zero analyzer issues.

### Breaking

- **`AppPreferences.containsKey`** returns `Future<bool>` instead of `bool`.
  Implementations backed by async stores can now honour the contract;
  `LocalPreferences` wraps the synchronous `SharedPreferences` call in `async`.
  Update all call sites: `await prefs.containsKey('key')`.

### Removed

- **`AppMessenger`** deleted. It was a global `GlobalKey` singleton — a navigation
  anti-pattern that made context-free snackbars fragile and hard to test.
  Use `ScaffoldMessenger.of(context)` (or a `GlobalKey<ScaffoldMessengerState>`
  you manage yourself) at the app level.

### Added

- **`AuthService.sendOtp` / `verifyOtpOnly`** — OTP-first signup flow (Flow B):
  trigger an OTP send before the registration form, verify the address without
  persisting tokens, then call `register`. Override `AuthEndpoints.sendOtp` if
  the backend uses a different path.
- **`PaginationState`** — cursor-based pagination, `refresh` state, `hasMore` flag,
  and `ApiException` error field. Replaces the offset-only v1 state machine.
- **`AnalyticsEvent.checked()`** factory — throws `ArgumentError` in both debug and
  release if any param value is not `String`, `num`, or `bool`. Use for
  dynamically-built param maps; error message names the offending key.
- **`AppTextField` / `PasswordField`** — `focusNode` and `autofocus` fields added.
- **`LocalizationConfig.localeResolutionCallback`** getter — correct
  `LocaleResolutionCallback` return type for direct use in `MaterialApp`.

### Fixed

- **`OtpField`** — FocusNode leak: `KeyboardListener` nodes were never disposed;
  now created in `initState` and disposed in `dispose`.
- **`OtpField`** — dead `from` parameter removed from `_distribute`; paste always
  fills from cell 0.
- **`HapticService.error()`** — was identical to `success()` (both `lightImpact`);
  `error()` now uses `heavyImpact`.
- **`LocalizationConfig`** — `assert` → `ArgumentError` in constructor body so it
  fires in release builds; `fallbackLocale` safe-defaults to `const Locale('en')`
  to avoid `StateError` on empty `supportedLocales`.
- **`ErrorStateView.fromException`** — no longer exposes internal `error.message`
  (can contain server implementation details); switches on `ApiErrorType` for safe,
  user-facing copy. Override via the `message` parameter.
- **`AppVersionInfo`** — semver comparison strips pre-release suffixes
  (`1.2.3-beta` → `1.2.3`) and build metadata (`2.0.0+42` → `2.0.0`) before
  comparing, preventing false `updateRequired` results.
- **`AppVersionChecker._parse`** — replaced opaque `as String` casts with explicit
  type checks; failure now reports which field is missing or wrong-typed.
- **`AuthInterceptor`** — `_retry` catch-all added; non-`DioException` errors no
  longer propagate raw.
- **`AuthInterceptor`** — if `refreshToken()` throws, `onAuthExpired` and
  `handler.next` were silently bypassed; now wrapped in `try/catch`.
- **`AuthService.logout`** — `PlatformException` from `TokenStore.clear()`
  (Keychain locked) caught so the `ApiResult` contract is always preserved.
- **`PrimaryButton` / `SecondaryButton`** — `Semantics(label: '$label, loading')`
  wraps the button during `isLoading` so screen readers announce the state.
- **`MediaPicker.pickFile`** — Flutter Web: `withData: kIsWeb` loads bytes on web;
  guard changed to `path == null && bytes == null` so a path-empty/bytes-null
  `MediaFile` is never returned (would crash `toMultipartFile`).
- **`ConnectivityChecker._sameResults`** — asymmetric set comparison fixed; old
  code returned `true` for `[wifi, ethernet]` vs `[wifi, wifi]`. Now uses
  `setA.length == setB.length && setA.containsAll(setB)`.
- **`DateFormatter`** — replaced hand-rolled formatting with `intl`; relative-time
  output is locale-aware and timezone-safe.
- **`TokenStore.hasAccessToken`** — dead default body removed from
  `abstract interface class` (unreachable via both `extends` and `implements`).
- **`AppPreferences.clear`** — doc corrected: `LocalPreferences` scopes the clear
  to `fsc_`-prefixed keys only; other libraries' keys are untouched.
- **`PersistentThemeModeController._save`** — dropped `Future` now has `.catchError`
  so a write failure is logged rather than silently lost.
- **`RouteGuard`** doc example — `store.hasAccessToken` corrected to
  `await store.hasAccessToken` (`Future<bool>`, not `bool`).
- **`RetryInterceptor`** barrel export moved into Module 1 with the other
  network interceptors.

- **`AppVersionChecker`** — `toJson()` added to `AppVersionInfo` for disk-cache persistence
  (round-trips through `fromJson`; excludes `currentVersion` which is always re-read locally).
- **`AppVersionChecker`** — `==` / `hashCode` added to `AppVersionInfo`; two instances with
  identical fields are now value-equal (uses `Object.hash`).
- **`AppVersionChecker`** — `X-Platform` header injected on every request (`ios`, `android`,
  `web`, etc.) so the server can return a platform-appropriate `update_url`. Opt out with
  `sendPlatformHeader: false`.

### Tests

221 tests (up from 148 at 1.0.0). New coverage: `AnalyticsEvent.checked` (5 cases),
`AuthService.logout` PlatformException absorption, pre-release/build-metadata version
parsing (3 cases), `ErrorStateView.fromException` safe messages,
`ConnectivityChecker.onResultChange` de-duplication, `AppVersionInfo.toJson` (3),
`AppVersionInfo` equality (4), platform header (2).

---

## 1.2.0

Bug fixes, security hardening, and new features across storage, network, theme, media, and push.

### Added

- **`PersistentThemeModeController`** — drop-in replacement for `ThemeModeController` that
  auto-saves the selected `ThemeMode` to `AppPreferences` (`fsc_theme_mode` key) and restores
  it on next launch. Use `await PersistentThemeModeController.create(prefs)` in `main()`.
- **`MediaPicker.pickFile`** — picks any file type via `file_picker`. Pass
  `allowedExtensions: ['pdf', 'docx']` to restrict. Returns `MediaFile` with MIME type derived
  from extension; `.toMultipartFile()` works immediately.
- **`templates/fcm_push_service.dart`** — copy-paste `PushService` implementation backed by
  Firebase Cloud Messaging. Add `firebase_messaging: ^15.0.0` to the client app and copy the
  template. Not compiled into the package — no Firebase dependency forced on consumers.

### Fixed

- **`OtpField` paste** — pasting a code now always fills from cell 0 regardless of which cell
  was focused, and clears trailing cells. Matches user expectation when copying an SMS OTP code.
- **`SecureTokenStore` default keys** — changed from `mobilions_access_token` /
  `mobilions_refresh_token` to `fsc_access_token` / `fsc_refresh_token` to prevent keychain
  collisions with other apps on shared keychain groups.
- **`RetryInterceptor` extra key** — `mobilions_retry_count` → `fsc_retry_count`.

### Changed

- **`RetryInterceptor` backoff** — replaced fixed exponential delay with full jitter
  (`Random().nextInt(ceiling)`). Prevents thundering-herd retries when many clients experience
  the same outage simultaneously.

### New dependency

- `file_picker: ^8.1.0`

---

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
