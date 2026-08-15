import 'package:flutter/material.dart';

import '../utils/layout.dart';

/// The label/value row every detail screen is built from.
///
/// Two things here are accessibility work rather than layout:
///
/// * the row is **one** semantics node ("Category: Hardware", plus an "Edit"
///   hint when it is tappable). Left to itself it produces three — an unlabelled
///   icon, "Category", "Hardware" — and a screen-reader user has to hold the
///   label in their head while swiping to the value;
/// * the fixed-width label column collapses into a stack once the user's font
///   scale passes ~1.4× ([prefersStackedRows]), instead of squeezing the value
///   into an ellipsis.
class LabelledRow extends StatelessWidget {
  const LabelledRow({
    super.key,
    required this.icon,
    required this.label,
    required this.child,
    this.iconColor,
    this.onTap,
    this.trailing,
    this.semanticsValue,
    this.semanticsHint,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final IconData icon;
  final String label;

  /// The value side of the row.
  final Widget child;

  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  /// Spoken form of the value, when the rendered one wouldn't read well
  /// (chips, abbreviated dates). Null means the child speaks for itself.
  final String? semanticsValue;

  /// What tapping does. Defaults to "Edit" for tappable rows.
  final String? semanticsHint;

  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stacked = prefersStackedRows(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.outline,
    );
    final labelText = Text(label, style: labelStyle);

    final value = Expanded(child: child);
    final affordance = trailing != null
        ? trailing!
        : (onTap != null
              ? Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: theme.colorScheme.outline,
                )
              : null);

    final Widget body = stacked
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: iconColor ?? theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: labelText),
                  ?affordance,
                ],
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(children: [value]),
              ),
            ],
          )
        : Row(
            crossAxisAlignment: crossAxisAlignment,
            children: [
              Icon(
                icon,
                size: 18,
                color: iconColor ?? theme.colorScheme.outline,
              ),
              const SizedBox(width: 12),
              SizedBox(width: 92, child: labelText),
              value,
              ?affordance,
            ],
          );

    final padded = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: body,
    );

    return Semantics(
      container: true,
      button: onTap != null,
      label: label,
      value: semanticsValue,
      hint: onTap == null ? null : (semanticsHint ?? 'Edit'),
      // The InkWell below is excluded from semantics so the row reads as one
      // node — which means this node has to carry the tap action itself.
      onTap: onTap,
      // The children keep their own labels only when we have no better sentence
      // to offer; a supplied value replaces them so the row reads as one thing.
      excludeSemantics: semanticsValue != null,
      child: onTap == null
          ? padded
          : InkWell(
              onTap: onTap,
              excludeFromSemantics: true,
              // One short line of text plus padding is ~36dp; a row you can tap
              // has to reach the 48dp target.
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: kMinInteractiveDimension,
                ),
                child: Center(heightFactor: 1, child: padded),
              ),
            ),
    );
  }
}

/// A labelled read-only (or tap-to-edit) field row. Used by every detail
/// screen — tickets, changes, problems, assets and management records — so a
/// field reads the same wherever it appears.
class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.trailing,
    this.semanticsValue,
    this.semanticsHint,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Tappable rows show a pencil affordance; null means read-only.
  final VoidCallback? onTap;

  /// Replaces the pencil when the row needs its own affordance (a call button,
  /// a spinner while an edit syncs).
  final Widget? trailing;

  /// Spoken form of [value] when the displayed one is abbreviated.
  final String? semanticsValue;
  final String? semanticsHint;

  @override
  Widget build(BuildContext context) {
    return LabelledRow(
      icon: icon,
      label: label,
      onTap: onTap,
      trailing: trailing,
      semanticsValue: semanticsValue ?? (value.isEmpty ? 'Empty' : value),
      semanticsHint: semanticsHint,
      child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
