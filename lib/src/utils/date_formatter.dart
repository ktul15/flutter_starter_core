/// Locale-agnostic date/time formatting helpers.
///
/// All methods accept [DateTime] values in any timezone; callers are
/// responsible for converting to local time before passing if needed.
///
/// No `intl` dependency — uses hand-rolled formatting to keep the package
/// lightweight. For locale-aware formatting inject `intl`'s `DateFormat` in
/// the consuming app.
abstract final class DateFormatter {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Human-readable relative time string.
  ///
  /// Examples: `"just now"`, `"5m ago"`, `"3h ago"`, `"2d ago"`, `"4w ago"`.
  /// Falls back to [formatDate] for dates older than 4 weeks.
  static String relative(DateTime date, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final diff = ref.difference(date);

    if (diff.isNegative) return formatDate(date);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 28) return '${(diff.inDays / 7).floor()}w ago';
    return formatDate(date);
  }

  /// Formats as `"15 Jun 2026"`.
  static String formatDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  /// Formats as `"14:30"` (24-hour).
  static String formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';

  /// Formats as `"15 Jun 2026, 14:30"`.
  static String formatDateTime(DateTime date) =>
      '${formatDate(date)}, ${formatTime(date)}';
}
