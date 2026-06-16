import 'package:flutter/material.dart';

/// Full-width filled button with a built-in loading state.
///
/// While [isLoading], the label is replaced by a spinner and taps are blocked.
/// Passing a `null` [onPressed] (with [isLoading] false) disables the button.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return FilledButton(
      // Keep button in enabled (non-grey) state while loading so the primary
      // background is retained and the spinner is visible against it.
      onPressed: isLoading ? () {} : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: onPrimary),
            )
          : _Label(label: label, icon: icon),
    );
  }
}

/// Outlined sibling of [PrimaryButton] with the same loading behavior.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return OutlinedButton(
      onPressed: isLoading ? () {} : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: primary),
            )
          : _Label(label: label, icon: icon),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
