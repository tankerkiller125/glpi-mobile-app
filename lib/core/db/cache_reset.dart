import 'package:drift/drift.dart';

import '../sync/outbox_op.dart';
import 'app_database.dart';

/// Drops everything mirrored from the server, keeping everything the outbox
/// still owns.
///
/// Switching entity (or profile) changes what GLPI will even show: the cached
/// queue, categories, locations and assets all belong to the entity they were
/// pulled in, and the repositories only ever upsert — nothing prunes rows that
/// fell out of scope. Without this, a technician switching entity would keep
/// seeing the previous entity's tickets forever.
///
/// The rule is: **delete synced rows, keep unsynced work.** A ticket composed
/// offline, a queued reply, an attachment still uploading — all survive, along
/// with their pending ops, and drain into the entity they were written in.
Future<void> clearSyncedCaches(AppDatabase db) async {
  await db.transaction(() async {
    // Local ids still referenced by an unfinished op: their rows must live.
    final live = <String>{};
    final ops = await (db.select(
      db.pendingOps,
    )..where((o) => o.status.isNotValue(OpStatus.done))).get();
    for (final op in ops) {
      live.add(op.ticketLocalId);
      final target = op.targetLocalId;
      if (target != null) live.add(target);
    }

    // ITIL objects: keep the ones an op owns (offline creates and their edits).
    await (db.delete(
      db.tickets,
    )..where((t) => t.serverId.isNotNull() & t.localId.isNotIn(live))).go();
    // Actors and timeline entries belong to a ticket; drop the orphans and any
    // fully-synced entry, keeping rows an op is still working on.
    final keptTickets = (await db.select(db.tickets).get())
        .map((t) => t.localId)
        .toSet();
    await (db.delete(
      db.ticketTeam,
    )..where((r) => r.ticketLocalId.isNotIn(keptTickets))).go();
    await (db.delete(db.timelineItems)..where(
          (r) =>
              r.ticketLocalId.isNotIn(keptTickets) |
              (r.serverId.isNotNull() & r.localId.isNotIn(live)),
        ))
        .go();
    await (db.delete(db.attachments)..where(
          (a) =>
              a.ticketLocalId.isNotIn(keptTickets) |
              (a.opUuid.isNull() & a.localId.isNotIn(live)),
        ))
        .go();
    await (db.delete(db.itilLinks)..where((l) => l.pending.equals(false))).go();
    await (db.delete(
      db.itilExtras,
    )..where((e) => e.ownerLocalId.isNotIn(live))).go();

    // Planning / projects / tools / assets: same rule via their pending flag.
    await (db.delete(
      db.planningEvents,
    )..where((e) => e.pending.equals(false))).go();
    await (db.delete(
      db.projectTasks,
    )..where((t) => t.pending.equals(false))).go();
    await db.delete(db.projects).go();
    await (db.delete(db.reminders)..where((r) => r.pending.equals(false))).go();
    await (db.delete(
      db.catalogItems,
    )..where((c) => c.pending.equals(false))).go();

    // Reference data is entity-scoped in GLPI (categories and locations differ
    // per entity), so it must be refetched rather than reused.
    await db.delete(db.dropdownItems).go();

    // Knowledge base: articles are entity-visible too, but a pinned article was
    // deliberately kept for offline reading — leave those alone.
    await (db.delete(
      db.kbArticles,
    )..where((a) => a.keepOffline.equals(false))).go();
    await db.delete(db.kbCategories).go();

    // Force every "have I synced this scope yet" marker to re-run.
    await db.delete(db.syncState).go();
  });
}
