import 'package:flutter/material.dart';

import '../../network/api_exception.dart';

/// Centered error view with a retry action.
///
/// Build directly from a message, or from an [ApiException] via
/// [ErrorStateView.fromException] to surface a normalized network error.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.message,
    this.title = 'Something went wrong',
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  /// Builds from an [ApiException] with a user-safe message derived from its
  /// [ApiException.type].
  ///
  /// [ApiException.message] is intentionally NOT used — it is a log-safe
  /// technical string that may contain server internals. Pass an explicit
  /// [message] to override the default user-facing copy for any error type.
  factory ErrorStateView.fromException(
    ApiException error, {
    Key? key,
    String? message,
    VoidCallback? onRetry,
    String retryLabel = 'Retry',
  }) =>
      ErrorStateView(
        key: key,
        message: message ?? _safeMessage(error.type),
        onRetry: onRetry,
        retryLabel: retryLabel,
      );

  static String _safeMessage(ApiErrorType type) => switch (type) {
        ApiErrorType.network => 'Check your connection and try again.',
        ApiErrorType.timeout => 'Request timed out.',
        ApiErrorType.unauthorized => 'Session expired. Please sign in again.',
        ApiErrorType.server => 'Server error. Try again later.',
        ApiErrorType.validation => 'Some fields are invalid.',
        ApiErrorType.cancelled => 'Request was cancelled.',
        _ => 'Something went wrong.',
      };

  final String message;
  final String title;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonal(onPressed: onRetry, child: Text(retryLabel)),
            ],
          ],
        ),
      ),
    );
  }
}
