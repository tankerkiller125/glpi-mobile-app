import 'dart:math' as math;

import 'package:flutter/material.dart';

/// WCAG 2.1 contrast thresholds.
///
/// Normal text needs 4.5:1, text at 18pt (or 14pt bold) and larger needs 3:1,
/// and so do meaningful non-text elements — icons, chart marks, the colored
/// edge of a card.
const double wcagAaText = 4.5;
const double wcagAaLargeText = 3.0;
const double wcagAaGraphics = 3.0;

/// Contrast ratio between two colors, 1.0 (identical) … 21.0 (black on white).
///
/// Both colors must be opaque: a translucent color has no single luminance.
/// Composite it over what is behind it first — [flatten] does that.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

/// [color] composited over [behind], so a translucent tint can be measured.
Color flatten(Color color, Color behind) => Color.alphaBlend(color, behind);

/// Darkens or lightens [foreground] just far enough to reach [minRatio]
/// against [background], keeping its hue and saturation.
///
/// GLPI's semantic colors (status green, priority amber, SLA red) are picked to
/// be recognisable as *marks* — a 4px card edge, a dot — and several of them
/// land near 2:1 as text on a light surface. Rather than give up the meaning by
/// recoloring them, this walks the lightness towards the end of the scale the
/// background is furthest from until the text is legible. Amber stays amber; it
/// just becomes a readable amber.
Color ensureContrast(
  Color foreground,
  Color background, {
  double minRatio = wcagAaText,
}) {
  if (contrastRatio(foreground, background) >= minRatio) return foreground;

  // A light background wants darker text and vice versa.
  final darken = background.computeLuminance() > 0.5;
  final hsl = HSLColor.fromColor(foreground);
  for (var step = 1; step <= 100; step++) {
    final lightness = darken
        ? hsl.lightness - step * 0.01
        : hsl.lightness + step * 0.01;
    if (lightness < 0 || lightness > 1) break;
    final candidate = hsl.withLightness(lightness).toColor();
    if (contrastRatio(candidate, background) >= minRatio) return candidate;
  }
  // Unreachable for any sane pair, but black/white always maximises contrast.
  return darken ? Colors.black : Colors.white;
}

/// The three colors a tinted pill needs — background, border and ink — derived
/// from one semantic [accent] over the [behind] surface it is drawn on.
///
/// Every status/priority/SLA/approval pill in the app is built the same way: a
/// 15% wash of the accent, a 50% border, and the accent itself as text. That
/// last part is what failed — this returns an ink that is guaranteed readable
/// on the wash it sits on.
@immutable
class AccentColors {
  const AccentColors({
    required this.background,
    required this.border,
    required this.ink,
  });

  /// Derive the trio for [accent] over [behind] (usually the theme surface).
  factory AccentColors.of(Color accent, Color behind) {
    final background = flatten(accent.withValues(alpha: 0.15), behind);
    return AccentColors(
      background: background,
      // The border is decoration; the ink and the label carry the meaning, so
      // it only needs to be visible, not AA-compliant.
      border: flatten(accent.withValues(alpha: 0.5), behind),
      ink: ensureContrast(accent, background),
    );
  }

  final Color background;
  final Color border;
  final Color ink;
}

/// Black or white — whichever reads better on [background].
///
/// For filled badges, where the fill is the meaningful color and the text has
/// to survive it. The same badge is often amber-on-dark in one theme and
/// amber-on-light in the other, and hard-coding white text fails one of them.
Color bestInkOn(Color background) =>
    contrastRatio(Colors.white, background) >=
        contrastRatio(Colors.black, background)
    ? Colors.white
    : Colors.black;

/// The accessible ink for a semantic [accent] drawn directly on [behind]
/// (no tinted pill) — a colored value in a detail row, a legend swatch's label.
Color accentInk(Color accent, Color behind) => ensureContrast(accent, behind);
