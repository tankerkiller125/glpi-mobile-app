import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/widgets/accessible_refresh.dart';
import '../../../core/widgets/rights_gate.dart';
import '../../ticket/ui/option_sheet.dart';
import 'catalog_tile.dart';

/// One itemtype's records. Search and the status filter are server-backed (the
/// dataset is far too large to filter locally), but the cached rows keep
/// showing when the request fails, so the screen is useful offline.
class CatalogListScreen extends ConsumerStatefulWidget {
  const CatalogListScreen({
    super.key,
    required this.domain,
    required this.itemtype,
  });

  final String domain;
  final String itemtype;

  @override
  ConsumerState<CatalogListScreen> createState() => _CatalogListScreenState();
}

class _CatalogListScreenState extends ConsumerState<CatalogListScreen> {
  String _query = '';
  int? _statusId;
  String? _statusLabel;
  Timer? _debounce;
  bool _loadedOnce = false;
  bool _offline = false;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      setState(() => _query = value);
      unawaited(_refresh());
    });
  }

  Future<void> _refresh() async {
    final repo = ref.read(catalogRepositoryProvider);
    if (repo == null) return;
    try {
      await repo.refreshList(
        widget.domain,
        widget.itemtype,
        search: _query.trim().isEmpty ? null : _query.trim(),
        statusId: _statusId,
      );
      if (mounted) setState(() => _offline = false);
    } on Exception {
      if (mounted) setState(() => _offline = true);
    }
  }

  Future<void> _pickStatus() async {
    final states = ref.read(assetStatusesProvider).value ?? const [];
    if (states.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Statuses are still syncing')),
      );
      return;
    }
    final chosen = await OptionSheet.show(
      context,
      title: 'Status',
      options: [
        const OptionItem(value: 0, label: 'Any status'),
        for (final s in states) OptionItem(value: s.serverId, label: s.name),
      ],
      current: _statusId ?? 0,
    );
    if (chosen == null || !mounted) return;
    setState(() {
      _statusId = chosen == 0 ? null : chosen;
      _statusLabel = chosen == 0
          ? null
          : states.firstWhere((s) => s.serverId == chosen).name;
    });
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadedOnce) {
      _loadedOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    }
    // Keep the status stream subscribed so the filter sheet has options.
    ref.watch(assetStatusesProvider);
    final theme = Theme.of(context);
    final scope = (domain: widget.domain, itemtype: widget.itemtype);
    final all = ref.watch(catalogListProvider(scope)).value ?? const [];
    // When a server round-trip failed we still have the previous rows; filter
    // them locally so typing keeps narrowing the list offline.
    final q = _query.trim().toLowerCase();
    final items = !_offline || q.isEmpty
        ? all
        : [
            for (final i in all)
              if (i.name.toLowerCase().contains(q) ||
                  (i.serial ?? '').toLowerCase().contains(q) ||
                  (i.otherserial ?? '').toLowerCase().contains(q))
                i,
          ];

    return RightsGate(
      allows: (r) => r.canReadItemtype(widget.itemtype),
      title: widget.itemtype,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.itemtype),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(104),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Name, serial or asset tag…',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onQueryChanged,
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      FilterChip(
                        avatar: const Icon(Icons.tune, size: 16),
                        label: Text(_statusLabel ?? 'Status'),
                        selected: _statusId != null,
                        onSelected: (_) => _pickStatus(),
                      ),
                      if (_offline)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Chip(
                            avatar: const Icon(Icons.cloud_off, size: 16),
                            label: const Text('Cached'),
                            backgroundColor: theme.colorScheme.surfaceContainer,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: AccessibleRefresh(
          onRefresh: _refresh,
          child: items.isEmpty
              ? ListView(
                  children: [
                    const SizedBox(height: 120),
                    Center(
                      child: Text(
                        'No ${widget.itemtype} records',
                        style: TextStyle(color: theme.colorScheme.outline),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) => CatalogTile(item: items[i]),
                ),
        ),
      ),
    );
  }
}
