import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/dto/major_dto.dart';
import '../../../core/api/errors.dart';
import '../../../core/api/itil_type.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/models/capabilities.dart';
import '../../../core/models/ticket_detail.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/sync/connectivity.dart';
import '../../../core/utils/layout.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../major_providers.dart';
import 'major_screen.dart';

/// The major-incident strip on a ticket: a banner when the ticket is bound to
/// an incident (as its driving ticket or attached to one), or the
/// declare/attach actions when it isn't. Renders nothing when the server lacks
/// the capability, the object isn't a synced Ticket, or there's nothing to
/// show — the conditional-section pattern from [AnalysisSection].
///
/// Declaring and attaching are live writes (no offline outbox): a queued
/// declaration racing the real incident process would be worse than a
/// disabled button.
class MajorBannerSection extends ConsumerWidget {
  const MajorBannerSection({super.key, required this.item});

  final TicketDetail item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (item.itemtype != itilTicket) return const SizedBox.shrink();
    final serverId = item.serverId;
    if (serverId == null) return const SizedBox.shrink();
    final caps = ref.watch(capabilitiesProvider).value ?? Capabilities.empty;
    if (!caps.has(Cap.major, Cap.majorView)) return const SizedBox.shrink();

    final info = ref.watch(majorTicketInfoProvider(serverId)).value;
    if (info == null) return const SizedBox.shrink(); // loading or error

    final bound = info.bound;
    if (bound != null) {
      return _IncidentBanner(incident: bound, attached: info.incident == null);
    }
    if (!caps.has(Cap.major, Cap.majorDeclare)) return const SizedBox.shrink();
    return _DeclareActions(item: item, serverId: serverId, info: info);
  }
}

/// The red strip: this ticket is part of a major incident.
class _IncidentBanner extends StatelessWidget {
  const _IncidentBanner({required this.incident, required this.attached});

  final MajorIncidentDto incident;

  /// True when the ticket is attached to the incident rather than driving it.
  final bool attached;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = attached
        ? '${l.majorAttached}: ${incident.title}'
        : '${l.majorBanner}: ${incident.title}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.push(Routes.majorIncident(incident.id)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: scheme.onErrorContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        majorStateLabel(l, incident.state),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: scheme.onErrorContainer),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// No incident yet: offer to declare one, or attach to an open match.
class _DeclareActions extends ConsumerWidget {
  const _DeclareActions({
    required this.item,
    required this.serverId,
    required this.info,
  });

  final TicketDetail item;
  final int serverId;
  final MajorTicketInfoDto info;

  void _invalidate(WidgetRef ref) {
    ref.invalidate(majorTicketInfoProvider(serverId));
    ref.invalidate(majorIncidentsProvider);
  }

  Future<void> _declare(BuildContext context, WidgetRef ref) async {
    final account = switch (ref.read(authControllerProvider)) {
      Ready(:final account) => account,
      _ => null,
    };
    final api = ref.read(glpiApiProvider);
    if (account == null || api == null) return;
    final result = await _DeclareSheet.show(context, initialTitle: item.name);
    if (result == null || !context.mounted) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final created = await api.declareMajorIncident(
        ticketsId: serverId,
        title: result.title,
        commanderId: account.userId,
        commsId: account.userId,
      );
      // The sheet's optional first update is a comms post of its own — the
      // declare route only takes user ids.
      if (created.id > 0 && result.firstUpdate.isNotEmpty) {
        await api.postMajorUpdate(
          created.id,
          audience: 'internal',
          content: result.firstUpdate,
        );
      }
      messenger.showSnackBar(SnackBar(content: Text(l.majorDeclared)));
      if (created.id > 0) {
        unawaited(router.push(Routes.majorIncident(created.id)));
      }
    } on GlpiError catch (e) {
      // e.g. 409: someone declared one for this ticket first — the refreshed
      // section will show their banner.
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
    _invalidate(ref);
  }

  Future<void> _attach(BuildContext context, WidgetRef ref) async {
    final api = ref.read(glpiApiProvider);
    if (api == null) return;
    final offer = await showModalBottomSheet<MajorAttachOfferDto>(
      useSafeArea: true,
      // Root navigator: from the embedded two-pane detail the nearest
      // navigator is the shell branch, whose barrier misses the rail,
      // bottom bar, and shell FAB (they overlap the sheet on a foldable).
      useRootNavigator: true,
      context: context,
      constraints: sheetConstraints(context),
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final o in info.offerAttach)
              ListTile(
                leading: const Icon(Icons.warning_amber_outlined),
                title: Text(o.title),
                onTap: () => Navigator.pop(context, o),
              ),
          ],
        ),
      ),
    );
    if (offer == null || !context.mounted) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await api.attachTicketToMajor(offer.id, serverId);
      messenger.showSnackBar(SnackBar(content: Text(l.majorAttached)));
    } on GlpiError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
    _invalidate(ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final online = ref.watch(connectivityProvider).value ?? true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: online ? () => _declare(context, ref) : null,
            icon: const Icon(Icons.warning_amber_outlined),
            label: Text(l.majorDeclare),
          ),
          if (info.offerAttach.isNotEmpty)
            OutlinedButton.icon(
              onPressed: online ? () => _attach(context, ref) : null,
              icon: const Icon(Icons.link),
              label: Text(l.majorAttach),
            ),
        ],
      ),
    );
  }
}

typedef _Declaration = ({String title, String firstUpdate});

/// Title (prefilled from the ticket) + optional first status update. The
/// signed-in user becomes the commander.
class _DeclareSheet extends StatefulWidget {
  const _DeclareSheet({required this.initialTitle});

  final String initialTitle;

  static Future<_Declaration?> show(
    BuildContext context, {
    required String initialTitle,
  }) => showModalBottomSheet<_Declaration>(
    useSafeArea: true,
    // Root navigator: from the embedded two-pane detail the nearest
    // navigator is the shell branch, whose barrier misses the rail,
    // bottom bar, and shell FAB (they overlap the sheet on a foldable).
    useRootNavigator: true,
    context: context,
    constraints: sheetConstraints(context),
    isScrollControlled: true,
    builder: (context) => _DeclareSheet(initialTitle: initialTitle),
  );

  @override
  State<_DeclareSheet> createState() => _DeclareSheetState();
}

class _DeclareSheetState extends State<_DeclareSheet> {
  late final _title = TextEditingController(text: widget.initialTitle);
  final _comms = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _comms.dispose();
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
              l.majorDeclare,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              decoration: InputDecoration(
                labelText: l.majorTitleLabel,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _comms,
              minLines: 2,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: l.majorFirstUpdateHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _title.text.trim().isEmpty
                    ? null
                    : () => Navigator.pop(context, (
                        title: _title.text.trim(),
                        firstUpdate: _comms.text.trim(),
                      )),
                child: Text(l.majorDeclare),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
