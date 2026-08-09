import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../api/glpi_api.dart';
import '../db/app_database.dart';
import '../models/itil_link.dart';
import '../sync/outbox_op.dart';

const _uuid = Uuid();

/// Relationships between ITIL objects (ticket↔ticket, change↔ticket, …) and the
/// Change/Problem analysis fields — both cached locally so they read offline,
/// and both written through the outbox.
class ItilLinkRepository {
  ItilLinkRepository(this._db, this._api);

  final AppDatabase _db;
  final GlpiApi _api;

  /// Reactive links for an object.
  Stream<List<ItilLink>> watchLinks(String ownerLocalId) {
    final q = _db.select(_db.itilLinks)
      ..where((l) => l.ownerLocalId.equals(ownerLocalId))
      ..orderBy([(l) => OrderingTerm(expression: l.targetItemtype)]);
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          ItilLink(
            localId: r.localId,
            itemtype: r.targetItemtype,
            serverId: r.targetServerId,
            name: r.targetName,
            status: r.targetStatus,
            linkType: r.linkType,
            pending: r.pending,
          ),
      ],
    );
  }

  /// Pull the server's link set, replacing the synced rows but keeping any that
  /// are still queued locally.
  Future<void> refreshLinks(
    String ownerLocalId,
    int ownerServerId, {
    required String itemtype,
  }) async {
    final links = await _api.listItilLinks(itemtype, ownerServerId);
    await _db.transaction(() async {
      await (_db.delete(_db.itilLinks)..where(
            (l) =>
                l.ownerLocalId.equals(ownerLocalId) & l.pending.equals(false),
          ))
          .go();
      for (final l in links) {
        // Skip any the outbox is still holding — the local row wins until sent.
        final queued =
            await (_db.select(_db.itilLinks)..where(
                  (r) =>
                      r.ownerLocalId.equals(ownerLocalId) &
                      r.targetItemtype.equals(l.itemtype) &
                      r.targetServerId.equals(l.id),
                ))
                .getSingleOrNull();
        if (queued != null) continue;
        await _db
            .into(_db.itilLinks)
            .insert(
              ItilLinksCompanion.insert(
                localId: _uuid.v4(),
                ownerLocalId: ownerLocalId,
                targetItemtype: l.itemtype,
                targetServerId: l.id,
                targetName: Value(l.name),
                targetStatus: Value(l.status),
                linkType: Value(l.linkType),
              ),
            );
      }
    });
  }

  /// Reactive analysis fields (Change/Problem).
  Stream<Map<String, String>> watchExtra(String ownerLocalId) {
    final q = _db.select(_db.itilExtras)
      ..where((e) => e.ownerLocalId.equals(ownerLocalId));
    return q.watchSingleOrNull().map((row) {
      if (row == null) return const <String, String>{};
      final decoded = jsonDecode(row.fieldsJson) as Map<String, Object?>;
      return {for (final e in decoded.entries) e.key: '${e.value ?? ''}'};
    });
  }

  /// Pull the analysis fields from the server into the local cache.
  ///
  /// Skipped while an edit is still queued: the server copy is stale by
  /// definition then, and overwriting would silently discard the local text.
  Future<void> refreshExtra(
    String ownerLocalId,
    int ownerServerId, {
    required String itemtype,
  }) async {
    final queued =
        await (_db.select(_db.pendingOps)..where(
              (o) =>
                  o.ticketLocalId.equals(ownerLocalId) &
                  o.opType.equals(OpType.extraPatch) &
                  o.status.isNotIn([OpStatus.done]),
            ))
            .get();
    if (queued.isNotEmpty) return;

    final extra = await _api.getItilExtra(itemtype, ownerServerId);
    await _db
        .into(_db.itilExtras)
        .insertOnConflictUpdate(
          ItilExtrasCompanion.insert(
            ownerLocalId: ownerLocalId,
            fieldsJson: Value(jsonEncode(extra.fields)),
          ),
        );
  }
}
