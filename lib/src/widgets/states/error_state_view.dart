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

  /// Builds from an [ApiException], using its `message`.
  factory ErrorStateView.fromException(
    ApiException error, {
    Key? key,
    VoidCallback? onRetry,
    String retryLabel = 'Retry',
  }) =>
      ErrorStateView(
        key: key,
        message: error.message,
        onRetry: onRetry,
        retryLabel: retryLabel,
      );

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
