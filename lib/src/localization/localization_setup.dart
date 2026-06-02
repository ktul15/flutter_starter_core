import 'package:flutter/widgets.dart';

/// Reusable i18n plumbing for `MaterialApp`/`WidgetsApp`.
///
/// Bundles supported locales, delegates, a [fallbackLocale], and a
/// device→app locale resolver. Actual translation strings/delegates are
/// [PER-PROJECT]; pass them in via [delegates] and [supportedLocales].
///
/// ```dart
/// MaterialApp(
///   supportedLocales: l10n.supportedLocales,
///   localizationsDelegates: l10n.delegates,
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
  final Iterable<LocalizationsDelegate<dynamic>> delegates;

  /// Used when the device locale matches nothing supported.
  final Locale fallbackLocale;

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
