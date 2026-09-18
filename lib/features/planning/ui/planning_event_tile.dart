import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/a11y/a11y.dart';
import '../../../core/models/planning_event.dart';
import '../../../core/models/rights.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import 'planning_screen.dart';

/// One calendar entry. Mirrors the ticket card's anatomy: a colored type bar,
/// the time range, the title, and the object it belongs to — plus an inline
/// done-checkbox for tasks.
class PlanningEventTile extends ConsumerWidget {
  const PlanningEventTile({
    super.key,
    required this.event,
    this.compact = false,
  });

  final PlanningEvent event;

  /// Week/agenda rows are denser and drop the subtitle.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = event.color(context.glpiColors);

    final rights = ref.watch(rightsProvider).value ?? Rights.empty;
    final canEdit = rights.canEditPlanningEvent(event.eventItemtype);
    final canReschedule = event.eventServerId != null && canEdit;
    // One sentence per entry, and the times spelled out — "09:00–10:30" is read
    // as a single run of digits.
    final spoken = semanticSentence([
      planningTimeRange(event),
      event.title,
      if (event.parentLabel.isNotEmpty) event.parentLabel,
      if (event.isDone) 'done',
      if (event.pending) 'waiting to sync',
    ]);

    return Opacity(
      opacity: event.pending ? 0.55 : 1,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: compact ? 2 : 4),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: color),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(compact ? 8 : 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        // The tap target stops short of the checkbox instead of
                        // wrapping it: nesting a control inside a tappable card
                        // gives the reader two nodes claiming the same pixels.
                        child: Semantics(
                          button: true,
                          label: spoken,
                          onTap: () => openPlanningTarget(context, ref, event),
                          onLongPress: canReschedule
                              ? () => reschedulePlanningEvent(context, event)
                              : null,
                          // Long-press is otherwise an invisible feature: this
                          // is the only way to reschedule an event.
                          onTapHint: 'open',
                          onLongPressHint: canReschedule ? 'reschedule' : null,
                          excludeSemantics: true,
                          child: InkWell(
                            onTap: () =>
                                openPlanningTarget(context, ref, event),
                            onLongPress: canReschedule
                                ? () => reschedulePlanningEvent(context, event)
                                : null,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(event.icon, size: 18, color: color),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            planningTimeRange(event),
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: color,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          if (event.pending) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              'syncing…',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .outline,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        event.title,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              decoration: event.isDone
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                              color: event.isDone
                                                  ? theme.colorScheme.outline
                                                  : null,
                                            ),
                                        maxLines: compact ? 1 : 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (!compact &&
                                          event.parentLabel.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          event.parentLabel,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.outline,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (event.canToggleDone && canEdit)
                        Checkbox(
                          value: event.isDone,
                          visualDensity: VisualDensity.compact,
                          // Otherwise it announces only "checked" — of what?
                          semanticLabel: 'Done: ${event.title}',
                          onChanged: (_) => ref
                              .read(ticketActionsProvider)
                              ?.toggleEventDone(event),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
