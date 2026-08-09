import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/itil_type.dart';
import '../../../core/models/itil_link.dart';
import '../../../core/models/ticket_detail.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/layout.dart';

/// Relationships to other ITIL objects: tickets caused by a problem, the change
/// that fixes them, duplicates, parent/child. Add/remove are offline-first, so a
/// queued link shows greyed until it syncs.
class LinkedItemsSection extends ConsumerWidget {
  const LinkedItemsSection({super.key, required this.item});

  final TicketDetail item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final links = ref.watch(itilLinksProvider(item.localId)).value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Linked items', style: theme.textTheme.labelLarge),
            const SizedBox(width: 4),
            if (links.isNotEmpty)
              Text(
                '(${links.length})',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _add(context, ref),
              icon: const Icon(Icons.add_link, size: 18),
              label: const Text('Link'),
            ),
          ],
        ),
        if (links.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Nothing linked',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          )
        else
          for (final link in links) _LinkTile(item: item, link: link),
      ],
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final picked = await LinkPickerSheet.show(context, ref, source: item);
    if (picked == null) return;
    await ref
        .read(ticketActionsProvider)
        ?.addLink(
          item,
          targetItemtype: picked.itemtype,
          targetId: picked.serverId,
          targetName: picked.name,
          targetStatus: picked.status,
          linkType: picked.linkType,
        );
  }
}

class _LinkTile extends ConsumerWidget {
  const _LinkTile({required this.item, required this.link});

  final TicketDetail item;
  final ItilLink link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.glpiColors;
    return Opacity(
      opacity: link.pending ? 0.55 : 1,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        leading: Icon(
          _icon(link.itemtype),
          color: colors.statusColor(link.status),
        ),
        title: Text(
          '${link.typeLabel} #${link.serverId}  ${link.name}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          link.pending
              ? '${link.relationLabel} · syncing…'
              : '${link.relationLabel} · ${link.statusLabel}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: IconButton(
          tooltip: 'Remove link',
          icon: const Icon(Icons.link_off, size: 20),
          onPressed: () =>
              ref.read(ticketActionsProvider)?.removeLink(item, link),
        ),
        onTap: link.pending ? null : () => _open(context, ref),
      ),
    );
  }

  /// Open the linked object, fetching + caching it if it isn't local yet.
  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(ticketRepositoryProvider);
    if (repo == null) return;
    final localId = await repo.openByServerId(
      link.serverId,
      itemtype: link.itemtype,
    );
    if (localId == null || !context.mounted) return;
    unawaited(context.push(Routes.ticket(localId)));
  }

  IconData _icon(String itemtype) => switch (itemtype) {
    itilChange => Icons.published_with_changes,
    itilProblem => Icons.troubleshoot,
    _ => Icons.confirmation_number_outlined,
  };
}

/// Pick an object to link: choose the type, search it, then the relation.
class LinkPickerSheet {
  static Future<
    ({String itemtype, int serverId, String name, int status, int linkType})?
  >
  show(BuildContext context, WidgetRef ref, {required TicketDetail source}) {
    return showModalBottomSheet<
      ({String itemtype, int serverId, String name, int status, int linkType})
    >(
      context: context,
      constraints: sheetConstraints(context),
      isScrollControlled: true,
      builder: (_) => _LinkPickerBody(source: source),
    );
  }
}

class _LinkPickerBody extends ConsumerStatefulWidget {
  const _LinkPickerBody({required this.source});
  final TicketDetail source;

  @override
  ConsumerState<_LinkPickerBody> createState() => _LinkPickerBodyState();
}

class _LinkPickerBodyState extends ConsumerState<_LinkPickerBody> {
  late String _type = widget.source.itemtype;
  int _linkType = ItilLinkType.linkTo;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Same-type links can express duplicate/parent/child; cross-type can't.
    final sameType = _type == widget.source.itemtype;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Link an item', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: [
              for (final t in itilTypes)
                ButtonSegment(value: t, label: Text(itilLabelPlural(t))),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() {
              _type = s.first;
              if (_type != widget.source.itemtype) {
                _linkType = ItilLinkType.linkTo;
              }
            }),
          ),
          const SizedBox(height: 12),
          if (sameType) ...[
            DropdownButtonFormField<int>(
              initialValue: _linkType,
              decoration: const InputDecoration(
                labelText: 'Relation',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final l in ItilLinkType.all)
                  DropdownMenuItem(
                    value: l,
                    child: Text(ItilLinkType.label(l)),
                  ),
              ],
              onChanged: (v) => setState(() => _linkType = v ?? _linkType),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Search ${itilLabelPlural(_type).toLowerCase()}',
              hintText: 'Title or #id',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 260,
            child: _Results(
              itemtype: _type,
              query: _query,
              excludeServerId: _type == widget.source.itemtype
                  ? widget.source.serverId
                  : null,
              onPick: (r) => Navigator.pop(context, (
                itemtype: _type,
                serverId: r.id,
                name: r.name,
                status: r.status,
                linkType: _linkType,
              )),
            ),
          ),
        ],
      ),
    );
  }
}

/// Live search results for the link picker. Falls back to the local cache when
/// offline, so linking still works with no signal.
class _Results extends ConsumerWidget {
  const _Results({
    required this.itemtype,
    required this.query,
    required this.excludeServerId,
    required this.onPick,
  });

  final String itemtype;
  final String query;
  final int? excludeServerId;
  final void Function(({int id, String name, int status})) onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(
      itilSearchProvider((itemtype: itemtype, query: query)),
    );
    return switch (results) {
      AsyncData(:final value) when value.isEmpty => const Center(
        child: Text('No matches'),
      ),
      AsyncData(:final value) => ListView(
        children: [
          for (final r in value)
            if (r.id != excludeServerId)
              ListTile(
                dense: true,
                title: Text(
                  '#${r.id}  ${r.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  itilStatuses(itemtype)[r.status] ?? 'Status ${r.status}',
                ),
                onTap: () => onPick(r),
              ),
        ],
      ),
      AsyncError() => const Center(child: Text('Search needs a connection')),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}
