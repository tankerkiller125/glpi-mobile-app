import 'package:flutter/material.dart';

import '../a11y/contrast.dart';
import '../theme/app_theme.dart';
import '../utils/formatting.dart';
import 'accent_pill.dart';

/// Status pill. Carries a text label (never color-only) for accessibility.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.itemtype = 'Ticket'});

  final int status;
  final String itemtype;

  @override
  Widget build(BuildContext context) {
    final label = statusLabel(status, itemtype: itemtype);
    return AccentPill(
      label: label,
      accent: context.glpiColors.statusColor(status),
      // "New" on its own is ambiguous out loud — name the dimension.
      semanticsLabel: 'Status: $label',
    );
  }
}

/// Priority as a filled flame icon + count is overkill for the card; a small
/// colored dot with a Semantics label is clearer at a glance.
///
/// The dot is the one place a color stands alone, so it gets the graphics-level
/// contrast treatment (3:1) and always announces the priority in words.
class PriorityDot extends StatelessWidget {
  const PriorityDot({super.key, required this.priority});

  final int priority;

  @override
  Widget build(BuildContext context) {
    final color = ensureContrast(
      context.glpiColors.priorityColor(priority),
      Theme.of(context).colorScheme.surface,
      minRatio: wcagAaGraphics,
    );
    return Semantics(
      label: 'Priority ${priorityLabel(priority)}',
      excludeSemantics: true,
      child: Icon(Icons.circle, size: 10, color: color),
    );
  }
}
