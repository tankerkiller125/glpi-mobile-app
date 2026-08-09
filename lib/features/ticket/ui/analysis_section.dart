import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/itil_type.dart';
import '../../../core/models/ticket_detail.dart';
import '../../../core/providers.dart';
import '../../../core/utils/html_text.dart';
import '../../../core/widgets/rich_content.dart';
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

    final theme = Theme.of(context);
    final values = ref.watch(itilExtraProvider(item.localId)).value ?? const {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.itemtype == itilChange ? 'Change analysis' : 'Problem analysis',
          style: theme.textTheme.labelLarge,
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
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            Expanded(
              child: empty
                  ? Text(
                      'Not set',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : RichContent(value, selectable: false),
            ),
            Icon(
              // Don't promise an edit the mobile editor can't make safely.
              htmlHasUnsupportedMarkup(value)
                  ? Icons.lock_outline
                  : Icons.edit_outlined,
              size: 16,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  /// GLPI stores these as rich text; show them as plain text on mobile.
}
