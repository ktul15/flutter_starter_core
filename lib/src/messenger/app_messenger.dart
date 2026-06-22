import 'package:flutter/material.dart';

/// Shows styled snackbars from anywhere without a [BuildContext].
///
/// **Wiring (required):** pass [key] to [MaterialApp.scaffoldMessengerKey].
/// Forgetting this causes silent no-ops in release and a clear assertion error
/// in debug — check the assert message if snackbars are not appearing.
///
/// ```dart
/// final messengerKey = GlobalKey<ScaffoldMessengerState>();
/// final messenger = AppMessenger(messengerKey);
///
/// MaterialApp(
///   scaffoldMessengerKey: messengerKey,   // ← required
///   ...
/// );
///
/// // From a BLoC or service:
/// messenger.showError('Something went wrong');
/// ```
class AppMessenger {
  AppMessenger(this._key);

  final GlobalKey<ScaffoldMessengerState> _key;

  ScaffoldMessengerState? get _messenger => _key.currentState;

  void _assertWired() {
    assert(
      _key.currentState != null,
      'AppMessenger: scaffoldMessengerKey is not attached to MaterialApp.\n'
      'Pass the same GlobalKey to MaterialApp.scaffoldMessengerKey.',
    );
  }

  /// Shows a green success snackbar.
  void showSuccess(String message, {Duration? duration}) =>
      _show(message, _SnackType.success, duration: duration);

  /// Shows a red error snackbar.
  void showError(String message, {Duration? duration}) =>
      _show(message, _SnackType.error, duration: duration);

  /// Shows a blue info snackbar.
  void showInfo(String message, {Duration? duration}) =>
      _show(message, _SnackType.info, duration: duration);

  /// Shows an amber warning snackbar.
  void showWarning(String message, {Duration? duration}) =>
      _show(message, _SnackType.warning, duration: duration);

  /// Shows a fully custom [SnackBar].
  void showSnackBar(SnackBar snackBar) {
    _assertWired();
    _messenger?.showSnackBar(snackBar);
  }

  /// Hides the currently visible snackbar immediately.
  void hideCurrentSnackBar() {
    _assertWired();
    _messenger?.hideCurrentSnackBar();
  }

  void _show(String message, _SnackType type, {Duration? duration}) {
    _assertWired();
    final cs = _messenger?.context != null
        ? Theme.of(_messenger!.context).colorScheme
        : null;

    final backgroundColor = switch (type) {
      _SnackType.success => cs?.tertiary ?? Colors.green,
      _SnackType.error => cs?.error ?? Colors.red,
      _SnackType.info => cs?.primary ?? Colors.blue,
      _SnackType.warning => cs?.secondary ?? Colors.amber,
    };

    final foregroundColor = switch (type) {
      _SnackType.success => cs?.onTertiary ?? Colors.white,
      _SnackType.error => cs?.onError ?? Colors.white,
      _SnackType.info => cs?.onPrimary ?? Colors.white,
      _SnackType.warning => cs?.onSecondary ?? Colors.white,
    };

    showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: foregroundColor)),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

enum _SnackType { success, error, info, warning }
