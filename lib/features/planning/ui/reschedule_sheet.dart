import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/planning_event.dart';
import '../../../core/providers.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/date_time_field.dart';
import '../../change_calendar/ui/freeze_warning.dart';

/// Move a planned event. Works for any planning type — ITIL tasks, project
/// tasks, reminders and standalone events — and queues the change offline.
class RescheduleSheet extends ConsumerStatefulWidget {
  const RescheduleSheet({super.key, required this.event});

  final PlanningEvent event;

  static Future<void> show(
    BuildContext context, {
    required PlanningEvent event,
  }) => showModalBottomSheet<void>(
    useSafeArea: true,
    context: context,
    constraints: sheetConstraints(context),
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => RescheduleSheet(event: event),
  );

  @override
  ConsumerState<RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends ConsumerState<RescheduleSheet> {
  late DateTime _begin = widget.event.begin;
  late DateTime _end = widget.event.end;
  late int _state = widget.event.state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTask = widget.event.isTask;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text('Reschedule', style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: 4),
          Text(
            widget.event.title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          DateTimeField(
            label: 'Starts',
            value: _begin,
            onChanged: (v) => setState(() {
              // Keep the duration when the start moves.
              final duration = _end.difference(_begin);
              _begin = v;
              _end = v.add(
                duration.isNegative ? const Duration(hours: 1) : duration,
              );
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
          if (isTask) ...[
            const SizedBox(height: 8),
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
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final actions = ref.read(ticketActionsProvider);
    if (actions == null) return;
    final e = widget.event;
    // Reminders and standalone events patch their own record; tasks are
    // rescheduled through their parent object.
    if (e.eventItemtype == 'Reminder' ||
        e.eventItemtype == 'PlanningExternalEvent') {
      await actions.patchPlanningItem(
        e,
        begin: _begin,
        end: _end,
        state: _state,
      );
    } else {
      await actions.planEvent(e, begin: _begin, end: _end, state: _state);
    }
    if (mounted) Navigator.pop(context);
  }
}
