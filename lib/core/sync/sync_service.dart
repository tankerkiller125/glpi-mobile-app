import 'dart:async';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'outbox_drainer.dart';
import 'outbox_op.dart';
import 'sync_status.dart';

/// Orchestrates outbox draining: single-flight, kicked on enqueue / connectivity
/// / manual refresh, and exposes a reactive [SyncStatus].
class SyncService {
  SyncService(this._db, this._drainer);

  final AppDatabase _db;
  final OutboxDrainer _drainer;

  bool _draining = false;
  bool _rerun = false;
  SyncPhase _phase = SyncPhase.idle;
  DateTime? _lastSyncAt;

  /// Reactive status: outbox counts from the DB merged with the live phase.
  Stream<SyncStatus> watchStatus() {
    return _db.select(_db.pendingOps).watch().map((rows) {
      final pending = rows.where((o) => o.status != OpStatus.done).length;
      final attention = rows
          .where((o) => o.status == OpStatus.needsAttention)
          .length;
      return SyncStatus(
        phase: _phase,
        pendingCount: pending,
        needsAttentionCount: attention,
        lastSyncAt: _lastSyncAt,
      );
    });
  }

  /// Trigger a drain. Coalesces concurrent calls (single-flight) and re-runs
  /// once more if kicked while already draining.
  Future<void> kick() async {
    if (_draining) {
      _rerun = true;
      return;
    }
    _draining = true;
    try {
      do {
        _rerun = false;
        _phase = SyncPhase.syncing;
        try {
          await _drainer.drain();
          _lastSyncAt = DateTime.now();
          _phase = SyncPhase.idle;
        } on Object {
          _phase = SyncPhase.offline;
        }
      } while (_rerun);
    } finally {
      _draining = false;
    }
  }

  /// Retry a single needs-attention op (from the Needs Attention screen).
  Future<void> retryOp(int opId) async {
    await (_db.update(_db.pendingOps)..where((o) => o.id.equals(opId))).write(
      const PendingOpsCompanion(
        status: Value(OpStatus.pending),
        attempts: Value(0),
        nextRetryAt: Value(null),
      ),
    );
    await kick();
  }

  Future<void> retryAll() async {
    await (_db.update(
      _db.pendingOps,
    )..where((o) => o.status.equals(OpStatus.needsAttention))).write(
      const PendingOpsCompanion(
        status: Value(OpStatus.pending),
        attempts: Value(0),
        nextRetryAt: Value(null),
      ),
    );
    await kick();
  }

  /// Discard an op. For a create, also removes its optimistic timeline row so
  /// the UI stops showing a stuck "sending" bubble.
  Future<void> discardOp(int opId) async {
    final op = await (_db.select(
      _db.pendingOps,
    )..where((o) => o.id.equals(opId))).getSingleOrNull();
    if (op == null) return;
    await _db.transaction(() async {
      if (op.targetLocalId != null &&
          (op.opType == OpType.followupCreate ||
              op.opType == OpType.taskCreate)) {
        await (_db.delete(
          _db.timelineItems,
        )..where((t) => t.localId.equals(op.targetLocalId!))).go();
      }
      await (_db.delete(_db.pendingOps)..where((o) => o.id.equals(opId))).go();
    });
  }
}
