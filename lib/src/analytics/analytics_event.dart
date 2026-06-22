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

  /// Event parameters. Values must be primitives (String, num, bool) —
  /// analytics SDKs reject DateTime, List, or custom objects at runtime.
  final Map<String, Object> params;
}
