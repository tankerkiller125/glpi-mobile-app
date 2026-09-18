import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/auth/auth_controller.dart';
import 'package:glpi_mobile/core/models/capabilities.dart';
import 'package:glpi_mobile/core/models/rights.dart';
import 'package:glpi_mobile/core/models/session_info.dart';
import 'package:glpi_mobile/core/providers.dart';
import 'package:glpi_mobile/core/sync/connectivity.dart';
import 'package:glpi_mobile/core/sync/sync_status.dart';
import 'package:glpi_mobile/core/theme/app_theme.dart';
import 'package:glpi_mobile/core/widgets/rights_gate.dart';
import 'package:glpi_mobile/features/shell/primary_nav_drawer.dart';
import 'package:glpi_mobile/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// Keeps the widget tree off SecureStore (a platform channel) in tests.
class _StubAuth extends AuthController {
  @override
  AuthState build() => const SignedOut();
}

Rights _fixture(String name) => SessionInfo.fromJson(
  jsonDecode(File('test/fixtures/$name').readAsStringSync())
      as Map<String, Object?>,
).rights;

/// The default 800px-tall test view cuts the bottom off a full module list,
/// and a row that was never built looks exactly like a row that was hidden.
void _tallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _host({required Widget home, required Rights rights}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        // Ahem renders every glyph full-width; a slightly smaller scale keeps
        // the drawer header off a font artifact (same as the capability test).
        builder: (context, _) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(0.8)),
          child: home,
        ),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      authControllerProvider.overrideWith(_StubAuth.new),
      capabilitiesProvider.overrideWith((ref) async => Capabilities.empty),
      rightsProvider.overrideWith((ref) async => rights),
      syncStatusProvider.overrideWith(
        (ref) => Stream.value(const SyncStatus()),
      ),
      connectivityProvider.overrideWith((ref) => Stream.value(true)),
    ],
    child: MaterialApp.router(
      theme: buildLightTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  group('drawer module rows follow the profile', () {
    testWidgets('a technician gets the modules their profile can open', (
      tester,
    ) async {
      _tallView(tester);
      await tester.pumpWidget(
        _host(
          home: const Scaffold(body: PrimaryNavDrawer()),
          rights: _fixture('session_technician.json'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Assistance'), findsOneWidget);
      expect(find.text('Planning'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Knowledge base'), findsOneWidget);
      expect(find.text('Reservations'), findsOneWidget);
      expect(find.text('Assets'), findsOneWidget);
      // The technician reads some management itemtypes (a Document, a
      // SoftwareLicense) even though Contract and Domain are closed to them.
      expect(find.text('Management'), findsOneWidget);
    });

    testWidgets('a self-service profile is left with almost nothing', (
      tester,
    ) async {
      _tallView(tester);
      await tester.pumpWidget(
        _host(
          home: const Scaffold(body: PrimaryNavDrawer()),
          rights: _fixture('session_selfservice.json'),
        ),
      );
      await tester.pumpAndSettle();

      // Their own tickets, the public FAQ, the public reminders and feeds,
      // and booking an item — GLPI's Self-Service profile holds exactly that.
      expect(find.text('Assistance'), findsOneWidget);
      expect(find.text('Knowledge base'), findsOneWidget);
      expect(find.text('Reminders'), findsOneWidget);
      expect(find.text('RSS feeds'), findsOneWidget);
      expect(find.text('Reservations'), findsOneWidget);
      // Everything a helpdesk profile has no key for at all.
      expect(find.text('Planning'), findsNothing);
      expect(find.text('Projects'), findsNothing);
      expect(find.text('Assets'), findsNothing);
      expect(find.text('Management'), findsNothing);
    });

    testWidgets('an unknown rights map hides every optional module', (
      tester,
    ) async {
      // What a cold start with nothing cached looks like: deny, don't tease.
      _tallView(tester);
      await tester.pumpWidget(
        _host(
          home: const Scaffold(body: PrimaryNavDrawer()),
          rights: Rights.empty,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Assistance'), findsOneWidget);
      expect(find.text('Planning'), findsNothing);
      expect(find.text('Knowledge base'), findsNothing);
      expect(find.text('Assets'), findsNothing);
    });
  });

  group('RightsGate', () {
    testWidgets('passes the screen through when the right is held', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          home: RightsGate(
            allows: (r) => r.canViewProjects,
            title: 'Projects',
            child: const Scaffold(body: Text('the project list')),
          ),
          rights: _fixture('session_technician.json'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('the project list'), findsOneWidget);
    });

    testWidgets('a deep link into a module the profile lacks explains itself', (
      tester,
    ) async {
      // A push notification or a restored route can land here whatever the
      // drawer shows, so the screen refuses rather than 403ing.
      await tester.pumpWidget(
        _host(
          home: RightsGate(
            allows: (r) => r.canViewProjects,
            title: 'Projects',
            child: const Scaffold(body: Text('the project list')),
          ),
          rights: _fixture('session_selfservice.json'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('the project list'), findsNothing);
      expect(find.text('Not available to you'), findsOneWidget);
      expect(find.textContaining('profile'), findsOneWidget);
      // The title stays, so it is clear what was refused.
      expect(find.text('Projects'), findsOneWidget);
    });
  });
}
