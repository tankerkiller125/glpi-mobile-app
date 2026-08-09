import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/theme/glpi_colors.dart';
import 'package:glpi_mobile/core/utils/formatting.dart';

void main() {
  final now = DateTime(2026, 8, 8, 12, 0);

  group('formatDueRelative', () {
    test('future within an hour shows minutes', () {
      expect(
        formatDueRelative(now.add(const Duration(minutes: 20)), now: now),
        'in 20m',
      );
    });

    test('future within a day shows hours (and minutes)', () {
      expect(
        formatDueRelative(
          now.add(const Duration(hours: 3, minutes: 20)),
          now: now,
        ),
        'in 3h 20m',
      );
      expect(
        formatDueRelative(now.add(const Duration(hours: 5)), now: now),
        'in 5h',
      );
    });

    test('further out shows days', () {
      expect(
        formatDueRelative(now.add(const Duration(days: 2)), now: now),
        'in 2d',
      );
    });

    test('past is overdue', () {
      expect(
        formatDueRelative(now.subtract(const Duration(hours: 3)), now: now),
        'overdue 3h',
      );
      expect(
        formatDueRelative(now.subtract(const Duration(days: 2)), now: now),
        'overdue 2d',
      );
    });

    test('at the boundary reads "due now"', () {
      expect(
        formatDueRelative(now.add(const Duration(seconds: 30)), now: now),
        'due now',
      );
    });

    test('null due is empty', () {
      expect(formatDueRelative(null, now: now), '');
    });
  });

  group('GlpiColors.slaColor', () {
    const c = GlpiColors.light;
    test('overdue is breach', () {
      expect(c.slaColor(const Duration(hours: -1)), c.slaBreach);
    });
    test('inside the warn window is warn', () {
      expect(c.slaColor(const Duration(hours: 2)), c.slaWarn);
      expect(c.slaColor(Duration.zero), c.slaWarn);
    });
    test('comfortably ahead is ok', () {
      expect(c.slaColor(const Duration(hours: 5)), c.slaOk);
      expect(c.slaColor(const Duration(days: 3)), c.slaOk);
    });
  });
}
