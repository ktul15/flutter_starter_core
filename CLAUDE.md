# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A privately-published, reusable Flutter **package** (`flutter_core`) that supplies cross-project infrastructure — networking, auth, storage, theming, common widgets, validation — so new client apps skip repetitive setup. It is a Dart/Flutter package, **not a plugin** (no platform channels unless a service demands one).

**The package does not exist yet.** `BUILD_PLAN.md` is the single source of truth: it defines the locked tech decisions, the module build order, and the acceptance criteria for each module. Read it before doing anything. This CLAUDE.md is a quick-reference summary; `BUILD_PLAN.md` wins on any conflict.

## Bootstrapping (first session only)

```bash
fvm flutter create --template=package flutter_core   # scaffold package
fvm flutter create example                            # runnable demo app that consumes the package
fvm flutter pub get
```

Then add the locked dependencies (see below) and set up codegen before writing Module 1.

## Commands

Use FVM (`fvm flutter` / `fvm dart`) — never bare `flutter`/`dart`. Aliases from the global zsh config:

| Task | Command |
|------|---------|
| Install deps | `fvpg` (`fvm flutter pub get`) |
| Add a dep | `fvpa <pkg>` |
| Codegen (freezed/json) | `fgc` (`fvm dart run build_runner build -d`) |
| Codegen watch | `fvm dart run build_runner watch -d` |
| Analyze (must pass with zero issues) | `fvm flutter analyze` |
| All tests | `fvm flutter test` |
| Single test file | `fvm flutter test test/network/api_client_test.dart` |
| Single test by name | `fvm flutter test --name "401 refresh retry"` |
| Clean | `fvc` (`fvm flutter clean`) |

Run `fgc` after touching any file with `@freezed`, `@JsonSerializable`, or other annotations.

## Locked tech decisions (do not substitute silently)

| Concern | Choice |
|---------|--------|
| HTTP | `dio` (interceptors) |
| Models / JSON | `freezed` + `json_serializable` |
| Result type | in-package sealed `ApiResult<T>` = `Success<T>` \| `Failure<T>` (Dart 3 sealed + pattern matching) |
| Secure storage | `flutter_secure_storage` behind a `TokenStore` interface |
| Connectivity | `connectivity_plus` |
| State management | **none** — package stays state-agnostic, exposes services only |
| DI | constructor injection only — no service locator forced on consumers |

If a dependency conflicts or is unavailable, **stop and surface it** — do not pick a substitute. Min: Dart 3.x, Flutter stable.

## Architecture & conventions

- **Public API discipline:** everything lives under `lib/src/`; the only public surface is the curated barrel `lib/mobilions_core.dart`. Export only what consumers need.
- **Modular folders** (`src/network`, `src/storage`, `src/auth`, `src/theme`, …) — each boundary is drawn so a module can later be extracted into its own package with minimal churn.
- **Network stands alone:** the network module must not depend on the auth module. `AuthInterceptor` does 401 → refresh-once → retry, then emits an auth-expired signal on failure. `ErrorInterceptor` maps `DioException` → `ApiException` (categories: network, timeout, unauthorized, server, validation, unknown). `LogInterceptor` is debug-only.
- **`requestRunner`** is the one shared helper that wraps a call, parses the body, and returns `ApiResult<T>`. Auth methods all return `ApiResult<T>`.
- **No `print`** — use the logging interceptor / guarded logger.
- **[PER-PROJECT] = out of scope:** concrete route tables, business endpoints/screens, brand theme values, translation strings, DTOs beyond the default auth shapes, and state-management wiring are never hard-coded. Provide an interface or config parameter instead. Default auth models (`User`, `AuthResponse`, `RegisterRequest`) are a documented *default shape* consumers override; keep endpoint paths in one constants file for easy override.
- Every public class/method gets a doc comment.

## Build order (strict — do not jump ahead)

1. **Network Core** — `ApiClient`, `ApiResult`, `ApiException`, `requestRunner`, 3 interceptors *(foundation)*
2. **Storage + Config** — `TokenStore` interface, `SecureTokenStore`, `EnvConfig`
3. **Auth Service** — login/register/forgot/reset/logout/verifyOtp/resendOtp/refreshToken on `ApiClient`
4. Social login (Google/Apple/Facebook, isolated per file)
5. Connectivity · 6. Theming · 7. Localization · 8. Common widgets · 9. Validation + utils · 10. Routing guard

Modules 1–3 are the must-haves for v1.0.0. Each module must compile (`fvm flutter analyze` zero issues), ship tests covering branching logic (error mapping, refresh flow, validators), and be documented before moving on. Commit after each module: `feat(network): add ApiClient + interceptors`.

## Publishing

Default to **git dependency** (tag releases `vX.Y.Z`, consumers pin a `ref`). Semantic versioning; bump `pubspec.yaml` + update `CHANGELOG.md` each release. Repo is currently **not git-initialized** — `git init` before the first release.
