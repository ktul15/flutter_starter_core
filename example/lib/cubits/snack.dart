/// Lightweight snackbar payload for BLoC listener pattern.
enum SnackType { success, error, info, warning }

class Snack {
  const Snack(this.message, this.type);
  final String message;
  final SnackType type;
}
