import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/sync/connectivity.dart';
import '../../core/sync/sync_status.dart';
import '../../core/widgets/cloud_status_icon.dart';
import '../../l10n/generated/app_localizations.dart';
import 'entity_switcher_sheet.dart';

/// The app's primary navigation: the module hub mirroring GLPI's sidebar, plus
/// dynamic Sync and Settings. Assistance is the shell itself; every other
/// module is a full-screen route pushed over it.
class PrimaryNavDrawer extends ConsumerWidget {
  const PrimaryNavDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final account = switch (ref.watch(authControllerProvider)) {
      Ready(:final account) => account,
      _ => null,
    };
    final cloud = ref.watch(cloudStateProvider);
    final status = ref.watch(syncStatusProvider).value ?? const SyncStatus();
    final location = GoRouterState.of(context).uri.path;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.support_agent,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text('GLPI Mobile', style: theme.textTheme.titleLarge),
                    ],
                  ),
                  if (account != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      account.displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // The working entity sits with the identity it belongs to: GLPI
            // scopes what you can see and where new tickets are filed, so it
            // reads as part of "who am I right now", not as a module.
            if (account != null)
              ListTile(
                leading: Icon(
                  Icons.apartment_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  account.entityName ?? '',
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  account.entityRecursive
                      ? 'Including sub-entities'
                      : 'This entity only',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                trailing: const Icon(Icons.unfold_more, size: 20),
                onTap: () {
                  // Close the drawer first — leaving it open behind the sheet
                  // reads as two menus at once. The sheet is then shown from
                  // the root navigator, since this context dies with the
                  // drawer.
                  Navigator.pop(context);
                  final root = rootNavigatorKey.currentContext;
                  if (root != null) EntitySwitcherSheet.show(root);
                },
              ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'Modules',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _ModuleTile(
                    icon: Icons.headset_mic_outlined,
                    label: 'Assistance',
                    selected: location.startsWith('/assistance'),
                    onTap: () => Navigator.pop(context),
                  ),
                  _ModuleTile(
                    icon: Icons.calendar_month_outlined,
                    label: 'Planning',
                    selected: location.startsWith(Routes.planning),
                    onTap: () => _go(context, Routes.planning),
                  ),
                  _ModuleTile(
                    icon: Icons.account_tree_outlined,
                    label: 'Projects',
                    selected: location.startsWith(Routes.projects),
                    onTap: () => _go(context, Routes.projects),
                  ),
                  _ModuleTile(
                    icon: Icons.menu_book_outlined,
                    label: 'Knowledge base',
                    selected: location.startsWith(Routes.kb),
                    onTap: () => _go(context, Routes.kb),
                  ),
                  _ModuleTile(
                    icon: Icons.sticky_note_2_outlined,
                    label: 'Reminders',
                    selected: location.startsWith(Routes.reminders),
                    onTap: () => _go(context, Routes.reminders),
                  ),
                  _ModuleTile(
                    icon: Icons.rss_feed_outlined,
                    label: 'RSS feeds',
                    selected: location.startsWith(Routes.rss),
                    onTap: () => _go(context, Routes.rss),
                  ),
                  _ModuleTile(
                    icon: Icons.event_available_outlined,
                    label: 'Reservations',
                    selected: location.startsWith(Routes.reservations),
                    onTap: () => _go(context, Routes.reservations),
                  ),
                  _ModuleTile(
                    icon: Icons.devices_other_outlined,
                    label: 'Assets',
                    selected: location.startsWith(Routes.assets),
                    onTap: () => _go(context, Routes.assets),
                  ),
                  _ModuleTile(
                    icon: Icons.business_center_outlined,
                    label: 'Management',
                    selected: location.startsWith(Routes.management),
                    onTap: () => _go(context, Routes.management),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Dynamic sync: reflects connectivity + sync state.
            ListTile(
              leading: CloudStatusIcon(state: cloud),
              title: Text('Sync · ${cloudStateLabel(cloud)}'),
              subtitle: _syncSubtitle(context, status),
              trailing: status.needsAttentionCount > 0
                  ? Badge(label: Text('${status.needsAttentionCount}'))
                  : (status.pendingCount > 0
                        ? Badge(
                            label: Text('${status.pendingCount}'),
                            backgroundColor: theme.colorScheme.primary,
                          )
                        : null),
              onTap: () {
                Navigator.pop(context);
                context.push(Routes.sync);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l.settingsTitle),
              onTap: () {
                Navigator.pop(context);
                context.push(Routes.settings);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext context, String route) {
    Navigator.pop(context);
    context.push(route);
  }

  Widget? _syncSubtitle(BuildContext context, SyncStatus status) {
    if (status.needsAttentionCount > 0) {
      return Text('${status.needsAttentionCount} need attention');
    }
    if (status.pendingCount > 0) {
      return Text('${status.pendingCount} pending');
    }
    return null;
  }
}

/// One drawer module row, highlighted when its route is active.
class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: selected,
      selectedTileColor: theme.colorScheme.secondaryContainer.withValues(
        alpha: 0.4,
      ),
      onTap: onTap,
    );
  }
}
