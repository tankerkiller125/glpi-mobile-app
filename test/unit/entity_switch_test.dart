import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/hl_client.dart';
import 'package:glpi_mobile/core/db/app_database.dart';
import 'package:glpi_mobile/core/db/cache_reset.dart';
import 'package:glpi_mobile/core/sync/outbox_op.dart';
import 'package:glpi_mobile/core/sync/outbox_writer.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('ops are pinned to the entity they were composed in', () {
    test('enqueue stamps the active entity', () async {
      var entity = (id: 4, recursive: false);
      final writer = OutboxWriter(db, entity: () => entity);

      await db
          .into(db.tickets)
          .insert(
            TicketsCompanion.insert(
              localId: 't1',
              serverId: const Value(3),
              name: 'In Delta',
              status: 1,
            ),
          );
      await writer.addFollowup(
        ticketLocalId: 't1',
        ticketServerId: 3,
        content: 'from Delta',
        isPrivate: false,
        authorId: 2,
        authorName: 'glpi',
      );

      // The technician moves to another entity before this drains.
      entity = (id: 1, recursive: true);
      await writer.addFollowup(
        ticketLocalId: 't1',
        ticketServerId: 3,
        content: 'from Acme',
        isPrivate: false,
        authorId: 2,
        authorName: 'glpi',
      );

      final ops = await db.select(db.pendingOps).get();
      expect(ops, hasLength(2));
      // Each op keeps its own entity — the first must not follow the switch.
      expect(ops.first.entityId, 4);
      expect(ops.first.entityRecursive, isFalse);
      expect(ops.last.entityId, 1);
      expect(ops.last.entityRecursive, isTrue);
    });

    test(
      'EntityScope overrides the ambient context for its body only',
      () async {
        expect(EntityScope.current, isNull);
        await EntityScope.run(7, true, () async {
          expect(EntityScope.current?.id, 7);
          expect(EntityScope.current?.recursive, isTrue);
          // Survives an await, which is the whole point of using a Zone.
          await Future<void>.delayed(Duration.zero);
          expect(EntityScope.current?.id, 7);
        });
        expect(EntityScope.current, isNull);
      },
    );

    test('a null entity leaves the ambient context alone', () async {
      await EntityScope.run(9, false, () async {
        await EntityScope.run(null, null, () async {
          // Older ops (queued before entities were pinned) inherit, not clear.
          expect(EntityScope.current?.id, 9);
        });
      });
    });
  });

  group('switching context clears synced caches but keeps unsynced work', () {
    test('drops server rows, keeps everything the outbox owns', () async {
      // A fully-synced ticket from the old entity.
      await db
          .into(db.tickets)
          .insert(
            TicketsCompanion.insert(
              localId: 'synced',
              serverId: const Value(10),
              name: 'Old entity ticket',
              status: 1,
            ),
          );
      // A ticket composed offline, still queued.
      await db
          .into(db.tickets)
          .insert(
            TicketsCompanion.insert(
              localId: 'offline',
              name: 'Written on the road',
              status: 1,
            ),
          );
      await db
          .into(db.pendingOps)
          .insert(
            PendingOpsCompanion.insert(
              opUuid: 'op-1',
              opType: OpType.ticketCreate,
              ticketLocalId: 'offline',
              ticketServerId: 0,
              createdAt: DateTime.now().toIso8601String(),
              entityId: const Value(4),
            ),
          );
      // Reference data belongs to the old entity.
      await db
          .into(db.dropdownItems)
          .insert(
            DropdownItemsCompanion.insert(
              kind: 'ITILCategory',
              serverId: 1,
              name: 'Network',
            ),
          );
      // A pinned KB article is a deliberate offline choice — it must survive.
      await db
          .into(db.kbArticles)
          .insert(
            KbArticlesCompanion.insert(
              serverId: const Value(5),
              name: 'VPN runbook',
              keepOffline: const Value(true),
            ),
          );
      await db
          .into(db.kbArticles)
          .insert(
            KbArticlesCompanion.insert(
              serverId: const Value(6),
              name: 'Merely cached',
            ),
          );

      await clearSyncedCaches(db);

      final tickets = await db.select(db.tickets).get();
      expect(tickets.map((t) => t.localId), ['offline']);
      expect(await db.select(db.pendingOps).get(), hasLength(1));
      expect(await db.select(db.dropdownItems).get(), isEmpty);
      final kb = await db.select(db.kbArticles).get();
      expect(kb.map((a) => a.serverId), [5]);
      // Sync markers are reset so every scope refetches.
      expect(await db.select(db.syncState).get(), isEmpty);
    });

    test('keeps a queued edit to an already-synced ticket', () async {
      await db
          .into(db.tickets)
          .insert(
            TicketsCompanion.insert(
              localId: 'edited',
              serverId: const Value(11),
              name: 'Has a queued reply',
              status: 1,
            ),
          );
      await db
          .into(db.pendingOps)
          .insert(
            PendingOpsCompanion.insert(
              opUuid: 'op-2',
              opType: OpType.followupCreate,
              ticketLocalId: 'edited',
              ticketServerId: 11,
              createdAt: DateTime.now().toIso8601String(),
            ),
          );

      await clearSyncedCaches(db);

      // Deleting it would strand the op against a missing row.
      expect(await db.select(db.tickets).get(), hasLength(1));
    });
  });
}
