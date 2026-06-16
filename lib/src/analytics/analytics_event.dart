/// A named analytics event with optional key-value parameters.
///
/// ```dart
/// const loginEvent = AnalyticsEvent('login', params: {'method': 'email'});
/// analytics.trackEvent(loginEvent);
/// ```
class AnalyticsEvent {
  const AnalyticsEvent(this.name, {this.params = const {}});

  /// Event name — use snake_case by convention (e.g. `'button_tapped'`).
  final String name;

  /// Arbitrary metadata attached to the event.
  final Map<String, Object?> params;
}
