import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Reusable i18n plumbing for `MaterialApp`/`WidgetsApp`.
///
/// Bundles supported locales, delegates, a [fallbackLocale], and a
/// device→app locale resolver. Actual translation strings/delegates are
/// [PER-PROJECT]; pass them in via [delegates] and [supportedLocales].
///
/// Use [allDelegates] (not [delegates]) for `MaterialApp.localizationsDelegates`
/// — it prepends the three required Material/Widgets/Cupertino delegates so
/// date pickers, input formatters, and RTL layout work without extra setup.
///
/// ```dart
/// final l10n = LocalizationConfig(
///   supportedLocales: const [Locale('en'), Locale('fr')],
///   delegates: [AppLocalizations.delegate],
/// );
///
/// MaterialApp(
///   supportedLocales: l10n.supportedLocales,
///   localizationsDelegates: l10n.allDelegates,
///   localeResolutionCallback: l10n.resolve,
/// );
/// ```
class LocalizationConfig {
  LocalizationConfig({
    required this.supportedLocales,
    this.delegates = const [],
    Locale? fallbackLocale,
  })  : assert(supportedLocales.isNotEmpty, 'Provide at least one locale'),
        fallbackLocale = fallbackLocale ?? supportedLocales.first;

  final List<Locale> supportedLocales;

  /// App-specific delegates (e.g. `AppLocalizations.delegate`).
  ///
  /// Do NOT pass the Material/Widgets/Cupertino delegates here — they are
  /// included automatically via [allDelegates].
  final Iterable<LocalizationsDelegate<dynamic>> delegates;

  /// Used when the device locale matches nothing supported.
  final Locale fallbackLocale;

  /// All delegates required by `MaterialApp.localizationsDelegates`.
  ///
  /// Combines the three standard Material delegates with any app-specific
  /// [delegates] supplied at construction time.
  Iterable<LocalizationsDelegate<dynamic>> get allDelegates => [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ...delegates,
      ];

  /// Resolves a device [locale] to a supported one.
  ///
  /// Prefers an exact language+country match, then a language-only match, then
  /// [fallbackLocale]. Suitable for `localeResolutionCallback`.
  Locale resolve(Locale? locale, [Iterable<Locale>? supported]) {
    if (locale == null) return fallbackLocale;
    final pool = supported ?? supportedLocales;

    for (final l in pool) {
      if (l.languageCode == locale.languageCode &&
          l.countryCode == locale.countryCode) {
        return l;
      }
    }
    for (final l in pool) {
      if (l.languageCode == locale.languageCode) return l;
    }
    return fallbackLocale;
  }
}
