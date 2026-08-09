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

const _server = liveServer;

Future<HlGlpiApi> _api() async {
  final dio = Dio();
  final r = await dio.post<Map<String, Object?>>(
    '$_server/api.php/token',
    data: {
      'grant_type': 'password',
      'client_id': liveClientId,
      'client_secret': liveClientSecret,
      'username': liveUsername,
      'password': livePassword,
      'scope': 'api user email',
    },
  );
  final token = r.data!['access_token']! as String;
  return HlGlpiApi(
    Dio(
      BaseOptions(
        baseUrl: '$_server/api.php/v2.3',
        headers: {'Authorization': 'Bearer $token', 'GLPI-API-Version': '2.3'},
      ),
    ),
  );
}

Future<AppDatabase> _dbForTicket(int serverId) async {
  final db = AppDatabase(NativeDatabase.memory());
  await db
      .into(db.tickets)
      .insert(
        TicketsCompanion.insert(
          localId: 't',
          serverId: Value(serverId),
          name: 'live',
          status: 1,
        ),
      );
  return db;
}

void main() {
  test('solution: enqueue → drain → ticket Solved on server', () async {
    final api = await _api();
    final db = await _dbForTicket(2);
    addTearDown(db.close);
    final marker = 'sol-${DateTime.now().microsecondsSinceEpoch}';

    await OutboxWriter(db).addSolution(
      ticketLocalId: 't',
      ticketServerId: 2,
      content: 'Resolved $marker',
    );
    await OutboxDrainer(db, api, myUserId: 2).drain();

    expect((await db.select(db.pendingOps).get()).single.status, OpStatus.done);
    final t = await api.getTicket(2);
    expect(t.status, 5); // Solved

    // Cleanup: find + delete the solution, reset status.
    final timeline = await api.getTimeline(2);
    final sol = timeline.firstWhere((e) => e.content.contains(marker));
    await Dio().delete<Object?>(
      '$_server/api.php/v2.3/Assistance/Ticket/2/Timeline/Solution/${sol.id}',
      options: Options(headers: await _authHeader()),
    );
    await api.patchTicket(2, {'status': 1});
  });

  test('validation: request → drain → exists on server', () async {
    final api = await _api();
    final db = await _dbForTicket(2);
    addTearDown(db.close);
    final marker = 'val-${DateTime.now().microsecondsSinceEpoch}';

    await OutboxWriter(db).requestValidation(
      ticketLocalId: 't',
      ticketServerId: 2,
      approverId: 4, // tech
      approverName: 'tech',
      comment: 'Approve $marker',
    );
    await OutboxDrainer(db, api, myUserId: 2).drain();

    expect((await db.select(db.pendingOps).get()).single.status, OpStatus.done);
    final timeline = await api.getTimeline(2);
    final matches = timeline.where(
      (e) => e.type == 'validation' && e.content.contains(marker),
    );
    expect(matches, hasLength(1));

    // Cleanup.
    await Dio().delete<Object?>(
      '$_server/api.php/v2.3/Assistance/Ticket/2/Timeline/Validation/${matches.first.id}',
      options: Options(headers: await _authHeader()),
    );
  });
}

Future<Map<String, String>> _authHeader() async {
  final dio = Dio();
  final r = await dio.post<Map<String, Object?>>(
    '$_server/api.php/token',
    data: {
      'grant_type': 'password',
      'client_id': liveClientId,
      'client_secret': liveClientSecret,
      'username': liveUsername,
      'password': livePassword,
      'scope': 'api user email',
    },
  );
  return {'Authorization': 'Bearer ${r.data!['access_token']}'};
}
