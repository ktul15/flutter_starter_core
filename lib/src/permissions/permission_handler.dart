import 'package:permission_handler/permission_handler.dart' as ph;

import 'app_permission.dart';

/// Requests and checks device permissions using `permission_handler`.
///
/// Consumers depend only on [AppPermission] and [PermissionStatus] from this
/// package — the underlying `permission_handler` SDK is never exposed directly.
///
/// ```dart
/// final perms = AppPermissions();
/// final status = await perms.request(AppPermission.camera);
/// if (status is PermissionGranted) { ... }
/// ```
class AppPermissions {
  const AppPermissions();

  /// Requests [permission], showing the system dialog if not yet decided.
  ///
  /// If permanently denied, the dialog is not shown — use [openSettings].
  Future<PermissionStatus> request(AppPermission permission) async {
    final status = await _map(permission).request();
    return _toStatus(status);
  }

  /// Returns the current status of [permission] without showing a dialog.
  Future<PermissionStatus> check(AppPermission permission) async {
    final status = await _map(permission).status;
    return _toStatus(status);
  }

  /// Opens the app's Settings page so the user can manually grant permission.
  ///
  /// Returns `true` if the Settings app was opened successfully.
  Future<bool> openSettings() => ph.openAppSettings();

  // Maps package permission to permission_handler Permission
  ph.Permission _map(AppPermission p) => switch (p) {
        AppPermission.camera => ph.Permission.camera,
        AppPermission.gallery => ph.Permission.photos,
        AppPermission.microphone => ph.Permission.microphone,
        AppPermission.locationWhenInUse => ph.Permission.locationWhenInUse,
        AppPermission.locationAlways => ph.Permission.locationAlways,
        AppPermission.notification => ph.Permission.notification,
        AppPermission.storage => ph.Permission.storage,
        AppPermission.contacts => ph.Permission.contacts,
        AppPermission.phone => ph.Permission.phone,
      };

  PermissionStatus _toStatus(ph.PermissionStatus s) => switch (s) {
        ph.PermissionStatus.granted ||
        ph.PermissionStatus.limited =>
          const PermissionGranted(),
        ph.PermissionStatus.permanentlyDenied => const PermissionPermanentlyDenied(),
        ph.PermissionStatus.restricted => const PermissionRestricted(),
        _ => const PermissionDenied(),
      };
}
