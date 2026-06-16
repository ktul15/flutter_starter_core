/// Device permissions the app may need to request.
///
/// Maps to `permission_handler`'s [Permission] internally; consumers never
/// import that package directly — use [AppPermissions] instead.
enum AppPermission {
  /// Device camera.
  camera,

  /// Photo library / gallery access.
  gallery,

  /// Microphone for audio recording.
  microphone,

  /// Location while the app is in use.
  locationWhenInUse,

  /// Location at all times (background location).
  locationAlways,

  /// Push notification display.
  notification,

  /// External storage read/write (Android ≤12).
  storage,

  /// Device contacts.
  contacts,

  /// Phone state and call management.
  phone,
}

/// Result of a permission check or request.
sealed class PermissionStatus {
  const PermissionStatus();
}

/// Permission is granted; the feature may be used.
final class PermissionGranted extends PermissionStatus {
  const PermissionGranted();
}

/// Permission was denied this time; the dialog may be shown again.
final class PermissionDenied extends PermissionStatus {
  const PermissionDenied();
}

/// Permission was permanently denied; direct the user to Settings.
final class PermissionPermanentlyDenied extends PermissionStatus {
  const PermissionPermanentlyDenied();
}

/// Permission is restricted by the OS or MDM policy (iOS).
final class PermissionRestricted extends PermissionStatus {
  const PermissionRestricted();
}
