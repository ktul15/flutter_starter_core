/// Result of comparing the running app version against the server's version policy.
enum VersionStatus {
  /// App is current — no action needed.
  upToDate,

  /// A newer version is available but not required.
  updateAvailable,

  /// App is below the minimum required version — must update before continuing.
  updateRequired,
}

/// Version policy returned by the server and compared against the running app.
///
/// All version strings must follow semver format: `"major.minor.patch"`.
class AppVersionInfo {
  const AppVersionInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.minRequiredVersion,
    this.updateUrl,
  });

  /// Version currently installed on the device.
  final String currentVersion;

  /// Latest available version on the store/server.
  final String latestVersion;

  /// Minimum version the server considers acceptable. Below this → force update.
  final String minRequiredVersion;

  /// Deep-link or store URL for the update, if provided by the server.
  final String? updateUrl;

  /// Computes the [VersionStatus] by comparing semver strings.
  VersionStatus get status {
    if (_compare(currentVersion, minRequiredVersion) < 0) {
      return VersionStatus.updateRequired;
    }
    if (_compare(currentVersion, latestVersion) < 0) {
      return VersionStatus.updateAvailable;
    }
    return VersionStatus.upToDate;
  }

  /// Returns negative if [a] < [b], zero if equal, positive if [a] > [b].
  static int _compare(String a, String b) {
    final av = _parts(a);
    final bv = _parts(b);
    for (var i = 0; i < 3; i++) {
      final diff = av[i] - bv[i];
      if (diff != 0) return diff;
    }
    return 0;
  }

  static List<int> _parts(String v) {
    // Strip build metadata (+...) and pre-release label (-...) before parsing
    // so "1.2.3-beta.1+42" is treated as "1.2.3", not "1.2.0".
    final clean = v.split('+').first.split('-').first;
    final parts = clean.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    while (parts.length < 3) {
      parts.add(0);
    }
    return parts;
  }
}
