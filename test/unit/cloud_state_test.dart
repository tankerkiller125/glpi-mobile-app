import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/sync/connectivity.dart';
import 'package:glpi_mobile/core/sync/sync_status.dart';

void main() {
  test('needs-attention wins → error, even while online', () {
    expect(
      deriveCloudState(const SyncStatus(needsAttentionCount: 2), online: true),
      CloudState.error,
    );
  });

  test('syncing phase → syncing', () {
    expect(
      deriveCloudState(
        const SyncStatus(phase: SyncPhase.syncing),
        online: true,
      ),
      CloudState.syncing,
    );
  });

  test('no network → offline', () {
    expect(
      deriveCloudState(const SyncStatus(), online: false),
      CloudState.offline,
    );
  });

  test('failed sync phase → offline (can\'t reach GLPI)', () {
    expect(
      deriveCloudState(
        const SyncStatus(phase: SyncPhase.offline),
        online: true,
      ),
      CloudState.offline,
    );
  });

  test('online and idle → connected', () {
    expect(
      deriveCloudState(const SyncStatus(), online: true),
      CloudState.connected,
    );
  });

  test('error beats offline when both apply', () {
    expect(
      deriveCloudState(const SyncStatus(needsAttentionCount: 1), online: false),
      CloudState.error,
    );
  });
}
