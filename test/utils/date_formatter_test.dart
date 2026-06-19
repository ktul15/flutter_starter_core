import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    // intl requires explicit initialization in VM/test context.
    // In Flutter apps this is handled by MaterialApp + flutter_localizations.
    await initializeDateFormatting('en');
  });

  // All DateTimes local — .toLocal() in formatter is a no-op here.
  final now = DateTime(2026, 6, 16, 14, 30);

  group('DateFormatter.relative — English (default)', () {
    test('just now for <60s', () {
      final date = now.subtract(const Duration(seconds: 30));
      expect(DateFormatter.relative(date, now: now), 'just now');
    });

    test('minutes ago', () {
      final date = now.subtract(const Duration(minutes: 5));
      expect(DateFormatter.relative(date, now: now), '5m ago');
    });

    test('hours ago', () {
      final date = now.subtract(const Duration(hours: 3));
      expect(DateFormatter.relative(date, now: now), '3h ago');
    });

    test('days ago', () {
      final date = now.subtract(const Duration(days: 2));
      expect(DateFormatter.relative(date, now: now), '2d ago');
    });

    test('weeks ago', () {
      final date = now.subtract(const Duration(days: 14));
      expect(DateFormatter.relative(date, now: now), '2w ago');
    });

    test('months ago', () {
      final date = now.subtract(const Duration(days: 60));
      expect(DateFormatter.relative(date, now: now), '2mo ago');
    });

    test('years ago', () {
      final date = now.subtract(const Duration(days: 400));
      expect(DateFormatter.relative(date, now: now), '1y ago');
    });

    test('future date falls back to formatDate', () {
      final future = now.add(const Duration(hours: 1));
      final result = DateFormatter.relative(future, now: now);
      expect(result, isNot(contains('ago')));
      expect(result, isNotEmpty);
    });
  });

  group('DateFormatter.relative — Arabic labels', () {
    final ar = DateFormatterLocale.ar;

    test('just now', () {
      final date = now.subtract(const Duration(seconds: 10));
      expect(DateFormatter.relative(date, now: now, locale: ar), 'الآن');
    });

    test('1 minute — singular', () {
      final date = now.subtract(const Duration(minutes: 1));
      expect(DateFormatter.relative(date, now: now, locale: ar), 'منذ دقيقة');
    });

    test('2 minutes — dual', () {
      final date = now.subtract(const Duration(minutes: 2));
      expect(DateFormatter.relative(date, now: now, locale: ar), 'منذ دقيقتين');
    });

    test('5 minutes — plural (3–10)', () {
      final date = now.subtract(const Duration(minutes: 5));
      expect(DateFormatter.relative(date, now: now, locale: ar), 'منذ 5 دقائق');
    });

    test('15 minutes — large singular (11+)', () {
      final date = now.subtract(const Duration(minutes: 15));
      expect(DateFormatter.relative(date, now: now, locale: ar), 'منذ 15 دقيقة');
    });

    test('1 hour — singular', () {
      final date = now.subtract(const Duration(hours: 1));
      expect(DateFormatter.relative(date, now: now, locale: ar), 'منذ ساعة');
    });

    test('2 hours — dual', () {
      final date = now.subtract(const Duration(hours: 2));
      expect(DateFormatter.relative(date, now: now, locale: ar), 'منذ ساعتين');
    });

    test('5 hours — plural (3–10)', () {
      final date = now.subtract(const Duration(hours: 5));
      expect(DateFormatter.relative(date, now: now, locale: ar), 'منذ 5 ساعات');
    });

    test('1 month — singular', () {
      final date = now.subtract(const Duration(days: 30));
      expect(DateFormatter.relative(date, now: now, locale: ar), 'منذ شهر');
    });

    test('2 months — dual', () {
      final date = now.subtract(const Duration(days: 60));
      expect(DateFormatter.relative(date, now: now, locale: ar), 'منذ شهرين');
    });

    test('1 year — singular', () {
      final date = now.subtract(const Duration(days: 365));
      expect(DateFormatter.relative(date, now: now, locale: ar), 'منذ سنة');
    });

    test('2 years — dual', () {
      final date = now.subtract(const Duration(days: 730));
      expect(DateFormatter.relative(date, now: now, locale: ar), 'منذ سنتين');
    });
  });

  group('DateFormatter.relative — Japanese labels', () {
    final ja = DateFormatterLocale.ja;

    test('just now', () {
      final date = now.subtract(const Duration(seconds: 5));
      expect(DateFormatter.relative(date, now: now, locale: ja), 'たった今');
    });

    test('minutes', () {
      final date = now.subtract(const Duration(minutes: 30));
      expect(DateFormatter.relative(date, now: now, locale: ja), '30分前');
    });

    test('months', () {
      final date = now.subtract(const Duration(days: 90));
      expect(DateFormatter.relative(date, now: now, locale: ja), '3ヶ月前');
    });

    test('years', () {
      final date = now.subtract(const Duration(days: 400));
      expect(DateFormatter.relative(date, now: now, locale: ja), '1年前');
    });
  });

  group('DateFormatter.formatDate', () {
    test('en locale', () {
      // intl yMMMd en → "Jun 16, 2026"
      expect(DateFormatter.formatDate(now), 'Jun 16, 2026');
    });
  });

  group('DateFormatter.formatTime', () {
    test('zero-pads single-digit hours and minutes', () {
      expect(DateFormatter.formatTime(DateTime(2026, 1, 1, 9, 5)), '09:05');
    });

    test('afternoon time', () {
      expect(DateFormatter.formatTime(now), '14:30');
    });
  });

  group('DateFormatter.formatDateTime', () {
    test('en locale', () {
      // intl yMMMd + Hm → "Jun 16, 2026 14:30"
      expect(DateFormatter.formatDateTime(now), 'Jun 16, 2026 14:30');
    });
  });

  group('DateFormatter — UTC timezone safety', () {
    test('UTC date converts to local before formatting', () {
      final utc = now.toUtc();
      expect(DateFormatter.formatDate(utc), DateFormatter.formatDate(now));
    });

    test('relative uses local time so UTC input is safe', () {
      final utcDate = now.subtract(const Duration(minutes: 10)).toUtc();
      final utcNow = now.toUtc();
      expect(DateFormatter.relative(utcDate, now: utcNow), '10m ago');
    });
  });
}
