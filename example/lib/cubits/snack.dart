import 'package:flutter/material.dart';

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

/// Show [snack] via [ScaffoldMessenger] using [context].
void dispatchSnack(BuildContext context, Snack snack) {
  final cs = Theme.of(context).colorScheme;
  final color = switch (snack.type) {
    SnackType.success => cs.tertiary,
    SnackType.error   => cs.error,
    SnackType.info    => cs.primary,
    SnackType.warning => cs.secondary,
  };
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(snack.message, style: TextStyle(color: cs.surface)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
