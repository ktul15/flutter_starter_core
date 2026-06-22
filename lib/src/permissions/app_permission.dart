/// Device permissions the app may need to request.
///
/// Maps to `permission_handler`'s [Permission] internally; consumers never
/// import that package directly — use [AppPermissions] instead.
enum AppPermission {
  /// Device camera.
  camera,

  /// Photo library / gallery access.
  ///
  /// **Android note:** maps to `Permission.photos` (requires SDK 33 / Android 13+).
  /// On Android 12 and below this permission is absent — use [storage] instead
  /// for broad read access on older devices. A production app should branch on
  /// the OS version via `device_info_plus`.
  gallery,

  /// Microphone for audio recording.
  microphone,

  /// Location while the app is in use.
  locationWhenInUse,

  /// Location at all times (background location).
  locationAlways,

  /// Push notification display.
  notification,

  /// Broad external storage read/write.
  ///
  /// **Android note:** maps to `Permission.storage`, which is deprecated for
  /// SDK 33+ (Android 13+). On SDK 33+ the system silently denies this
  /// permission — use [gallery] (photos), or the scoped media permissions
  /// (`Permission.videos`, `Permission.audio`) directly via `permission_handler`
  /// for SDK 33+. Branch on the OS version via `device_info_plus`.
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
