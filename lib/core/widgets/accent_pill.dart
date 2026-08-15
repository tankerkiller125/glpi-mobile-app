import 'package:flutter/material.dart';

import '../a11y/contrast.dart';

/// The app's semantic pill: a wash of a meaning-carrying color behind a label
/// that always states the meaning in words.
///
/// Status, SLA countdown, approval state and privacy all render as one of
/// these. Two accessibility rules are baked in so no call site has to remember
/// them:
///
/// * the label text is never optional — color alone would leave the meaning
///   invisible to anyone who can't separate these hues (GLPI's status green and
///   the priority amber are a classic red/green-deficient collision);
/// * the ink is derived from the accent with [AccentColors], which darkens or
///   lightens it until it clears WCAG AA against the wash it sits on. The raw
///   accents are tuned to be legible as 4px marks, and several of them sit
///   around 2:1 as text.
class AccentPill extends StatelessWidget {
  const AccentPill({
    super.key,
    required this.label,
    required this.accent,
    this.icon,
    this.semanticsLabel,
    this.borderRadius = 6,
    this.bordered = true,
  });

  final String label;
  final Color accent;
  final IconData? icon;

  /// What a screen reader says instead of [label] — usually the same words with
  /// the dimension named ("Status: New", "due in 3 hours"). Falls back to
  /// [label].
  final String? semanticsLabel;

  final double borderRadius;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AccentColors.of(accent, theme.colorScheme.surface);
    return Semantics(
      container: true,
      label: semanticsLabel ?? label,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(borderRadius),
          border: bordered ? Border.all(color: colors.border) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: colors.ink),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              // labelMedium (12sp), not labelSmall (11sp): these pills carry
              // real information and were the smallest type in the app.
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
