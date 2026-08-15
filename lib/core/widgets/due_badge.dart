import 'package:flutter/material.dart';

import 'accent_pill.dart';

/// A small colored pill for an SLA countdown ("in 3h", "overdue 2d"). The
/// caller supplies the color (see [GlpiColors.slaColor]) and, for a screen
/// reader, the spoken form (see `spokenDueRelative`) — "in 3h" is read as
/// "in three h".
class DueBadge extends StatelessWidget {
  const DueBadge({
    super.key,
    required this.text,
    required this.color,
    this.semanticsLabel,
  });

  final String text;
  final Color color;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return AccentPill(
      label: text,
      accent: color,
      semanticsLabel: semanticsLabel,
      borderRadius: 10,
      bordered: false,
    );
  }
}
