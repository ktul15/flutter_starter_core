import 'dart:async';

import 'package:flutter/foundation.dart';

/// Delays execution of [run] until [delay] has elapsed since the last call.
///
/// Useful for search-as-you-type, live validation, and any input that triggers
/// expensive work — only the last call within the window executes.
///
/// ```dart
/// final _debouncer = Debouncer();
///
/// void _onSearchChanged(String query) {
///   _debouncer.run(() => _search(query));
/// }
///
/// @override
/// void dispose() {
///   _debouncer.dispose();
///   super.dispose();
/// }
/// ```
class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 500)});

  /// How long to wait after the last [run] call before executing the action.
  final Duration delay;

  Timer? _timer;

  /// Cancels any pending action and schedules [action] to run after [delay].
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels any pending action without executing it.
  void cancel() => _timer?.cancel();

  /// Cancels any pending action and releases the timer.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  /// Whether an action is currently scheduled.
  bool get isPending => _timer?.isActive ?? false;
}
