import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/a11y/contrast.dart';
import '../../../core/api/itil_type.dart';
import '../../../core/models/ticket_detail.dart';
import '../../../core/models/timeline_entry.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/sync/ticket_actions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/widgets/accessible_refresh.dart';
import '../../../core/widgets/due_badge.dart';
import '../../../core/widgets/info_tile.dart';
import '../../../core/widgets/rich_content.dart';
import '../../../core/widgets/section_heading.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../assistant/ui/ai_ticket_section.dart';
import '../../change_calendar/ui/change_schedule_section.dart';
import '../../entitle/ui/entitlement_card.dart';
import '../../kedb/ui/kedb_banner_section.dart';
import '../../major/ui/major_banner_section.dart';
import '../../presence/ui/presence_bar.dart';
import '../../sop/ui/sop_section.dart';
import '../../timer/timer_banner.dart';
import 'analysis_section.dart';
import 'attachments_section.dart';
import 'category_picker.dart';
import 'compose_sheet.dart';
import 'composer.dart';
import 'linked_assets_section.dart';
import 'linked_items_section.dart';
import 'option_sheet.dart';
import 'status_sheet.dart';
import 'timeline_entry_tile.dart';
import 'user_picker.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({
    super.key,
    required this.localId,
    this.embedded = false,
  });

  final String localId;

  /// Shown beside the queue on a wide screen rather than pushed over it: there
  /// is nothing to go back to, so the back button would strand the user.
  final bool embedded;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  bool _refreshedOnce = false;

  Future<void> _refresh() async {
    // Read everything before the first await: the awaits below can outlive
    // this widget — the two-pane layout remounts the detail when the selected
    // ticket changes, and a fold/unfold can remove the pane entirely — and
    // touching `ref` after unmount throws.
    final detail = ref.read(ticketDetailProvider(widget.localId)).value;
    final serverId = detail?.serverId;
    if (serverId == null) return;
    final itemtype = detail?.itemtype ?? itilTicket;
    final ticketRepo = ref.read(ticketRepositoryProvider);
    final timelineRepo = ref.read(timelineRepositoryProvider);
    final attachments = ref.read(attachmentRepositoryProvider);
    final links = ref.read(itilLinkRepositoryProvider);
    try {
      await ticketRepo?.refreshTicket(
        widget.localId,
        serverId,
        itemtype: itemtype,
      );
      await timelineRepo?.refreshTimeline(
        widget.localId,
        serverId,
        itemtype: itemtype,
      );
      await attachments?.refresh(widget.localId, serverId, itemtype: itemtype);
      await links?.refreshLinks(widget.localId, serverId, itemtype: itemtype);
      if (itemtype != itilTicket) {
        await links?.refreshExtra(widget.localId, serverId, itemtype: itemtype);
      }
    } on Exception {
      // Offline: cached detail + timeline + attachments keep showing.
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(ticketDetailProvider(widget.localId));
    final detail = async.value;
    // Is a timer already running for THIS ticket? If so, the banner shows Stop,
    // so hide the redundant app-bar start button.
    final timerRunningHere =
        ref.watch(activeTimerProvider).value?.ticketLocalId == widget.localId;
    final pending =
        ref.watch(ticketPendingCountProvider(widget.localId)).value ?? 0;

    // Auto-refresh once the ticket's serverId is known — but not while writes
    // are still pending: a server pull replaces the actor set, so refreshing
    // mid-sync (e.g. a just-created ticket whose assign op hasn't landed yet)
    // would clobber optimistic state. Wait for the outbox to drain first.
    if (!_refreshedOnce && detail?.serverId != null && pending == 0) {
      _refreshedOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: Text(
          detail == null
              ? ''
              : (detail.serverId == null
                    ? itilLabel(detail.itemtype)
                    : '${itilLabel(detail.itemtype)} #${detail.serverId}'),
        ),
        actions: [
          if (detail?.serverId != null && !timerRunningHere)
            IconButton(
              tooltip: 'Start timer',
              icon: const Icon(Icons.timer_outlined),
              onPressed: () => _startTimer(detail!),
            ),
          if (detail != null)
            PopupMenuButton<String>(
              tooltip: 'More actions',
              onSelected: (v) => _onAction(v, detail),
              itemBuilder: (context) => [
                if (!_isAssignedToMe(detail))
                  const PopupMenuItem(
                    value: 'assign',
                    child: ListTile(
                      leading: Icon(Icons.person_add_alt),
                      title: Text('Assign to me'),
                    ),
                  ),
                const PopupMenuItem(
                  value: 'status',
                  child: ListTile(
                    leading: Icon(Icons.flag_outlined),
                    title: Text('Change status'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'solution',
                  child: ListTile(
                    leading: Icon(Icons.check_circle_outline),
                    title: Text('Add solution'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'kb',
                  child: ListTile(
                    leading: Icon(Icons.menu_book_outlined),
                    title: Text('Search knowledge base'),
                  ),
                ),
                if (itilSupportsValidation(detail.itemtype))
                  const PopupMenuItem(
                    value: 'approval',
                    child: ListTile(
                      leading: Icon(Icons.how_to_reg_outlined),
                      title: Text('Request approval'),
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: switch (async) {
        AsyncData(value: final d?) => Column(
          children: [
            Expanded(
              child: AccessibleRefresh(
                onRefresh: _refresh,
                child: _DetailBody(detail: d, ticketLocalId: widget.localId),
              ),
            ),
            // Show the running-timer banner here too — this is where a tech
            // works a ticket, so the timer must be visible/stoppable here.
            const TimerBanner(),
            Composer(ticket: d),
          ],
        ),
        AsyncData() => const Center(child: Text('Ticket not found')),
        AsyncError() => Center(
          child: Text(AppLocalizations.of(context).genericError),
        ),
        _ => const Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading'),
        ),
      },
    );
  }

  bool _isAssignedToMe(TicketDetail detail) {
    final actions = ref.read(ticketActionsProvider);
    if (actions == null) return false;
    return detail
        .byRole('assigned')
        .any((a) => a.type == 'User' && a.id == actions.userId);
  }

  Future<void> _startTimer(TicketDetail detail) async {
    await ref
        .read(timerServiceProvider)
        .start(
          ticketLocalId: detail.localId,
          ticketServerId: detail.serverId!,
          ticketName: detail.name,
        );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Timer started')));
    }
  }

  Future<void> _onAction(String value, TicketDetail detail) async {
    final actions = ref.read(ticketActionsProvider);
    if (actions == null) return;
    switch (value) {
      case 'assign':
        await actions.assignSelf(detail);
      case 'kb':
        // Pre-fill the search with this object's title and carry its local id
        // so the reader can offer "use as solution" / "add as reply".
        if (!mounted) return;
        await context.push(
          Uri(
            path: Routes.kb,
            queryParameters: {'q': detail.name, 'source': detail.localId},
          ).toString(),
        );
      case 'status':
        final status = await StatusSheet.show(
          context,
          current: detail.status,
          itemtype: detail.itemtype,
        );
        if (status != null) await actions.setStatus(detail, status);
      case 'solution':
        final content = await ComposeSheet.show(
          context,
          title: 'Add solution',
          hint: 'Describe the solution…',
          submitLabel: 'Solve',
          rich: true,
        );
        if (content != null && content.trim().isNotEmpty) {
          await actions.addSolution(detail, content.trim());
        }
      case 'approval':
        final user = await UserPicker.show(
          context,
          title: 'Request approval from',
        );
        if (user == null || !mounted) return;
        final comment = await ComposeSheet.show(
          context,
          title: 'Request approval',
          hint: 'What should they approve?',
          submitLabel: 'Request',
          rich: true,
        );
        if (comment != null) {
          await actions.requestApproval(
            detail,
            approverId: user.id,
            approverName: user.displayName,
            comment: comment.trim(),
          );
        }
    }
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.detail, required this.ticketLocalId});

  final TicketDetail detail;
  final String ticketLocalId;

  TicketActions? _actions(WidgetRef ref) => ref.read(ticketActionsProvider);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final timeline = ref.watch(timelineProvider(ticketLocalId));
    final colors = context.glpiColors;

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The title is this screen's heading: screen-reader users can
              // jump between headings instead of swiping through every field.
              Semantics(
                header: true,
                child: Text(detail.name, style: theme.textTheme.titleLarge),
              ),
              const SizedBox(height: 10),
              // Quick-edit chips: status and type (both editable, same style).
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TicketChip(
                    field: 'Status',
                    dotColor: colors.statusColor(detail.status),
                    label: statusLabel(
                      detail.status,
                      itemtype: detail.itemtype,
                    ),
                    onTap: () => _editStatus(context, ref),
                  ),
                  if (itilHasRequestType(detail.itemtype))
                    _TicketChip(
                      field: 'Type',
                      icon: detail.type == 1
                          ? Icons.error_outline
                          : Icons.help_outline,
                      label: typeLabel(detail.type),
                      onTap: () => _editType(context, ref),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Optional capability-gated sections; each renders nothing
              // when its plugin is absent or it has nothing to say — see
              // MajorBannerSection for the pattern.
              PresenceBar(item: detail),
              MajorBannerSection(item: detail),
              KedbBannerSection(item: detail),
              EntitlementCard(item: detail),
              ChangeScheduleSection(item: detail),
              // SLA targets (shown only when the ticket carries a due date).
              if (detail.timeToResolve != null)
                _DueTile(
                  label: 'Due',
                  due: detail.timeToResolve!,
                  open: detail.isOpen,
                ),
              // Editable detail fields.
              _RequesterTile(
                detail: detail,
                onAdd: () => _addActor(context, ref, 'requester'),
                onRemove: (a) => _actions(ref)?.removeActor(detail, a),
              ),
              _AssignedTile(
                detail: detail,
                onAdd: () => _addActor(context, ref, 'assigned'),
                onRemove: (a) => _actions(ref)?.removeActor(detail, a),
              ),
              _ObserverTile(
                detail: detail,
                onAdd: () => _addActor(context, ref, 'observer'),
                onRemove: (a) => _actions(ref)?.removeActor(detail, a),
              ),
              InfoTile(
                icon: Icons.folder_outlined,
                label: 'Category',
                value: detail.categoryName ?? 'None',
                onTap: () => _editCategory(context, ref),
              ),
              // Urgency + Impact are the editable inputs; Priority is derived.
              InfoTile(
                icon: Icons.priority_high,
                label: 'Urgency',
                value: urgencyLabel(detail.urgency),
                onTap: () => _editUrgency(context, ref),
              ),
              InfoTile(
                icon: Icons.bolt_outlined,
                label: 'Impact',
                value: urgencyLabel(detail.impact),
                onTap: () => _editImpact(context, ref),
              ),
              _PriorityTile(
                priority: detail.priority,
                color: colors.priorityColor(detail.priority),
              ),
              if (detail.locationName != null)
                InfoTile(
                  icon: Icons.place_outlined,
                  label: 'Location',
                  value: detail.locationName!,
                ),
              if (detail.entityName != null)
                InfoTile(
                  icon: Icons.business_outlined,
                  label: 'Entity',
                  value: detail.entityName!,
                ),
              InfoTile(
                icon: Icons.schedule,
                label: 'Created',
                value: formatDateTime(detail.dateCreation),
              ),
              InfoTile(
                icon: Icons.update,
                label: 'Updated',
                value: formatDateTime(detail.dateMod),
              ),
              if (detail.content.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                const SectionHeading('Description'),
                const SizedBox(height: 4),
                RichContent(detail.content),
              ],
              if (detail.itemtype != itilTicket) ...[
                const SizedBox(height: 12),
                AnalysisSection(item: detail),
              ],
              const SizedBox(height: 12),
              SopSection(item: detail),
              AiTicketSection(item: detail),
              LinkedItemsSection(item: detail),
              const SizedBox(height: 12),
              LinkedAssetsSection(item: detail),
              const SizedBox(height: 12),
              AttachmentsSection.forTicket(detail),
              const SizedBox(height: 8),
              const Divider(),
              const SectionHeading('Timeline'),
            ],
          ),
        ),
        switch (timeline) {
          AsyncData(:final value) when value.isEmpty => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No activity yet')),
          ),
          AsyncData(:final value) => Column(
            children: [
              for (final TimelineEntry e in value)
                TimelineEntryTile(
                  entry: e,
                  onToggleTask: e.type == 'task'
                      ? () => _actions(ref)?.toggleTask(detail, e)
                      : null,
                  onReview: _reviewHandler(context, ref, e),
                ),
              const SizedBox(height: 16),
            ],
          ),
          AsyncError() => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Could not load timeline')),
          ),
          _ => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(semanticsLabel: 'Loading'),
            ),
          ),
        },
      ],
    );
  }

  Future<void> _editStatus(BuildContext context, WidgetRef ref) async {
    final v = await StatusSheet.show(
      context,
      current: detail.status,
      itemtype: detail.itemtype,
    );
    if (v != null) await _actions(ref)?.setStatus(detail, v);
  }

  Future<void> _editUrgency(BuildContext context, WidgetRef ref) async {
    final v = await OptionSheet.show(
      context,
      title: 'Urgency',
      current: detail.urgency,
      options: [
        for (var u = 5; u >= 1; u--)
          OptionItem(value: u, label: urgencyLabel(u)),
      ],
    );
    if (v != null) await _actions(ref)?.setUrgency(detail, v);
  }

  Future<void> _editImpact(BuildContext context, WidgetRef ref) async {
    final v = await OptionSheet.show(
      context,
      title: 'Impact',
      current: detail.impact,
      options: [
        for (var i = 5; i >= 1; i--)
          OptionItem(value: i, label: urgencyLabel(i)),
      ],
    );
    if (v != null) await _actions(ref)?.setImpact(detail, v);
  }

  Future<void> _editType(BuildContext context, WidgetRef ref) async {
    final v = await OptionSheet.show(
      context,
      title: 'Type',
      current: detail.type,
      options: const [
        OptionItem(value: 1, label: 'Incident'),
        OptionItem(value: 2, label: 'Request'),
      ],
    );
    if (v != null) await _actions(ref)?.setType(detail, v);
  }

  Future<void> _editCategory(BuildContext context, WidgetRef ref) async {
    final picked = await CategoryPicker.show(context, detail.categoryId);
    if (picked != null) {
      await _actions(
        ref,
      )?.setCategory(detail, categoryId: picked.$1, categoryName: picked.$2);
    }
  }

  /// Returns an approve/refuse handler for an entry when the current user can
  /// review it: waiting solutions (by a requester) or validations targeting me.
  void Function(bool)? _reviewHandler(
    BuildContext context,
    WidgetRef ref,
    TimelineEntry e,
  ) {
    final actions = _actions(ref);
    if (actions == null || !e.isWaitingApproval) return null;

    if (e.type == 'solution') {
      final iAmRequester = detail
          .byRole('requester')
          .any((a) => a.type == 'User' && a.id == actions.userId);
      if (!iAmRequester) return null;
      return (accept) => actions.answerSolution(detail, e, accept: accept);
    }

    if (e.type == 'validation') {
      if (!actions.isMyValidation(e)) return null;
      return (accept) async {
        String? comment;
        if (!accept) {
          comment = await ComposeSheet.show(
            context,
            title: 'Refuse approval',
            hint: 'Reason (optional)…',
            submitLabel: 'Refuse',
            rich: true,
          );
        }
        await actions.answerValidation(
          detail,
          e,
          accept: accept,
          comment: comment?.trim(),
        );
      };
    }
    return null;
  }

  Future<void> _addActor(
    BuildContext context,
    WidgetRef ref,
    String role,
  ) async {
    final user = await UserPicker.show(
      context,
      title: switch (role) {
        'assigned' => 'Assign to',
        'requester' => 'Add requester',
        _ => 'Add observer',
      },
    );
    if (user != null) {
      await _actions(ref)?.addActor(
        detail,
        role: role,
        type: 'User',
        id: user.id,
        name: user.displayName,
      );
    }
  }
}

/// A labelled read-only or tappable info row.

/// An SLA due-date row: absolute target plus a colored remaining/overdue pill
/// (only while the ticket is open — the SLA clock stops once it's resolved).
class _DueTile extends StatelessWidget {
  const _DueTile({required this.label, required this.due, required this.open});

  final String label;
  final DateTime due;
  final bool open;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = due.difference(DateTime.now());
    final color = open
        ? context.glpiColors.slaColor(remaining)
        : theme.colorScheme.outline;
    return LabelledRow(
      icon: Icons.alarm,
      iconColor: color,
      label: label,
      // "in 3h" is read as "in three h"; say the whole thing instead.
      semanticsValue: open
          ? '${formatDateTime(due)}, ${spokenDueRelative(due)}'
          : formatDateTime(due),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(formatDateTime(due), style: theme.textTheme.bodyMedium),
          if (open) DueBadge(text: formatDueRelative(due), color: color),
        ],
      ),
    );
  }
}

/// Actor row with removable/addable chips (assigned, observers).
class _ActorEditTile extends StatelessWidget {
  const _ActorEditTile({
    required this.icon,
    required this.label,
    required this.actors,
    this.onAdd,
    this.onRemove,
  });

  final IconData icon;
  final String label;
  final List<TicketActor> actors;
  final VoidCallback? onAdd;
  final void Function(TicketActor)? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LabelledRow(
      icon: icon,
      label: label,
      crossAxisAlignment: CrossAxisAlignment.start,
      // The chips stay individually reachable (each is a control), so the row
      // announces only who is on it; the chips announce how to remove them.
      semanticsValue: actors.isEmpty
          ? 'None'
          : actors.map((a) => a.displayName).join(', '),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final a in actors)
            InputChip(
              // No shrinkWrap: it drops the chip below the 48dp touch target,
              // and these sit close enough together to mis-tap.
              visualDensity: VisualDensity.compact,
              avatar: Icon(
                a.isGroup ? Icons.group_outlined : Icons.person_outline,
                size: 16,
              ),
              label: Text(a.displayName),
              deleteButtonTooltipMessage: 'Remove ${a.displayName} from $label',
              onDeleted: onRemove == null ? null : () => onRemove!(a),
            ),
          if (actors.isEmpty) Text('None', style: theme.textTheme.bodyMedium),
          if (onAdd != null)
            ActionChip(
              visualDensity: VisualDensity.compact,
              avatar: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
              tooltip: 'Add to $label',
              onPressed: onAdd,
            ),
        ],
      ),
    );
  }
}

class _RequesterTile extends StatelessWidget {
  const _RequesterTile({
    required this.detail,
    required this.onAdd,
    required this.onRemove,
  });
  final TicketDetail detail;
  final VoidCallback onAdd;
  final void Function(TicketActor) onRemove;

  @override
  Widget build(BuildContext context) {
    // Always shown (even with no requester) so one can be added.
    return _ActorEditTile(
      icon: Icons.record_voice_over_outlined,
      label: 'Requester',
      actors: detail.byRole('requester').toList(),
      onAdd: onAdd,
      onRemove: onRemove,
    );
  }
}

class _AssignedTile extends StatelessWidget {
  const _AssignedTile({
    required this.detail,
    required this.onAdd,
    required this.onRemove,
  });
  final TicketDetail detail;
  final VoidCallback onAdd;
  final void Function(TicketActor) onRemove;

  @override
  Widget build(BuildContext context) {
    return _ActorEditTile(
      icon: Icons.assignment_ind_outlined,
      label: 'Assigned',
      actors: detail.byRole('assigned').toList(),
      onAdd: onAdd,
      onRemove: onRemove,
    );
  }
}

class _ObserverTile extends StatelessWidget {
  const _ObserverTile({
    required this.detail,
    required this.onAdd,
    required this.onRemove,
  });
  final TicketDetail detail;
  final VoidCallback onAdd;
  final void Function(TicketActor) onRemove;

  @override
  Widget build(BuildContext context) {
    final observers = detail.byRole('observer').toList();
    // Only show observers row if there are any or we can add (always can).
    return _ActorEditTile(
      icon: Icons.visibility_outlined,
      label: 'Observers',
      actors: observers,
      onAdd: onAdd,
      onRemove: onRemove,
    );
  }
}

/// A consistent tappable ticket chip (status / type). Uniform sizing via a
/// single ActionChip; a leading colored dot or icon distinguishes them.
class _TicketChip extends StatelessWidget {
  const _TicketChip({
    required this.label,
    required this.onTap,
    required this.field,
    this.icon,
    this.dotColor,
  });

  final String label;
  final VoidCallback onTap;

  /// What the chip is showing ("Status", "Type") — the chip's own text is just
  /// the value, so this names the dimension for the tooltip and the reader.
  final String field;

  final IconData? icon;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ActionChip(
      visualDensity: VisualDensity.compact,
      avatar: icon != null
          ? Icon(icon, size: 16)
          : Icon(
              Icons.circle,
              size: 12,
              color: dotColor == null
                  ? null
                  : ensureContrast(
                      dotColor!,
                      scheme.surface,
                      minRatio: wcagAaGraphics,
                    ),
            ),
      label: Text(label),
      // The chip's text is only the value ("New"); the tooltip is what tells a
      // screen reader — and a hesitating thumb — which field it belongs to.
      tooltip: 'Change ${field.toLowerCase()}',
      onPressed: onTap,
    );
  }
}

/// Read-only priority row — priority is derived from urgency × impact.
class _PriorityTile extends StatelessWidget {
  const _PriorityTile({required this.priority, required this.color});

  final int priority;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LabelledRow(
      icon: Icons.flag_outlined,
      // The flag is the only colored mark in the row; hold it to 3:1.
      iconColor: ensureContrast(
        color,
        theme.colorScheme.surface,
        minRatio: wcagAaGraphics,
      ),
      label: 'Priority',
      semanticsValue:
          '${priorityLabel(priority)}, derived from urgency and impact',
      child: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(priorityLabel(priority), style: theme.textTheme.bodyMedium),
          Text(
            'derived from urgency × impact',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
