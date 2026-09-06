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
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/accent_pill.dart';
import '../../../core/widgets/accessible_refresh.dart';
import '../../../core/widgets/capability_gate.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../alert_providers.dart';

/// The word for a severity, localized.
String severityLabel(AppLocalizations l, AlertSeverity s) => switch (s) {
  AlertSeverity.critical => l.severityCritical,
  AlertSeverity.high => l.severityHigh,
  AlertSeverity.medium => l.severityMedium,
  AlertSeverity.low => l.severityLow,
  AlertSeverity.info => l.severityInfo,
};

/// Severity reuses the priority scale's colors — same meaning, same palette.
Color severityColor(BuildContext context, AlertSeverity s) =>
    context.glpiColors.priorityColor(switch (s) {
      AlertSeverity.critical => 5,
      AlertSeverity.high => 4,
      AlertSeverity.medium => 3,
      AlertSeverity.low => 2,
      AlertSeverity.info => 1,
    });

/// The word for an alert state, localized.
String alertStateLabel(AppLocalizations l, String state) => switch (state) {
  'acked' => l.alertStateAcked,
  'ticketed' => l.alertStateTicketed,
  'suppressed' => l.alertStateSuppressed,
  'closed' => l.alertStateClosed,
  _ => l.alertStateOpen,
};

/// Monitoring alerts from the glpi-signal plugin: the on-call card, severity
/// and state filters, and the live alert list with swipe-to-acknowledge.
///
/// Read-through only, on purpose: acks and closes race escalation timers, so
/// there is no offline outbox for them — offline, the actions disable with a
/// message rather than queueing a late ack that lies about who responded.
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(oncallProvider);
    ref.invalidate(alertsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return CapabilityGate(
      plugin: Cap.signal,
      feature: Cap.signalAlerts,
      title: l.alertsTitle,
      child: Scaffold(
        appBar: AppBar(title: Text(l.alertsTitle)),
        body: AccessibleRefresh(
          onRefresh: () => _refresh(ref),
          child: _AlertList(onRefresh: () => _refresh(ref)),
        ),
      ),
    );
  }
}

class _AlertList extends ConsumerWidget {
  const _AlertList({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final caps = ref.watch(capabilitiesProvider).value ?? Capabilities.empty;
    final online = ref.watch(connectivityProvider).value ?? true;
    final canAck = caps.has(Cap.signal, Cap.signalAck) && online;
    final filter = ref.watch(alertFilterProvider);
    final alerts = ref.watch(alertsProvider);

    // A 1280dp alert row strands the state pill a screen-width from the
    // title; cap the measure like every other long-form surface.
    return ReadableWidth(
      child: ListView(
        // Short lists must stay pullable for refresh.
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (caps.has(Cap.signal, Cap.signalOncall)) const _OncallCard(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (state, label) in [
                  ('open', l.alertStateOpen),
                  ('acked', l.alertStateAcked),
                  ('ticketed', l.alertStateTicketed),
                  ('suppressed', l.alertStateSuppressed),
                  ('closed', l.alertStateClosed),
                ])
                  FilterChip(
                    label: Text(label),
                    selected: filter.states.contains(state),
                    onSelected: (_) => ref
                        .read(alertFilterProvider.notifier)
                        .toggleState(state),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in AlertSeverity.values)
                  FilterChip(
                    avatar: Icon(
                      Icons.circle,
                      size: 12,
                      color: ensureContrast(
                        severityColor(context, s),
                        theme.colorScheme.surface,
                        minRatio: wcagAaGraphics,
                      ),
                    ),
                    label: Text(severityLabel(l, s)),
                    selected: filter.severity == s,
                    onSelected: (_) =>
                        ref.read(alertFilterProvider.notifier).setSeverity(s),
                  ),
              ],
            ),
          ),
          switch (alerts) {
            AsyncData(:final value) when value.isEmpty => Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  l.alertsEmpty,
                  style: TextStyle(color: theme.colorScheme.outline),
                ),
              ),
            ),
            AsyncData(:final value) => Column(
              children: [
                for (final a in value)
                  _AlertTile(alert: a, canAck: canAck, onRefresh: onRefresh),
              ],
            ),
            // Alerts are read-through (no cache, by design): offline, say so
            // instead of a generic failure.
            AsyncError(:final error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  error is GlpiNetworkError
                      ? l.alertsNeedConnection
                      : l.genericError,
                ),
              ),
            ),
            _ => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(semanticsLabel: 'Loading'),
              ),
            ),
          },
        ],
      ),
    );
  }
}

class _AlertTile extends ConsumerWidget {
  const _AlertTile({
    required this.alert,
    required this.canAck,
    required this.onRefresh,
  });

  final AlertDto alert;
  final bool canAck;
  final Future<void> Function() onRefresh;

  Future<void> _ack(BuildContext context, WidgetRef ref) async {
    final api = ref.read(glpiApiProvider);
    if (api == null) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await api.ackAlert(alert.id);
      messenger.showSnackBar(SnackBar(content: Text(l.alertAcked)));
    } on GlpiError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
    await onRefresh();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final lastSeen = parseGlpiDateTime(alert.lastSeen);
    final color = ensureContrast(
      severityColor(context, alert.severity),
      theme.colorScheme.surface,
      minRatio: wcagAaGraphics,
    );

    final tile = ListTile(
      leading: Semantics(
        label: severityLabel(l, alert.severity),
        excludeSemantics: true,
        child: Icon(Icons.circle, size: 12, color: color),
      ),
      title: Text(alert.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          if (alert.host.isNotEmpty) alert.host,
          if (lastSeen != null) relativeAge(lastSeen),
          l.alertEventCount(alert.eventCount),
          if (alert.ackUserName != null) l.alertAckedBy(alert.ackUserName!),
        ].join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: AccentPill(
        label: alertStateLabel(l, alert.state),
        accent: alert.isOpen
            ? theme.colorScheme.error
            : theme.colorScheme.outline,
      ),
      onTap: () => context.push(Routes.alert(alert.id)),
    );

    if (!alert.needsAck || !canAck) return tile;
    return Dismissible(
      key: ValueKey('alert-${alert.id}'),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: theme.colorScheme.primaryContainer,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(width: 8),
            Text(
              l.alertAck,
              style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
            ),
          ],
        ),
      ),
      // Never actually dismiss: the ack lands, then the refreshed list moves
      // the row to its new state instead of a local remove guessing at it.
      confirmDismiss: (_) async {
        await _ack(context, ref);
        return false;
      },
      child: tile,
    );
  }
}

/// Who holds the pager: one row per rota, with the signed-in user's own duty
/// highlighted and the next handoff named.
class _OncallCard extends ConsumerWidget {
  const _OncallCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final rotas = ref.watch(oncallProvider).value ?? const [];
    if (rotas.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(l.oncallTitle, style: theme.textTheme.labelLarge),
            ),
            const SizedBox(height: 4),
            for (final rota in rotas) _RotaRow(rota: rota),
          ],
        ),
      ),
    );
  }
}

class _RotaRow extends StatelessWidget {
  const _RotaRow({required this.rota});

  final OncallRotaDto rota;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final handoff = parseGlpiDateTime(rota.nextHandoff);
    final who = rota.amIOnCall
        ? l.oncallYou
        : (rota.oncallUserName ?? l.oncallNobody);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            rota.amIOnCall ? Icons.notifications_active : Icons.phone_in_talk,
            size: 20,
            color: rota.amIOnCall
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rota.name, style: theme.textTheme.bodySmall),
                Text(
                  who,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: rota.amIOnCall ? FontWeight.w600 : null,
                    color: rota.amIOnCall ? theme.colorScheme.primary : null,
                  ),
                ),
                if (rota.nextUserName != null && handoff != null)
                  Text(
                    l.oncallHandoff(
                      rota.nextUserName!,
                      formatDateTime(handoff),
                    ),
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
