import 'package:package_info_plus/package_info_plus.dart';

import '../network/api_client.dart';
import '../network/api_exception.dart';
import '../network/api_result.dart';
import '../network/request_runner.dart';
import 'version_status.dart';

/// Fetches the server's version policy and compares it against the running app.
///
/// Version data is server-controlled, not fetched directly from the App Store or
/// Play Store. This is intentional:
/// - `min_required_version` (force-update threshold) can only come from your own
///   server — the stores have no concept of "this version is blocked".
/// - The server can flip a force-update immediately (e.g. a security incident)
///   without waiting for store API propagation.
/// - A single endpoint works cross-platform (iOS + Android).
///
/// **Operational requirement:** every time a new build ships to the stores, the
/// backend endpoint must also be updated with the new `latest_version`. If it
/// falls out of sync, [VersionStatus.updateAvailable] will never be returned
/// even when a newer version exists in the store.
///
/// The [endpoint] must return JSON matching [AppVersionInfo.fromJson]:
/// ```json
/// {
///   "latest_version": "2.0.0",
///   "min_required_version": "1.5.0",
///   "update_url": "https://play.google.com/..."
/// }
/// ```
/// `current_version` is read locally — do not include it in the server response.
///
/// Results are cached for [cacheDuration] (default 4 hours) so repeated calls
/// within one app session do not hit the network. Pass `forceRefresh: true` to
/// [check] to bypass the cache (e.g. after the user manually taps "check for
/// updates").
///
/// ```dart
/// final checker = AppVersionChecker(client: apiClient, endpoint: '/app/version');
/// final result = await checker.check();
/// result.when(
///   success: (info) {
///     if (info.status == VersionStatus.updateRequired) showForceUpdateDialog();
///   },
///   failure: (_) {},
/// );
/// ```
class AppVersionChecker {
  /// Creates a checker.
  ///
  /// [versionProvider] overrides how the current app version is read — defaults
  /// to `PackageInfo.fromPlatform().version`. Override in tests to avoid the
  /// platform channel:
  ///
  /// ```dart
  /// AppVersionChecker(
  ///   client: mockClient,
  ///   endpoint: '/app/version',
  ///   versionProvider: () async => '1.0.0',
  /// )
  /// ```
  AppVersionChecker({
    required ApiClient client,
    required String endpoint,
    this.cacheDuration = const Duration(hours: 4),
    Future<String> Function()? versionProvider,
  })  : _client = client,
        _endpoint = endpoint,
        _versionProvider = versionProvider ?? _defaultVersionProvider;

  final ApiClient _client;
  final String _endpoint;
  final Future<String> Function() _versionProvider;

  /// How long a successful [check] result is reused before the next call hits
  /// the network. Defaults to 4 hours. Set to [Duration.zero] to disable.
  final Duration cacheDuration;

  AppVersionInfo? _cached;
  DateTime? _cachedAt;

  static Future<String> _defaultVersionProvider() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  /// Fetches (or returns cached) version policy, compares to current app version.
  ///
  /// Cached when [cacheDuration] > 0 and the last successful fetch was within
  /// that window. Pass [forceRefresh] to bypass the cache unconditionally.
  Future<ApiResult<AppVersionInfo>> check({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid()) return Success(_cached!);

    final String current;
    try {
      current = await _versionProvider();
    } catch (e) {
      return Failure(
        ApiException(
          type: ApiErrorType.unknown,
          message: 'Failed to read app version from package metadata: $e',
        ),
      );
    }

    final result = await requestRunner(
      () => _client.get(_endpoint),
      (data) => AppVersionInfo.fromJson(data as Map<String, dynamic>, current),
    );

    if (result is Success<AppVersionInfo>) {
      _cached = result.data;
      _cachedAt = DateTime.now();
    }

    return result;
  }

  /// Discards any cached result so the next [check] call hits the network.
  void invalidateCache() {
    _cached = null;
    _cachedAt = null;
  }

  bool _isCacheValid() {
    if (_cached == null || _cachedAt == null) return false;
    return DateTime.now().difference(_cachedAt!) < cacheDuration;
  }
}
