import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/planning_event.dart';
import '../../../core/models/reminder.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/utils/html_text.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/date_time_field.dart';

/// Reminders: personal notes, optionally scheduled into the planning calendar.
/// Reminders shared by other users are shown read-only.
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  bool _loadedOnce = false;

  Future<void> _refresh() async {
    try {
      await ref.read(toolsRepositoryProvider)?.refreshReminders();
    } on Exception {
      // Offline: cached reminders keep showing.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadedOnce) {
      _loadedOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    }
    final reminders = ref.watch(remindersProvider).value ?? const <Reminder>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: reminders.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 100),
                  Center(
                    child: Text(
                      'No reminders',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: reminders.length,
                itemBuilder: (context, i) =>
                    _ReminderCard(reminder: reminders[i]),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ReminderEditor.show(context),
        tooltip: 'New reminder',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ReminderCard extends ConsumerWidget {
  const _ReminderCard({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.glpiColors;

    return Opacity(
      opacity: reminder.pending ? 0.55 : 1,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: InkWell(
          onTap: reminder.isEditable
              ? () => ReminderEditor.show(context, existing: reminder)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reminder.name,
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!reminder.isMine)
                      Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: theme.colorScheme.outline,
                      ),
                  ],
                ),
                if (reminder.content.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    htmlToPlainText(reminder.content),
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (reminder.isPlanned && reminder.begin != null) ...[
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: colors.planningReminder,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formatDateTime(reminder.begin),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.planningReminder,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        reminder.stateLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ] else
                      Text(
                        'Not scheduled',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    const Spacer(),
                    if (reminder.pending)
                      Text(
                        'syncing…',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Create or edit a reminder.
class ReminderEditor extends ConsumerStatefulWidget {
  const ReminderEditor({super.key, this.existing});

  final Reminder? existing;

  static Future<void> show(BuildContext context, {Reminder? existing}) =>
      showModalBottomSheet<void>(
        context: context,
        constraints: sheetConstraints(context),
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => ReminderEditor(existing: existing),
      );

  @override
  ConsumerState<ReminderEditor> createState() => _ReminderEditorState();
}

class _ReminderEditorState extends ConsumerState<ReminderEditor> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _content = TextEditingController(
    text: htmlToPlainText(widget.existing?.content ?? ''),
  );
  late bool _planned = widget.existing?.isPlanned ?? false;
  late DateTime _begin = widget.existing?.begin ?? _defaultBegin();
  late DateTime _end =
      widget.existing?.end ?? _defaultBegin().add(const Duration(minutes: 30));
  late int _state = widget.existing?.state ?? PlanningState.todo;

  static DateTime _defaultBegin() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day, n.hour + 1);
  }

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _name.dispose();
    _content.dispose();
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
                Text(
                  _isEdit ? 'Edit reminder' : 'New reminder',
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                if (_isEdit)
                  IconButton(
                    tooltip: 'Delete',
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
              controller: _content,
              minLines: 3,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Schedule this reminder'),
              subtitle: const Text('Shows it in your planning calendar'),
              value: _planned,
              onChanged: (v) => setState(() => _planned = v),
            ),
            if (_planned) ...[
              DateTimeField(
                label: 'Starts',
                value: _begin,
                onChanged: (v) => setState(() {
                  final d = _end.difference(_begin);
                  _begin = v;
                  _end = v.add(d.isNegative ? const Duration(minutes: 30) : d);
                }),
              ),
              DateTimeField(
                label: 'Ends',
                value: _end,
                onChanged: (v) => setState(() => _end = v),
              ),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: PlanningState.information,
                    label: Text('Info'),
                  ),
                  ButtonSegment(
                    value: PlanningState.todo,
                    label: Text('To do'),
                  ),
                  ButtonSegment(value: PlanningState.done, label: Text('Done')),
                ],
                selected: {_state},
                onSelectionChanged: (s) => setState(() => _state = s.first),
              ),
            ],
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
      await actions.patchReminder(
        widget.existing!,
        name: _name.text.trim(),
        content: _content.text.trim(),
        isPlanned: _planned,
        begin: _planned ? _begin : null,
        end: _planned ? _end : null,
        state: _state,
      );
    } else {
      await actions.createReminder(
        name: _name.text.trim(),
        content: _content.text.trim(),
        isPlanned: _planned,
        begin: _planned ? _begin : null,
        end: _planned ? _end : null,
        state: _state,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: const Text('This cannot be undone.'),
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
    await ref.read(ticketActionsProvider)?.deleteReminder(widget.existing!);
    if (mounted) Navigator.pop(context);
  }
}

/// GLPI stores reminder bodies as rich text; mobile renders them plain.
