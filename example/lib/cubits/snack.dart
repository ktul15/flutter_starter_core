import 'package:flutter_starter_core/flutter_starter_core.dart';

enum SnackType { success, error, info, warning }

/// One-shot UI side-effect carrier.
///
/// Reference equality is intentional — each `Snack(...)` call creates a unique
/// instance so [BlocConsumer.listenWhen] fires once per emission, even when the
/// message text is repeated.
class Snack {
  Snack(this.message, this.type);
  final String message;
  final SnackType type;
}

/// Route [snack] to the appropriate [AppMessenger] method.
void dispatchSnack(AppMessenger messenger, Snack snack) {
  switch (snack.type) {
    case SnackType.success:
      messenger.showSuccess(snack.message);
    case SnackType.error:
      messenger.showError(snack.message);
    case SnackType.info:
      messenger.showInfo(snack.message);
    case SnackType.warning:
      messenger.showWarning(snack.message);
  }
}
