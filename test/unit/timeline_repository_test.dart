import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/dto/timeline_dto.dart';
import 'package:glpi_mobile/core/db/app_database.dart';
import 'package:glpi_mobile/core/repositories/timeline_repository.dart';

import '../support/fake_glpi_api.dart';

/// Serves the captured timeline fixture for one ticket.
class FakeTimelineApi with FakeGlpiApiDefaults {
  FakeTimelineApi(this._entries);
  final List<TimelineEntryDto> _entries;

  @override
  Future<List<TimelineEntryDto>> getTimeline(
    int ticketId, {
    String itemtype = 'Ticket',
  }) async => _entries;
}

List<TimelineEntryDto> loadTimeline() {
  final raw =
      jsonDecode(File('test/fixtures/ticket_timeline.json').readAsStringSync())
          as List<Object?>;
  return raw
      .whereType<Map<String, Object?>>()
      .map(TimelineEntryDto.fromJson)
      .toList();
}

void main() {
  late AppDatabase db;
  late FakeTimelineApi api;
  late TimelineRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    // Seed a parent ticket row (FK target).
    await db
        .into(db.tickets)
        .insert(
          TicketsCompanion.insert(
            localId: 't1',
            serverId: const Value(3),
            name: 'Server migration',
            status: 1,
          ),
        );
    api = FakeTimelineApi(loadTimeline());
    repo = TimelineRepository(db, api);
  });

  tearDown(() => db.close());

  test('refreshTimeline parses followups and tasks from the fixture', () async {
    await repo.refreshTimeline('t1', 3);
    final entries = await repo.watchTimeline('t1').first;
    expect(entries, isNotEmpty);
    expect(
      entries.map((e) => e.type).toSet(),
      containsAll(['followup', 'task']),
    );

    final tasks = entries.where((e) => e.type == 'task').toList();
    expect(tasks, isNotEmpty);
    // First task duration is 6h = 21600s in the fixture.
    expect(tasks.first.taskDuration, 21600);

    final privateFollowup = entries.firstWhere(
      (e) => e.type == 'followup' && e.isPrivate,
    );
    expect(privateFollowup.isPrivate, isTrue);
  });

  test('refreshTimeline is a replace-set (no duplicates on re-sync)', () async {
    await repo.refreshTimeline('t1', 3);
    final first = await repo.watchTimeline('t1').first;
    await repo.refreshTimeline('t1', 3);
    final second = await repo.watchTimeline('t1').first;
    expect(second.length, first.length);
  });

  test('locally-created rows survive a replace-set refresh', () async {
    // A pending (serverId == null) local followup, e.g. an offline reply.
    await db
        .into(db.timelineItems)
        .insert(
          TimelineItemsCompanion.insert(
            localId: 'local-1',
            ticketLocalId: 't1',
            itemType: 'followup',
            content: const Value('offline reply'),
          ),
        );
    await repo.refreshTimeline('t1', 3);
    final entries = await repo.watchTimeline('t1').first;
    expect(entries.where((e) => e.serverId == null), hasLength(1));
  });
}
