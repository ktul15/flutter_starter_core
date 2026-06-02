/// A validator returns `null` when [value] is valid, else an error message.
typedef Validator = String? Function(String? value);

/// Composable, message-returning field validators.
///
/// Each returns `null` on success or an error string, matching Flutter's
/// `FormField.validator` contract. Default messages are English; override via
/// the `message` parameter for i18n.
abstract final class Validators {
  static final RegExp _email = RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$');

  /// Fails when null/empty/whitespace-only.
  static Validator required([String message = 'This field is required']) =>
      (value) => (value == null || value.trim().isEmpty) ? message : null;

  /// Fails when present but not a valid email. Empty passes — compose with
  /// [required] to also require it.
  static Validator email([String message = 'Enter a valid email']) =>
      (value) => (value == null || value.isEmpty || _email.hasMatch(value))
          ? null
          : message;

  /// Fails when shorter than [length].
  static Validator minLength(int length, [String? message]) =>
      (value) => (value != null && value.length >= length)
          ? null
          : (message ?? 'Must be at least $length characters');

  /// Fails when longer than [length].
  static Validator maxLength(int length, [String? message]) =>
      (value) => (value == null || value.length <= length)
          ? null
          : (message ?? 'Must be at most $length characters');

  /// Password policy: min length (default 8) + at least one letter and digit.
  static Validator password({
    int minLength = 8,
    String? message,
  }) =>
      (value) {
        final v = value ?? '';
        final ok = v.length >= minLength &&
            v.contains(RegExp(r'[A-Za-z]')) &&
            v.contains(RegExp(r'\d'));
        return ok
            ? null
            : (message ??
                'At least $minLength characters, with a letter and a number');
      };

  /// Fails when [value] differs from the value returned by [other].
  ///
  /// `other` is a callback so it reads the latest value (e.g. the password
  /// field) at validation time.
  static Validator match(
    String? Function() other, [
    String message = 'Values do not match',
  ]) =>
      (value) => value == other() ? null : message;

  /// Runs [validators] in order, returning the first error (or `null`).
  static Validator compose(List<Validator> validators) => (value) {
        for (final validate in validators) {
          final error = validate(value);
          if (error != null) return error;
        }
        return null;
      };
}
