import 'package:clock/clock.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/dto/attachment_dto.dart';
import 'package:glpi_mobile/core/api/dto/form_dto.dart';
import 'package:glpi_mobile/core/api/dto/timeline_dto.dart';
import 'package:glpi_mobile/core/api/errors.dart';
import 'package:glpi_mobile/core/db/app_database.dart';
import 'package:glpi_mobile/core/sync/outbox_drainer.dart';
import 'package:glpi_mobile/core/sync/outbox_op.dart';
import 'package:glpi_mobile/core/sync/outbox_writer.dart';

import '../support/fake_glpi_api.dart';

/// Scriptable fake: records calls, can inject failures and simulate a lost
/// response (executes the write but throws), and serves a timeline for probes.
class ScriptedApi with FakeGlpiApiDefaults {
  int _nextId = 1000;
  final List<String> calls = [];
  final List<TimelineEntryDto> timeline = [];

  // Injection controls.
  GlpiError? failNext;
  bool dropResponseNext = false; // execute then throw (lost response)

  int _emit(String kind, String content, bool asServer) {
    final id = _nextId++;
    if (asServer) {
      timeline.add(
        TimelineEntryDto(
          type: kind,
          id: id,
          content: content,
          isPrivate: false,
          dateCreation: '2026-08-07T00:00:00+00:00',
          authorId: 2,
          authorName: 'glpi',
          taskDuration: null,
          taskState: null,
          solutionStatus: null,
          validationStatus: null,
          approverId: null,
          approverType: null,
          approvalComment: null,
        ),
      );
    }
    return id;
  }

  /// Generic catalog PATCHes and asset↔ITIL link calls, as readable strings.
  final List<String> catalogPatches = [];
  final List<String> itemLinkCalls = [];

  @override
  Future<void> patchCatalogItem(
    String domain,
    String itemtype,
    int id,
    Map<String, Object?> fields,
  ) async {
    catalogPatches.add('$domain/$itemtype/$id:${fields.keys.join(",")}');
  }

  @override
  Future<void> addItilItem(
    String itemtype,
    int id, {
    required String targetItemtype,
    required int targetId,
  }) async {
    itemLinkCalls.add('$itemtype/$id->$targetItemtype/$targetId');
  }

  @override
  Future<void> removeItilItem(
    String itemtype,
    int id, {
    required String targetItemtype,
    required int targetId,
  }) async {
    itemLinkCalls.add('$itemtype/$id-x-$targetItemtype/$targetId');
  }

  // Tickets the "server" has created, as {id, content} — powers createTicket
  // and its marker probe.
  final List<Map<String, Object?>> createdTickets = [];

  @override
  Future<List<TimelineEntryDto>> getTimeline(
    int ticketId, {
    String itemtype = 'Ticket',
  }) async => List.of(timeline);

  @override
  Future<int> createTicket(
    Map<String, Object?> body, {
    String itemtype = 'Ticket',
  }) async {
    calls.add('createTicket');
    final content = body['content'] as String? ?? '';
    if (dropResponseNext) {
      dropResponseNext = false;
      final id = _nextId++;
      createdTickets.add({'id': id, 'content': content}); // server recorded it
      throw const GlpiNetworkError('lost response');
    }
    if (failNext != null) {
      final e = failNext!;
      failNext = null;
      throw e;
    }
    final id = _nextId++;
    createdTickets.add({'id': id, 'content': content});
    return id;
  }

  @override
  Future<int?> findTicketByMarker(
    String opUuid, {
    String itemtype = 'Ticket',
  }) async {
    for (final t in createdTickets) {
      if ((t['content'] as String).contains('op:$opUuid')) {
        return t['id'] as int;
      }
    }
    return null;
  }

  @override
  Future<void> addTeamMember(
    int ticketId, {
    required String type,
    required String role,
    required int memberId,
    String itemtype = 'Ticket',
  }) async {
    calls.add('addTeamMember:$ticketId');
    if (failNext != null) {
      final e = failNext!;
      failNext = null;
      throw e;
    }
  }

  @override
  Future<int> createFollowup(
    int ticketId, {
    required String content,
    required bool isPrivate,
    String itemtype = 'Ticket',
  }) async {
    calls.add('createFollowup');
    if (dropResponseNext) {
      dropResponseNext = false;
      _emit('followup', content, true); // server recorded it
      throw const GlpiNetworkError('lost response');
    }
    if (failNext != null) {
      final e = failNext!;
      failNext = null;
      throw e;
    }
    return _emit('followup', content, true);
  }

  final List<String> submittedForms = []; // "formId:marker" per submit call
  @override
  Future<FormSubmitResult> submitForm(
    int formId, {
    required Map<int, Object?> answers,
    required String marker,
  }) async {
    calls.add('submitForm:$formId');
    if (failNext != null) {
      final e = failNext!;
      failNext = null;
      throw e;
    }
    submittedForms.add('$formId:$marker');
    return FormSubmitResult(answersSetId: _nextId++, ticketId: _nextId++);
  }

  final List<String> uploads = []; // "ticketId:marker" per upload call
  @override
  Future<AttachmentDto> uploadAttachment(
    int ticketId, {
    required String filePath,
    required String name,
    required String marker,
    String itemtype = 'Ticket',
  }) async {
    calls.add('uploadAttachment:$ticketId');
    uploads.add('$ticketId:$marker');
    if (failNext != null) {
      final e = failNext!;
      failNext = null;
      throw e;
    }
    return AttachmentDto(
      id: _nextId++,
      name: name,
      filename: name,
      mime: 'image/png',
    );
  }

  final List<String> planCalls = [];
  @override
  Future<void> planItilTask(
    int parentId,
    int taskId, {
    required String itemtype,
    String? plannedBegin,
    String? plannedEnd,
    int? state,
  }) async {
    calls.add('planItilTask');
    planCalls.add('$itemtype/$parentId/task/$taskId:$plannedBegin:$state');
    if (failNext != null) {
      final e = failNext!;
      failNext = null;
      throw e;
    }
  }

  final List<String> eventCalls = [];
  @override
  Future<int> createExternalEvent(Map<String, Object?> body) async {
    calls.add('createExternalEvent');
    if (failNext != null) {
      final e = failNext!;
      failNext = null;
      throw e;
    }
    eventCalls.add('create:${body['name']}');
    return _nextId++;
  }

  @override
  Future<int> createReminder(Map<String, Object?> body) async {
    calls.add('createReminder');
    if (failNext != null) {
      final e = failNext!;
      failNext = null;
      throw e;
    }
    eventCalls.add('reminder:${body['name']}');
    return _nextId++;
  }

  final List<String> toolCalls = [];
  @override
  Future<int> createKbComment(int articleId, String comment) async {
    calls.add('createKbComment');
    toolCalls.add('kb:$articleId');
    return _nextId++;
  }

  @override
  Future<int> createReservation(Map<String, Object?> body) async {
    calls.add('createReservation');
    if (failNext != null) {
      final e = failNext!;
      failNext = null;
      throw e;
    }
    toolCalls.add('resa:${body['reservationitems_id']}');
    return _nextId++;
  }

  @override
  Future<void> deleteReservation(int id) async {
    calls.add('deleteReservation');
    toolCalls.add('resa-del:$id');
  }

  final List<String> projectCalls = [];
  @override
  Future<void> patchProjectTask(int taskId, Map<String, Object?> fields) async {
    calls.add('patchProjectTask');
    projectCalls.add('patch:$taskId:${fields.keys.join(",")}');
  }

  @override
  Future<int> createProjectTask(
    int projectId,
    Map<String, Object?> body,
  ) async {
    calls.add('createProjectTask');
    if (failNext != null) {
      final e = failNext!;
      failNext = null;
      throw e;
    }
    projectCalls.add('create:$projectId:${body['name']}');
    return _nextId++;
  }

  final List<String> linkCalls = [];
  @override
  Future<void> addItilLink(
    String itemtype,
    int id, {
    required String targetItemtype,
    required int targetId,
    int linkType = 1,
  }) async {
    calls.add('addItilLink');
    linkCalls.add('$itemtype/$id->$targetItemtype/$targetId:$linkType');
    if (failNext != null) {
      final e = failNext!;
      failNext = null;
      throw e;
    }
  }

  @override
  Future<void> removeItilLink(
    String itemtype,
    int id, {
    required String targetItemtype,
    required int targetId,
  }) async {
    calls.add('removeItilLink');
    linkCalls.add('$itemtype/$id-x-$targetItemtype/$targetId');
  }

  final List<String> extraCalls = [];
  @override
  Future<void> patchItilExtra(
    String itemtype,
    int id,
    Map<String, Object?> fields,
  ) async {
    calls.add('patchItilExtra');
    extraCalls.add('$itemtype/$id:${fields.keys.join(",")}');
  }

  @override
  Future<void> patchTicket(
    int ticketId,
    Map<String, Object?> fields, {
    String itemtype = 'Ticket',
  }) async {
    calls.add('patchTicket:${fields.keys.join(",")}');
    if (failNext != null) {
      final e = failNext!;
      failNext = null;
      throw e;
    }
  }
}

void main() {
  late AppDatabase db;
  late ScriptedApi api;
  late OutboxWriter writer;
  late OutboxDrainer drainer;

  Future<void> seedTicket() => db
      .into(db.tickets)
      .insert(
        TicketsCompanion.insert(
          localId: 't1',
          serverId: const Value(3),
          name: 'Server migration',
          status: 1,
        ),
      );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    api = ScriptedApi();
    writer = OutboxWriter(db);
    drainer = OutboxDrainer(db, api, myUserId: 2);
    await seedTicket();
  });

  tearDown(() => db.close());

  Future<List<PendingOp>> ops() => db.select(db.pendingOps).get();

  test('offline followup drains and stamps the server id on its row', () async {
    await writer.addFollowup(
      ticketLocalId: 't1',
      ticketServerId: 3,
      content: 'hello',
      isPrivate: false,
    );
    // The optimistic row exists with no server id yet.
    var rows = await db.select(db.timelineItems).get();
    expect(rows.single.serverId, isNull);

    await drainer.drain();

    rows = await db.select(db.timelineItems).get();
    expect(rows.single.serverId, isNotNull); // adopted the created id
    expect((await ops()).single.status, OpStatus.done);
    expect(api.calls, ['createFollowup']);
  });

  test(
    'duplicate-POST recovery: lost response is adopted, not re-created',
    () async {
      await writer.addFollowup(
        ticketLocalId: 't1',
        ticketServerId: 3,
        content: 'hello',
        isPrivate: false,
      );
      api.dropResponseNext =
          true; // first send succeeds server-side, response lost

      await drainer.drain(); // attempt 1: throws network -> failedRetryable
      expect((await ops()).single.status, OpStatus.failedRetryable);

      // Clear backoff and drain again: probe should find the marker and adopt.
      await (db.update(
        db.pendingOps,
      )).write(const PendingOpsCompanion(nextRetryAt: Value(null)));
      await drainer.drain();

      expect((await ops()).single.status, OpStatus.done);
      // createFollowup called once (the lost one); the retry adopted via probe.
      expect(api.calls.where((c) => c == 'createFollowup'), hasLength(1));
      // Exactly one followup on the server timeline (no duplicate).
      expect(api.timeline.where((e) => e.type == 'followup'), hasLength(1));
    },
  );

  test('offline ticket create drains, stamps the server id, and sends the '
      'dependent assign op against the real id', () async {
    final localId = await writer.createTicket(
      name: 'Logged on site',
      content: 'AP down in warehouse',
      type: 1,
      urgency: 4,
      impact: 3,
      assignToMe: true,
      myUserId: 2,
      myUserName: 'glpi',
    );
    // Optimistic ticket exists with no server id; both ops sit at sentinel 0.
    var t = await (db.select(
      db.tickets,
    )..where((x) => x.localId.equals(localId))).getSingle();
    expect(t.serverId, isNull);
    final queued = await ops();
    expect(queued.map((o) => o.opType), [OpType.ticketCreate, OpType.teamAdd]);
    expect(queued.every((o) => o.ticketServerId == 0), isTrue);

    await drainer.drain();

    t = await (db.select(
      db.tickets,
    )..where((x) => x.localId.equals(localId))).getSingle();
    expect(t.serverId, isNotNull); // create backfilled the real id
    expect((await ops()).every((o) => o.status == OpStatus.done), isTrue);
    // The assign op targeted the freshly-created id, not the 0 sentinel.
    expect(api.calls, ['createTicket', 'addTeamMember:${t.serverId}']);
  });

  test('duplicate-POST recovery for a ticket create adopts via marker', () async {
    final localId = await writer.createTicket(
      name: 'Logged on site',
      content: 'body',
      type: 1,
      urgency: 3,
      impact: 3,
      myUserId: 2,
      myUserName: 'glpi',
    );
    api.dropResponseNext = true; // create succeeds server-side, response lost

    await drainer.drain(); // attempt 1: throws network -> failedRetryable
    final createOp = (await ops()).firstWhere(
      (o) => o.opType == OpType.ticketCreate,
    );
    expect(createOp.status, OpStatus.failedRetryable);

    // Clear backoff and drain again: the marker probe should adopt, not re-POST.
    await (db.update(
      db.pendingOps,
    )).write(const PendingOpsCompanion(nextRetryAt: Value(null)));
    await drainer.drain();

    final t = await (db.select(
      db.tickets,
    )..where((x) => x.localId.equals(localId))).getSingle();
    expect(t.serverId, isNotNull);
    expect((await ops()).single.status, OpStatus.done);
    // createTicket POSTed once (the lost one); the retry adopted via the probe.
    expect(api.calls.where((c) => c == 'createTicket'), hasLength(1));
    expect(api.createdTickets, hasLength(1)); // no duplicate ticket
  });

  test('offline form submission creates the ticket and its queued files upload '
      'against the new id', () async {
    final localId = await writer.submitForm(
      formId: 1,
      answers: {6: 'Projector bulb out', 7: 'Needs replacing', 1: 4},
      placeholderTitle: 'Projector bulb out',
      placeholderContent: 'Needs replacing',
      files: [
        (path: '/tmp/shot.png', name: 'shot.png', mime: 'image/png', size: 9),
      ],
    );
    // Placeholder ticket + both ops queued at the sentinel.
    var t = await (db.select(
      db.tickets,
    )..where((x) => x.localId.equals(localId))).getSingle();
    expect(t.serverId, isNull);
    expect(t.name, 'Projector bulb out');
    expect((await ops()).map((o) => o.opType), [
      OpType.formSubmit,
      OpType.attachmentUpload,
    ]);

    await drainer.drain();

    t = await (db.select(
      db.tickets,
    )..where((x) => x.localId.equals(localId))).getSingle();
    expect(t.serverId, isNotNull); // stamped from the submission result
    expect((await ops()).every((o) => o.status == OpStatus.done), isTrue);
    expect(api.submittedForms, hasLength(1));
    // The attachment went to the ticket the form just created.
    expect(api.uploads.single.split(':').first, '${t.serverId}');
    final att = await db.select(db.attachments).getSingle();
    expect(att.serverDocId, isNotNull);
  });

  test('a failed form submission retries with the same marker', () async {
    await writer.submitForm(
      formId: 1,
      answers: {6: 'Retry me'},
      placeholderTitle: 'Retry me',
    );
    api.failNext = const GlpiNetworkError('offline');
    await drainer.drain();
    expect((await ops()).single.status, OpStatus.failedRetryable);
    expect(api.submittedForms, isEmpty);

    await (db.update(
      db.pendingOps,
    )).write(const PendingOpsCompanion(nextRetryAt: Value(null)));
    await drainer.drain();

    expect((await ops()).single.status, OpStatus.done);
    // The marker is the op uuid, so the server can dedupe a double-send.
    final op = (await ops()).single;
    expect(api.submittedForms.single, '1:${op.opUuid}');
  });

  test(
    'offline attachment upload drains and stamps the document on its row',
    () async {
      await writer.addAttachment(
        ticketLocalId: 't1',
        ticketServerId: 3,
        localPath: '/tmp/photo.png',
        name: 'photo.png',
        mime: 'image/png',
        sizeBytes: 42,
      );
      var rows = await db.select(db.attachments).get();
      expect(rows.single.serverDocId, isNull); // pending upload
      expect(rows.single.opUuid, isNotNull);

      await drainer.drain();

      rows = await db.select(db.attachments).get();
      expect(rows.single.serverDocId, isNotNull); // stamped with the doc id
      expect(rows.single.opUuid, isNull); // no longer pending
      expect((await ops()).single.status, OpStatus.done);
      expect(api.uploads, hasLength(1));
    },
  );

  test(
    'offline ITIL link add/remove drains against the right itemtype',
    () async {
      // A Change that links to a Ticket.
      await db
          .into(db.tickets)
          .insert(
            TicketsCompanion.insert(
              localId: 'c1',
              serverId: const Value(7),
              itemtype: const Value('Change'),
              name: 'Datacentre move',
              status: 1,
            ),
          );
      await writer.addLink(
        ownerLocalId: 'c1',
        ownerServerId: 7,
        itemtype: 'Change',
        targetItemtype: 'Ticket',
        targetServerId: 3,
        targetName: 'Server migration',
      );
      // Optimistic row is present and marked pending.
      var links = await db.select(db.itilLinks).get();
      expect(links.single.pending, isTrue);
      expect(links.single.targetItemtype, 'Ticket');

      await drainer.drain();
      expect(api.linkCalls.single, 'Change/7->Ticket/3:1');
      expect((await ops()).single.status, OpStatus.done);
      // The synced link stops showing as pending.
      links = await db.select(db.itilLinks).get();
      expect(links.single.pending, isFalse);

      // Now unlink.
      await writer.removeLink(
        ownerLocalId: 'c1',
        ownerServerId: 7,
        itemtype: 'Change',
        targetItemtype: 'Ticket',
        targetServerId: 3,
      );
      links = await db.select(db.itilLinks).get();
      expect(links, isEmpty); // removed optimistically
      await drainer.drain();
      expect(api.linkCalls.last, 'Change/7-x-Ticket/3');
    },
  );

  test('offline analysis-field edit caches locally then drains', () async {
    await db
        .into(db.tickets)
        .insert(
          TicketsCompanion.insert(
            localId: 'p1',
            serverId: const Value(9),
            itemtype: const Value('Problem'),
            name: 'Recurring VPN drops',
            status: 1,
          ),
        );
    await writer.patchExtra(
      ownerLocalId: 'p1',
      ownerServerId: 9,
      itemtype: 'Problem',
      fields: {'causecontent': 'Firmware bug'},
    );
    // Cached immediately so the screen reads it offline.
    final cached = await db.select(db.itilExtras).getSingle();
    expect(cached.fieldsJson, contains('Firmware bug'));

    await drainer.drain();
    expect(api.extraCalls.single, 'Problem/9:causecontent');
    expect((await ops()).single.status, OpStatus.done);
  });

  test('offline task reschedule drains against the parent object', () async {
    await db
        .into(db.planningEvents)
        .insert(
          PlanningEventsCompanion.insert(
            localId: 'pe1',
            eventItemtype: 'TicketTask',
            eventServerId: const Value(55),
            parentItemtype: const Value('Ticket'),
            parentServerId: const Value(3),
            title: const Value('Swap the port'),
            begin: '2026-08-10 09:00:00',
            end: '2026-08-10 10:00:00',
          ),
        );
    await writer.planEvent(
      eventLocalId: 'pe1',
      eventItemtype: 'TicketTask',
      eventServerId: 55,
      parentItemtype: 'Ticket',
      parentServerId: 3,
      begin: DateTime(2026, 8, 11, 14),
      state: 2,
    );
    var rows = await db.select(db.planningEvents).get();
    expect(rows.single.pending, isTrue);
    expect(rows.single.state, 2); // optimistic

    await drainer.drain();
    expect(api.planCalls.single, 'Ticket/3/task/55:2026-08-11 14:00:00:2');
    rows = await db.select(db.planningEvents).get();
    expect(rows.single.pending, isFalse); // stops showing "syncing…"
    expect((await ops()).single.status, OpStatus.done);
  });

  test('offline event + reminder creates stamp their new server ids', () async {
    await writer.createPlanningItem(
      kind: 'PlanningExternalEvent',
      name: 'On-site visit',
      text: 'Quarterly',
      begin: DateTime(2026, 8, 12, 9),
      end: DateTime(2026, 8, 12, 10),
    );
    await writer.createPlanningItem(
      kind: 'Reminder',
      name: 'Order batteries',
      text: '',
      begin: DateTime(2026, 8, 12, 8),
      end: DateTime(2026, 8, 12, 8, 30),
    );
    var rows = await db.select(db.planningEvents).get();
    expect(rows.every((r) => r.eventServerId == null && r.pending), isTrue);

    await drainer.drain();
    rows = await db.select(db.planningEvents).get();
    expect(rows.every((r) => r.eventServerId != null && !r.pending), isTrue);
    expect(api.eventCalls, hasLength(2));
  });

  test('offline project task create + patch drain', () async {
    await db
        .into(db.projects)
        .insert(
          ProjectsCompanion.insert(
            localId: 'pr1',
            serverId: const Value(9),
            name: 'Branch refresh',
          ),
        );
    final taskLocal = await writer.createProjectTask(
      projectLocalId: 'pr1',
      projectServerId: 9,
      name: 'Rack the switches',
      percentDone: 0,
    );
    var tasks = await db.select(db.projectTasks).get();
    expect(tasks.single.pending, isTrue);
    expect(tasks.single.serverId, isNull);

    await drainer.drain();
    tasks = await db.select(db.projectTasks).get();
    expect(tasks.single.serverId, isNotNull);
    expect(tasks.single.pending, isFalse);
    expect(api.projectCalls.first, startsWith('create:9:'));

    // Now edit it.
    await writer.patchProjectTask(
      taskLocalId: taskLocal,
      taskServerId: tasks.single.serverId!,
      percentDone: 50,
    );
    await drainer.drain();
    tasks = await db.select(db.projectTasks).get();
    expect(tasks.single.percentDone, 50);
    expect(tasks.single.pending, isFalse);
    expect(api.projectCalls.last, contains('percent_done'));
  });

  test('offline reminder create + edit + delete drain', () async {
    final localId = await writer.createReminder(
      name: 'Order batteries',
      content: 'Before Friday',
      isPlanned: true,
      begin: DateTime(2026, 8, 12, 8),
      end: DateTime(2026, 8, 12, 9),
      state: 1,
    );
    var rows = await db.select(db.reminders).get();
    expect(rows.single.pending, isTrue);
    expect(rows.single.serverId, isNull);

    await drainer.drain();
    rows = await db.select(db.reminders).get();
    expect(rows.single.serverId, isNotNull); // stamped from the create
    expect(rows.single.pending, isFalse);

    await writer.patchReminder(
      localId: localId,
      serverId: rows.single.serverId!,
      name: 'Order UPS batteries',
    );
    await drainer.drain();
    rows = await db.select(db.reminders).get();
    expect(rows.single.name, 'Order UPS batteries');
    expect(rows.single.pending, isFalse);

    await writer.deleteReminder(
      localId: localId,
      serverId: rows.single.serverId!,
    );
    expect(await db.select(db.reminders).get(), isEmpty); // optimistic
    await drainer.drain();
    expect((await ops()).every((o) => o.status == OpStatus.done), isTrue);
  });

  test('offline KB comment and reservation drain', () async {
    await writer.addKbComment(articleId: 7, comment: 'Worked for me');
    await writer.createReservation(
      reservationItemId: 4,
      begin: DateTime(2026, 8, 13, 9),
      end: DateTime(2026, 8, 13, 11),
      comment: 'Site visit',
    );
    await drainer.drain();
    expect(api.toolCalls, containsAll(<String>['kb:7', 'resa:4']));
    expect((await ops()).every((o) => o.status == OpStatus.done), isTrue);
  });

  test(
    'offline asset edit drains and clears the row\'s pending flag',
    () async {
      await db
          .into(db.catalogItems)
          .insert(
            CatalogItemsCompanion.insert(
              localId: 'a1',
              domain: 'Assets',
              itemtype: 'Computer',
              serverId: 11,
              name: const Value('DELTA-WS01'),
            ),
          );
      await writer.patchCatalogItem(
        localId: 'a1',
        serverId: 11,
        domain: 'Assets',
        itemtype: 'Computer',
        promoted: const CatalogItemsCompanion(
          statusName: Value('Broken'),
          pending: Value(true),
        ),
        apiBody: const {'status': 3},
      );
      var rows = await db.select(db.catalogItems).get();
      expect(rows.single.statusName, 'Broken'); // optimistic
      expect(rows.single.pending, isTrue);

      await drainer.drain();

      expect(api.catalogPatches.single, 'Assets/Computer/11:status');
      rows = await db.select(db.catalogItems).get();
      expect(rows.single.pending, isFalse);
      expect((await ops()).single.status, OpStatus.done);
    },
  );

  test(
    'an asset link queued against an unsynced ticket resolves its id',
    () async {
      // A ticket created offline: no server id yet.
      final localId = await writer.createTicket(
        name: 'Screen cracked',
        content: 'Dropped on site',
        type: 1,
        urgency: 3,
        impact: 3,
      );
      await writer.addItemLink(
        ownerLocalId: localId,
        ownerServerId: 0, // sentinel — the create hasn't landed
        itemtype: 'Ticket',
        targetItemtype: 'Computer',
        targetServerId: 11,
      );

      await drainer.drain();

      // FIFO-per-partition ran the create first, so the link used the real id.
      final ticket = await (db.select(
        db.tickets,
      )..where((t) => t.localId.equals(localId))).getSingle();
      expect(ticket.serverId, isNotNull);
      expect(
        api.itemLinkCalls.single,
        'Ticket/${ticket.serverId}->Computer/11',
      );
      expect((await ops()).every((o) => o.status == OpStatus.done), isTrue);
    },
  );

  test('validation error sends the op to needs-attention (no retry)', () async {
    await writer.setStatus(ticketLocalId: 't1', ticketServerId: 3, status: 5);
    api.failNext = const GlpiValidationError('bad status');

    await drainer.drain();
    expect((await ops()).single.status, OpStatus.needsAttention);
  });

  test('network error schedules a retry with backoff, no permanence', () async {
    await writer.setStatus(ticketLocalId: 't1', ticketServerId: 3, status: 2);
    api.failNext = const GlpiNetworkError('offline');

    await drainer.drain();
    final op = (await ops()).single;
    expect(op.status, OpStatus.failedRetryable);
    expect(op.nextRetryAt, isNotNull);
  });

  test(
    'a blocked partition head holds back later ops for the same ticket',
    () async {
      // Op A (status change) will fail-retry; Op B (followup) is behind it.
      await writer.setStatus(ticketLocalId: 't1', ticketServerId: 3, status: 2);
      await writer.addFollowup(
        ticketLocalId: 't1',
        ticketServerId: 3,
        content: 'second',
        isPrivate: false,
      );
      api.failNext = const GlpiNetworkError('offline'); // hits op A

      await drainer.drain();
      final all = await ops();
      final statusOp = all.firstWhere((o) => o.opType == OpType.ticketPatch);
      final followupOp = all.firstWhere(
        (o) => o.opType == OpType.followupCreate,
      );
      expect(statusOp.status, OpStatus.failedRetryable);
      // The followup must NOT have been sent (partition order preserved).
      expect(followupOp.status, OpStatus.pending);
      expect(api.calls.where((c) => c == 'createFollowup'), isEmpty);
    },
  );

  test(
    'respects nextRetryAt: does not send before the backoff elapses',
    () async {
      await writer.setStatus(ticketLocalId: 't1', ticketServerId: 3, status: 2);
      api.failNext = const GlpiNetworkError('offline');
      await drainer.drain(); // schedules retry ~5s out

      api.calls.clear();
      await drainer.drain(); // immediately: still in backoff
      expect(api.calls, isEmpty);

      // Advance the clock past the backoff window.
      await withClock(
        Clock.fixed(DateTime.now().add(const Duration(hours: 1))),
        () => drainer.drain(),
      );
      expect(api.calls, isNotEmpty);
    },
  );
}
