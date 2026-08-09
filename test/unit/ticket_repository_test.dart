import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/dto/ticket_dto.dart';
import 'package:glpi_mobile/core/api/errors.dart';
import 'package:glpi_mobile/core/api/glpi_api.dart';
import 'package:glpi_mobile/core/api/rsql.dart';
import 'package:glpi_mobile/core/db/app_database.dart';
import 'package:glpi_mobile/core/repositories/ticket_repository.dart';

import '../support/fake_glpi_api.dart';

/// In-memory fake serving the captured ticket_list fixture.
class FakeGlpiApi with FakeGlpiApiDefaults {
  FakeGlpiApi(this._tickets);
  final List<TicketDto> _tickets;
  int searchCalls = 0;
  int getTicketCalls = 0;

  @override
  Future<Page<TicketDto>> searchTickets({
    Rsql? filter,
    String sort = 'date_mod:desc',
    int start = 0,
    int limit = 100,
    String itemtype = 'Ticket',
  }) async {
    searchCalls++;
    final slice = _tickets.skip(start).take(limit).toList();
    return Page(slice, _tickets.length);
  }

  @override
  Future<TicketDto> getTicket(int id, {String itemtype = 'Ticket'}) async {
    getTicketCalls++;
    final match = _tickets.where((t) => t.id == id);
    if (match.isEmpty) throw const GlpiNotFoundError('no such ticket');
    return match.first;
  }
}

List<TicketDto> loadFixtureTickets() {
  final raw =
      jsonDecode(File('test/fixtures/ticket_list.json').readAsStringSync())
          as List<Object?>;
  return raw.whereType<Map<String, Object?>>().map(TicketDto.fromJson).toList();
}

void main() {
  _pruneTests();

  // Scoped so this setUp does not also run for the prune group, which opens
  // its own database: two live AppDatabase instances at once is exactly what
  // drift warns about.
  group('TicketRepository', () {
    late AppDatabase db;
    late FakeGlpiApi api;
    late TicketRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      api = FakeGlpiApi(loadFixtureTickets());
      repo = TicketRepository(db, api);
    });

    tearDown(() => db.close());

    test('refreshQueue upserts all open tickets from the API', () async {
      final synced = await repo.refreshQueue();
      expect(synced, greaterThan(0));
      final items = await repo.watchQueue().first;
      // Fixture has 24 tickets, all open (status 1).
      expect(items, hasLength(24));
      expect(items.every((t) => t.status == 1), isTrue);
    });

    test('team roles map to Mine / Unassigned correctly', () async {
      await repo.refreshQueue();
      final items = await repo.watchQueue().first;
      final assignedToGlpi = items
          .where((t) => t.assignedToUser(2))
          .map((t) => t.serverId)
          .toSet();
      // Seeded: tickets 1, 3, 7 assigned to user glpi (id 2).
      expect(assignedToGlpi, containsAll(<int>{1, 3, 7}));
      final unassigned = items.where((t) => t.isUnassigned).length;
      expect(unassigned, 24 - assignedToGlpi.length);
    });

    test(
      're-sync is idempotent (upsert by server id, no duplicates)',
      () async {
        await repo.refreshQueue();
        await repo.refreshQueue();
        final items = await repo.watchQueue().first;
        expect(items, hasLength(24));
        // Team rows replaced, not duplicated.
        final teamRows = await db.select(db.ticketTeam).get();
        final ticket3 = items.firstWhere((t) => t.serverId == 3);
        expect(ticket3.assignedUserIds, contains(2));
        expect(teamRows.where((m) => m.role == 'assigned'), hasLength(3));
      },
    );

    test('watchQueue emits again after a refresh (reactive)', () async {
      final emissions = <int>[];
      final sub = repo.watchQueue().listen(
        (items) => emissions.add(items.length),
      );
      await Future<void>.delayed(Duration.zero);
      await repo.refreshQueue();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();
      expect(emissions.last, 24);
    });

    // --- Push deep-linking helpers ---

    test('localIdForServerId returns null before caching, id after', () async {
      expect(await repo.localIdForServerId(3), isNull);
      await repo.refreshQueue();
      final localId = await repo.localIdForServerId(3);
      expect(localId, isNotNull);
      final row = await repo.watchTicket(localId!).first;
      expect(row?.serverId, 3);
    });

    test('openByServerId fetches + caches a not-yet-seen ticket', () async {
      // Cache miss → fetches via the API and mints a local row.
      expect(await repo.localIdForServerId(3), isNull);
      final localId = await repo.openByServerId(3);
      expect(localId, isNotNull);
      expect(api.getTicketCalls, 1);
      // Second call is a cache hit (no extra fetch).
      final again = await repo.openByServerId(3);
      expect(again, localId);
      expect(api.getTicketCalls, 1);
    });

    test('openByServerId returns null when the fetch fails', () async {
      expect(await repo.openByServerId(999999), isNull);
    });
  });
}

void _pruneTests() {
  group('refreshQueue prunes rows that left the scope', () {
    late AppDatabase db;
    tearDown(() => db.close());

    Future<void> seedCached(AppDatabase d, int serverId, String localId) => d
        .into(d.tickets)
        .insert(
          TicketsCompanion.insert(
            localId: localId,
            serverId: Value(serverId),
            name: 'cached $serverId',
            status: 1,
          ),
        );

    test('drops a ticket the server no longer returns', () async {
      db = AppDatabase(NativeDatabase.memory());
      // Two cached tickets; the server only knows about one now — the other
      // was closed, reassigned, or belongs to the entity we just left.
      await seedCached(db, 100, 'keep');
      await seedCached(db, 200, 'gone');
      final api = FakeGlpiApi([
        TicketDto.fromJson(const {
          'id': 100,
          'name': 'still open',
          'content': '',
          'status': {'id': 1, 'name': 'New'},
          'priority': 3,
          'urgency': 3,
          'impact': 3,
          'type': 1,
        }),
      ]);
      await TicketRepository(db, api).refreshQueue();

      final rows = await db.select(db.tickets).get();
      expect(rows.map((t) => t.serverId), [100]);
    });

    test('never prunes a row an outbox op still owns', () async {
      db = AppDatabase(NativeDatabase.memory());
      await seedCached(db, 200, 'queued');
      await db
          .into(db.pendingOps)
          .insert(
            PendingOpsCompanion.insert(
              opUuid: 'op-1',
              opType: 'followupCreate',
              ticketLocalId: 'queued',
              ticketServerId: 200,
              createdAt: DateTime.now().toIso8601String(),
            ),
          );

      await TicketRepository(db, FakeGlpiApi(const [])).refreshQueue();

      // Deleting it would strand the queued reply.
      expect(await db.select(db.tickets).get(), hasLength(1));
    });
  });
}
