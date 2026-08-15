import 'package:flutter/material.dart';

/// A section title inside a screen ("Description", "Timeline", "Attachments").
///
/// Marked as a heading so screen readers can offer heading-by-heading
/// navigation: a ticket detail is a long scroll of rows, and jumping to
/// "Timeline" beats swiping past thirty fields to reach it. TalkBack and
/// VoiceOver both expose this as a rotor/granularity step.
class SectionHeading extends StatelessWidget {
  const SectionHeading(this.text, {super.key, this.count, this.trailing});

  final String text;

  /// Shown as "(3)" beside the title, and folded into the spoken heading.
  final int? count;

  /// An action that belongs to the section (an Add button, a filter).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = Semantics(
      header: true,
      label: count == null ? text : '$text, $count',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: theme.textTheme.labelLarge),
          if (count != null) ...[
            const SizedBox(width: 4),
            Text(
              '($count)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ],
      ),
    );
    if (trailing == null) return title;
    return Row(children: [title, const Spacer(), trailing!]);
  }
}
