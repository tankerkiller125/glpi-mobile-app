import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/dto/presence_dto.dart';
import '../../../core/api/itil_type.dart';
import '../../../core/models/capabilities.dart';
import '../../../core/models/ticket_detail.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../presence_providers.dart';

/// Who else is on this ticket, and who has picked the work up.
///
/// The question a technician has the moment they open a ticket, and it matters
/// more on a phone than at a desk: the person out at a site is the least likely
/// to know what the office already started, and the most likely to duplicate
/// it.
///
/// Renders nothing at all when the server has no presence plugin, when the
/// object is not synced yet, or when nobody else is here and nobody holds the
/// claim — a bar that says "only you" on every ticket is a bar people stop
/// reading.
class PresenceBar extends ConsumerWidget {
  const PresenceBar({super.key, required this.item});

  final TicketDetail item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverId = item.serverId;
    if (serverId == null) return const SizedBox.shrink();
    // Ticket, Change and Problem — the three the plugin watches by default.
    if (!itilTypes.contains(item.itemtype)) return const SizedBox.shrink();

    final caps = ref.watch(capabilitiesProvider).value ?? Capabilities.empty;
    if (!caps.has(Cap.presence, Cap.presenceView)) {
      return const SizedBox.shrink();
    }

    final target = (itemtype: item.itemtype, itemsId: serverId);
    final state = ref.watch(presenceControllerProvider(target));
    final others = state.others;

    if (others.isEmpty && state.claim == null) return const SizedBox.shrink();

    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = ref.read(presenceControllerProvider(target).notifier);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _who(l, state, others),
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (state.claim != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.pan_tool_alt_outlined,
                      size: 16,
                      color: state.claimedByYou
                          ? theme.colorScheme.primary
                          : theme.colorScheme.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.claimedByYou
                            ? l.presenceClaimedByYou
                            : l.presenceClaimedBy(state.claim!.name),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
              if (state.canClaim &&
                  caps.has(Cap.presence, Cap.presenceClaim)) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _ClaimButton(
                    state: state,
                    onClaim: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final taken = state.claimedByOther;
                      final ok = await controller.claim(takeover: taken);
                      if (!ok) {
                        messenger.showSnackBar(
                          SnackBar(content: Text(l.presenceClaimTaken)),
                        );
                      }
                    },
                    onRelease: controller.release,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// "Sam is typing…" beats "2 people here" — it is the one line that changes
  /// what the reader does next.
  String _who(
    AppLocalizations l,
    PresenceStateDto state,
    List<PresenceParticipantDto> others,
  ) {
    for (final p in others) {
      if (p.typing) return l.presenceTyping(p.name);
    }
    if (others.isEmpty) return l.presenceOnlyYou;
    return others.map((p) => p.name).join(', ');
  }
}

class _ClaimButton extends StatelessWidget {
  const _ClaimButton({
    required this.state,
    required this.onClaim,
    required this.onRelease,
  });

  final PresenceStateDto state;
  final Future<void> Function() onClaim;
  final Future<void> Function() onRelease;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    if (state.claimedByYou) {
      return TextButton.icon(
        onPressed: () => onRelease(),
        icon: const Icon(Icons.undo, size: 18),
        label: Text(l.presenceRelease),
      );
    }

    return TextButton.icon(
      onPressed: () => onClaim(),
      icon: const Icon(Icons.pan_tool_alt_outlined, size: 18),
      // Taking over somebody else's claim is a different act from picking up
      // an unclaimed ticket, and the button says which one it is.
      label: Text(state.claimedByOther ? l.presenceTakeover : l.presenceClaim),
    );
  }
}
