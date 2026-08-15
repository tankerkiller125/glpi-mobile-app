import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/a11y/a11y.dart';
import '../../core/api/itil_type.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/sync/connectivity.dart';
import '../../core/utils/layout.dart';
import '../../l10n/generated/app_localizations.dart';
import '../queue/queue_controls.dart';
import '../queue/ui/filter_sheet.dart';
import '../timer/timer_banner.dart';
import 'primary_nav_drawer.dart';
import 'sync_scope.dart';

/// The Assistance module scaffold: primary nav in the drawer, module-specific
/// navigation (ticket queue scopes) in the bottom bar.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  bool _searching = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load the cached instance priority matrix immediately (offline-safe),
      // then refresh everything from the server.
      ref.read(referenceRepositoryProvider)?.loadCachedPriorityMatrix();
      _refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      await ref
          .read(ticketRepositoryProvider)
          ?.refreshQueue(itemtype: ref.read(itilModuleProvider));
      // Populate the dropdown cache (categories) for edit pickers.
      await ref.read(referenceRepositoryProvider)?.refreshAll();
    } on Exception {
      // Cached lists keep showing; pull-to-refresh surfaces the offline notice.
    }
  }

  void _stopSearch() {
    setState(() => _searching = false);
    _searchController.clear();
    ref.read(queueControlsProvider.notifier).setSearch('');
  }

  /// Identifies the working context, so a change is easy to spot.
  static (int?, int?, bool) _contextOf(AuthState state) => switch (state) {
    Ready(:final account) => (
      account.profileId,
      account.entityId,
      account.entityRecursive,
    ),
    _ => (null, null, true),
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    // Reload whenever the working context changes, wherever it was changed
    // from — the drawer, Settings, or anywhere added later. The caches for the
    // old entity are already gone by this point; this refills them.
    ref.listen(authControllerProvider, (previous, next) {
      if (previous == null) return;
      if (_contextOf(previous) == _contextOf(next)) return;
      final entity = switch (next) {
        Ready(:final account) => account.entityName ?? '',
        _ => '',
      };
      unawaited(_refresh());
      if (!mounted || entity.isEmpty) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Switched to $entity')));
    });

    // Losing the connection changes nothing on screen except a small cloud in
    // the app bar — say it, because it changes what the next tap will do.
    ref.listen(cloudStateProvider, (previous, next) {
      if (previous == null || previous == next) return;
      announce(context, switch (next) {
        CloudState.offline => 'Offline. Changes are saved and sync later.',
        CloudState.connected when previous == CloudState.offline =>
          'Back online',
        CloudState.error => 'Some changes need attention',
        _ => '',
      });
    });

    final filterCount = ref.watch(
      queueControlsProvider.select((c) => c.activeFilterCount),
    );
    final cloud = ref.watch(cloudStateProvider);
    final size = windowSizeOf(context);

    return Scaffold(
      drawer: const PrimaryNavDrawer(),
      appBar: AppBar(
        title: _searching
            ? Semantics(
                label:
                    'Search ${itilLabelPlural(ref.watch(itilModuleProvider)).toLowerCase()}',
                textField: true,
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search tickets…',
                    border: InputBorder.none,
                  ),
                  onChanged: (v) =>
                      ref.read(queueControlsProvider.notifier).setSearch(v),
                ),
              )
            // Just the module. The entity lives in the drawer, where it fits
            // and where you change it — appended here it only ever truncated.
            : Text(itilLabelPlural(ref.watch(itilModuleProvider))),
        leading: _searching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Close search',
                onPressed: _stopSearch,
              )
            : Builder(
                builder: (context) => IconButton(
                  icon: _MenuIcon(cloud: cloud),
                  // The badge on this icon is the only sync signal outside the
                  // drawer, so the state belongs in the name too.
                  tooltip: switch (cloud) {
                    CloudState.offline => 'Menu, working offline',
                    CloudState.error => 'Menu, sync needs attention',
                    _ => 'Menu',
                  },
                  onPressed: Scaffold.of(context).openDrawer,
                ),
              ),
        actions: [
          if (!_searching)
            PopupMenuButton<String>(
              tooltip: 'Switch module',
              icon: const Icon(Icons.swap_horiz),
              initialValue: ref.watch(itilModuleProvider),
              onSelected: (value) {
                ref.read(itilModuleProvider.notifier).set(value);
                _refresh();
              },
              itemBuilder: (context) => [
                for (final t in itilTypes)
                  PopupMenuItem(
                    value: t,
                    child: ListTile(
                      dense: true,
                      leading: Icon(_moduleIcon(t)),
                      title: Text(itilLabelPlural(t)),
                    ),
                  ),
              ],
            ),
          if (!_searching)
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search',
              onPressed: () => setState(() => _searching = true),
            ),
          IconButton(
            onPressed: () => FilterSheet.show(context),
            // A badge is a number floating over an icon; without this the
            // button announces nothing and the count announces "3".
            tooltip: filterCount > 0
                ? 'Filter and sort, $filterCount active'
                : 'Filter and sort',
            icon: Badge(
              isLabelVisible: filterCount > 0,
              label: Text('$filterCount'),
              child: const Icon(Icons.tune),
            ),
          ),
        ],
      ),
      body: SyncScope(
        child: Row(
          children: [
            // Wide windows get a rail: a bottom bar wastes the short axis and
            // puts the scopes far from the content on a tablet.
            if (size.hasRail)
              NavigationRail(
                extended: size == WindowSize.expanded,
                selectedIndex: widget.shell.currentIndex,
                onDestinationSelected: _goBranch,
                labelType: size == WindowSize.expanded
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.person_outline),
                    selectedIcon: const Icon(Icons.person),
                    label: Text(l.queueTabMine),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.groups_outlined),
                    selectedIcon: const Icon(Icons.groups),
                    label: Text(l.queueTabGroups),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.inbox_outlined),
                    selectedIcon: const Icon(Icons.inbox),
                    label: Text(l.queueTabUnassigned),
                  ),
                ],
              ),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: widget.shell),
                  const TimerBanner(),
                ],
              ),
            ),
          ],
        ),
      ),
      // In two-pane mode the scaffold's bottom-right is the *detail* pane,
      // where the FAB lands on top of the reply box. There it belongs to the
      // list column instead (see ScopeListView).
      floatingActionButton: _searching || size.hasTwoPanes
          ? null
          : FloatingActionButton(
              onPressed: () => context.push(Routes.catalog),
              tooltip: 'New ticket',
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: size.hasRail
          ? null
          : NavigationBar(
              selectedIndex: widget.shell.currentIndex,
              onDestinationSelected: _goBranch,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: l.queueTabMine,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.groups_outlined),
                  selectedIcon: const Icon(Icons.groups),
                  label: l.queueTabGroups,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.inbox_outlined),
                  selectedIcon: const Icon(Icons.inbox),
                  label: l.queueTabUnassigned,
                ),
              ],
            ),
    );
  }

  void _goBranch(int index) => widget.shell.goBranch(
    index,
    initialLocation: index == widget.shell.currentIndex,
  );
}

IconData _moduleIcon(String itemtype) => switch (itemtype) {
  itilChange => Icons.published_with_changes,
  itilProblem => Icons.troubleshoot,
  _ => Icons.confirmation_number_outlined,
};

/// Hamburger that shows a small cloud overlay when sync needs attention or is
/// offline, so drawer-only sync state is still discoverable without opening it.
class _MenuIcon extends StatelessWidget {
  const _MenuIcon({required this.cloud});

  final CloudState cloud;

  @override
  Widget build(BuildContext context) {
    final showBadge = cloud == CloudState.error || cloud == CloudState.offline;
    if (!showBadge) return const Icon(Icons.menu);
    return Badge(
      backgroundColor: cloud == CloudState.error
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).colorScheme.outline,
      smallSize: 8,
      child: const Icon(Icons.menu),
    );
  }
}
