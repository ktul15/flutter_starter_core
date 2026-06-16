import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A row of individual digit cells for OTP/PIN entry.
///
/// - Auto-advances to next cell on digit entry.
/// - Auto-retreats to previous cell on backspace when current cell is empty.
/// - Paste: distributes characters across cells, calls [onCompleted] when full.
/// - Styled via `Theme.of(context).inputDecorationTheme` — no hardcoded colours.
///
/// ```dart
/// OtpField(
///   length: 6,
///   onCompleted: (otp) => bloc.add(OtpSubmitted(otp)),
/// )
/// ```
class OtpField extends StatefulWidget {
  const OtpField({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
    this.obscure = false,
    this.autoFocus = true,
    this.style,
  }) : assert(length > 0);

  /// Number of OTP digits/cells.
  final int length;

  /// Called when all cells are filled with the complete OTP string.
  final void Function(String otp) onCompleted;

  /// Called on every keystroke with the current (possibly partial) value.
  final void Function(String current)? onChanged;

  /// Whether to obscure the digits (password-style dots).
  final bool obscure;

  /// Whether the first cell requests focus automatically.
  final bool autoFocus;

  /// Text style for each digit. Defaults to `Theme.of(context).textTheme.headlineMedium`.
  final TextStyle? style;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _currentValue =>
      _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Paste: distribute across cells starting from index
      _distribute(value, from: index);
      return;
    }
    if (value.isNotEmpty) {
      if (index + 1 < widget.length) {
        _nodes[index + 1].requestFocus();
      } else {
        _nodes[index].unfocus();
      }
    }
    widget.onChanged?.call(_currentValue);
    if (_currentValue.length == widget.length) {
      widget.onCompleted(_currentValue);
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _nodes[index - 1].requestFocus();
      widget.onChanged?.call(_currentValue);
    }
  }

  void _distribute(String pasted, {required int from}) {
    final digits = pasted.replaceAll(RegExp(r'\D'), '');
    // Always fill from cell 0 regardless of which cell received the paste.
    // Users copying an SMS OTP code tap anywhere and expect the full code to
    // land in order — starting from the focused cell breaks that expectation.
    for (var i = 0; i < widget.length; i++) {
      _controllers[i].text = i < digits.length ? digits[i] : '';
    }
    final nextEmpty = _controllers.indexWhere((c) => c.text.isEmpty);
    if (nextEmpty == -1) {
      _nodes.last.unfocus();
      widget.onCompleted(_currentValue);
    } else {
      _nodes[nextEmpty].requestFocus();
    }
    widget.onChanged?.call(_currentValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = widget.style ?? theme.textTheme.headlineMedium;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.length, (i) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: (theme.textTheme.bodyMedium?.fontSize ?? 4) * 0.5,
          ),
          child: SizedBox(
            width: 48,
            child: KeyboardListener(
              focusNode: FocusNode(skipTraversal: true),
              onKeyEvent: (e) => _onKeyEvent(i, e),
              child: TextField(
                controller: _controllers[i],
                focusNode: _nodes[i],
                autofocus: widget.autoFocus && i == 0,
                obscureText: widget.obscure,
                textAlign: TextAlign.center,
                style: textStyle,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                onChanged: (v) => _onChanged(i, v),
                decoration: const InputDecoration(counterText: ''),
              ),
            ),
          ),
        );
      }),
    );
  }
}
