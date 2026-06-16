import 'push_message.dart';

/// Contract for push notification services (FCM, APNs, OneSignal, etc.).
///
/// **[PER-PROJECT] implementation.** The package does not bundle
/// `firebase_messaging` or any native SDK — implement this interface with the
/// backend your project uses and inject it at app startup.
///
/// Typical wiring (Firebase example):
/// ```dart
/// class FcmPushService implements PushService {
///   final _messaging = FirebaseMessaging.instance;
///   // ... implement each method
/// }
/// ```
abstract interface class PushService {
  /// Requests the OS permission to show notifications.
  ///
  /// On Android 13+ this shows the runtime permission dialog.
  /// On iOS this shows the native alert sheet.
  Future<PushPermissionStatus> requestPermission();

  /// Returns the device registration token (FCM token / APNs device token).
  ///
  /// May return `null` if permission was denied or the token is not yet ready.
  Future<String?> getToken();

  /// Fires whenever the registration token is refreshed.
  ///
  /// Subscribe to update your backend with the new token.
  Stream<String> get onTokenRefresh;

  /// Fires when a push message arrives while the app is in the foreground.
  Stream<PushMessage> get onMessage;

  /// Fires when the user taps a notification and the app is opened from the
  /// background (not terminated).
  Stream<PushMessage> get onMessageOpenedApp;

  /// Returns the push message that launched the app from the terminated state,
  /// or `null` if the app was opened normally.
  ///
  /// Call once during app initialisation.
  Future<PushMessage?> getInitialMessage();

  /// Subscribes the device to a named [topic] for broadcast pushes.
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribes from a named [topic].
  Future<void> unsubscribeFromTopic(String topic);
}
