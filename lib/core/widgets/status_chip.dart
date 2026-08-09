import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/formatting.dart';

/// Status pill. Carries a text label (never color-only) for accessibility.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.itemtype = 'Ticket'});

  final int status;
  final String itemtype;

  @override
  Widget build(BuildContext context) {
    final color = context.glpiColors.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        statusLabel(status, itemtype: itemtype),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Priority as a filled flame icon + count is overkill for the card; a small
/// colored dot with a Semantics label is clearer at a glance.
class PriorityDot extends StatelessWidget {
  const PriorityDot({super.key, required this.priority});

  final int priority;

  @override
  Widget build(BuildContext context) {
    final color = context.glpiColors.priorityColor(priority);
    return Semantics(
      label: 'Priority ${priorityLabel(priority)}',
      child: Icon(Icons.circle, size: 10, color: color),
    );
  }
}
