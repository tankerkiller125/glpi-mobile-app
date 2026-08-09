import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/utils/formatting.dart';

void main() {
  group('parseGlpiDateTime', () {
    test('keeps the wall clock when the API claims +00:00', () {
      // GLPI serializes server-local times with a bogus UTC offset; the app
      // must not shift them by the device's timezone.
      final d = parseGlpiDateTime('2026-08-08T08:00:00+00:00');
      expect(d, isNotNull);
      expect(d!.hour, 8);
      expect(d.minute, 0);
      expect(d.day, 8);
    });

    test('handles Z, offsets and naive strings identically', () {
      for (final raw in [
        '2026-08-08T09:30:00Z',
        '2026-08-08T09:30:00+02:00',
        '2026-08-08T09:30:00-0500',
        '2026-08-08 09:30:00',
      ]) {
        final d = parseGlpiDateTime(raw);
        expect(d, isNotNull, reason: raw);
        expect(d!.hour, 9, reason: raw);
        expect(d.minute, 30, reason: raw);
      }
    });

    test('null and empty are null', () {
      expect(parseGlpiDateTime(null), isNull);
      expect(parseGlpiDateTime(''), isNull);
    });
  });
}
