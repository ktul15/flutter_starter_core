import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

// ── State ──────────────────────────────────────────────────────────────────────

class LocalizationDemoState extends Equatable {
  const LocalizationDemoState({this.deviceLocale, this.resolvedLocale});

  final Locale? deviceLocale;
  final Locale? resolvedLocale;

  @override
  List<Object?> get props => [deviceLocale, resolvedLocale];
}

// ── Cubit ──────────────────────────────────────────────────────────────────────

/// Demonstrates [LocalizationConfig.resolve] interactively.
class LocalizationCubit extends Cubit<LocalizationDemoState> {
  LocalizationCubit() : super(const LocalizationDemoState());

  /// The shared config instance — exposed for the builder to read [supportedLocales].
  static final config = LocalizationConfig(
    supportedLocales: const [
      Locale('en'),
      Locale('es'),
      Locale('fr'),
      Locale('de'),
    ],
    fallbackLocale: const Locale('en'),
  );

  void resolve(Locale? locale) {
    emit(LocalizationDemoState(
      deviceLocale: locale,
      resolvedLocale: config.resolve(locale),
    ));
  }
}
