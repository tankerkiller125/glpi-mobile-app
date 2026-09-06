import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/a11y/a11y.dart';
import '../../../core/api/dto/kedb_dto.dart';
import '../../../core/api/errors.dart';
import '../../../core/api/itil_type.dart';
import '../../../core/models/capabilities.dart';
import '../../../core/models/ticket_detail.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/sync/connectivity.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../kedb_providers.dart';

/// The known-error offers on a ticket — the KEDB banner, as a `_DetailBody`
/// section: each match shows its title and snippet with "Use workaround"
/// (records a `used` hit, then stages the snippet into the reply composer)
/// and "Dismiss" (records a `dismissed` hit and hides the card). Renders
/// nothing when the server lacks the capability, the object isn't a synced
/// Ticket, or every offer has been handled — the conditional-section pattern
/// from [AnalysisSection].
///
/// Hits are live writes (no offline outbox): they are bookkeeping about a
/// suggestion the technician just looked at, not ticket content worth
/// queueing.
class KedbBannerSection extends ConsumerWidget {
  const KedbBannerSection({super.key, required this.item});

  final TicketDetail item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (item.itemtype != itilTicket) return const SizedBox.shrink();
    final serverId = item.serverId;
    if (serverId == null) return const SizedBox.shrink();
    final caps = ref.watch(capabilitiesProvider).value ?? Capabilities.empty;
    if (!caps.has(Cap.kedb, Cap.kedbMatch)) return const SizedBox.shrink();

    final matches = ref.watch(kedbMatchesProvider(serverId)).value;
    if (matches == null || matches.isEmpty) return const SizedBox.shrink();
    final handled = ref.watch(kedbHandledProvider(serverId));
    final visible = matches.where((m) => !handled.contains(m.id)).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          for (final m in visible)
            _MatchCard(match: m, item: item, serverId: serverId),
        ],
      ),
    );
  }
}

class _MatchCard extends ConsumerWidget {
  const _MatchCard({
    required this.match,
    required this.item,
    required this.serverId,
  });

  final KedbMatchDto match;
  final TicketDetail item;
  final int serverId;

  Future<void> _use(BuildContext context, WidgetRef ref) async {
    final api = ref.read(glpiApiProvider);
    if (api == null) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await api.kedbRecordHit(
        keId: match.id,
        ticketsId: serverId,
        action: 'used',
      );
      // The server's snippet names the KE; fall back to the match's own
      // workaround text if an older server returns none.
      final snippet = result.snippet ?? match.workaround;
      ref.read(pendingComposerTextProvider.notifier).set(snippet);
      ref.read(kedbHandledProvider(serverId).notifier).hide(match.id);
      messenger.showSnackBar(SnackBar(content: Text(l.kedbWorkaroundInserted)));
    } on GlpiError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _dismiss(
    BuildContext context,
    WidgetRef ref, {
    required bool recordHit,
  }) async {
    // Hide first — the dismissal must not depend on the network round-trip.
    ref.read(kedbHandledProvider(serverId).notifier).hide(match.id);
    announce(context, AppLocalizations.of(context).kedbDismissed);
    if (!recordHit) return;
    final api = ref.read(glpiApiProvider);
    if (api == null) return;
    try {
      await api.kedbRecordHit(
        keId: match.id,
        ticketsId: serverId,
        action: 'dismissed',
      );
    } on GlpiError {
      // The audit row is best-effort; the technician's decision stands.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final caps = ref.watch(capabilitiesProvider).value ?? Capabilities.empty;
    final online = ref.watch(connectivityProvider).value ?? true;
    final canHit = caps.has(Cap.kedb, Cap.kedbHits) && online;
    final snippet = match.snippet;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.push(
            Uri(
              path: Routes.knownError(match.id),
              queryParameters: {'source': item.localId},
            ).toString(),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 18,
                      color: scheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${l.kedbBanner}: ${match.title}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (snippet.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    snippet,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                Row(
                  children: [
                    if (match.hasWorkaround)
                      TextButton.icon(
                        onPressed: canHit ? () => _use(context, ref) : null,
                        icon: const Icon(Icons.healing_outlined, size: 18),
                        label: Text(l.kedbUseWorkaround),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          _dismiss(context, ref, recordHit: canHit),
                      child: Text(l.kedbDismiss),
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
