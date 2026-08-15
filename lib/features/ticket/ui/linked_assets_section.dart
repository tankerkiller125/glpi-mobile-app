import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/catalog_item.dart';
import '../../../core/models/ticket_detail.dart';
import '../../../core/providers.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/section_heading.dart';

/// The assets a ticket/change/problem is about. Add/remove are offline-first;
/// the list itself comes from the server (the link table is small and the app
/// never needs to browse it without a ticket in hand).
class LinkedAssetsSection extends ConsumerWidget {
  const LinkedAssetsSection({super.key, required this.item});

  final TicketDetail item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final serverId = item.serverId;
    if (serverId == null) return const SizedBox.shrink();
    final key = (itemtype: item.itemtype, serverId: serverId);
    final assets = ref.watch(itilItemsProvider(key)).value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          'Assets',
          count: assets.isEmpty ? null : assets.length,
          trailing: TextButton.icon(
            onPressed: () => _add(context, ref, serverId),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Link asset'),
          ),
        ),
        if (assets.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'No assets linked',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          )
        else
          for (final asset in assets)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(catalogIcon(asset.itemtype), size: 20),
              title: Text(
                asset.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                [
                  asset.typeLabel,
                  if (asset.serial.isNotEmpty) asset.serial,
                ].join(' · '),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.link_off, size: 18),
                tooltip: 'Unlink ${asset.name}',
                onPressed: () async {
                  await ref
                      .read(ticketActionsProvider)
                      ?.unlinkAssetFromItil(
                        ownerLocalId: item.localId,
                        ownerServerId: serverId,
                        itemtype: item.itemtype,
                        assetItemtype: asset.itemtype,
                        assetId: asset.id,
                      );
                  ref.invalidate(itilItemsProvider(key));
                },
              ),
            ),
      ],
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref, int serverId) async {
    final picked = await AssetPickerSheet.show(context, ref);
    if (picked == null) return;
    await ref
        .read(ticketActionsProvider)
        ?.linkAssetToItil(
          ownerLocalId: item.localId,
          ownerServerId: serverId,
          itemtype: item.itemtype,
          assetItemtype: picked.itemtype,
          assetId: picked.serverId,
        );
    ref.invalidate(
      itilItemsProvider((itemtype: item.itemtype, serverId: serverId)),
    );
  }
}

/// Search-as-you-type asset picker, spanning the primary asset itemtypes so
/// the technician can just type a serial.
class AssetPickerSheet extends ConsumerStatefulWidget {
  const AssetPickerSheet({super.key});

  static Future<CatalogItem?> show(BuildContext context, WidgetRef ref) =>
      showModalBottomSheet<CatalogItem>(
        context: context,
        constraints: sheetConstraints(context),
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => const AssetPickerSheet(),
      );

  @override
  ConsumerState<AssetPickerSheet> createState() => _AssetPickerSheetState();
}

class _AssetPickerSheetState extends ConsumerState<AssetPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = _query.trim().length < 2
        ? const AsyncValue<List<CatalogItem>>.data([])
        : ref.watch(
            catalogSearchProvider((domain: 'Assets', query: _query.trim())),
          );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Search assets',
                hintText: 'Name, serial or asset tag…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: switch (results) {
                AsyncData(:final value) when value.isEmpty => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _query.trim().length < 2
                        ? 'Type at least 2 characters'
                        : 'No matches',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                AsyncData(:final value) => ListView.separated(
                  shrinkWrap: true,
                  itemCount: value.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) => ListTile(
                    leading: Icon(catalogIcon(value[i].itemtype)),
                    title: Text(value[i].displayName),
                    subtitle: Text(
                      [
                        value[i].itemtype,
                        if ((value[i].serial ?? '').isNotEmpty)
                          value[i].serial!,
                      ].join(' · '),
                    ),
                    onTap: () => Navigator.pop(context, value[i]),
                  ),
                ),
                AsyncError() => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Asset search needs a connection'),
                ),
                _ => const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(semanticsLabel: 'Loading'),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
