import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/planning_event.dart';
import '../../../core/providers.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/date_time_field.dart';
import '../../change_calendar/ui/freeze_warning.dart';

/// Create or edit a standalone calendar entry: a `PlanningExternalEvent` or a
/// `Reminder`. Both share this editor because GLPI models them almost
/// identically (name + text + optional planning window + state).
class EventEditorSheet extends ConsumerStatefulWidget {
  const EventEditorSheet({
    super.key,
    this.existing,
    this.kind = 'PlanningExternalEvent',
    this.initialBegin,
    this.initialEnd,
  });

  /// When set, the sheet edits this entry instead of creating one.
  final PlanningEvent? existing;
  final String kind;
  final DateTime? initialBegin;
  final DateTime? initialEnd;

  static Future<void> show(
    BuildContext context, {
    PlanningEvent? existing,
    String kind = 'PlanningExternalEvent',
    DateTime? initialBegin,
    DateTime? initialEnd,
  }) => showModalBottomSheet<void>(
    useSafeArea: true,
    context: context,
    constraints: sheetConstraints(context),
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => EventEditorSheet(
      existing: existing,
      kind: kind,
      initialBegin: initialBegin,
      initialEnd: initialEnd,
    ),
  );

  @override
  ConsumerState<EventEditorSheet> createState() => _EventEditorSheetState();
}

class _EventEditorSheetState extends ConsumerState<EventEditorSheet> {
  late final _name = TextEditingController(text: widget.existing?.title ?? '');
  final _text = TextEditingController();
  late DateTime _begin =
      widget.existing?.begin ?? widget.initialBegin ?? _defaultBegin();
  late DateTime _end =
      widget.existing?.end ??
      widget.initialEnd ??
      _defaultBegin().add(const Duration(hours: 1));
  late int _state = widget.existing?.state ?? PlanningState.todo;

  static DateTime _defaultBegin() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day, n.hour + 1);
  }

  String get _kind => widget.existing?.eventItemtype ?? widget.kind;
  bool get _isReminder => _kind == 'Reminder';
  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _name.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    _isEdit
                        ? (_isReminder ? 'Edit reminder' : 'Edit event')
                        : (_isReminder ? 'New reminder' : 'New event'),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const Spacer(),
                if (_isEdit)
                  IconButton(
                    tooltip: _isReminder ? 'Delete reminder' : 'Delete event',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _confirmDelete,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _name,
              autofocus: !_isEdit,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _text,
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: _isReminder ? 'Note' : 'Description',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            DateTimeField(
              label: 'Starts',
              value: _begin,
              onChanged: (v) => setState(() {
                final d = _end.difference(_begin);
                _begin = v;
                _end = v.add(d.isNegative ? const Duration(hours: 1) : d);
              }),
            ),
            DateTimeField(
              label: 'Ends',
              value: _end,
              onChanged: (v) => setState(() => _end = v),
            ),
            // Courtesy heads-up when the picked window crosses a change
            // freeze (renders nothing without the glpichange capability).
            FreezeWarning(begin: _begin, end: _end),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: PlanningState.information,
                  label: Text('Info'),
                ),
                ButtonSegment(value: PlanningState.todo, label: Text('To do')),
                ButtonSegment(value: PlanningState.done, label: Text('Done')),
              ],
              selected: {_state},
              onSelectionChanged: (s) => setState(() => _state = s.first),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _name.text.trim().isEmpty ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(_isEdit ? 'Save' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final actions = ref.read(ticketActionsProvider);
    if (actions == null) return;
    if (_isEdit) {
      await actions.patchPlanningItem(
        widget.existing!,
        name: _name.text.trim(),
        text: _text.text.trim().isEmpty ? null : _text.text.trim(),
        begin: _begin,
        end: _end,
        state: _state,
      );
    } else {
      await actions.createPlanningItem(
        kind: _kind,
        name: _name.text.trim(),
        text: _text.text.trim(),
        begin: _begin,
        end: _end,
        state: _state,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isReminder ? 'Delete reminder?' : 'Delete event?'),
        content: const Text('This removes it from your planning.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(ticketActionsProvider)?.deletePlanningItem(widget.existing!);
    if (mounted) Navigator.pop(context);
  }
}
