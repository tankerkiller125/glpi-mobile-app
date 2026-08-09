import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/catalog_item.dart';
import '../../../core/providers.dart';
import 'catalog_tile.dart';

/// Search across a domain's primary itemtypes at once — the technician knows
/// the serial on the label, not which GLPI itemtype it lives under.
class CatalogSearchDelegate extends SearchDelegate<void> {
  CatalogSearchDelegate({required this.domain, required this.ref})
    : super(searchFieldLabel: 'Name, serial or asset tag…');

  final String domain;
  final WidgetRef ref;

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
        tooltip: 'Clear',
      ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
    tooltip: 'Back',
  );

  @override
  Widget buildSuggestions(BuildContext context) => query.trim().length < 2
      ? Center(
          child: Text(
            'Type at least 2 characters',
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        )
      : buildResults(context);

  @override
  Widget buildResults(BuildContext context) {
    final results = ref.watch(
      catalogSearchProvider((domain: domain, query: query.trim())),
    );
    return switch (results) {
      AsyncData(:final value) when value.isEmpty => Center(
        child: Text(
          'No matches',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      AsyncData(:final value) => _grouped(value),
      AsyncError() => const Center(child: Text('Search needs a connection')),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  /// Group hits under their itemtype so a serial that matches both a Monitor
  /// and a Computer reads unambiguously.
  Widget _grouped(List<CatalogItem> items) {
    final byType = <String, List<CatalogItem>>{};
    for (final i in items) {
      byType.putIfAbsent(i.itemtype, () => []).add(i);
    }
    final types = byType.keys.toList()..sort();
    return ListView(
      children: [
        for (final t in types) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Builder(
              builder: (context) => Text(
                '$t (${byType[t]!.length})',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
          for (final item in byType[t]!) CatalogTile(item: item),
        ],
      ],
    );
  }
}
