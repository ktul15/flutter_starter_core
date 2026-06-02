import 'package:connectivity_plus/connectivity_plus.dart';

/// Reports online/offline status as a simple `bool`.
///
/// Wraps `connectivity_plus`, collapsing its `List<ConnectivityResult>` into
/// "is there any usable transport". Inject a [Connectivity] for testing.
///
/// Note: connectivity_plus reports *transport* presence, not real reachability —
/// a connected Wi-Fi with no internet still reads online. Pair with an actual
/// request for hard guarantees.
class ConnectivityChecker {
  ConnectivityChecker({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// `true` if any non-[ConnectivityResult.none] transport is active.
  Future<bool> get isOnline async =>
      _isOnline(await _connectivity.checkConnectivity());

  /// Emits `true`/`false` as connectivity changes. De-duplicated so only real
  /// online↔offline transitions are emitted.
  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.map(_isOnline).distinct();

  static bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
