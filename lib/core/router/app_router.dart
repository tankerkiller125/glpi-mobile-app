import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/ui/context_screen.dart';
import '../../features/auth/ui/scan_screen.dart';
import '../../features/auth/ui/server_screen.dart';
import '../../features/catalog/ui/catalog_detail_screen.dart';
import '../../features/catalog/ui/catalog_hub_screen.dart';
import '../../features/catalog/ui/catalog_list_screen.dart';
import '../../features/forms/ui/dynamic_form_screen.dart';
import '../../features/forms/ui/service_catalog_screen.dart';
import '../../features/planning/ui/planning_screen.dart';
import '../../features/projects/ui/project_detail_screen.dart';
import '../../features/projects/ui/projects_screen.dart';
import '../../features/queue/queue_providers.dart';
import '../../features/queue/ui/scope_list_view.dart';
import '../../features/settings/ui/settings_screen.dart';
import '../../features/shell/home_shell.dart';
import '../../features/sync_ui/ui/needs_attention_screen.dart';
import '../../features/ticket/ui/create_ticket_screen.dart';
import '../../features/ticket/ui/ticket_detail_screen.dart';
import '../../features/tools/ui/kb_article_screen.dart';
import '../../features/tools/ui/kb_screen.dart';
import '../../features/tools/ui/reminders_screen.dart';
import '../../features/tools/ui/reservations_screen.dart';
import '../../features/tools/ui/rss_screen.dart';
import '../auth/auth_controller.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class Routes {
  static const server = '/onboarding/server';
  static const pair = '/onboarding/pair';
  static const context = '/onboarding/context';

  // Assistance module — bottom-nav destinations (queue scopes).
  static const mine = '/assistance/mine';
  static const groups = '/assistance/groups';
  static const unassigned = '/assistance/unassigned';

  // Primary-nav (drawer) destinations, pushed over the shell.
  static const sync = '/sync';
  static const settings = '/settings';
  static const createTicket = '/ticket/new';
  // Ticket intake goes through GLPI's Service Catalog forms.
  static const catalog = '/catalog';

  static String form(int formId) => '/catalog/$formId';

  // Tools / Assets / Management modules (drawer destinations).
  static const planning = '/planning';
  static const projects = '/projects';
  static const kb = '/kb';
  static const reminders = '/reminders';
  static const rss = '/rss';
  static const reservations = '/reservations';
  static const assets = '/assets';
  static const management = '/management';

  static String project(String localId) => '/projects/$localId';
  static String kbArticle(int serverId) => '/kb/$serverId';
  static String assetList(String itemtype) => '/assets/$itemtype';
  static String assetDetail(String itemtype, String localId) =>
      '/assets/$itemtype/$localId';
  static String managementList(String itemtype) => '/management/$itemtype';
  static String managementDetail(String itemtype, String localId) =>
      '/management/$itemtype/$localId';

  static String ticket(String localId) => '/ticket/$localId';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  // Rebuild redirect decisions whenever auth state changes.
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.mine,
    redirect: (context, state) {
      final inOnboarding = state.matchedLocation.startsWith('/onboarding');
      return switch (authState) {
        AuthUnknown() => null,
        SignedOut() => inOnboarding ? null : Routes.server,
        NeedsContext() => Routes.context,
        Ready() => inOnboarding ? Routes.mine : null,
      };
    },
    routes: [
      GoRoute(path: Routes.server, builder: (_, _) => const ServerScreen()),
      GoRoute(path: Routes.pair, builder: (_, _) => const ScanScreen()),
      GoRoute(path: Routes.context, builder: (_, _) => const ContextScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.mine,
                builder: (_, _) => const ScopeListView(scope: QueueScope.mine),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.groups,
                builder: (_, _) =>
                    const ScopeListView(scope: QueueScope.groups),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.unassigned,
                builder: (_, _) =>
                    const ScopeListView(scope: QueueScope.unassigned),
              ),
            ],
          ),
        ],
      ),
      // Drawer destinations — full-screen routes with their own back button.
      GoRoute(
        path: Routes.sync,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const NeedsAttentionScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const SettingsScreen(),
      ),
      // Tools modules.
      GoRoute(
        path: Routes.planning,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const PlanningScreen(),
      ),
      GoRoute(
        path: Routes.projects,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const ProjectsScreen(),
      ),
      GoRoute(
        path: '/projects/:localId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            ProjectDetailScreen(localId: state.pathParameters['localId']!),
      ),
      GoRoute(
        path: Routes.kb,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => KbScreen(
          initialQuery: state.uri.queryParameters['q'],
          sourceTicketLocalId: state.uri.queryParameters['source'],
        ),
      ),
      GoRoute(
        path: '/kb/:articleId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => KbArticleScreen(
          articleId: int.parse(state.pathParameters['articleId']!),
          sourceTicketLocalId: state.uri.queryParameters['source'],
        ),
      ),
      GoRoute(
        path: Routes.reminders,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const RemindersScreen(),
      ),
      GoRoute(
        path: Routes.rss,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const RssScreen(),
      ),
      GoRoute(
        path: Routes.reservations,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const ReservationsScreen(),
      ),
      // Assets & Management: one generic browser, two domains.
      GoRoute(
        path: Routes.assets,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const CatalogHubScreen(domain: 'Assets'),
      ),
      GoRoute(
        path: '/assets/:itemtype',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => CatalogListScreen(
          domain: 'Assets',
          itemtype: state.pathParameters['itemtype']!,
        ),
      ),
      GoRoute(
        path: '/assets/:itemtype/:localId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => CatalogDetailScreen(
          domain: 'Assets',
          itemtype: state.pathParameters['itemtype']!,
          localId: state.pathParameters['localId']!,
        ),
      ),
      GoRoute(
        path: Routes.management,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const CatalogHubScreen(domain: 'Management'),
      ),
      GoRoute(
        path: '/management/:itemtype',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => CatalogListScreen(
          domain: 'Management',
          itemtype: state.pathParameters['itemtype']!,
        ),
      ),
      GoRoute(
        path: '/management/:itemtype/:localId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => CatalogDetailScreen(
          domain: 'Management',
          itemtype: state.pathParameters['itemtype']!,
          localId: state.pathParameters['localId']!,
        ),
      ),
      // Service catalog: pick a form, then fill it in.
      GoRoute(
        path: Routes.catalog,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const ServiceCatalogScreen(),
      ),
      GoRoute(
        path: '/catalog/:formId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => DynamicFormScreen(
          formId: int.parse(state.pathParameters['formId']!),
        ),
      ),
      // Static path — must precede '/ticket/:localId' so it isn't captured as
      // a localId of "new". Kept as a fallback for instances with no catalog
      // forms published.
      GoRoute(
        path: Routes.createTicket,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const CreateTicketScreen(),
      ),
      GoRoute(
        path: '/ticket/:localId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            TicketDetailScreen(localId: state.pathParameters['localId']!),
      ),
    ],
  );
});
