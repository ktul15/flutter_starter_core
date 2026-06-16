import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

// ── Cubit ──────────────────────────────────────────────────────────────────────

/// Bridges [PersistentThemeModeController] (ValueNotifier) into the BLoC world.
///
/// The [MaterialApp] in main.dart continues to use [ValueListenableBuilder]
/// on the controller; this cubit lets the ThemeScreen use [BlocBuilder].
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._controller) : super(_controller.value) {
    _controller.addListener(_onChanged);
  }

  final PersistentThemeModeController _controller;

  void _onChanged() => emit(_controller.value);

  void setMode(ThemeMode mode) => _controller.set(mode);

  void toggle({required bool platformIsDark}) =>
      _controller.toggle(platformIsDark: platformIsDark);

  @override
  Future<void> close() {
    _controller.removeListener(_onChanged);
    return super.close();
  }
}
