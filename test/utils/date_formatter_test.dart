import 'package:flutter_test/flutter_test.dart';
import 'package:mobilions_core/mobilions_core.dart';

void main() {
  final now = DateTime(2026, 6, 16, 14, 30);

  group('DateFormatter.relative', () {
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

    test('falls back to formatDate beyond 4 weeks', () {
      final date = now.subtract(const Duration(days: 60));
      expect(DateFormatter.relative(date, now: now), isNot(contains('ago')));
    });
  });

  group('DateFormatter.formatDate', () {
    test('formats correctly', () {
      expect(DateFormatter.formatDate(now), '16 Jun 2026');
    });
  });

  group('DateFormatter.formatTime', () {
    test('zero-pads hours and minutes', () {
      expect(DateFormatter.formatTime(DateTime(2026, 1, 1, 9, 5)), '09:05');
    });
  });

  group('DateFormatter.formatDateTime', () {
    test('combines date and time', () {
      expect(DateFormatter.formatDateTime(now), '16 Jun 2026, 14:30');
    });
  });
}
