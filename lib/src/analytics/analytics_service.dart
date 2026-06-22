import 'analytics_event.dart';

/// Contract for product analytics services (Firebase Analytics, Mixpanel, etc.).
///
/// **[PER-PROJECT] implementation.** No concrete SDK is bundled — implement
/// this interface in the consuming app and inject it wherever events are
/// tracked. Use [NoOpAnalyticsService] as a safe default until the real impl
/// is wired.
abstract interface class AnalyticsService {
  /// Tracks [event] with its associated parameters.
  Future<void> trackEvent(AnalyticsEvent event);

  /// Identifies the current user. Call after successful login.
  ///
  /// [properties] values must be `String`, `num`, or `bool` — analytics SDKs
  /// reject other types at runtime.
  Future<void> setUser({
    required String userId,
    Map<String, Object>? properties,
  });

  /// Clears the current user identity. Call on logout.
  Future<void> resetUser();

  /// Sets the active screen name for session tracking.
  Future<void> setCurrentScreen(String screenName);

  /// Tracks a non-fatal error for monitoring.
  Future<void> trackError(Object error, {StackTrace? stack, bool fatal = false});
}

/// No-op [AnalyticsService] — silently discards all events.
///
/// Use as the default implementation before wiring a real analytics backend.
/// Avoids null-checks throughout the codebase.
class NoOpAnalyticsService implements AnalyticsService {
  const NoOpAnalyticsService();

  @override
  Future<void> trackEvent(AnalyticsEvent event) async {}

  @override
  Future<void> setUser({
    required String userId,
    Map<String, Object>? properties,
  }) async {}

  @override
  Future<void> resetUser() async {}

  @override
  Future<void> setCurrentScreen(String screenName) async {}

  @override
  Future<void> trackError(
    Object error, {
    StackTrace? stack,
    bool fatal = false,
  }) async {}
}
