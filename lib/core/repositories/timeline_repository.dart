import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../api/glpi_api.dart';
import '../api/itil_type.dart';
import '../db/app_database.dart';
import '../models/timeline_entry.dart';

const _uuid = Uuid();

/// Reads and syncs a ticket's merged timeline. The GLPI `/Timeline` endpoint is
/// authoritative, so a refresh is a replace-set: synced rows absent from the
/// response are deleted; locally-created rows (serverId == null, future M3)
/// are preserved.
class TimelineRepository {
  TimelineRepository(this._db, this._api);

  final AppDatabase _db;
  final GlpiApi _api;

  Stream<List<TimelineEntry>> watchTimeline(String ticketLocalId) {
    final query = _db.select(_db.timelineItems)
      ..where((t) => t.ticketLocalId.equals(ticketLocalId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.dateCreation, mode: OrderingMode.asc),
      ]);
    return query.watch().map((rows) => rows.map(_toEntry).toList());
  }

  TimelineEntry _toEntry(TimelineItem row) => TimelineEntry(
    localId: row.localId,
    serverId: row.serverId,
    type: row.itemType,
    content: row.content,
    isPrivate: row.isPrivate,
    dateCreation: row.dateCreation == null
        ? null
        : DateTime.tryParse(row.dateCreation!),
    authorId: row.authorId,
    authorName: row.authorName,
    taskDuration: row.taskDuration,
    taskState: row.taskState,
    solutionStatus: row.solutionStatus,
    validationStatus: row.validationStatus,
    approverId: row.approverId,
    approverType: row.approverType,
    approvalComment: row.approvalComment,
  );

  Future<void> refreshTimeline(
    String ticketLocalId,
    int ticketServerId, {
    String itemtype = itilTicket,
  }) async {
    final entries = await _api.getTimeline(ticketServerId, itemtype: itemtype);
    await _db.transaction(() async {
      // Replace-set: drop existing synced rows for this ticket, keep pending
      // (serverId == null) local rows.
      await (_db.delete(_db.timelineItems)..where(
            (t) =>
                t.ticketLocalId.equals(ticketLocalId) & t.serverId.isNotNull(),
          ))
          .go();
      for (final e in entries) {
        await _db
            .into(_db.timelineItems)
            .insert(
              TimelineItemsCompanion.insert(
                localId: _uuid.v4(),
                ticketLocalId: ticketLocalId,
                serverId: Value(e.id),
                itemType: e.type,
                content: Value(e.content),
                isPrivate: Value(e.isPrivate),
                dateCreation: Value(e.dateCreation),
                authorId: Value(e.authorId),
                authorName: Value(e.authorName),
                taskDuration: Value(e.taskDuration),
                taskState: Value(e.taskState),
                solutionStatus: Value(e.solutionStatus),
                validationStatus: Value(e.validationStatus),
                approverId: Value(e.approverId),
                approverType: Value(e.approverType),
                approvalComment: Value(e.approvalComment),
              ),
            );
      }
    });
  }
}
