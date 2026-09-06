import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/a11y/contrast.dart';
import '../../../core/api/dto/signal_dto.dart';
import '../../../core/api/errors.dart';
import '../../../core/models/capabilities.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/sync/connectivity.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/accent_pill.dart';
import '../../../core/widgets/accessible_refresh.dart';
import '../../../core/widgets/capability_gate.dart';
import '../../../core/widgets/info_tile.dart';
import '../../../core/widgets/section_heading.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../alert_providers.dart';
import 'alerts_screen.dart';

/// One alert in full: every field the row carries, the page log, and the
/// ack/close actions (capability- and connectivity-gated — see [AlertsScreen]
/// for why there is deliberately no offline outbox here).
class AlertDetailScreen extends ConsumerWidget {
  const AlertDetailScreen({super.key, required this.alertId});

  final int alertId;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(alertDetailProvider(alertId));
    ref.invalidate(alertsProvider);
  }

  Future<void> _act(
    BuildContext context,
    WidgetRef ref, {
    required bool close,
  }) async {
    final api = ref.read(glpiApiProvider);
    if (api == null) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await (close ? api.closeAlert(alertId) : api.ackAlert(alertId));
      messenger.showSnackBar(
        SnackBar(content: Text(close ? l.alertClosed : l.alertAcked)),
      );
    } on GlpiError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
    await _refresh(ref);
  }

  Future<void> _openTicket(
    BuildContext context,
    WidgetRef ref,
    int serverId,
  ) async {
    final tickets = ref.read(ticketRepositoryProvider);
    if (tickets == null) return;
    final localId = await tickets.openByServerId(serverId);
    if (localId == null || !context.mounted) return;
    unawaited(context.push(Routes.ticket(localId)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(alertDetailProvider(alertId));

    return CapabilityGate(
      plugin: Cap.signal,
      feature: Cap.signalAlerts,
      title: l.alertNumber(alertId),
      child: Scaffold(
        appBar: AppBar(title: Text(l.alertNumber(alertId))),
        body: switch (async) {
          AsyncData(value: final d?) => AccessibleRefresh(
            onRefresh: () => _refresh(ref),
            child: _AlertBody(
              detail: d,
              onAck: () => _act(context, ref, close: false),
              onClose: () => _act(context, ref, close: true),
              onOpenTicket: (id) => _openTicket(context, ref, id),
            ),
          ),
          AsyncData() || AsyncError() => Center(child: Text(l.genericError)),
          _ => const Center(
            child: CircularProgressIndicator(semanticsLabel: 'Loading'),
          ),
        },
      ),
    );
  }
}

class _AlertBody extends ConsumerWidget {
  const _AlertBody({
    required this.detail,
    required this.onAck,
    required this.onClose,
    required this.onOpenTicket,
  });

  final AlertDetailDto detail;
  final VoidCallback onAck;
  final VoidCallback onClose;
  final void Function(int serverId) onOpenTicket;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final a = detail.alert;
    final caps = ref.watch(capabilitiesProvider).value ?? Capabilities.empty;
    final online = ref.watch(connectivityProvider).value ?? true;
    final canAck = caps.has(Cap.signal, Cap.signalAck);
    final firstSeen = parseGlpiDateTime(a.firstSeen);
    final lastSeen = parseGlpiDateTime(a.lastSeen);

    return ReadableWidth(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Semantics(
            header: true,
            child: Text(a.name, style: theme.textTheme.titleLarge),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AccentPill(
                label: severityLabel(l, a.severity),
                accent: ensureContrast(
                  severityColor(context, a.severity),
                  theme.colorScheme.surface,
                  minRatio: wcagAaGraphics,
                ),
              ),
              AccentPill(
                label: alertStateLabel(l, a.state),
                accent: a.isOpen
                    ? theme.colorScheme.error
                    : theme.colorScheme.outline,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (canAck && !a.isClosed) ...[
            Row(
              children: [
                if (a.needsAck) ...[
                  FilledButton.icon(
                    onPressed: online ? onAck : null,
                    icon: const Icon(Icons.check),
                    label: Text(l.alertAck),
                  ),
                  const SizedBox(width: 8),
                ],
                OutlinedButton.icon(
                  onPressed: online ? onClose : null,
                  icon: const Icon(Icons.close),
                  label: Text(l.alertClose),
                ),
              ],
            ),
            if (!online)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l.actionNeedsConnection,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
          if (a.host.isNotEmpty)
            InfoTile(
              icon: Icons.dns_outlined,
              label: l.alertHost,
              value: a.host,
            ),
          if (a.itemtype.isNotEmpty && a.itemsId != null)
            InfoTile(
              icon: Icons.devices_other_outlined,
              label: l.alertItem,
              value: '${a.itemtype} #${a.itemsId}',
            ),
          if (a.entityName != null)
            InfoTile(
              icon: Icons.business_outlined,
              label: l.entityLabel,
              value: a.entityName!,
            ),
          InfoTile(
            icon: Icons.numbers,
            label: l.alertEvents,
            value: l.alertEventCount(a.eventCount),
          ),
          if (firstSeen != null)
            InfoTile(
              icon: Icons.schedule,
              label: l.alertFirstSeen,
              value: formatDateTime(firstSeen),
            ),
          if (lastSeen != null)
            InfoTile(
              icon: Icons.update,
              label: l.alertLastSeen,
              value: formatDateTime(lastSeen),
            ),
          if (a.ackUserName != null)
            InfoTile(
              icon: Icons.how_to_reg_outlined,
              label: l.alertStateAcked,
              value: a.ackUserName!,
            ),
          if (a.ticketsId != null)
            InfoTile(
              icon: Icons.confirmation_number_outlined,
              label: l.majorTicket,
              value: '#${a.ticketsId}',
              onTap: () => onOpenTicket(a.ticketsId!),
              semanticsHint: l.alertOpenTicket,
            ),
          const SizedBox(height: 12),
          SectionHeading(l.alertPageLog, count: detail.log.length),
          const SizedBox(height: 4),
          if (detail.log.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                l.alertPageLogEmpty,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            )
          else
            for (final page in detail.log) _PageTile(page: page),
        ],
      ),
    );
  }
}

class _PageTile extends StatelessWidget {
  const _PageTile({required this.page});

  final AlertPageDto page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final when = parseGlpiDateTime(page.date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.campaign_outlined,
            size: 18,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [
                    if (page.target.isNotEmpty) page.target,
                    if (page.status.isNotEmpty) page.status,
                  ].join(' · '),
                  style: theme.textTheme.bodyMedium,
                ),
                if (page.message.isNotEmpty)
                  Text(page.message, style: theme.textTheme.bodySmall),
                if (when != null)
                  Text(
                    formatDateTime(when),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
