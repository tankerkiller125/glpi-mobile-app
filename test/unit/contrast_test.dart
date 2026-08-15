import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/a11y/contrast.dart';
import 'package:glpi_mobile/core/theme/app_theme.dart';
import 'package:glpi_mobile/core/theme/glpi_colors.dart';

/// The semantic colors are picked for recognisability as marks, not as text.
/// These tests pin the rule that anything rendered *as text* goes through
/// [ensureContrast] first, and prove the helper actually gets there for every
/// GLPI status, priority and SLA colour in both themes.
void main() {
  group('contrastRatio', () {
    test('black on white is the maximum 21:1', () {
      expect(contrastRatio(Colors.black, Colors.white), closeTo(21, 0.01));
    });

    test('a colour against itself is 1:1', () {
      expect(contrastRatio(Colors.teal, Colors.teal), closeTo(1, 0.001));
    });

    test('is symmetric', () {
      const a = Color(0xFF43A047);
      const b = Color(0xFFFFFBFE);
      expect(contrastRatio(a, b), closeTo(contrastRatio(b, a), 0.0001));
    });

    test('matches the known AA boundary for grey on white', () {
      // #767676 is the canonical darkest-passing / lightest-failing pair.
      expect(
        contrastRatio(const Color(0xFF767676), Colors.white),
        greaterThanOrEqualTo(wcagAaText),
      );
      expect(
        contrastRatio(const Color(0xFF777777), Colors.white),
        lessThan(wcagAaText),
      );
    });
  });

  group('ensureContrast', () {
    test('leaves a colour that already passes untouched', () {
      const ink = Color(0xFF1B5E20);
      expect(ensureContrast(ink, Colors.white), ink);
    });

    test('darkens against a light background, keeping the hue', () {
      const amber = Color(0xFFFFB300);
      final ink = ensureContrast(amber, Colors.white);
      expect(
        contrastRatio(ink, Colors.white),
        greaterThanOrEqualTo(wcagAaText),
      );
      expect(
        HSLColor.fromColor(ink).hue,
        closeTo(HSLColor.fromColor(amber).hue, 1),
      );
      expect(ink.computeLuminance(), lessThan(amber.computeLuminance()));
    });

    test('lightens against a dark background', () {
      const deepRed = Color(0xFFB71C1C);
      const surface = Color(0xFF141218);
      final ink = ensureContrast(deepRed, surface);
      expect(contrastRatio(ink, surface), greaterThanOrEqualTo(wcagAaText));
      expect(ink.computeLuminance(), greaterThan(deepRed.computeLuminance()));
    });

    test('honours a lower bar for graphics', () {
      const amber = Color(0xFFFFB300);
      final ink = ensureContrast(amber, Colors.white, minRatio: wcagAaGraphics);
      expect(
        contrastRatio(ink, Colors.white),
        greaterThanOrEqualTo(wcagAaGraphics),
      );
      // A lower bar means less adjustment than the text bar needs.
      expect(
        ink.computeLuminance(),
        greaterThan(ensureContrast(amber, Colors.white).computeLuminance()),
      );
    });
  });

  group('bestInkOn', () {
    test('picks black on a light fill and white on a dark one', () {
      expect(bestInkOn(const Color(0xFFF5B84B)), Colors.black); // light amber
      expect(bestInkOn(const Color(0xFF1A237E)), Colors.white); // deep indigo
    });

    test('always returns the higher-contrast of the two', () {
      // Including the light theme's "dark" amber, where the app used to hard-
      // code white (4.0:1) and black is in fact the better of the pair.
      for (final fill in const [
        Color(0xFFB26A00),
        Color(0xFFF5B84B),
        Color(0xFF43A047),
        Color(0xFFE53935),
      ]) {
        final ink = bestInkOn(fill);
        final other = ink == Colors.white ? Colors.black : Colors.white;
        expect(
          contrastRatio(ink, fill),
          greaterThanOrEqualTo(contrastRatio(other, fill)),
        );
      }
    });
  });

  group('every semantic pill is legible in both themes', () {
    /// Status ids for tickets, priorities 1–6, and the three SLA states.
    Iterable<(String, Color)> semanticColors(GlpiColors c) sync* {
      for (var s = 1; s <= 6; s++) {
        yield ('status $s', c.statusColor(s));
      }
      for (var p = 1; p <= 6; p++) {
        yield ('priority $p', c.priorityColor(p));
      }
      yield ('sla ok', c.slaOk);
      yield ('sla warn', c.slaWarn);
      yield ('sla breach', c.slaBreach);
      yield ('planning ticket', c.planningTicket);
      yield ('planning change', c.planningChange);
      yield ('planning problem', c.planningProblem);
      yield ('planning project', c.planningProject);
      yield ('planning reminder', c.planningReminder);
      yield ('planning event', c.planningEvent);
    }

    for (final (themeName, theme, colors) in [
      ('light', buildLightTheme(), GlpiColors.light),
      ('dark', buildDarkTheme(), GlpiColors.dark),
    ]) {
      test('$themeName: AccentPill ink clears AA on its own tint', () {
        for (final (name, accent) in semanticColors(colors)) {
          final pill = AccentColors.of(accent, theme.colorScheme.surface);
          expect(
            contrastRatio(pill.ink, pill.background),
            greaterThanOrEqualTo(wcagAaText),
            reason: '$themeName $name is unreadable on its own pill',
          );
        }
      });

      test('$themeName: marks clear the 3:1 graphics bar on the surface', () {
        for (final (name, accent) in semanticColors(colors)) {
          final mark = ensureContrast(
            accent,
            theme.colorScheme.surface,
            minRatio: wcagAaGraphics,
          );
          expect(
            contrastRatio(mark, theme.colorScheme.surface),
            greaterThanOrEqualTo(wcagAaGraphics),
            reason: '$themeName $name is invisible as a dot or a card edge',
          );
        }
      });

      test('$themeName: the raw accents would NOT have passed', () {
        // Guards the reason this code exists: at least one of the shipped
        // colours fails as text, so removing ensureContrast has to fail a test.
        final failures = [
          for (final (name, accent) in semanticColors(colors))
            if (contrastRatio(
                  accent,
                  AccentColors.of(accent, theme.colorScheme.surface).background,
                ) <
                wcagAaText)
              name,
        ];
        expect(failures, isNotEmpty);
      });
    }
  });
}
