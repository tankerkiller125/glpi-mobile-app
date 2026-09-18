import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/dto/signal_dto.dart';
import 'package:glpi_mobile/core/api/glpi_api.dart';
import 'package:glpi_mobile/core/auth/auth_controller.dart';
import 'package:glpi_mobile/core/models/capabilities.dart';
import 'package:glpi_mobile/core/models/rights.dart';
import 'package:glpi_mobile/core/providers.dart';
import 'package:glpi_mobile/core/sync/connectivity.dart';
import 'package:glpi_mobile/core/sync/sync_status.dart';
import 'package:glpi_mobile/core/theme/app_theme.dart';
import 'package:glpi_mobile/features/alerts/ui/alerts_screen.dart';
import 'package:glpi_mobile/features/shell/primary_nav_drawer.dart';
import 'package:glpi_mobile/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../support/fake_glpi_api.dart';

/// Keeps the widget tree off SecureStore (a platform channel) in tests.
class _StubAuth extends AuthController {
  @override
  AuthState build() => const SignedOut();
}

/// Serves one alert and one rota through the standard fake.
class _SignalApi with FakeGlpiApiDefaults {
  @override
  Future<List<AlertDto>> listAlerts({
    String state = 'open,acked',
    String? severity,
    int start = 0,
    int limit = 50,
  }) async => [
    AlertDto.fromJson(const {
      'id': 1,
      'name': 'RAID degraded',
      'severity': 'critical',
      'state': 'open',
      'host': 'nas01',
    }),
  ];

  @override
  Future<List<OncallRotaDto>> listOncallRotas() async => [
    OncallRotaDto.fromJson(const {
      'id': 1,
      'name': 'Infra',
      'oncall_user': {'id': 2, 'name': 'alex'},
      'am_i_on_call': true,
    }),
  ];
}

final _bothPlugins = Capabilities.fromJson(const {
  'glpisignal': {
    'version': '0.1.0',
    'features': {'alerts': true, 'ack': true, 'oncall': true},
  },
  'glpimajor': {
    'version': '0.1.0',
    'features': {'view': true, 'declare': true, 'publish': false},
  },
});

/// A profile that may see every built-in module, so these tests stay about
/// capabilities. Rights gating has its own file.
final _allRights = Rights.fromSessionJson(const {
  'active_profile': {
    'interface': 'central',
    'rights': {
      'ticket': 523295,
      'change': 132223,
      'problem': 1151,
      'planning': 3073,
      'project': 1150,
      'knowbase': 15383,
      'reminder_public': 159,
      'rssfeed_public': 159,
      'reservation': 1055,
      'computer': 4095,
      'contract': 255,
    },
  },
});

Widget _host({required Widget home, required Capabilities caps, GlpiApi? api}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        // The test font (Ahem) renders every glyph full-width, so the drawer
        // header overflows by a couple of px at scale 1.0; a slightly smaller
        // scale keeps layout assertions off the back of a font artifact.
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
      capabilitiesProvider.overrideWith((ref) async => caps),
      rightsProvider.overrideWith((ref) async => _allRights),
      glpiApiProvider.overrideWithValue(api),
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
  group('drawer gating', () {
    testWidgets('shows the optional module tiles when the server offers them', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          home: const Scaffold(body: PrimaryNavDrawer()),
          caps: _bothPlugins,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alerts'), findsOneWidget);
      expect(find.text('Major incidents'), findsOneWidget);
      // The built-in modules are untouched by gating.
      expect(find.text('Planning'), findsOneWidget);
    });

    testWidgets('hides them when the capabilities map is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          home: const Scaffold(body: PrimaryNavDrawer()),
          caps: Capabilities.empty,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alerts'), findsNothing);
      expect(find.text('Major incidents'), findsNothing);
      expect(find.text('Planning'), findsOneWidget);
    });
  });

  group('capability-gated screens', () {
    testWidgets(
      'a deep link without the capability lands on a graceful notice',
      (tester) async {
        await tester.pumpWidget(
          _host(home: const AlertsScreen(), caps: Capabilities.empty),
        );
        await tester.pumpAndSettle();

        expect(find.text('Not available'), findsOneWidget);
        expect(
          find.textContaining('not available on this server'),
          findsOneWidget,
        );
      },
    );

    testWidgets('with the capability, the alerts list renders from the API', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          home: const AlertsScreen(),
          caps: _bothPlugins,
          api: _SignalApi(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('RAID degraded'), findsOneWidget);
      // The on-call card highlights the signed-in user's duty.
      expect(find.text('You are on call'), findsOneWidget);
      expect(find.text('Not available'), findsNothing);
    });
  });
}
