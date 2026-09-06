import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/dto/ai_dto.dart';
import '../../../core/api/errors.dart';
import '../../../core/api/itil_type.dart';
import '../../../core/models/capabilities.dart';
import '../../../core/models/ticket_detail.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/rich_content.dart';
import '../../../core/widgets/section_heading.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../assistant_providers.dart';

/// What glpi-ai offers on a ticket: ask the assistant about it, act on the
/// triage it proposed, and read the solution it drafted.
///
/// Every part is capability-gated and renders nothing when the server has not
/// got it — the conditional-section pattern the other plugin surfaces use.
/// Nothing here happens on its own: drafting and triage both spend money at a
/// provider, so both are buttons.
class AiTicketSection extends ConsumerWidget {
  const AiTicketSection({super.key, required this.item});

  final TicketDetail item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverId = item.serverId;
    if (serverId == null) return const SizedBox.shrink();

    final caps = ref.watch(capabilitiesProvider).value ?? Capabilities.empty;
    final assistant = caps.has(Cap.ai, Cap.aiAssistant);
    // Drafting and triage are ticket-shaped: the server refuses them for a
    // change or a problem, so the app does not offer them there.
    final isTicket = item.itemtype == itilTicket;
    final triage = isTicket && caps.has(Cap.ai, Cap.aiTriage);
    final draft = isTicket && caps.has(Cap.ai, Cap.aiDraft);

    if (!assistant && !triage && !draft) return const SizedBox.shrink();

    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(l.aiTitle),
        const SizedBox(height: 4),
        if (assistant)
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () =>
                  context.push(Routes.assistantOn(item.itemtype, serverId)),
              icon: const Icon(Icons.auto_awesome_outlined, size: 18),
              label: Text(l.assistantOnTicket),
            ),
          ),
        if (triage) _TriageCard(ticketsId: serverId),
        if (draft) _DraftCard(ticketsId: serverId),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// The triage suggestion, as chips a technician accepts or rejects one at a
/// time. A proposal the ticket already matches is not shown — agreeing with
/// the current value is not a decision worth a button.
class _TriageCard extends ConsumerStatefulWidget {
  const _TriageCard({required this.ticketsId});

  final int ticketsId;

  @override
  ConsumerState<_TriageCard> createState() => _TriageCardState();
}

class _TriageCardState extends ConsumerState<_TriageCard> {
  bool _busy = false;

  Future<void> _run(Future<AiTriageStateDto> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      // Applying writes the ticket, so the screen behind this needs re-reading
      // as well as the suggestion itself.
      ref.invalidate(aiTriageProvider(widget.ticketsId));
    } on GlpiError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final api = ref.watch(glpiApiProvider);
    final state = ref.watch(aiTriageProvider(widget.ticketsId)).value;
    if (state == null || api == null) return const SizedBox.shrink();

    final suggestion = state.suggestion;
    final open = suggestion?.open ?? const <AiTriageFieldDto>[];

    // Nothing suggested and nothing to run: say nothing.
    if (suggestion == null && !state.canApply) return const SizedBox.shrink();
    if (suggestion != null && suggestion.isReady && open.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.aiTriageTitle, style: theme.textTheme.titleSmall),
            if (suggestion != null && suggestion.reasoning.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                suggestion.reasoning,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
            if (open.isEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _busy || !state.canApply
                      ? null
                      : () => _run(() => api.runAiTriage(widget.ticketsId)),
                  icon: _busy
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow, size: 18),
                  label: Text(_busy ? l.aiTriageRunning : l.aiTriageRun),
                ),
              )
            else
              for (final field in open)
                _TriageRow(
                  field: field,
                  busy: _busy,
                  canApply: state.canApply,
                  onApply: () => _run(
                    () => api.decideAiTriage(
                      suggestion!.id,
                      'apply',
                      field.field,
                    ),
                  ),
                  onDismiss: () => _run(
                    () => api.decideAiTriage(
                      suggestion!.id,
                      'dismiss',
                      field.field,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _TriageRow extends StatelessWidget {
  const _TriageRow({
    required this.field,
    required this.busy,
    required this.canApply,
    required this.onApply,
    required this.onDismiss,
  });

  final AiTriageFieldDto field;
  final bool busy;
  final bool canApply;
  final VoidCallback onApply;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final name = switch (field.field) {
      'itilcategories_id' => l.aiFieldCategory,
      'urgency' => l.aiFieldUrgency,
      'impact' => l.aiFieldImpact,
      'plugin_glpisop_sops_id' => l.aiFieldProcedure,
      _ => field.field,
    };

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name: ${field.label}',
                  style: theme.textTheme.bodyMedium,
                ),
                // What it is now, so "Category: Email" is a comparison rather
                // than an assertion.
                if (field.currentLabel.isNotEmpty)
                  Text(
                    field.currentLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: busy ? null : onDismiss,
            child: Text(l.aiTriageDismiss),
          ),
          FilledButton.tonal(
            onPressed: busy || !canApply ? null : onApply,
            child: Text(l.aiTriageApply),
          ),
        ],
      ),
    );
  }
}

/// The drafted solution: ask for one, read it, and move it into the reply box
/// or throw it away. Nothing is written to the ticket by this card — a draft
/// becomes an answer only when a person sends it.
class _DraftCard extends ConsumerStatefulWidget {
  const _DraftCard({required this.ticketsId});

  final int ticketsId;

  @override
  ConsumerState<_DraftCard> createState() => _DraftCardState();
}

class _DraftCardState extends ConsumerState<_DraftCard> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      ref.invalidate(aiDraftProvider(widget.ticketsId));
    } on GlpiError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final api = ref.watch(glpiApiProvider);
    final state = ref.watch(aiDraftProvider(widget.ticketsId)).value;
    if (state == null || api == null || !state.available) {
      return const SizedBox.shrink();
    }

    final draft = state.draft;
    final ready = draft != null && draft.isReady && !draft.isDecided;

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.aiDraftTitle,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                if (ready && draft.confidence.isNotEmpty)
                  Text(
                    l.aiConfidence(draft.confidence),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
              ],
            ),
            if (!ready)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _run(() => api.makeAiDraft(widget.ticketsId)),
                  icon: _busy
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.edit_note, size: 18),
                  label: Text(
                    _busy
                        ? l.aiDrafting
                        : (draft == null ? l.aiDraftSolution : l.aiDraftRedo),
                  ),
                ),
              )
            else ...[
              const SizedBox(height: 6),
              // The draft's own words, rendered from the server's markdown.
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: SingleChildScrollView(
                  child: RichContent(draft.contentHtmlOrText),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l.aiDraftUnread,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () {
                            final messenger = ScaffoldMessenger.of(context);
                            unawaited(
                              _run(() async {
                                await api.decideAiDraft(draft.id, 'discard');
                                messenger.showSnackBar(
                                  SnackBar(content: Text(l.aiDraftDiscarded)),
                                );
                              }),
                            );
                          },
                    child: Text(l.aiDraftDiscard),
                  ),
                  FilledButton.tonal(
                    onPressed: _busy
                        ? null
                        : () {
                            final messenger = ScaffoldMessenger.of(context);
                            unawaited(
                              _run(() async {
                                // Staged into the composer rather than sent: the
                                // technician is the author, and the draft has to
                                // pass under their eyes on the way.
                                ref
                                    .read(pendingComposerTextProvider.notifier)
                                    .set(draft.content);
                                await api.decideAiDraft(draft.id, 'used');
                                messenger.showSnackBar(
                                  SnackBar(content: Text(l.aiDraftInserted)),
                                );
                              }),
                            );
                          },
                    child: Text(l.aiDraftUse),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
