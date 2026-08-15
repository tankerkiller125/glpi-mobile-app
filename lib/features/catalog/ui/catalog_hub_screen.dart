import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/catalog_item.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/accessible_refresh.dart';
import 'catalog_scan_screen.dart';
import 'catalog_search_delegate.dart';

/// The entry point for **Assets** and **Management** — one screen, two domains.
///
/// GLPI exposes ~30 itemtypes through an identical contract, so instead of a
/// screen per type the hub lists whatever the server reports (custom asset
/// definitions included) and every type shares the same list/detail pair.
class CatalogHubScreen extends ConsumerWidget {
  const CatalogHubScreen({super.key, required this.domain});

  /// `Assets` or `Management` — matches GLPI's HL API path segment.
  final String domain;

  bool get _isAssets => domain == 'Assets';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = ref.watch(itemtypesProvider(domain));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isAssets ? 'Assets' : 'Management'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: CatalogSearchDelegate(domain: domain, ref: ref),
            ),
          ),
          if (_isAssets)
            IconButton(
              tooltip: 'Scan barcode',
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () => Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CatalogScanScreen(),
                ),
              ),
            ),
        ],
      ),
      body: AccessibleRefresh(
        onRefresh: () async => ref.invalidate(itemtypesProvider(domain)),
        child: switch (types) {
          AsyncData(:final value) when value.isEmpty => _empty(
            context,
            'No itemtypes available',
          ),
          AsyncData(:final value) => GridView.builder(
            padding: const EdgeInsets.all(12),
            // Sized by extent, not a fixed count: two columns on a phone,
            // more as the window grows, without a breakpoint table.
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemCount: value.length,
            itemBuilder: (context, i) => _TypeCard(
              domain: domain,
              itemtype: value[i].itemtype,
              label: value[i].name,
            ),
          ),
          AsyncError() => _empty(context, 'Itemtypes need a connection'),
          _ => const Center(
            child: CircularProgressIndicator(semanticsLabel: 'Loading'),
          ),
        },
      ),
    );
  }

  Widget _empty(BuildContext context, String message) => ListView(
    children: [
      const SizedBox(height: 120),
      Center(
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      ),
    ],
  );
}

class _TypeCard extends ConsumerWidget {
  const _TypeCard({
    required this.domain,
    required this.itemtype,
    required this.label,
  });

  final String domain;
  final String itemtype;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final count = ref.watch(
      catalogCountProvider((domain: domain, itemtype: itemtype)),
    );

    final spokenCount = switch (count) {
      AsyncData(:final value) when value == 1 => '1 record',
      AsyncData(:final value) when value >= 0 => '$value records',
      AsyncData() || AsyncError() => 'count unavailable',
      _ => 'counting',
    };
    final route = domain == 'Assets'
        ? Routes.assetList(itemtype)
        : Routes.managementList(itemtype);

    return Semantics(
      container: true,
      button: true,
      // The tile is an icon, a name and a bare number in a grid; spoken as
      // "Computers, 42 records" it is a destination.
      label: '$label, $spokenCount',
      onTap: () => context.push(route),
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => context.push(route),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  catalogIcon(itemtype),
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
                const Spacer(),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  switch (count) {
                    // -1 is the repository's "couldn't reach the server" marker.
                    AsyncData(:final value) when value >= 0 => '$value',
                    AsyncData() => '—',
                    AsyncError() => '—',
                    _ => '…',
                  },
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
