import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/itil_type.dart';
import '../../../core/models/ticket_detail.dart';
import '../../../core/providers.dart';
import '../../../core/utils/html_text.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/rich_content.dart';
import '../../../core/widgets/section_heading.dart';
import 'compose_sheet.dart';

/// The analysis fields GLPI gives Changes and Problems but not Tickets:
/// impact/cause/symptom notes, and a change's rollout, backout and checklists.
/// Edits are offline-first (cached locally, drained through the outbox).
class AnalysisSection extends ConsumerWidget {
  const AnalysisSection({super.key, required this.item});

  final TicketDetail item;

  /// Field name → label, per ITIL type. Order matches GLPI's own tabs.
  static const _fields = {
    itilChange: [
      ('impactcontent', 'Impact'),
      ('controlistcontent', 'Control list'),
      ('rolloutplancontent', 'Rollout plan'),
      ('backoutplancontent', 'Backout plan'),
      ('checklistcontent', 'Checklist'),
    ],
    itilProblem: [
      ('impactcontent', 'Impact'),
      ('causecontent', 'Cause'),
      ('symptomcontent', 'Symptom'),
    ],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fields = _fields[item.itemtype];
    if (fields == null) return const SizedBox.shrink(); // Tickets have none

    final values = ref.watch(itilExtraProvider(item.localId)).value ?? const {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          item.itemtype == itilChange ? 'Change analysis' : 'Problem analysis',
        ),
        const SizedBox(height: 4),
        for (final (key, label) in fields)
          _AnalysisTile(
            label: label,
            value: values[key] ?? '',
            onEdit: () => _edit(context, ref, key, label, values[key] ?? ''),
          ),
      ],
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    String field,
    String label,
    String current,
  ) async {
    // The mobile editor has no table model: importing one flattens it into a
    // paragraph of run-together cells. Refusing to edit is the only honest
    // option — the alternative is destroying the author's work on save.
    if (htmlHasUnsupportedMarkup(current)) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(label),
          content: const Text(
            'This field contains a table or an image, which the mobile editor '
            'would flatten. It stays read-only here — edit it in GLPI.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    final text = await ComposeSheet.show(
      context,
      title: label,
      hint: 'Describe the $label…',
      submitLabel: 'Save',
      initialText: current,
      rich: true,
    );
    if (text == null) return;
    await ref.read(ticketActionsProvider)?.patchExtra(item, {
      field: text.trim(),
    });
  }
}

class _AnalysisTile extends StatelessWidget {
  const _AnalysisTile({
    required this.label,
    required this.value,
    required this.onEdit,
  });

  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final empty = value.trim().isEmpty;
    final locked = htmlHasUnsupportedMarkup(value);
    final stacked = prefersStackedRows(context);

    final labelText = Text(
      label,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.outline,
      ),
    );
    final valueWidget = empty
        ? Text(
            'Not set',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
              fontStyle: FontStyle.italic,
            ),
          )
        : RichContent(value, selectable: false);
    final affordance = Icon(
      // Don't promise an edit the mobile editor can't make safely.
      locked ? Icons.lock_outline : Icons.edit_outlined,
      size: 16,
      color: theme.colorScheme.outline,
    );

    return Semantics(
      container: true,
      button: true,
      label: label,
      value: empty ? 'Not set' : htmlToPlainText(value),
      // Both outcomes are worth knowing before you tap: one opens an editor,
      // the other opens an explanation of why it won't.
      hint: locked ? 'Read-only, contains a table or image' : 'Edit',
      onTap: onEdit,
      excludeSemantics: true,
      child: InkWell(
        onTap: onEdit,
        excludeFromSemantics: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: stacked
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: labelText),
                          affordance,
                        ],
                      ),
                      const SizedBox(height: 2),
                      valueWidget,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 110, child: labelText),
                      Expanded(child: valueWidget),
                      affordance,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
