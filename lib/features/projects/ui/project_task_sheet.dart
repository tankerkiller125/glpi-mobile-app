import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/project.dart';
import '../../../core/providers.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/date_time_field.dart';

/// Create or edit a project task: the fields a technician actually moves —
/// name, notes, percent complete and the planned window.
class ProjectTaskSheet extends ConsumerStatefulWidget {
  const ProjectTaskSheet({
    super.key,
    required this.project,
    this.task,
    this.parentTaskServerId,
  });

  final Project project;

  /// Null creates a new task.
  final ProjectTask? task;
  final int? parentTaskServerId;

  static Future<void> show(
    BuildContext context, {
    required Project project,
    ProjectTask? task,
    int? parentTaskServerId,
  }) => showModalBottomSheet<void>(
    useSafeArea: true,
    context: context,
    constraints: sheetConstraints(context),
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => ProjectTaskSheet(
      project: project,
      task: task,
      parentTaskServerId: parentTaskServerId,
    ),
  );

  @override
  ConsumerState<ProjectTaskSheet> createState() => _ProjectTaskSheetState();
}

class _ProjectTaskSheetState extends ConsumerState<ProjectTaskSheet> {
  late final _name = TextEditingController(text: widget.task?.name ?? '');
  late final _content = TextEditingController(text: widget.task?.content ?? '');
  late int _percent = widget.task?.percentDone ?? 0;
  late DateTime? _start = widget.task?.planStartDate;
  late DateTime? _end = widget.task?.planEndDate;

  bool get _isEdit => widget.task != null;

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
            Semantics(
              header: true,
              child: Text(
                _isEdit ? 'Edit task' : 'New task',
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              autofocus: !_isEdit,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _content,
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            // Percent complete, stepped in 10s — precise enough on a phone.
            Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text(
                    'Progress',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Decrease progress',
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _percent <= 0
                      ? null
                      : () => setState(() => _percent -= 10),
                ),
                // The number between the two buttons is the value they change;
                // read alone it is a stray "40%".
                Semantics(
                  label: 'Progress',
                  value: '$_percent percent',
                  child: ExcludeSemantics(
                    child: Text(
                      '$_percent%',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Increase progress',
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _percent >= 100
                      ? null
                      : () => setState(() => _percent += 10),
                ),
              ],
            ),
            DateTimeField(
              label: 'Starts',
              value: _start,
              onChanged: (v) => setState(() => _start = v),
            ),
            DateTimeField(
              label: 'Ends',
              value: _end,
              onChanged: (v) => setState(() => _end = v),
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
      await actions.patchProjectTask(
        widget.task!,
        name: _name.text.trim(),
        content: _content.text.trim(),
        percentDone: _percent,
        planStart: _start,
        planEnd: _end,
      );
    } else {
      await actions.createProjectTask(
        widget.project,
        name: _name.text.trim(),
        content: _content.text.trim(),
        parentTaskServerId: widget.parentTaskServerId,
        percentDone: _percent,
        planStart: _start,
        planEnd: _end,
      );
    }
    if (mounted) Navigator.pop(context);
  }
}
