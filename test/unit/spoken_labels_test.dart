import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/a11y/a11y.dart';
import 'package:glpi_mobile/core/utils/formatting.dart';

/// The visible labels in this app are deliberately terse — "4h", "in 3h 20m",
/// "1h 30m". A screen reader reads those literally ("four h"), so every place
/// that shows one hands the semantics layer a spoken variant instead.
void main() {
  final now = DateTime(2026, 8, 15, 12);

  group('spokenAge', () {
    test('expands what relativeAge abbreviates', () {
      final cases = {
        now.subtract(const Duration(seconds: 20)): 'just now',
        now.subtract(const Duration(minutes: 1)): '1 minute ago',
        now.subtract(const Duration(minutes: 45)): '45 minutes ago',
        now.subtract(const Duration(hours: 4)): '4 hours ago',
        now.subtract(const Duration(days: 1)): '1 day ago',
        now.subtract(const Duration(days: 10)): '1 week ago',
        now.subtract(const Duration(days: 60)): '2 months ago',
        now.subtract(const Duration(days: 800)): '2 years ago',
      };
      for (final entry in cases.entries) {
        expect(spokenAge(entry.key, now: now), entry.value);
      }
    });

    test('never says "1 minutes"', () {
      expect(
        spokenAge(now.subtract(const Duration(minutes: 1)), now: now),
        isNot(contains('1 minutes')),
      );
    });

    test('is empty for a missing timestamp, like its visible twin', () {
      expect(spokenAge(null), '');
      expect(relativeAge(null), '');
    });
  });

  group('spokenDueRelative', () {
    test('says whether a deadline is ahead or behind', () {
      expect(
        spokenDueRelative(
          now.add(const Duration(hours: 3, minutes: 20)),
          now: now,
        ),
        'due in 3 hours 20 minutes',
      );
      expect(
        spokenDueRelative(now.add(const Duration(hours: 2)), now: now),
        'due in 2 hours',
      );
      expect(
        spokenDueRelative(now.subtract(const Duration(days: 2)), now: now),
        'overdue by 2 days',
      );
      expect(spokenDueRelative(now, now: now), 'due now');
    });

    test('covers the same cases as the visible badge', () {
      for (final offset in const [
        Duration(minutes: -90),
        Duration(minutes: 30),
        Duration(hours: 5),
        Duration(days: 3),
      ]) {
        final due = now.add(offset);
        expect(formatDueRelative(due, now: now), isNotEmpty);
        expect(spokenDueRelative(due, now: now), isNotEmpty);
      }
    });
  });

  group('spokenDuration', () {
    test('spells out hours and minutes', () {
      expect(spokenDuration(5400), '1 hour 30 minutes');
      expect(spokenDuration(3600), '1 hour');
      expect(spokenDuration(2700), '45 minutes');
    });

    test('is empty when there is no duration to speak of', () {
      expect(spokenDuration(null), '');
      expect(spokenDuration(0), '');
      expect(spokenDuration(-60), '');
    });
  });

  group('semanticSentence', () {
    test('joins the parts into one readable sentence', () {
      expect(
        semanticSentence(['Ticket 42', 'Email outage', 'Status New']),
        'Ticket 42. Email outage. Status New.',
      );
    });

    test('drops nulls and blanks rather than leaving gaps', () {
      expect(semanticSentence(['Ticket 42', null, '', '   ']), 'Ticket 42.');
    });

    test('does not double up punctuation the caller already wrote', () {
      expect(semanticSentence(['Done.', 'Really?']), 'Done. Really?');
    });
  });
}
