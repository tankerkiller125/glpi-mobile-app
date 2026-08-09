@Tags(['live'])
library;

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/glpi_api.dart';
import 'package:glpi_mobile/core/db/app_database.dart';
import 'package:glpi_mobile/core/sync/outbox_drainer.dart';
import 'package:glpi_mobile/core/sync/outbox_op.dart';
import 'package:glpi_mobile/core/sync/outbox_writer.dart';
import 'live_config.dart';

/// End-to-end write path against the dev GLPI: enqueue a followup offline-style,
/// drain it, and assert it landed on the server timeline exactly once.
const _server = liveServer;
const _clientId = liveClientId;
const _clientSecret = liveClientSecret;

Future<String> _token() async {
  final dio = Dio();
  final r = await dio.post<Map<String, Object?>>(
    '$_server/api.php/token',
    data: {
      'grant_type': 'password',
      'client_id': _clientId,
      'client_secret': _clientSecret,
      'username': liveUsername,
      'password': livePassword,
      'scope': 'api user email',
    },
  );
  return r.data!['access_token']! as String;
}

void main() {
  test('followup enqueued locally drains to the GLPI timeline once', () async {
    final token = await _token();
    final dio = Dio(
      BaseOptions(
        baseUrl: '$_server/api.php/v2.3',
        headers: {'Authorization': 'Bearer $token', 'GLPI-API-Version': '2.3'},
      ),
    );
    final api = HlGlpiApi(dio);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final writer = OutboxWriter(db);
    final drainer = OutboxDrainer(db, api, myUserId: 2);

    // Seed a local ticket mirroring server ticket 2.
    await db
        .into(db.tickets)
        .insert(
          TicketsCompanion.insert(
            localId: 'tk2',
            serverId: const Value(2),
            name: 'VPN setup for new hire',
            status: 1,
          ),
        );

    final marker = 'live-test-${DateTime.now().microsecondsSinceEpoch}';
    await writer.addFollowup(
      ticketLocalId: 'tk2',
      ticketServerId: 2,
      content: 'Automated write test $marker',
      isPrivate: true,
    );

    await drainer.drain();

    // Op is done, optimistic row got a server id.
    final ops = await db.select(db.pendingOps).get();
    expect(ops.single.status, OpStatus.done);
    final rows = await db.select(db.timelineItems).get();
    expect(rows.single.serverId, isNotNull);

    // The followup exists on the server exactly once.
    final timeline = await api.getTimeline(2);
    final matches = timeline.where((e) => e.content.contains(marker)).toList();
    expect(matches, hasLength(1));

    // Cleanup: delete the followup we created.
    await dio.delete<Object?>(
      '/Assistance/Ticket/2/Timeline/Followup/${matches.first.id}',
    );
  });
}
