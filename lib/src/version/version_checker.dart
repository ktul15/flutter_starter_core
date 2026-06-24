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
/// The [endpoint] must return JSON matching [AppVersionInfo]:
/// ```json
/// {
///   "latest_version": "2.0.0",
///   "min_required_version": "1.5.0",
///   "update_url": "https://play.google.com/..."
/// }
/// ```
/// `current_version` is read locally via `package_info_plus` — do not include
/// it in the server response.
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
  AppVersionChecker({required ApiClient client, required String endpoint})
      : _client = client,
        _endpoint = endpoint;

  final ApiClient _client;
  final String _endpoint;

  /// Returns the version string from the device's package metadata (e.g. `"1.2.3"`).
  Future<String> _getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  /// Fetches the server's version policy, compares to current, returns [AppVersionInfo].
  Future<ApiResult<AppVersionInfo>> check() async {
    final String current;
    try {
      current = await _getCurrentVersion();
    } catch (e) {
      return Failure(
        ApiException(
          type: ApiErrorType.unknown,
          message: 'Failed to read app version from package metadata: $e',
        ),
      );
    }
    return requestRunner(
      () => _client.get(_endpoint),
      (data) => _parse(data as Map<String, dynamic>, current),
    );
  }

  AppVersionInfo _parse(Map<String, dynamic> json, String currentVersion) {
    final latest = json['latest_version'];
    final minRequired = json['min_required_version'];
    if (latest is! String) {
      throw ApiException(
        type: ApiErrorType.parseFailure,
        message:
            'version response missing or non-String "latest_version": $latest',
      );
    }
    if (minRequired is! String) {
      throw ApiException(
        type: ApiErrorType.parseFailure,
        message:
            'version response missing or non-String "min_required_version": $minRequired',
      );
    }
    return AppVersionInfo(
      currentVersion: currentVersion,
      latestVersion: latest,
      minRequiredVersion: minRequired,
      updateUrl: json['update_url'] as String?,
    );
  }
}
