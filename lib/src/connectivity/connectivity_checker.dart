import 'package:connectivity_plus/connectivity_plus.dart';

/// Reports online/offline status as a simple `bool`.
///
/// Wraps `connectivity_plus`, collapsing its `List<ConnectivityResult>` into
/// "is there any usable transport". Inject a [Connectivity] for testing.
///
/// **Captive portal warning:** `connectivity_plus` reports *transport presence*,
/// not real internet reachability. A device connected to a hotel/airport Wi-Fi
/// that has not yet completed the captive portal login will report [isOnline]
/// as `true` even though no internet traffic can flow. For a hard connectivity
/// guarantee, follow up with an actual lightweight API request (e.g. a HEAD
/// request to your health-check endpoint). Use [onResultChange] to access the
/// raw [ConnectivityResult] list when you need transport-type details.
class ConnectivityChecker {
  ConnectivityChecker({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// `true` if any non-[ConnectivityResult.none] transport is active.
  ///
  /// Does **not** guarantee real internet access — see class-level warning.
  Future<bool> get isOnline async =>
      _isOnline(await _connectivity.checkConnectivity());

  /// Raw connectivity results from the platform, updated on every change.
  ///
  /// Use this when you need the transport type (e.g. to distinguish Wi-Fi from
  /// mobile data) or to implement your own reachability check.
  Stream<List<ConnectivityResult>> get onResultChange =>
      _connectivity.onConnectivityChanged;

  /// Emits `true`/`false` as connectivity changes. De-duplicated so only real
  /// online↔offline transitions are emitted.
  ///
  /// Does **not** guarantee real internet access — see class-level warning.
  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.map(_isOnline).distinct();

  static bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
