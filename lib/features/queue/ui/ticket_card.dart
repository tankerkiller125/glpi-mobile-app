import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/a11y/a11y.dart';
import '../../../core/a11y/contrast.dart';
import '../../../core/api/itil_type.dart';
import '../../../core/models/ticket_list_item.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/widgets/due_badge.dart';
import '../../../core/widgets/status_chip.dart';

class TicketCard extends ConsumerWidget {
  const TicketCard({
    super.key,
    required this.ticket,
    this.onTap,
    this.selected = false,
  });

  final TicketListItem ticket;
  final VoidCallback? onTap;

  /// Highlighted when it is the ticket shown in the detail pane beside it.
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // The 4px edge is the card's only status signal until you read the chip, so
    // it has to clear the 3:1 bar for meaningful graphics against the card.
    final statusColor = ensureContrast(
      context.glpiColors.statusColor(ticket.status),
      selected
          ? theme.colorScheme.secondaryContainer
          : theme.colorScheme.surfaceContainerLow,
      minRatio: wcagAaGraphics,
    );
    final pending =
        ref.watch(ticketPendingCountProvider(ticket.localId)).value ?? 0;
    // Surface the SLA only when it's at risk (inside the 4h warn window or
    // overdue) so the queue flags urgency without cluttering every card.
    final due = ticket.timeToResolve;
    final dueRemaining = due?.difference(DateTime.now());
    final showDue =
        ticket.isOpen &&
        dueRemaining != null &&
        dueRemaining <= const Duration(hours: 4);
    final subtitleParts = [
      if (ticket.requesterName != null && ticket.requesterName!.isNotEmpty)
        ticket.requesterName!,
      if (ticket.entityName != null && ticket.entityName!.isNotEmpty)
        ticket.entityName!,
      if (ticket.categoryName != null && ticket.categoryName!.isNotEmpty)
        ticket.categoryName!,
    ];

    // One node per card. Read as fragments a queue is a maze: an unlabelled
    // dot, a bare number, "New", "4h". Read as a sentence it is a triage list.
    final spoken = semanticSentence([
      ticket.serverId == null
          ? '${itilLabel(ticket.itemtype)}, not yet sent'
          : '${itilLabel(ticket.itemtype)} ${ticket.serverId}',
      ticket.name,
      'Priority ${priorityLabel(ticket.priority)}',
      'Status ${statusLabel(ticket.status, itemtype: ticket.itemtype)}',
      if (subtitleParts.isNotEmpty) subtitleParts.join(', '),
      if (showDue) spokenDueRelative(due),
      if (pending > 0)
        pending == 1
            ? '1 change waiting to sync'
            : '$pending changes waiting to sync',
      if (ticket.dateMod != null) 'updated ${spokenAge(ticket.dateMod)}',
    ]);

    return Semantics(
      container: true,
      button: onTap != null,
      selected: selected,
      label: spoken,
      // Hiding the children hides the InkWell's tap action with them, so the
      // action has to live on this node.
      onTap: onTap,
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        color: selected ? theme.colorScheme.secondaryContainer : null,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: statusColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PriorityDot(priority: ticket.priority),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ticket.serverId == null
                                    ? ticket.name
                                    : '#${ticket.serverId}  ${ticket.name}',
                                style: theme.textTheme.titleSmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (subtitleParts.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitleParts.join(' · '),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            StatusChip(
                              status: ticket.status,
                              itemtype: ticket.itemtype,
                            ),
                            if (pending > 0) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 15,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                            if (showDue) ...[
                              const SizedBox(width: 8),
                              DueBadge(
                                text: formatDueRelative(due),
                                color: context.glpiColors.slaColor(
                                  dueRemaining,
                                ),
                              ),
                            ],
                            const Spacer(),
                            Text(
                              relativeAge(ticket.dateMod),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
