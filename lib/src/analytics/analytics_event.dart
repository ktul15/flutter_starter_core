/// A named analytics event with optional key-value parameters.
///
/// ```dart
/// const loginEvent = AnalyticsEvent('login', params: {'method': 'email'});
/// analytics.trackEvent(loginEvent);
/// ```
class AnalyticsEvent {
  /// Use [AnalyticsEvent.checked] when params are built dynamically to get a
  /// compile-safe [ArgumentError] on non-primitive values.
  const AnalyticsEvent(this.name, {this.params = const {}});

  /// Creates an [AnalyticsEvent] with runtime primitive-type validation.
  ///
  /// Throws [ArgumentError] in both debug and release if any param value is
  /// not `String`, `num`, or `bool`. Use this constructor when params are
  /// built dynamically (not compile-time constants).
  factory AnalyticsEvent.checked(
    String name, {
    Map<String, Object> params = const {},
  }) {
    for (final entry in params.entries) {
      if (entry.value is! String && entry.value is! num && entry.value is! bool) {
        throw ArgumentError.value(
          entry.value,
          'params["${entry.key}"]',
          'AnalyticsEvent params values must be String, num, or bool',
        );
      }
    }
    return AnalyticsEvent(name, params: params);
  }

  /// Event name — use snake_case by convention (e.g. `'button_tapped'`).
  final String name;

  /// Event parameters. Values **must** be `String`, `num`, or `bool`.
  ///
  /// Use [AnalyticsEvent.checked] when params are built dynamically to get
  /// an [ArgumentError] instead of a silent analytics SDK failure.
  final Map<String, Object> params;
}
