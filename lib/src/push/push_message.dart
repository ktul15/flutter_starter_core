/// Normalised push notification payload, regardless of provider.
///
/// Concrete [PushService] implementations map their SDK's message type to this
/// shape so downstream code is provider-agnostic.
class PushMessage {
  const PushMessage({
    this.title,
    this.body,
    this.imageUrl,
    this.data = const {},
    this.collapseKey,
  });

  /// Notification title, if provided.
  final String? title;

  /// Notification body text, if provided.
  final String? body;

  /// URL of an image to show in the notification (FCM image key).
  final String? imageUrl;

  /// Arbitrary key-value data payload from the push backend.
  final Map<String, dynamic> data;

  /// Collapse key — messages with the same key replace each other on the device.
  final String? collapseKey;
}

/// Push notification permission state.
enum PushPermissionStatus {
  /// User granted permission.
  granted,

  /// User denied permission.
  denied,

  /// Permission granted provisionally (iOS only — quiet notifications).
  provisional,

  /// Permission not yet requested.
  notDetermined,
}
