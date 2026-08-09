import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// Persistent task timer. Stores only the start timestamp, so elapsed time is
/// recomputed on read and survives app kill/restart. One active timer at a time
/// in v1 (starting a new one replaces any existing).
class TimerService {
  TimerService(this._db);

  final AppDatabase _db;

  Stream<ActiveTimer?> watchActive() => _db
      .select(_db.activeTimers)
      .watch()
      .map((rows) => rows.isEmpty ? null : rows.first);

  Future<ActiveTimer?> current() async {
    final rows = await _db.select(_db.activeTimers).get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> start({
    required String ticketLocalId,
    required int ticketServerId,
    required String ticketName,
  }) async {
    await _db.transaction(() async {
      await _db.delete(_db.activeTimers).go(); // single active timer
      await _db
          .into(_db.activeTimers)
          .insert(
            ActiveTimersCompanion.insert(
              ticketLocalId: ticketLocalId,
              ticketServerId: ticketServerId,
              ticketName: Value(ticketName),
              startedAt: DateTime.now().toUtc().toIso8601String(),
            ),
          );
    });
  }

  /// Stops the timer and returns the elapsed whole minutes (rounded up).
  Future<int> stop() async {
    final timer = await current();
    if (timer == null) return 0;
    await _db.delete(_db.activeTimers).go();
    final started = DateTime.tryParse(timer.startedAt);
    if (started == null) return 0;
    final elapsed = DateTime.now().toUtc().difference(started.toUtc());
    return (elapsed.inSeconds / 60).ceil();
  }
}

int elapsedSeconds(ActiveTimer timer, {DateTime? now}) {
  final started = DateTime.tryParse(timer.startedAt);
  if (started == null) return 0;
  final ref = (now ?? DateTime.now()).toUtc();
  return ref.difference(started.toUtc()).inSeconds.clamp(0, 1 << 31);
}
