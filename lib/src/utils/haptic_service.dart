import 'package:flutter/services.dart';

/// Thin wrapper around Flutter's [HapticFeedback] for consistent haptic use.
///
/// ```dart
/// await HapticService.success(); // on form submit
/// await HapticService.error();   // on validation failure
/// ```
abstract final class HapticService {
  /// Light impact — subtle selection feedback.
  static Future<void> light() => HapticFeedback.lightImpact();

  /// Medium impact — standard button press.
  static Future<void> medium() => HapticFeedback.mediumImpact();

  /// Heavy impact — destructive or significant action.
  static Future<void> heavy() => HapticFeedback.heavyImpact();

  /// Selection click — toggling or picking from a list.
  static Future<void> selection() => HapticFeedback.selectionClick();

  /// Light impact — used to signal a success result.
  static Future<void> success() => HapticFeedback.lightImpact();

  /// Heavy impact — used to signal an error or rejection.
  static Future<void> error() => HapticFeedback.heavyImpact();
}
