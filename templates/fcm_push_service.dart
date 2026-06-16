// FCM concrete implementation of PushService.
//
// SETUP — in your CLIENT app's pubspec.yaml add:
//   firebase_messaging: ^15.0.0
//
// Then copy this file into your project (e.g. lib/services/fcm_push_service.dart)
// and inject it wherever PushService is required.
//
// Also complete Firebase project setup:
//   - Android: google-services.json in android/app/
//   - iOS: GoogleService-Info.plist in ios/Runner/ + APNs key in Firebase console
//   - Run: flutterfire configure (from the flutterfire_cli package)

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

/// Background message handler — must be a top-level function.
/// Register it in main() before Firebase.initializeApp():
///
/// ```dart
/// FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
/// ```
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  // Handle background messages here (e.g. update local DB, badge count).
}

/// [PushService] backed by Firebase Cloud Messaging.
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp();
///   FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
///
///   final push = FcmPushService();
///   await push.requestPermission();
///
///   runApp(MyApp(pushService: push));
/// }
/// ```
class FcmPushService implements PushService {
  FcmPushService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  @override
  Future<PushPermissionStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return _mapStatus(settings.authorizationStatus);
  }

  @override
  Future<String?> getToken({String? vapidKey}) =>
      _messaging.getToken(vapidKey: vapidKey);

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Stream<PushMessage> get onMessage =>
      FirebaseMessaging.onMessage.map(_fromRemote);

  @override
  Stream<PushMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp.map(_fromRemote);

  @override
  Future<PushMessage?> getInitialMessage() async {
    final msg = await _messaging.getInitialMessage();
    return msg == null ? null : _fromRemote(msg);
  }

  @override
  Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);

  @override
  Future<void> unsubscribeFromTopic(String topic) =>
      _messaging.unsubscribeFromTopic(topic);

  PushMessage _fromRemote(RemoteMessage msg) => PushMessage(
        title: msg.notification?.title,
        body: msg.notification?.body,
        imageUrl: msg.notification?.android?.imageUrl ??
            msg.notification?.apple?.imageUrl,
        data: msg.data,
        collapseKey: msg.collapseKey,
      );

  PushPermissionStatus _mapStatus(AuthorizationStatus s) => switch (s) {
        AuthorizationStatus.authorized => PushPermissionStatus.granted,
        AuthorizationStatus.denied => PushPermissionStatus.denied,
        AuthorizationStatus.provisional => PushPermissionStatus.provisional,
        AuthorizationStatus.notDetermined => PushPermissionStatus.notDetermined,
      };
}
