# Build Plan — `flutter_core` Reusable Package

A privately-published Flutter package providing reusable infrastructure (networking, auth, common UI, services) for new client projects. This document is the single source of truth for Claude Code to develop the package end to end.

---

## 0. How Claude Code Should Use This Document

- Build **module by module, in the order listed in Section 5**. Do not jump ahead.
- After each module: ensure it compiles (`flutter analyze`), has tests, and is documented.
- Treat anything marked **[PER-PROJECT]** as out of scope — the package only provides interfaces/abstractions for those, never concrete implementations.
- Commit after each completed module with a clear message (e.g. `feat(network): add ApiClient + interceptors`).
- Keep the public API surface minimal: export only what consumers need via `lib/flutter_core.dart`.
- When a decision is ambiguous, prefer the choice already recorded in Section 3 (Tech Decisions). Do not introduce new dependencies without flagging.

---

## 1. Goal

Build a single Flutter package, `flutter_core`, that is:
- **Privately published** (see Section 8 for the publishing mechanism).
- **Consumed by new projects** as a versioned dependency.
- **Modular internally** — clean folder boundaries per feature so any module can later be extracted into its own package with minimal effort.

The package eliminates repetitive setup for: networking, authentication, theming, routing, common widgets, and shared services.

---

## 2. Package Identity

- **Name:** `flutter_core` (adjust to an org-scoped name before publishing, e.g. `acme_core`).
- **Type:** Dart/Flutter package (not a plugin — no platform channels unless a service requires it).
- **Min SDK:** Dart 3.x (required for sealed classes / pattern matching).
- **Flutter:** stable channel, latest at build time.

---

## 3. Tech Decisions (locked)

| Concern | Choice | Notes |
|---|---|---|
| HTTP client | `dio` | Interceptor support, wide adoption |
| JSON parsing | `freezed` + `json_serializable` | Codegen for models + sealed unions |
| Result type | Sealed `ApiResult<T>` (`Success`/`Failure`) | Built in-package, powered by freezed |
| Secure storage | `flutter_secure_storage` behind a `TokenStore` interface | Interface in package; default impl provided, swappable |
| State management | **None enforced** | Package stays state-agnostic; expose services, let the app wire them |
| Routing | Expose helpers + guard logic only | Concrete route table is **[PER-PROJECT]** |
| Connectivity | `connectivity_plus` | For the network checker |
| DI | Constructor injection only | No service locator dependency forced on consumers |

> If any package above is unavailable or yields version conflicts, stop and surface the conflict rather than substituting silently.

---

## 4. Repository Structure

```
flutter_core/
├── lib/
│   ├── flutter_core.dart            # public barrel file (curated exports)
│   └── src/
│       ├── network/
│       │   ├── api_client.dart
│       │   ├── api_result.dart
│       │   ├── api_exception.dart
│       │   ├── request_runner.dart  # the shared _request helper
│       │   └── interceptors/
│       │       ├── auth_interceptor.dart
│       │       ├── error_interceptor.dart
│       │       └── log_interceptor.dart
│       ├── storage/
│       │   ├── token_store.dart            # interface
│       │   └── secure_token_store.dart     # default impl
│       ├── config/
│       │   └── env_config.dart             # dev/staging/prod
│       ├── connectivity/
│       │   └── connectivity_checker.dart
│       ├── auth/
│       │   ├── auth_service.dart
│       │   ├── models/                     # auth request/response models
│       │   └── social/                     # google/apple/facebook wrappers
│       ├── theme/
│       │   ├── app_theme.dart
│       │   └── theme_mode_controller.dart
│       ├── localization/
│       │   └── localization_setup.dart
│       ├── routing/
│       │   └── route_guard.dart            # guard logic only
│       ├── widgets/
│       │   ├── buttons/
│       │   ├── inputs/
│       │   ├── loaders/
│       │   └── states/                     # empty / error states
│       ├── validation/
│       │   └── validators.dart
│       └── utils/
│           └── pagination.dart
├── test/
├── example/                          # runnable demo app consuming the package
├── pubspec.yaml
├── CHANGELOG.md
├── README.md
└── LICENSE
```

---

## 5. Build Order (Modules)

Build strictly in this sequence. Each module lists scope, deliverables, and acceptance criteria.

### Module 1 — Network Core  *(foundation; everything depends on this)*
**Scope:** `ApiClient` (Dio wrapper), `ApiResult<T>`, `ApiException`, the shared `request_runner` helper, and all three interceptors.

**Deliverables:**
- `ApiClient` with configurable `baseUrl`, optional `TokenStore`, and `get/post/put/patch/delete`.
- `ApiResult<T>` sealed type with `Success<T>` and `Failure<T>`.
- `ApiException` with categories: network, timeout, unauthorized, server, validation, unknown — plus a `message` and optional field errors.
- `AuthInterceptor`: injects bearer token; on 401 attempts refresh once, then retries the request; on refresh failure emits an auth-expired signal.
- `ErrorInterceptor`: maps `DioException` → `ApiException`.
- `LogInterceptor`: debug-only request/response logging.
- `requestRunner`: wraps a call, parses the body, returns `ApiResult<T>`.

**Acceptance:**
- Unit tests for: success parse, each error category mapping, 401-refresh-retry happy path, 401-refresh-fail path.
- No dependency on the auth module (network must stand alone).

### Module 2 — Storage + Config
**Scope:** `TokenStore` interface, `SecureTokenStore` default impl, `EnvConfig`.

**Deliverables:**
- `TokenStore` interface: `read/write/clear` for access + refresh tokens.
- `SecureTokenStore` backed by `flutter_secure_storage`.
- `EnvConfig` with named environments and a current-environment selector.

**Acceptance:** Auth interceptor from Module 1 can be wired to a real `TokenStore`. Tests use a fake `TokenStore`.

### Module 3 — Auth Service
**Scope:** `AuthService` built on `ApiClient` + `requestRunner`.

**Deliverables (methods):**
- `login(email, password)`
- `register(RegisterRequest)`
- `forgotPassword(email)`
- `resetPassword(token, newPassword)`
- `logout()`
- `verifyOtp(email, code)` / `resendOtp(email)`
- `refreshToken()` (used by the interceptor)
- Models: `AuthResponse`, `RegisterRequest`, `User` (freezed). These are a **default shape** — document clearly that consumers override field names/paths per project.

**Acceptance:** All methods return `ApiResult<T>`; tests mock `ApiClient`. Endpoint paths centralized in one constants file for easy per-project override.

### Module 4 — Social Login (optional toggle)
**Scope:** Thin wrappers exposing a uniform `SocialAuthResult` for Google, Apple, Facebook.
**Acceptance:** Each provider behind its own file; importing one must not force the others' native setup. Document required platform config per provider.

### Module 5 — Connectivity
**Scope:** `ConnectivityChecker` — current status + a stream of changes, using `connectivity_plus`.
**Acceptance:** Tested against a mockable platform interface.

### Module 6 — Theming
**Scope:** `AppTheme` (light/dark `ThemeData` builders from a small token set) + `ThemeModeController`.
**Acceptance:** Consumer can pass brand colors and get coherent light/dark themes. No hard-coded brand values.

### Module 7 — Localization Setup
**Scope:** Reusable i18n bootstrapping (delegates, supported-locale plumbing). Actual translation strings are **[PER-PROJECT]**.
**Acceptance:** Example app switches locale at runtime.

### Module 8 — Common Widgets
**Scope:** Buttons (primary/secondary/loading), inputs (text/password with validation hooks), loaders (spinner/skeleton), empty state, error state with retry.
**Acceptance:** Each widget rendered in the example app; golden or widget tests for key states.

### Module 9 — Validation + Utils
**Scope:** `Validators` (email, password, required, min/max, match) returning nullable error strings; `Pagination` helper for infinite scroll.
**Acceptance:** Pure-Dart unit tests.

### Module 10 — Routing Guard
**Scope:** `RouteGuard` logic that decides allow/redirect based on auth state. The route table itself is **[PER-PROJECT]**.
**Acceptance:** Unit-tested decision logic, framework-agnostic where possible.

---

## 6. Per-Project (Out of Scope — provide abstractions only)

- Concrete data models / DTOs beyond the default auth shapes.
- Business-specific endpoints and screens.
- The concrete route table.
- App-specific theme brand values and translation strings.
- The chosen state management wiring.

The package must never hard-code these. Where they're needed, expose an interface or a configuration parameter.

---

## 7. Cross-Cutting Requirements

- **Public API discipline:** only export via `lib/flutter_core.dart`; everything else lives under `src/` and stays private.
- **Null safety + Dart 3:** use sealed classes and pattern matching for `ApiResult`.
- **No `print`:** use the logging interceptor / a guarded logger.
- **Docs:** every public class/method gets a doc comment. README shows install + a login example end to end.
- **Tests:** each module ships with tests; aim for meaningful coverage of branching logic (error mapping, refresh flow, validators).
- **Example app:** `example/` must compile and demonstrate: configure client → login → handle Success/Failure → show an empty/error state.
- **Codegen:** document the `build_runner` command in README; commit generated files or document the generate step (pick one and be consistent).

---

## 8. Private Publishing

Pick ONE based on the user's infrastructure (default to git dependency if unspecified):

**Option A — Git dependency (simplest, recommended to start):**
- Consumers add:
  ```yaml
  dependencies:
    flutter_core:
      git:
        url: <private-repo-url>
        ref: v1.0.0   # tag per release
  ```
- Release = tag a version. No registry needed.

**Option B — Private pub server:**
- Set `publish_to:` in `pubspec.yaml` to the private server URL.
- Requires hosting (e.g. a self-hosted pub server or a commercial private registry).

For either option:
- Follow semantic versioning. Bump `pubspec.yaml` version + update `CHANGELOG.md` every release.
- Tag releases `vX.Y.Z`.

---

## 9. Definition of Done (whole package, v1.0.0)

- Modules 1–3 complete and fully tested (these are the must-haves: network + storage + auth).
- Modules 4–10 complete or explicitly deferred with a tracking note in CHANGELOG.
- `flutter analyze` passes with zero issues.
- All tests green.
- `example/` app runs and demonstrates the login flow against a configurable base URL.
- README documents install (private dependency), configuration, and the core login example.
- v1.0.0 tagged and consumable from a fresh project.

---

## 10. First Actions for Claude Code

1. Scaffold the package (`flutter create --template=package flutter_core`) and the `example/` app.
2. Add locked dependencies from Section 3 to `pubspec.yaml`; run `flutter pub get`.
3. Set up `build_runner` + `freezed` + `json_serializable`.
4. Begin **Module 1 — Network Core**. Do not proceed to Module 2 until its acceptance criteria are met.
