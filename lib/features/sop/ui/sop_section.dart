import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/dto/sop_dto.dart';
import '../../../core/api/itil_type.dart';
import '../../../core/models/capabilities.dart';
import '../../../core/models/ticket_detail.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../sop_providers.dart';

/// The procedures attached to a ticket, as a `_DetailBody` section.
///
/// Renders nothing when the server has no SOP plugin and nothing when the
/// ticket has no procedure — the conditional-section pattern the other plugin
/// surfaces use. An enforcing run with outstanding steps is called out, because
/// it is the reason the ticket will refuse to be solved.
class SopSection extends ConsumerWidget {
  const SopSection({super.key, required this.item});

  final TicketDetail item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverId = item.serverId;
    if (serverId == null) return const SizedBox.shrink();
    if (!itilTypes.contains(item.itemtype)) return const SizedBox.shrink();

    final caps = ref.watch(capabilitiesProvider).value ?? Capabilities.empty;
    if (!caps.has(Cap.sop, Cap.sopRuns)) return const SizedBox.shrink();

    final target = (itemtype: item.itemtype, itemsId: serverId);
    final runs = ref.watch(sopRunsProvider(target)).value ?? const [];
    if (runs.isEmpty) return const SizedBox.shrink();

    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeadingRow(title: l.sopSectionTitle, count: runs.length),
        for (final run in runs) SopRunTile(run: run),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// A heading that matches the ticket screen's other sections without pulling
/// the whole detail file in.
class SectionHeadingRow extends StatelessWidget {
  const SectionHeadingRow({
    super.key,
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Semantics(
        header: true,
        child: Text(
          count > 0 ? '$title ($count)' : title,
          style: theme.textTheme.titleSmall,
        ),
      ),
    );
  }
}

/// One procedure: name, progress, and what it is still waiting for.
class SopRunTile extends StatelessWidget {
  const SopRunTile({super.key, required this.run});

  final SopRunDto run;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final blocking = run.enforcing && run.outstanding > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push(Routes.sopRun(run.id)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    run.isComplete
                        ? Icons.checklist_rtl
                        : Icons.checklist_outlined,
                    size: 18,
                    color: run.isAbandoned
                        ? theme.colorScheme.outline
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      run.name,
                      style: theme.textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    l.sopProgress(run.done, run.total),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: run.fraction,
                  minHeight: 6,
                  // A run nobody may edit reads as information, not as work.
                  color: run.isAbandoned
                      ? theme.colorScheme.outline
                      : (blocking
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                run.isAbandoned
                    ? run.statusLabel
                    : l.sopOutstanding(run.outstanding),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              if (blocking) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.block, size: 14, color: theme.colorScheme.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l.sopBlocking,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
