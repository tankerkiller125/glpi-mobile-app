import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/dto/change_dto.dart';
import 'package:glpi_mobile/core/api/dto/entitle_dto.dart';
import 'package:glpi_mobile/core/api/dto/kedb_dto.dart';
import 'package:glpi_mobile/core/api/glpi_api.dart';
import 'package:glpi_mobile/core/api/itil_type.dart';
import 'package:glpi_mobile/core/auth/auth_controller.dart';
import 'package:glpi_mobile/core/models/capabilities.dart';
import 'package:glpi_mobile/core/models/rights.dart';
import 'package:glpi_mobile/core/models/ticket_detail.dart';
import 'package:glpi_mobile/core/providers.dart';
import 'package:glpi_mobile/core/sync/connectivity.dart';
import 'package:glpi_mobile/core/theme/app_theme.dart';
import 'package:glpi_mobile/features/change_calendar/change_providers.dart';
import 'package:glpi_mobile/features/change_calendar/ui/change_schedule_section.dart';
import 'package:glpi_mobile/features/change_calendar/ui/freeze_warning.dart';
import 'package:glpi_mobile/features/entitle/ui/entitlement_card.dart';
import 'package:glpi_mobile/features/kedb/ui/kedb_banner_section.dart';
import 'package:glpi_mobile/features/ticket/ui/composer.dart';
import 'package:glpi_mobile/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../support/fake_glpi_api.dart';

/// Keeps the widget tree off SecureStore (a platform channel) in tests.
class _StubAuth extends AuthController {
  @override
  AuthState build() => const SignedOut();
}

/// Serves phase-2 payloads through the standard fake and records hits.
class _Phase2Api with FakeGlpiApiDefaults {
  _Phase2Api({this.entitlement, this.matches = const [], this.schedule});

  EntitlementDto? entitlement;
  List<KedbMatchDto> matches;
  ChangeScheduleDto? schedule;
  final hits = <(int keId, int ticketsId, String action)>[];

  @override
  Future<EntitlementDto> getEntitlement(int entitiesId) async =>
      entitlement ??
      const EntitlementDto(
        state: EntitlementDto.silent,
        ageSeconds: 0,
        error: null,
        payload: null,
      );

  @override
  Future<List<KedbMatchDto>> kedbMatchesForTicket(int ticketsId) async =>
      matches;

  @override
  Future<KedbHitResultDto> kedbRecordHit({
    required int keId,
    required int ticketsId,
    required String action,
  }) async {
    hits.add((keId, ticketsId, action));
    return KedbHitResultDto(
      ok: true,
      snippet: action == 'used'
          ? 'Known error: Zebra\n\nWorkaround applied: Restart the spooler'
          : null,
    );
  }

  @override
  Future<ChangeScheduleDto> getChangeSchedule(int changeId) async =>
      schedule ?? (throw UnimplementedError());
}

final _allPlugins = Capabilities.fromJson(const {
  'glpikedb': {
    'version': '0.1.0',
    'features': {'match': true, 'search': true, 'hits': true},
  },
  'glpientitle': {
    'version': '0.2.0',
    'features': {'entitlement': true},
  },
  'glpichange': {
    'version': '0.1.0',
    'features': {'calendar': true, 'schedule': true, 'freezes': true},
  },
});

TicketDetail _ticket({
  String itemtype = itilTicket,
  int? serverId = 42,
  int? entityId = 7,
}) => TicketDetail(
  localId: 'L1',
  serverId: serverId,
  itemtype: itemtype,
  name: 'Printer down',
  content: '',
  status: 1,
  priority: 3,
  urgency: 3,
  impact: 3,
  type: 1,
  categoryId: null,
  categoryName: null,
  entityId: entityId,
  entityName: 'Acme',
  locationName: null,
  recipientName: null,
  dateCreation: null,
  dateMod: null,
  timeToResolve: null,
  actors: const [],
);

EntitlementDto _freshEntitlement() => EntitlementDto.fromJson(const {
  'state': 'fresh',
  'age': 0,
  'error': null,
  'payload': {
    'contracts': [
      {
        'contract': 'MSP Gold',
        'billing_model': 'Block Hours',
        'is_labor_contract': true,
        'block': {'consumed_hours': 12, 'pool_hours': 40},
      },
    ],
    'has_labor_coverage': true,
    'lapsed': [
      {'contract': 'Old Deal', 'model': 'Fixed Fee', 'ended': '2026-06-30'},
    ],
  },
});

Widget _host({
  required Widget body,
  required Capabilities caps,
  GlpiApi? api,
  List<FreezeDto> freezes = const [],
}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) =>
            Scaffold(body: SingleChildScrollView(child: body)),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      authControllerProvider.overrideWith(_StubAuth.new),
      capabilitiesProvider.overrideWith((ref) async => caps),
      // A technician-shaped profile: these tests are about the sections, not
      // about rights gating (which has its own file), and the composer is
      // hidden outright without the followup/task rights.
      rightsProvider.overrideWith(
        (ref) async => Rights.fromSessionJson(const {
          'active_profile': {
            'interface': 'central',
            'rights': {'ticket': 429063, 'followup': 64535, 'task': 64535},
          },
        }),
      ),
      glpiApiProvider.overrideWithValue(api),
      connectivityProvider.overrideWith((ref) => Stream.value(true)),
      // Always overridden so no test arms the real provider's cache timer.
      activeFreezesProvider.overrideWith((ref) async => freezes),
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
  group('EntitlementCard', () {
    testWidgets('renders contract, gauge and lapsed warning when fresh', (
      tester,
    ) async {
      final api = _Phase2Api(entitlement: _freshEntitlement());
      await tester.pumpWidget(
        _host(
          body: EntitlementCard(item: _ticket()),
          caps: _allPlugins,
          api: api,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('MSP Gold'), findsOneWidget);
      expect(find.text('12 of 40 hours used'), findsOneWidget);
      expect(find.text('Bills this ticket'), findsOneWidget);
      expect(
        find.textContaining('Old Deal (Fixed Fee) ran out on 2026-06-30'),
        findsOneWidget,
      );
      // Fresh data carries no age note — that line is `entitleStale`, and it
      // is the whole of what distinguishes this from the stale case below.
      expect(find.textContaining('Answered'), findsNothing);
    });

    testWidgets('states the age honestly when stale', (tester) async {
      final api = _Phase2Api(
        entitlement: EntitlementDto.fromJson(const {
          'state': 'stale',
          'age': 7200,
          'error': 'ERPNext unreachable',
          'payload': {
            'contracts': [
              {'contract': 'MSP Gold', 'billing_model': 'Fixed Fee'},
            ],
            'has_labor_coverage': true,
          },
        }),
      );
      await tester.pumpWidget(
        _host(
          body: EntitlementCard(item: _ticket()),
          caps: _allPlugins,
          api: api,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Answered 2h ago'), findsOneWidget);
    });

    testWidgets('silent renders nothing at all', (tester) async {
      await tester.pumpWidget(
        _host(
          body: EntitlementCard(item: _ticket()),
          caps: _allPlugins,
          api: _Phase2Api(), // answers silent
        ),
      );
      await tester.pumpAndSettle();

      // The card's own heading: naming anything else here is an assertion
      // that passes whether or not the card rendered.
      expect(find.text('Cover'), findsNothing);
    });

    testWidgets('missing capability renders nothing', (tester) async {
      final api = _Phase2Api(entitlement: _freshEntitlement());
      await tester.pumpWidget(
        _host(
          body: EntitlementCard(item: _ticket()),
          caps: Capabilities.empty,
          api: api,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('MSP Gold'), findsNothing);
    });

    testWidgets('shows the uncontracted-block warning without coverage', (
      tester,
    ) async {
      final api = _Phase2Api(
        entitlement: EntitlementDto.fromJson(const {
          'state': 'fresh',
          'age': 0,
          'payload': {
            'contracts': [],
            'has_labor_coverage': false,
            'uncontracted': {'policy': 'Block Responses', 'rate': 0},
          },
        }),
      );
      await tester.pumpWidget(
        _host(
          body: EntitlementCard(item: _ticket()),
          caps: _allPlugins,
          api: api,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('No contract covers this entity'),
        findsOneWidget,
      );
      expect(find.textContaining('This work is not covered'), findsOneWidget);
    });
  });

  group('KedbBannerSection', () {
    KedbMatchDto match() => KedbMatchDto.fromJson(const {
      'id': 18,
      'title': 'Zebra label printer drops jobs',
      'status': 'active',
      'workaround': 'Restart the spooler service.',
      'has_workaround': true,
      'reasons': ['category'],
      'weight': 100,
    });

    testWidgets('shows the match with its workaround actions', (tester) async {
      final api = _Phase2Api(matches: [match()]);
      await tester.pumpWidget(
        _host(
          body: KedbBannerSection(item: _ticket()),
          caps: _allPlugins,
          api: api,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Zebra label printer drops jobs'),
        findsOneWidget,
      );
      expect(find.text('Use workaround'), findsOneWidget);
      expect(find.text('Dismiss'), findsOneWidget);
    });

    testWidgets('Dismiss records the hit and hides the card', (tester) async {
      final api = _Phase2Api(matches: [match()]);
      await tester.pumpWidget(
        _host(
          body: KedbBannerSection(item: _ticket()),
          caps: _allPlugins,
          api: api,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Zebra'), findsNothing);
      expect(api.hits.single, (18, 42, 'dismissed'));
    });

    testWidgets('Use workaround records the hit and stages the composer text', (
      tester,
    ) async {
      final api = _Phase2Api(matches: [match()]);
      await tester.pumpWidget(
        _host(
          body: KedbBannerSection(item: _ticket()),
          caps: _allPlugins,
          api: api,
        ),
      );
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(KedbBannerSection)),
      );
      await tester.tap(find.text('Use workaround'));
      await tester.pumpAndSettle();

      expect(api.hits.single, (18, 42, 'used'));
      expect(
        container.read(pendingComposerTextProvider),
        contains('Workaround applied'),
      );
      // A used offer is handled — the card leaves the ticket.
      expect(find.textContaining('Zebra'), findsNothing);
      // Let the confirmation snackbar's auto-dismiss timer run out.
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('missing capability renders nothing', (tester) async {
      final api = _Phase2Api(matches: [match()]);
      await tester.pumpWidget(
        _host(
          body: KedbBannerSection(item: _ticket()),
          caps: Capabilities.empty,
          api: api,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Zebra'), findsNothing);
    });

    testWidgets('an unsynced ticket renders nothing', (tester) async {
      final api = _Phase2Api(matches: [match()]);
      await tester.pumpWidget(
        _host(
          body: KedbBannerSection(item: _ticket(serverId: null)),
          caps: _allPlugins,
          api: api,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Zebra'), findsNothing);
    });
  });

  group('ChangeScheduleSection', () {
    testWidgets('renders window, freeze and dismissed collision on a Change', (
      tester,
    ) async {
      final api = _Phase2Api(
        schedule: ChangeScheduleDto.fromJson(const {
          'window': {
            'begin': '2026-09-01 22:00:00',
            'end': '2026-09-02 02:00:00',
            'source': 'explicit',
            'source_label': 'Planned dates',
          },
          'collisions': [
            {
              'id': 7,
              'kind': 'shared_ci',
              'other_itemtype': 'Change',
              'other_items_id': 275,
              'is_dismissed': 1,
              'dismiss_reason': 'Coordinated',
            },
          ],
          'freezes': [
            {
              'id': 25,
              'title': 'Quarter close',
              'begin': '2026-09-28 00:00:00',
              'end': '2026-10-02 00:00:00',
              'severity': 'policy',
            },
          ],
        }),
      );
      await tester.pumpWidget(
        _host(
          body: ChangeScheduleSection(
            item: _ticket(itemtype: itilChange, serverId: 276),
          ),
          caps: _allPlugins,
          api: api,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Schedule'), findsOneWidget);
      expect(find.textContaining('Planned dates'), findsOneWidget);
      expect(find.textContaining('Quarter close'), findsOneWidget);
      expect(find.textContaining('Change #275'), findsOneWidget);
      expect(find.textContaining('dismissed: Coordinated'), findsOneWidget);
    });

    testWidgets('renders nothing on a plain Ticket', (tester) async {
      await tester.pumpWidget(
        _host(
          body: ChangeScheduleSection(item: _ticket()),
          caps: _allPlugins,
          api: _Phase2Api(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Schedule'), findsNothing);
    });
  });

  group('Composer prefill', () {
    testWidgets('a staged workaround snippet lands in the reply field', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          body: Composer(ticket: _ticket()),
          caps: _allPlugins,
          api: _Phase2Api(),
        ),
      );
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(Composer)),
      );
      container
          .read(pendingComposerTextProvider.notifier)
          .set('Known error: Zebra\n\nWorkaround applied: Restart the spooler');
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Known error: Zebra\n\nWorkaround applied: Restart the spooler',
        ),
        findsOneWidget,
      );
      // Consumed on arrival — the handshake must not replay on rebuild.
      expect(container.read(pendingComposerTextProvider), isNull);
    });
  });

  group('FreezeWarning', () {
    final freeze = FreezeDto.fromJson(const {
      'id': 25,
      'title': 'Quarter close',
      'begin': '2026-09-28 00:00:00',
      'end': '2026-10-02 00:00:00',
      'severity': 'policy',
    });

    testWidgets('warns when the picked window crosses an active freeze', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          body: FreezeWarning(
            begin: DateTime(2026, 9, 29, 9),
            end: DateTime(2026, 9, 29, 11),
          ),
          caps: _allPlugins,
          freezes: [freeze],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Inside the Quarter close freeze'),
        findsOneWidget,
      );
    });

    testWidgets('stays silent outside the freeze', (tester) async {
      await tester.pumpWidget(
        _host(
          body: FreezeWarning(
            begin: DateTime(2026, 9, 10, 9),
            end: DateTime(2026, 9, 10, 11),
          ),
          caps: _allPlugins,
          freezes: [freeze],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('freeze'), findsNothing);
    });
  });
}
