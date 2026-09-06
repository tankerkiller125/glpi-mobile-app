import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/models/capabilities.dart';
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
    // Optional server-plugin modules only appear when the server offers them
    // (the last-known map keeps them stable offline).
    final caps = ref.watch(capabilitiesProvider).value ?? Capabilities.empty;

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
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Live-ops surfaces the companion plugins add. Grouped and
                  // first: during an incident they are what the drawer is
                  // opened for, and the shell itself (Assistance) is already
                  // on screen behind the drawer. Hidden entirely on servers
                  // that advertise none of them.
                  if (caps.has(Cap.signal, Cap.signalAlerts) ||
                      caps.has(Cap.major, Cap.majorView) ||
                      caps.has(Cap.kedb, Cap.kedbSearch) ||
                      caps.has(Cap.ai, Cap.aiAssistant) ||
                      caps.has(Cap.change, Cap.changeCalendar)) ...[
                    const _SectionLabel('Operations'),
                    // First of the live-ops entries: it is the one that is
                    // useful without already knowing which ticket you want.
                    if (caps.has(Cap.ai, Cap.aiAssistant))
                      _ModuleTile(
                        icon: Icons.auto_awesome_outlined,
                        label: l.assistantTitle,
                        selected: location.startsWith(Routes.assistant),
                        onTap: () => _go(context, Routes.assistant),
                      ),
                    if (caps.has(Cap.signal, Cap.signalAlerts))
                      _ModuleTile(
                        icon: Icons.notifications_active_outlined,
                        label: l.alertsTitle,
                        selected: location.startsWith(Routes.alerts),
                        onTap: () => _go(context, Routes.alerts),
                      ),
                    if (caps.has(Cap.major, Cap.majorView))
                      _ModuleTile(
                        icon: Icons.warning_amber_outlined,
                        label: l.majorTitle,
                        selected: location.startsWith(Routes.major),
                        onTap: () => _go(context, Routes.major),
                      ),
                    if (caps.has(Cap.kedb, Cap.kedbSearch))
                      _ModuleTile(
                        icon: Icons.report_gmailerrorred_outlined,
                        label: l.kedbTitle,
                        selected: location.startsWith(Routes.kedb),
                        onTap: () => _go(context, Routes.kedb),
                      ),
                    if (caps.has(Cap.change, Cap.changeCalendar))
                      _ModuleTile(
                        icon: Icons.edit_calendar_outlined,
                        label: l.changeCalendarTitle,
                        selected: location.startsWith(Routes.changeCalendar),
                        onTap: () => _go(context, Routes.changeCalendar),
                      ),
                  ],
                  const _SectionLabel('Modules'),
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
              // The subtitle already says "3 need attention"; the badge would
              // otherwise add a bare "3" after it.
              trailing: status.needsAttentionCount > 0
                  ? ExcludeSemantics(
                      child: Badge(
                        label: Text('${status.needsAttentionCount}'),
                      ),
                    )
                  : (status.pendingCount > 0
                        ? ExcludeSemantics(
                            child: Badge(
                              label: Text('${status.pendingCount}'),
                              backgroundColor: theme.colorScheme.primary,
                            ),
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

/// A small grouping label inside the drawer's scrolling module list.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ),
    );
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
