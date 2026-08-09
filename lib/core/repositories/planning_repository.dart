import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../api/glpi_api.dart';
import '../db/app_database.dart';
import '../models/planning_event.dart';
import '../utils/formatting.dart';

const _uuid = Uuid();

/// The calendar: reads planning events from the local DB (reactive) and syncs
/// them from the plugin's aggregated feed. Locally-created events (offline) are
/// kept until their outbox op drains, exactly like pending ITIL links.
class PlanningRepository {
  PlanningRepository(this._db, this._api);

  final AppDatabase _db;
  final GlpiApi _api;

  /// `YYYY-MM-DD` for the feed's range parameters.
  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Events overlapping [day], ordered all-day first then by start time.
  Stream<List<PlanningEvent>> watchDay(DateTime day) {
    final start = '${dayKey(day)} 00:00:00';
    final end = '${dayKey(day)} 23:59:59';
    // An event belongs to the day if it starts before the day ends and ends
    // after the day starts (covers multi-day spans).
    final q = _db.select(_db.planningEvents)
      ..where(
        (e) =>
            e.begin.isSmallerOrEqualValue(end) &
            e.end.isBiggerOrEqualValue(start),
      )
      ..orderBy([
        (e) => OrderingTerm(expression: e.isAllDay, mode: OrderingMode.desc),
        (e) => OrderingTerm(expression: e.begin),
      ]);
    return q.watch().map((rows) => rows.map(_toModel).toList());
  }

  /// Every cached event in a window (the week/agenda view).
  Stream<List<PlanningEvent>> watchRange(DateTime from, DateTime to) {
    final start = '${dayKey(from)} 00:00:00';
    final end = '${dayKey(to)} 23:59:59';
    final q = _db.select(_db.planningEvents)
      ..where(
        (e) =>
            e.begin.isSmallerOrEqualValue(end) &
            e.end.isBiggerOrEqualValue(start),
      )
      ..orderBy([(e) => OrderingTerm(expression: e.begin)]);
    return q.watch().map((rows) => rows.map(_toModel).toList());
  }

  PlanningEvent _toModel(PlanningEventRow r) => PlanningEvent(
    localId: r.localId,
    eventItemtype: r.eventItemtype,
    eventServerId: r.eventServerId,
    parentItemtype: r.parentItemtype,
    parentServerId: r.parentServerId,
    parentName: r.parentName ?? '',
    title: r.title,
    begin: parseGlpiDateTime(r.begin) ?? DateTime.now(),
    end: parseGlpiDateTime(r.end) ?? DateTime.now(),
    isAllDay: r.isAllDay,
    state: r.state,
    pending: r.pending,
  );

  /// Pull the feed for a window and replace the synced rows in it, keeping any
  /// row the outbox still owns.
  Future<void> refresh(DateTime from, DateTime to) async {
    final events = await _api.fetchPlanning(dayKey(from), dayKey(to));
    final start = '${dayKey(from)} 00:00:00';
    final end = '${dayKey(to)} 23:59:59';
    await _db.transaction(() async {
      await (_db.delete(_db.planningEvents)..where(
            (e) =>
                e.pending.equals(false) &
                e.begin.isSmallerOrEqualValue(end) &
                e.end.isBiggerOrEqualValue(start),
          ))
          .go();
      for (final e in events) {
        // A locally-queued edit of the same event wins until it drains.
        final queued =
            await (_db.select(_db.planningEvents)..where(
                  (r) =>
                      r.eventItemtype.equals(e.eventItemtype) &
                      r.eventServerId.equals(e.eventId) &
                      r.pending.equals(true),
                ))
                .getSingleOrNull();
        if (queued != null) continue;
        await _db
            .into(_db.planningEvents)
            .insert(
              PlanningEventsCompanion.insert(
                localId: _uuid.v4(),
                eventItemtype: e.eventItemtype,
                eventServerId: Value(e.eventId),
                parentItemtype: Value(e.parentItemtype),
                parentServerId: Value(e.parentId),
                parentName: Value(e.parentName),
                title: Value(e.title),
                begin: e.begin,
                end: e.end,
                isAllDay: Value(e.isAllDay),
                state: Value(e.state),
              ),
            );
      }
    });
  }
}
