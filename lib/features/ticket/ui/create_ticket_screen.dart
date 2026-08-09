import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/utils/html_text.dart';
import '../../../core/utils/priority_matrix.dart';
import 'category_picker.dart';
import 'option_sheet.dart';

/// Log a new ticket. Writes optimistically through the outbox (works offline);
/// on submit it navigates to the new ticket's detail, which shows "Sending…"
/// until the create syncs.
class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  int _type = 1; // 1 Incident, 2 Request
  int _urgency = 3;
  int _impact = 3;
  int? _categoryId;
  String? _categoryName;
  bool _assignToMe = true;
  bool _submitting = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  bool get _canSubmit => _title.text.trim().isNotEmpty && !_submitting;

  Future<void> _submit() async {
    final actions = ref.read(ticketActionsProvider);
    if (actions == null || !_canSubmit) return;
    setState(() => _submitting = true);
    final localId = await actions.createTicket(
      name: _title.text.trim(),
      // GLPI renders content as markup; keep the typed line breaks.
      content: plainTextToHtml(_description.text.trim()),
      type: _type,
      urgency: _urgency,
      impact: _impact,
      categoryId: _categoryId,
      categoryName: _categoryName,
      assignToMe: _assignToMe,
    );
    if (!mounted) return;
    // Replace this screen with the new ticket so Back returns to the queue.
    context.pushReplacement(Routes.ticket(localId));
  }

  Future<void> _editUrgency() async {
    final v = await OptionSheet.show(
      context,
      title: 'Urgency',
      current: _urgency,
      options: [
        for (var u = 5; u >= 1; u--)
          OptionItem(value: u, label: urgencyLabel(u)),
      ],
    );
    if (v != null) setState(() => _urgency = v);
  }

  Future<void> _editImpact() async {
    final v = await OptionSheet.show(
      context,
      title: 'Impact',
      current: _impact,
      options: [
        for (var i = 5; i >= 1; i--)
          OptionItem(value: i, label: urgencyLabel(i)),
      ],
    );
    if (v != null) setState(() => _impact = v);
  }

  Future<void> _editCategory() async {
    final picked = await CategoryPicker.show(context, _categoryId);
    if (picked != null) {
      setState(() {
        _categoryId = picked.$1;
        _categoryName = picked.$2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.glpiColors;
    final priority = computePriority(_urgency, _impact);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New ticket'),
        actions: [
          TextButton(
            onPressed: _canSubmit ? _submit : null,
            child: const Text('Create'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _title,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Short summary',
            ),
            onChanged: (_) => setState(() {}), // toggle the Create button
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            minLines: 3,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'What’s happening?',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: 1,
                label: Text('Incident'),
                icon: Icon(Icons.error_outline),
              ),
              ButtonSegment(
                value: 2,
                label: Text('Request'),
                icon: Icon(Icons.help_outline),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 8),
          _PickerTile(
            icon: Icons.priority_high,
            label: 'Urgency',
            value: urgencyLabel(_urgency),
            onTap: _editUrgency,
          ),
          _PickerTile(
            icon: Icons.bolt_outlined,
            label: 'Impact',
            value: urgencyLabel(_impact),
            onTap: _editImpact,
          ),
          // Priority is derived from urgency × impact (read-only).
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 20,
                  color: colors.priorityColor(priority),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 96,
                  child: Text(
                    'Priority',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
                Text(priorityLabel(priority), style: theme.textTheme.bodyLarge),
                const SizedBox(width: 8),
                Text(
                  'derived',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          _PickerTile(
            icon: Icons.folder_outlined,
            label: 'Category',
            value: _categoryName ?? 'None',
            onTap: _editCategory,
          ),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.assignment_ind_outlined),
            title: const Text('Assign to me'),
            value: _assignToMe,
            onChanged: (v) => setState(() => _assignToMe = v),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _canSubmit ? _submit : null,
            icon: const Icon(Icons.send),
            label: const Text('Create ticket'),
          ),
        ],
      ),
    );
  }
}

/// A tappable label→value row that opens a picker (urgency/impact/category).
class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.outline),
            const SizedBox(width: 16),
            SizedBox(
              width: 96,
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
            Icon(
              Icons.edit_outlined,
              size: 18,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
