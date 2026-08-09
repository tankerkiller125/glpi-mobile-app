enum SyncPhase { idle, syncing, offline, authRequired }

/// Snapshot of sync state for the UI (app-bar chip, needs-attention badge).
class SyncStatus {
  const SyncStatus({
    this.phase = SyncPhase.idle,
    this.pendingCount = 0,
    this.needsAttentionCount = 0,
    this.lastSyncAt,
  });

  final SyncPhase phase;
  final int pendingCount;
  final int needsAttentionCount;
  final DateTime? lastSyncAt;

  SyncStatus copyWith({
    SyncPhase? phase,
    int? pendingCount,
    int? needsAttentionCount,
    DateTime? lastSyncAt,
  }) => SyncStatus(
    phase: phase ?? this.phase,
    pendingCount: pendingCount ?? this.pendingCount,
    needsAttentionCount: needsAttentionCount ?? this.needsAttentionCount,
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
  );
}
