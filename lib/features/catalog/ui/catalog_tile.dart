import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/catalog_item.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/widgets/due_badge.dart';

/// One row in an asset / management list. Shows what identifies a record in the
/// field — name, serial, where it is and who has it — plus an expiry badge for
/// the types that have a meaningful end date (contracts, certificates,
/// licenses).
class CatalogTile extends ConsumerWidget {
  const CatalogTile({super.key, required this.item, this.showType = false});

  final CatalogItem item;

  /// Cross-type results (search, scan) label which itemtype each hit came from.
  final bool showType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subtitle = [
      if (showType) item.itemtype,
      if ((item.locationName ?? '').isNotEmpty) item.locationName!,
      if ((item.userName ?? '').isNotEmpty) item.userName!,
      if ((item.modelName ?? '').isNotEmpty) item.modelName!,
    ].join(' · ');
    final expiry = parseGlpiDateTime(item.expiryDate);

    return ListTile(
      leading: Icon(catalogIcon(item.itemtype)),
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.pending)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.outline,
                  semanticsLabel: 'Waiting to sync',
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((item.serial ?? '').isNotEmpty)
            Text(
              item.serial!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.outline,
              ),
            ),
          if (subtitle.isNotEmpty)
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
      trailing: expiry == null
          ? ((item.statusName ?? '').isEmpty
                ? null
                : Text(
                    item.statusName!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ))
          : DueBadge(
              text: formatDueRelative(expiry),
              color: expiryColor(context, expiry),
              // "in 12d" is read as "in twelve d", and without "expires" the
              // number could be anything.
              semanticsLabel: 'Expires ${spokenDueRelative(expiry)}',
            ),
      isThreeLine: (item.serial ?? '').isNotEmpty && subtitle.isNotEmpty,
      onTap: () => openCatalogItem(context, ref, item),
    );
  }
}

/// Warn 30 days out, red once past — the window a technician can still act in.
Color expiryColor(BuildContext context, DateTime expiry) {
  final scheme = Theme.of(context).colorScheme;
  final days = expiry.difference(DateTime.now()).inDays;
  if (days < 0) return scheme.error;
  if (days <= 30) return Colors.orange.shade800;
  return scheme.outline;
}

/// Open a record's detail, resolving (or creating) its local row first —
/// cross-type search results carry no localId.
Future<void> openCatalogItem(
  BuildContext context,
  WidgetRef ref,
  CatalogItem item,
) async {
  var localId = item.localId;
  if (localId.isEmpty) {
    final repo = ref.read(catalogRepositoryProvider);
    if (repo == null) return;
    localId =
        await repo.localIdFor(item.domain, item.itemtype, item.serverId) ?? '';
    if (localId.isEmpty) return;
  }
  if (!context.mounted) return;
  await context.push(
    item.domain == 'Assets'
        ? Routes.assetDetail(item.itemtype, localId)
        : Routes.managementDetail(item.itemtype, localId),
  );
}
