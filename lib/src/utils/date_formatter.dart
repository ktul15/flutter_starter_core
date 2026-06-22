import 'package:intl/intl.dart';

/// Locale-aware relative time label strings for [DateFormatter.relative].
///
/// For non-English locales call `initializeDateFormatting(locale)` once at
/// app startup alongside `flutter_localizations` setup.
class DateFormatterLocale {
  DateFormatterLocale({
    required this.justNow,
    required this.minutesAgo,
    required this.hoursAgo,
    required this.daysAgo,
    required this.weeksAgo,
    required this.monthsAgo,
    required this.yearsAgo,
  });

  final String justNow;
  final String Function(int n) minutesAgo;
  final String Function(int n) hoursAgo;
  final String Function(int n) daysAgo;
  final String Function(int n) weeksAgo;
  final String Function(int n) monthsAgo;
  final String Function(int n) yearsAgo;

  /// Arabic has singular / dual / plural (3–10) / large-number (11+) forms.
  static String _ar(
    int n, {
    required String singular,
    required String dual,
    required String plural,
    required String large,
  }) {
    if (n == 1) return 'منذ $singular';
    if (n == 2) return 'منذ $dual';
    if (n <= 10) return 'منذ $n $plural';
    return 'منذ $n $large';
  }

  static final en = DateFormatterLocale(
    justNow: 'just now',
    minutesAgo: (n) => '${n}m ago',
    hoursAgo: (n) => '${n}h ago',
    daysAgo: (n) => '${n}d ago',
    weeksAgo: (n) => '${n}w ago',
    monthsAgo: (n) => '${n}mo ago',
    yearsAgo: (n) => '${n}y ago',
  );

  static final ar = DateFormatterLocale(
    justNow: 'الآن',
    minutesAgo: (n) => _ar(n, singular: 'دقيقة', dual: 'دقيقتين', plural: 'دقائق', large: 'دقيقة'),
    hoursAgo: (n) => _ar(n, singular: 'ساعة', dual: 'ساعتين', plural: 'ساعات', large: 'ساعة'),
    daysAgo: (n) => _ar(n, singular: 'يوم', dual: 'يومين', plural: 'أيام', large: 'يوم'),
    weeksAgo: (n) => _ar(n, singular: 'أسبوع', dual: 'أسبوعين', plural: 'أسابيع', large: 'أسبوع'),
    monthsAgo: (n) => _ar(n, singular: 'شهر', dual: 'شهرين', plural: 'أشهر', large: 'شهر'),
    yearsAgo: (n) => _ar(n, singular: 'سنة', dual: 'سنتين', plural: 'سنوات', large: 'سنة'),
  );

  static final ja = DateFormatterLocale(
    justNow: 'たった今',
    minutesAgo: (n) => '$n分前',
    hoursAgo: (n) => '$n時間前',
    daysAgo: (n) => '$n日前',
    weeksAgo: (n) => '$n週間前',
    monthsAgo: (n) => '$nヶ月前',
    yearsAgo: (n) => '$n年前',
  );

  static final es = DateFormatterLocale(
    justNow: 'ahora mismo',
    minutesAgo: (n) => 'hace $n min',
    hoursAgo: (n) => 'hace $n h',
    daysAgo: (n) => 'hace $n d',
    weeksAgo: (n) => 'hace $n sem',
    monthsAgo: (n) => n == 1 ? 'hace 1 mes' : 'hace $n meses',
    yearsAgo: (n) => n == 1 ? 'hace 1 año' : 'hace $n años',
  );

  static final fr = DateFormatterLocale(
    justNow: "à l'instant",
    minutesAgo: (n) => 'il y a $n min',
    hoursAgo: (n) => 'il y a $n h',
    daysAgo: (n) => 'il y a $n j',
    weeksAgo: (n) => 'il y a $n sem',
    monthsAgo: (n) => 'il y a $n mois',
    yearsAgo: (n) => n == 1 ? 'il y a 1 an' : 'il y a $n ans',
  );
}

/// Locale-aware date and time formatting helpers.
///
/// All methods call `.toLocal()` on the input — pass UTC or local timestamps
/// interchangeably and the output is always in the device's local time.
///
/// For non-English locales call `initializeDateFormatting(locale)` once at
/// app startup before invoking any formatting method with that locale.
abstract final class DateFormatter {
  /// Human-readable relative time string.
  ///
  /// Granularity: seconds → minutes → hours → days → weeks → months → years.
  /// Future dates fall back to [formatDate].
  /// Uses [locale] for relative labels (default: [DateFormatterLocale.en]).
  /// Uses [dateLocale] for the absolute date fallback (default: `'en'`).
  static String relative(
    DateTime date, {
    DateTime? now,
    DateFormatterLocale? locale,
    String dateLocale = 'en',
  }) {
    final l = locale ?? DateFormatterLocale.en;
    final local = date.toLocal();
    final ref = (now ?? DateTime.now()).toLocal();
    final diff = ref.difference(local);

    if (diff.isNegative) return formatDate(date, locale: dateLocale);
    if (diff.inSeconds < 60) return l.justNow;
    if (diff.inMinutes < 60) return l.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return l.daysAgo(diff.inDays);
    if (diff.inDays < 30) return l.weeksAgo(diff.inDays ~/ 7);
    if (diff.inDays < 365) return l.monthsAgo(diff.inDays ~/ 30);
    return l.yearsAgo(diff.inDays ~/ 365);
  }

  /// Locale-aware date string, e.g. `"Jun 16, 2026"` (en), `"16 juin 2026"` (fr).
  static String formatDate(DateTime date, {String locale = 'en'}) =>
      DateFormat.yMMMd(locale).format(date.toLocal());

  /// 24-hour time, e.g. `"14:30"`.
  static String formatTime(DateTime date, {String locale = 'en'}) =>
      DateFormat.Hm(locale).format(date.toLocal());

  /// Locale-aware date + 24-hour time, e.g. `"Jun 16, 2026 14:30"` (en).
  static String formatDateTime(DateTime date, {String locale = 'en'}) =>
      DateFormat.yMMMd(locale).add_Hm().format(date.toLocal());
}
