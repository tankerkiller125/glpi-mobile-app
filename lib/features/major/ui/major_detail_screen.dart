import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/dto/major_dto.dart';
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
import '../../../core/widgets/date_time_field.dart';
import '../../../core/widgets/info_tile.dart';
import '../../../core/widgets/rich_content.dart';
import '../../../core/widgets/section_heading.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../major_providers.dart';
import 'major_screen.dart';

/// GLPI stores timestamps as local `YYYY-MM-DD HH:MM:SS`.
String _wire(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')} '
    '${d.hour.toString().padLeft(2, '0')}:'
    '${d.minute.toString().padLeft(2, '0')}:00';

/// One major incident: the record, its comms log labeled by audience, the
/// post-update composer and the resolve action (both gated on
/// `glpimajor.publish` and on being online — comms are live writes, never
/// queued).
class MajorDetailScreen extends ConsumerWidget {
  const MajorDetailScreen({super.key, required this.incidentId});

  final int incidentId;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(majorIncidentDetailProvider(incidentId));
    ref.invalidate(majorIncidentsProvider);
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

  Future<void> _postUpdate(BuildContext context, WidgetRef ref) async {
    final result = await _PostUpdateSheet.show(context);
    if (result == null) return;
    final api = ref.read(glpiApiProvider);
    if (api == null || !context.mounted) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await api.postMajorUpdate(
        incidentId,
        audience: result.audience,
        content: result.content,
      );
      if (result.nextUpdateAt != null) {
        await api.patchMajorIncident(incidentId, {
          'next_update_at': _wire(result.nextUpdateAt!),
        });
      }
      messenger.showSnackBar(SnackBar(content: Text(l.majorUpdatePosted)));
    } on GlpiError catch (e) {
      // 400 for blank content, 422 for a state the server refuses — the
      // server's message says which.
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
    await _refresh(ref);
  }

  Future<void> _resolve(BuildContext context, WidgetRef ref) async {
    final api = ref.read(glpiApiProvider);
    if (api == null) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await api.patchMajorIncident(incidentId, {'state': 'resolved'});
      messenger.showSnackBar(SnackBar(content: Text(l.majorResolved)));
    } on GlpiValidationError {
      // A PIR-required incident refuses to resolve without an outcome (422);
      // surface the server's message and ask for one.
      if (!context.mounted) return;
      // The wire answer is a terse code (`state_refused`); tell the user what
      // is actually needed in their language instead.
      final outcome = await _promptOutcome(context, l.majorOutcomeNeeded);
      if (outcome != null && outcome.trim().isNotEmpty) {
        try {
          await api.patchMajorIncident(incidentId, {
            'state': 'resolved',
            'outcome': outcome.trim(),
          });
          messenger.showSnackBar(SnackBar(content: Text(l.majorResolved)));
        } on GlpiError catch (e2) {
          messenger.showSnackBar(SnackBar(content: Text(e2.message)));
        }
      }
    } on GlpiError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
    await _refresh(ref);
  }

  Future<String?> _promptOutcome(BuildContext context, String reason) {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.majorResolve),
        // Scrollable: with the soft keyboard up a fixed column overflows on
        // phone-height screens.
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reason),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 3,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l.majorResolve),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(majorIncidentDetailProvider(incidentId));

    return CapabilityGate(
      plugin: Cap.major,
      feature: Cap.majorView,
      title: l.majorNumber(incidentId),
      child: Scaffold(
        appBar: AppBar(title: Text(l.majorNumber(incidentId))),
        body: switch (async) {
          AsyncData(value: final d?) => AccessibleRefresh(
            onRefresh: () => _refresh(ref),
            child: _IncidentBody(
              detail: d,
              onPostUpdate: () => _postUpdate(context, ref),
              onResolve: () => _resolve(context, ref),
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

class _IncidentBody extends ConsumerWidget {
  const _IncidentBody({
    required this.detail,
    required this.onPostUpdate,
    required this.onResolve,
    required this.onOpenTicket,
  });

  final MajorIncidentDetailDto detail;
  final VoidCallback onPostUpdate;
  final VoidCallback onResolve;
  final void Function(int serverId) onOpenTicket;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final i = detail.incident;
    final caps = ref.watch(capabilitiesProvider).value ?? Capabilities.empty;
    final online = ref.watch(connectivityProvider).value ?? true;
    final canPublish = caps.has(Cap.major, Cap.majorPublish);
    final declared = parseGlpiDateTime(i.declaredAt);
    final nextUpdate = parseGlpiDateTime(i.nextUpdateAt);

    return ReadableWidth(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Semantics(
            header: true,
            child: Text(i.title, style: theme.textTheme.titleLarge),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AccentPill(
                label: majorStateLabel(l, i.state),
                accent: i.isOpen
                    ? theme.colorScheme.error
                    : theme.colorScheme.outline,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (canPublish && i.isOpen) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: online ? onPostUpdate : null,
                  icon: const Icon(Icons.campaign_outlined),
                  label: Text(l.majorPostUpdate),
                ),
                OutlinedButton.icon(
                  onPressed: online ? onResolve : null,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(l.majorResolve),
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
          if (i.commanderName != null)
            InfoTile(
              icon: Icons.support_agent,
              label: l.majorCommander,
              value: i.commanderName!,
            ),
          if (i.ticketsId != null)
            InfoTile(
              icon: Icons.confirmation_number_outlined,
              label: l.majorTicket,
              value: '#${i.ticketsId}',
              onTap: () => onOpenTicket(i.ticketsId!),
            ),
          if (i.entityName != null)
            InfoTile(
              icon: Icons.business_outlined,
              label: l.entityLabel,
              value: i.entityName!,
            ),
          if (declared != null)
            InfoTile(
              icon: Icons.schedule,
              label: l.majorDeclaredAt,
              value: formatDateTime(declared),
            ),
          if (nextUpdate != null)
            InfoTile(
              icon: Icons.alarm,
              label: l.majorNextUpdate,
              value: i.isOpen
                  ? '${formatDateTime(nextUpdate)} '
                        '(${formatDueRelative(nextUpdate)})'
                  : formatDateTime(nextUpdate),
            ),
          const SizedBox(height: 12),
          SectionHeading(l.majorUpdates, count: detail.updates.length),
          const SizedBox(height: 4),
          if (detail.updates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                l.majorUpdatesEmpty,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            )
          else
            for (final u in detail.updates) _UpdateTile(update: u),
        ],
      ),
    );
  }
}

/// One comms update, labeled with its audience so internal notes are never
/// mistaken for something the public saw.
class _UpdateTile extends StatelessWidget {
  const _UpdateTile({required this.update});

  final MajorUpdateDto update;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final when = parseGlpiDateTime(update.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AccentPill(
                  label: update.isCustomer
                      ? l.majorAudienceCustomer
                      : l.majorAudienceInternal,
                  accent: update.isCustomer
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.outline,
                ),
                if (update.author.isNotEmpty)
                  Text(update.author, style: theme.textTheme.bodySmall),
                if (when != null)
                  Text(
                    formatDateTime(when),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            RichContent(update.content, selectable: false),
          ],
        ),
      ),
    );
  }
}

/// What the composer hands back.
typedef _PostedUpdate = ({
  String audience,
  String content,
  DateTime? nextUpdateAt,
});

/// The post-update composer: audience selector, the update text, and the
/// promised next-update time.
class _PostUpdateSheet extends StatefulWidget {
  const _PostUpdateSheet();

  static Future<_PostedUpdate?> show(BuildContext context) =>
      showModalBottomSheet<_PostedUpdate>(
        useSafeArea: true,
        // Root navigator: from the embedded two-pane detail the nearest
        // navigator is the shell branch, whose barrier misses the rail,
        // bottom bar, and shell FAB (they overlap the sheet on a foldable).
        useRootNavigator: true,
        context: context,
        constraints: sheetConstraints(context),
        isScrollControlled: true,
        builder: (context) => const _PostUpdateSheet(),
      );

  @override
  State<_PostUpdateSheet> createState() => _PostUpdateSheetState();
}

class _PostUpdateSheetState extends State<_PostUpdateSheet> {
  final _content = TextEditingController();
  String _audience = 'internal';
  DateTime? _nextUpdateAt;

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.majorPostUpdate,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'internal',
                  label: Text(l.majorAudienceInternal),
                  icon: const Icon(Icons.lock_outline),
                ),
                ButtonSegment(
                  value: 'customer',
                  label: Text(l.majorAudienceCustomer),
                  icon: const Icon(Icons.public),
                ),
              ],
              selected: {_audience},
              onSelectionChanged: (s) => setState(() => _audience = s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _content,
              autofocus: true,
              minLines: 3,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: l.majorUpdateHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            DateTimeField(
              label: l.majorNextUpdate,
              value: _nextUpdateAt,
              onChanged: (v) => setState(() => _nextUpdateAt = v),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                // The server 400s blank content; don't offer to send it.
                onPressed: _content.text.trim().isEmpty
                    ? null
                    : () => Navigator.pop(context, (
                        audience: _audience,
                        content: _content.text.trim(),
                        nextUpdateAt: _nextUpdateAt,
                      )),
                child: Text(l.majorPostUpdate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
