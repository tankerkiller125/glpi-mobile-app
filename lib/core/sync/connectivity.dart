import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'sync_status.dart';

/// Network reachability (a proxy for "connected to GLPI"). True when any
/// transport is up.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final conn = Connectivity();
  bool online(List<ConnectivityResult> r) =>
      r.any((x) => x != ConnectivityResult.none);
  yield online(await conn.checkConnectivity());
  yield* conn.onConnectivityChanged.map(online);
});

/// The four states the primary-nav cloud button reflects.
enum CloudState { connected, syncing, offline, error }

/// Pure derivation: an unresolved sync issue wins, then live syncing, then
/// offline (no network OR a failed sync), else connected.
CloudState deriveCloudState(SyncStatus status, {required bool online}) {
  if (status.needsAttentionCount > 0) return CloudState.error;
  if (status.phase == SyncPhase.syncing) return CloudState.syncing;
  if (!online || status.phase == SyncPhase.offline) return CloudState.offline;
  return CloudState.connected;
}

final cloudStateProvider = Provider<CloudState>((ref) {
  final status = ref.watch(syncStatusProvider).value ?? const SyncStatus();
  final online = ref.watch(connectivityProvider).value ?? true;
  return deriveCloudState(status, online: online);
});
