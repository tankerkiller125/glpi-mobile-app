import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../api/itil_type.dart';
import '../db/app_database.dart';
import '../utils/priority_matrix.dart';
import 'outbox_op.dart';

const _uuid = Uuid();

/// Writes optimistic local changes and their outbox ops in a single
/// transaction — the core offline-write invariant. Each method returns after
/// the DB commit; the sync engine sends the op later.
/// The GLPI context a request runs in: which entity, and whether sub-entities
/// are included.
typedef EntityContext = ({int id, bool recursive});

class OutboxWriter {
  OutboxWriter(this._db, {EntityContext? Function()? entity})
    : _entity = entity ?? _noEntity;

  final AppDatabase _db;

  /// Read at enqueue time so every op remembers the entity it was composed in.
  final EntityContext? Function() _entity;

  static EntityContext? _noEntity() => null;

  String _now() => DateTime.now().toUtc().toIso8601String();

  /// Optimistically create a whole ticket: insert a local (server-id-less)
  /// ticket row so it appears in the queue immediately as "Sending…", and
  /// enqueue a ticketCreate op. Optionally assign it to the current user — that
  /// teamAdd op is queued against the sentinel (0) server id and rewritten to
  /// the real id once the ticket create completes (see OutboxDrainer). Returns
  /// the new ticket's local id (for navigation).
  Future<String> createTicket({
    required String name,
    required String content,
    required int type,
    required int urgency,
    required int impact,
    String itemtype = itilTicket,
    int? categoryId,
    String? categoryName,
    bool assignToMe = false,
    int? myUserId,
    String? myUserName,
  }) async {
    final opUuid = _uuid.v4();
    final ticketLocalId = _uuid.v4();
    // Marker rides only in the wire content (recovers a lost POST); the local
    // row keeps the clean text.
    final wire = content.trim().isEmpty
        ? opMarker(opUuid)
        : '$content\n${opMarker(opUuid)}';
    await _db.transaction(() async {
      await _db
          .into(_db.tickets)
          .insert(
            TicketsCompanion.insert(
              localId: ticketLocalId,
              name: name,
              status: 1, // New
              itemtype: Value(itemtype),
              content: Value(content),
              priority: Value(computePriority(urgency, impact)),
              urgency: Value(urgency),
              impact: Value(impact),
              type: Value(type),
              categoryId: Value(categoryId),
              categoryName: Value(categoryName),
              recipientName: Value(myUserName), // "Created by"
              dateCreation: Value(_now()),
              dateMod: Value(_now()),
            ),
          );
      await _enqueue(
        opUuid: opUuid,
        opType: OpType.ticketCreate,
        ticketLocalId: ticketLocalId,
        ticketServerId: 0, // sentinel — filled in once the object exists
        itemtype: itemtype,
        targetLocalId: ticketLocalId,
        payload: {
          'name': name,
          'content': wire,
          // Changes/Problems have no incident/request type field.
          if (itemtype == itilTicket) 'type': type,
          'urgency': urgency,
          'impact': impact,
          if (categoryId != null) 'category': {'id': categoryId},
        },
      );
      if (assignToMe && myUserId != null) {
        await _db
            .into(_db.ticketTeam)
            .insert(
              TicketTeamCompanion.insert(
                localId: _uuid.v4(),
                ticketLocalId: ticketLocalId,
                role: 'assigned',
                memberType: 'User',
                memberId: myUserId,
                displayName: Value(myUserName ?? ''),
              ),
            );
        await _enqueue(
          opUuid: _uuid.v4(),
          opType: OpType.teamAdd,
          ticketLocalId: ticketLocalId,
          ticketServerId: 0, // resolved to the real id after the create lands
          itemtype: itemtype,
          payload: {'type': 'User', 'role': 'assigned', 'memberId': myUserId},
        );
      }
    });
    return ticketLocalId;
  }

  /// Submit a service-catalog form offline-first: insert an optimistic
  /// (server-id-less) ticket row so it shows in the queue immediately, enqueue
  /// the formSubmit op carrying the answers, and queue any picked files as
  /// attachment uploads against the same ticket (they resolve the real ticket
  /// id once the submission lands, via the 0 sentinel). Returns the local id.
  ///
  /// [placeholderTitle] is only what the queue shows until the server replies —
  /// GLPI's form destination decides the real title, which arrives on refresh.
  Future<String> submitForm({
    required int formId,
    required Map<int, Object?> answers,
    required String placeholderTitle,
    String placeholderContent = '',
    List<({String path, String name, String? mime, int size})> files = const [],
    String? myUserName,
  }) async {
    final opUuid = _uuid.v4();
    final ticketLocalId = _uuid.v4();
    await _db.transaction(() async {
      await _db
          .into(_db.tickets)
          .insert(
            TicketsCompanion.insert(
              localId: ticketLocalId,
              name: placeholderTitle,
              status: 1, // New
              content: Value(placeholderContent),
              recipientName: Value(myUserName),
              dateCreation: Value(_now()),
              dateMod: Value(_now()),
            ),
          );
      await _enqueue(
        opUuid: opUuid,
        opType: OpType.formSubmit,
        ticketLocalId: ticketLocalId,
        ticketServerId: 0, // filled in from the submission result
        targetLocalId: ticketLocalId,
        payload: {
          'formId': formId,
          // JSON object keys must be strings.
          'answers': answers.map((k, v) => MapEntry('$k', v)),
        },
      );
      for (final f in files) {
        final rowId = _uuid.v4();
        final fileOpUuid = _uuid.v4();
        await _db
            .into(_db.attachments)
            .insert(
              AttachmentsCompanion.insert(
                localId: rowId,
                ticketLocalId: ticketLocalId,
                name: Value(f.name),
                mime: Value(f.mime),
                localPath: Value(f.path),
                sizeBytes: Value(f.size),
                opUuid: Value(fileOpUuid),
                dateCreation: Value(_now()),
              ),
            );
        await _enqueue(
          opUuid: fileOpUuid,
          opType: OpType.attachmentUpload,
          ticketLocalId: ticketLocalId,
          ticketServerId: 0, // resolved after the form submission creates it
          targetLocalId: rowId,
          payload: {'localPath': f.path, 'name': f.name},
        );
      }
    });
    return ticketLocalId;
  }

  /// Reschedule and/or re-state a planned event. Works for ITIL tasks
  /// (`itemtype` = the parent Ticket/Change/Problem) and project tasks
  /// (`itemtype` = 'ProjectTask'); reminders and external events go through
  /// their own patch methods.
  Future<void> planEvent({
    required String eventLocalId,
    required String eventItemtype,
    required int eventServerId,
    required String parentItemtype,
    required int parentServerId,
    DateTime? begin,
    DateTime? end,
    int? state,
  }) async {
    await _db.transaction(() async {
      await (_db.update(
        _db.planningEvents,
      )..where((e) => e.localId.equals(eventLocalId))).write(
        PlanningEventsCompanion(
          begin: begin == null ? const Value.absent() : Value(_sql(begin)),
          end: end == null ? const Value.absent() : Value(_sql(end)),
          state: state == null ? const Value.absent() : Value(state),
          pending: const Value(true),
        ),
      );
      await _enqueue(
        opUuid: _uuid.v4(),
        opType: OpType.taskPlan,
        ticketLocalId: eventLocalId,
        ticketServerId: parentServerId,
        itemtype: parentItemtype,
        targetLocalId: eventLocalId,
        targetServerId: eventServerId,
        payload: {
          'eventItemtype': eventItemtype,
          'plannedBegin': ?(begin == null ? null : _sql(begin)),
          'plannedEnd': ?(end == null ? null : _sql(end)),
          'state': ?state,
        },
      );
    });
  }

  /// Create a standalone calendar event or a reminder, optimistically.
  /// [kind] is `PlanningExternalEvent` or `Reminder`.
  Future<String> createPlanningItem({
    required String kind,
    required String name,
    required String text,
    required DateTime begin,
    required DateTime end,
    int state = 1,
    bool isAllDay = false,
  }) async {
    final rowId = _uuid.v4();
    final opUuid = _uuid.v4();
    await _db.transaction(() async {
      await _db
          .into(_db.planningEvents)
          .insert(
            PlanningEventsCompanion.insert(
              localId: rowId,
              eventItemtype: kind,
              title: Value(name),
              begin: _sql(begin),
              end: _sql(end),
              isAllDay: Value(isAllDay),
              state: Value(state),
              pending: const Value(true),
            ),
          );
      await _enqueue(
        opUuid: opUuid,
        opType: kind == 'Reminder' ? OpType.reminderCreate : OpType.eventCreate,
        ticketLocalId: rowId,
        ticketServerId: 0,
        itemtype: kind,
        targetLocalId: rowId,
        payload: {
          'name': name,
          // The marker rides in the body text so a lost POST is recoverable.
          'text': text.trim().isEmpty
              ? opMarker(opUuid)
              : '$text\n${opMarker(opUuid)}',
          'begin': _sql(begin),
          'end': _sql(end),
          'state': state,
        },
      );
    });
    return rowId;
  }

  /// Edit an existing event/reminder, optimistically.
  Future<void> patchPlanningItem({
    required String eventLocalId,
    required String kind,
    required int serverId,
    String? name,
    String? text,
    DateTime? begin,
    DateTime? end,
    int? state,
  }) async {
    await _db.transaction(() async {
      await (_db.update(
        _db.planningEvents,
      )..where((e) => e.localId.equals(eventLocalId))).write(
        PlanningEventsCompanion(
          title: name == null ? const Value.absent() : Value(name),
          begin: begin == null ? const Value.absent() : Value(_sql(begin)),
          end: end == null ? const Value.absent() : Value(_sql(end)),
          state: state == null ? const Value.absent() : Value(state),
          pending: const Value(true),
        ),
      );
      await _enqueue(
        opUuid: _uuid.v4(),
        opType: kind == 'Reminder' ? OpType.reminderPatch : OpType.eventPatch,
        ticketLocalId: eventLocalId,
        ticketServerId: serverId,
        itemtype: kind,
        targetLocalId: eventLocalId,
        targetServerId: serverId,
        payload: {
          'name': ?name,
          'text': ?text,
          'begin': ?(begin == null ? null : _sql(begin)),
          'end': ?(end == null ? null : _sql(end)),
          'state': ?state,
        },
      );
    });
  }

  /// Delete an event/reminder, optimistically.
  Future<void> deletePlanningItem({
    required String eventLocalId,
    required String kind,
    required int serverId,
  }) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.planningEvents,
      )..where((e) => e.localId.equals(eventLocalId))).go();
      await _enqueue(
        opUuid: _uuid.v4(),
        opType: kind == 'Reminder' ? OpType.reminderDelete : OpType.eventDelete,
        ticketLocalId: eventLocalId,
        ticketServerId: serverId,
        itemtype: kind,
        targetServerId: serverId,
        payload: const {},
      );
    });
  }

  /// GLPI stores planning timestamps as local `YYYY-MM-DD HH:MM:SS`.
  static String _sql(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}:00';

  // --- Tools ---

  /// Reminders are stored in their own table (the planning feed shows the
  /// planned ones); create/edit/delete all queue through the outbox.
  Future<String> createReminder({
    required String name,
    required String content,
    bool isPlanned = false,
    DateTime? begin,
    DateTime? end,
    int state = 0,
  }) async {
    final rowId = _uuid.v4();
    final opUuid = _uuid.v4();
    await _db.transaction(() async {
      await _db
          .into(_db.reminders)
          .insert(
            RemindersCompanion.insert(
              localId: rowId,
              name: name,
              content: Value(content),
              isPlanned: Value(isPlanned),
              begin: Value(begin == null ? null : _sql(begin)),
              end: Value(end == null ? null : _sql(end)),
              state: Value(state),
              pending: const Value(true),
            ),
          );
      await _enqueue(
        opUuid: opUuid,
        opType: OpType.reminderCreate,
        ticketLocalId: rowId,
        ticketServerId: 0,
        itemtype: 'Reminder',
        targetLocalId: rowId,
        payload: {
          'name': name,
          'text': content.trim().isEmpty
              ? opMarker(opUuid)
              : '$content\n${opMarker(opUuid)}',
          'begin': ?(begin == null ? null : _sql(begin)),
          'end': ?(end == null ? null : _sql(end)),
          'state': state,
          'is_planned': isPlanned,
        },
      );
    });
    return rowId;
  }

  Future<void> patchReminder({
    required String localId,
    required int serverId,
    String? name,
    String? content,
    bool? isPlanned,
    DateTime? begin,
    DateTime? end,
    int? state,
  }) async {
    await _db.transaction(() async {
      await (_db.update(
        _db.reminders,
      )..where((r) => r.localId.equals(localId))).write(
        RemindersCompanion(
          name: name == null ? const Value.absent() : Value(name),
          content: content == null ? const Value.absent() : Value(content),
          isPlanned: isPlanned == null
              ? const Value.absent()
              : Value(isPlanned),
          begin: begin == null ? const Value.absent() : Value(_sql(begin)),
          end: end == null ? const Value.absent() : Value(_sql(end)),
          state: state == null ? const Value.absent() : Value(state),
          pending: const Value(true),
        ),
      );
      await _enqueue(
        opUuid: _uuid.v4(),
        opType: OpType.reminderPatch,
        ticketLocalId: localId,
        ticketServerId: serverId,
        itemtype: 'Reminder',
        targetLocalId: localId,
        targetServerId: serverId,
        payload: {
          'name': ?name,
          'text': ?content,
          'begin': ?(begin == null ? null : _sql(begin)),
          'end': ?(end == null ? null : _sql(end)),
          'state': ?state,
          'is_planned': ?isPlanned,
        },
      );
    });
  }

  Future<void> deleteReminder({
    required String localId,
    required int serverId,
  }) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.reminders,
      )..where((r) => r.localId.equals(localId))).go();
      await _enqueue(
        opUuid: _uuid.v4(),
        opType: OpType.reminderDelete,
        ticketLocalId: localId,
        ticketServerId: serverId,
        itemtype: 'Reminder',
        targetServerId: serverId,
        payload: const {},
      );
    });
  }

  /// Post a knowledge-base comment (articles themselves stay read-only).
  Future<void> addKbComment({
    required int articleId,
    required String comment,
  }) async {
    final opUuid = _uuid.v4();
    await _enqueue(
      opUuid: opUuid,
      opType: OpType.kbCommentCreate,
      ticketLocalId: 'kb-$articleId',
      ticketServerId: articleId,
      itemtype: 'KnowbaseItem',
      payload: {'comment': comment},
    );
  }

  Future<void> createRssFeed({
    required String name,
    required String url,
  }) async {
    await _enqueue(
      opUuid: _uuid.v4(),
      opType: OpType.rssCreate,
      ticketLocalId: 'rss-new-${_uuid.v4()}',
      ticketServerId: 0,
      itemtype: 'RSSFeed',
      payload: {'name': name, 'url': url},
    );
  }

  Future<void> deleteRssFeed(int id) async {
    await _enqueue(
      opUuid: _uuid.v4(),
      opType: OpType.rssDelete,
      ticketLocalId: 'rss-$id',
      ticketServerId: id,
      itemtype: 'RSSFeed',
      targetServerId: id,
      payload: const {},
    );
  }

  /// Book a reservable item. GLPI rejects overlaps, so a clashing booking
  /// surfaces in Needs Attention rather than failing silently.
  Future<void> createReservation({
    required int reservationItemId,
    required DateTime begin,
    required DateTime end,
    String comment = '',
  }) async {
    await _enqueue(
      opUuid: _uuid.v4(),
      opType: OpType.reservationCreate,
      ticketLocalId: 'resa-${_uuid.v4()}',
      ticketServerId: reservationItemId,
      itemtype: 'Reservation',
      payload: {
        'reservationitems_id': reservationItemId,
        'begin': _sql(begin),
        'end': _sql(end),
        'comment': comment,
      },
    );
  }

  Future<void> deleteReservation(int id) async {
    await _enqueue(
      opUuid: _uuid.v4(),
      opType: OpType.reservationDelete,
      ticketLocalId: 'resa-$id',
      ticketServerId: id,
      itemtype: 'Reservation',
      targetServerId: id,
      payload: const {},
    );
  }

  /// Link an asset to an ITIL object. [ownerServerId] may be the 0 sentinel
  /// when the ticket itself is still queued — the drainer resolves it live.
  Future<void> addItemLink({
    required String ownerLocalId,
    required int ownerServerId,
    required String itemtype,
    required String targetItemtype,
    required int targetServerId,
  }) async {
    await _enqueue(
      opUuid: _uuid.v4(),
      opType: OpType.itemLinkAdd,
      ticketLocalId: ownerLocalId,
      ticketServerId: ownerServerId,
      itemtype: itemtype,
      payload: {'targetItemtype': targetItemtype, 'targetId': targetServerId},
    );
  }

  Future<void> removeItemLink({
    required String ownerLocalId,
    required int ownerServerId,
    required String itemtype,
    required String targetItemtype,
    required int targetServerId,
  }) async {
    await _enqueue(
      opUuid: _uuid.v4(),
      opType: OpType.itemLinkRemove,
      ticketLocalId: ownerLocalId,
      ticketServerId: ownerServerId,
      itemtype: itemtype,
      payload: {'targetItemtype': targetItemtype, 'targetId': targetServerId},
    );
  }

  /// Edit an asset / management record, optimistically. [promoted] updates the
  /// searchable columns; [apiBody] is the PATCH GLPI receives.
  Future<void> patchCatalogItem({
    required String localId,
    required int serverId,
    required String domain,
    required String itemtype,
    required CatalogItemsCompanion promoted,
    required Map<String, Object?> apiBody,
  }) async {
    await _db.transaction(() async {
      await (_db.update(
        _db.catalogItems,
      )..where((c) => c.localId.equals(localId))).write(promoted);
      await _enqueue(
        opUuid: _uuid.v4(),
        opType: OpType.catalogPatch,
        ticketLocalId: localId,
        ticketServerId: serverId,
        itemtype: itemtype,
        targetLocalId: localId,
        targetServerId: serverId,
        payload: {'domain': domain, 'fields': apiBody},
      );
    });
  }

  // --- Projects ---

  /// Edit a project task (percent / dates / name), optimistically.
  Future<void> patchProjectTask({
    required String taskLocalId,
    required int taskServerId,
    String? name,
    String? content,
    int? percentDone,
    DateTime? planStart,
    DateTime? planEnd,
  }) async {
    await _db.transaction(() async {
      await (_db.update(
        _db.projectTasks,
      )..where((t) => t.localId.equals(taskLocalId))).write(
        ProjectTasksCompanion(
          name: name == null ? const Value.absent() : Value(name),
          content: content == null ? const Value.absent() : Value(content),
          percentDone: percentDone == null
              ? const Value.absent()
              : Value(percentDone),
          planStartDate: planStart == null
              ? const Value.absent()
              : Value(_sql(planStart)),
          planEndDate: planEnd == null
              ? const Value.absent()
              : Value(_sql(planEnd)),
          pending: const Value(true),
        ),
      );
      await _enqueue(
        opUuid: _uuid.v4(),
        opType: OpType.projectTaskPatch,
        ticketLocalId: taskLocalId,
        ticketServerId: taskServerId,
        itemtype: 'ProjectTask',
        targetLocalId: taskLocalId,
        targetServerId: taskServerId,
        payload: {
          'name': ?name,
          'content': ?content,
          'percent_done': ?percentDone,
          'plan_start_date': ?(planStart == null ? null : _sql(planStart)),
          'plan_end_date': ?(planEnd == null ? null : _sql(planEnd)),
        },
      );
    });
  }

  /// Add a task to a project, optimistically.
  Future<String> createProjectTask({
    required String projectLocalId,
    required int projectServerId,
    required String name,
    String content = '',
    int? parentTaskServerId,
    int percentDone = 0,
    DateTime? planStart,
    DateTime? planEnd,
  }) async {
    final rowId = _uuid.v4();
    final opUuid = _uuid.v4();
    await _db.transaction(() async {
      await _db
          .into(_db.projectTasks)
          .insert(
            ProjectTasksCompanion.insert(
              localId: rowId,
              projectLocalId: projectLocalId,
              parentTaskServerId: Value(parentTaskServerId),
              name: name,
              content: Value(content),
              percentDone: Value(percentDone),
              planStartDate: Value(planStart == null ? null : _sql(planStart)),
              planEndDate: Value(planEnd == null ? null : _sql(planEnd)),
              pending: const Value(true),
            ),
          );
      await _enqueue(
        opUuid: opUuid,
        opType: OpType.projectTaskCreate,
        ticketLocalId: rowId,
        ticketServerId: projectServerId,
        itemtype: 'ProjectTask',
        targetLocalId: rowId,
        payload: {
          'name': name,
          // Marker in the body recovers a lost POST.
          'content': content.trim().isEmpty
              ? opMarker(opUuid)
              : '$content\n${opMarker(opUuid)}',
          'percent_done': percentDone,
          'projecttasks_id': ?parentTaskServerId,
          'plan_start_date': ?(planStart == null ? null : _sql(planStart)),
          'plan_end_date': ?(planEnd == null ? null : _sql(planEnd)),
        },
      );
    });
    return rowId;
  }

  /// Link another ITIL object to this one, optimistically.
  Future<void> addLink({
    required String ownerLocalId,
    required int ownerServerId,
    required String itemtype,
    required String targetItemtype,
    required int targetServerId,
    required String targetName,
    int targetStatus = 1,
    int linkType = 1,
  }) async {
    final rowId = _uuid.v4();
    await _db.transaction(() async {
      await _db
          .into(_db.itilLinks)
          .insert(
            ItilLinksCompanion.insert(
              localId: rowId,
              ownerLocalId: ownerLocalId,
              targetItemtype: targetItemtype,
              targetServerId: targetServerId,
              targetName: Value(targetName),
              targetStatus: Value(targetStatus),
              linkType: Value(linkType),
              pending: const Value(true),
            ),
          );
      await _enqueue(
        opUuid: _uuid.v4(),
        opType: OpType.linkAdd,
        ticketLocalId: ownerLocalId,
        ticketServerId: ownerServerId,
        itemtype: itemtype,
        targetLocalId: rowId,
        payload: {
          'targetItemtype': targetItemtype,
          'targetId': targetServerId,
          'linkType': linkType,
        },
      );
    });
  }

  /// Remove a link, optimistically.
  Future<void> removeLink({
    required String ownerLocalId,
    required int ownerServerId,
    required String itemtype,
    required String targetItemtype,
    required int targetServerId,
  }) async {
    await _db.transaction(() async {
      await (_db.delete(_db.itilLinks)..where(
            (l) =>
                l.ownerLocalId.equals(ownerLocalId) &
                l.targetItemtype.equals(targetItemtype) &
                l.targetServerId.equals(targetServerId),
          ))
          .go();
      await _enqueue(
        opUuid: _uuid.v4(),
        opType: OpType.linkRemove,
        ticketLocalId: ownerLocalId,
        ticketServerId: ownerServerId,
        itemtype: itemtype,
        payload: {'targetItemtype': targetItemtype, 'targetId': targetServerId},
      );
    });
  }

  /// Edit Change/Problem analysis fields, optimistically (cached locally so the
  /// screen shows the new text immediately and offline).
  Future<void> patchExtra({
    required String ownerLocalId,
    required int ownerServerId,
    required String itemtype,
    required Map<String, String> fields,
  }) async {
    await _db.transaction(() async {
      final existing = await (_db.select(
        _db.itilExtras,
      )..where((e) => e.ownerLocalId.equals(ownerLocalId))).getSingleOrNull();
      final merged = <String, Object?>{
        ...(existing == null
            ? const <String, Object?>{}
            : jsonDecode(existing.fieldsJson) as Map<String, Object?>),
        ...fields,
      };
      await _db
          .into(_db.itilExtras)
          .insertOnConflictUpdate(
            ItilExtrasCompanion.insert(
              ownerLocalId: ownerLocalId,
              fieldsJson: Value(jsonEncode(merged)),
            ),
          );
      await _enqueue(
        opUuid: _uuid.v4(),
        opType: OpType.extraPatch,
        ticketLocalId: ownerLocalId,
        ticketServerId: ownerServerId,
        itemtype: itemtype,
        payload: fields,
      );
    });
  }

  /// Optimistically add a ticket attachment: insert a pending Attachments row
  /// pointing at the on-device file, and enqueue an upload op. The op's uuid is
  /// the server-side idempotency marker, so a retried upload is de-duplicated.
  Future<void> addAttachment({
    required String ticketLocalId,
    required int ticketServerId,
    String itemtype = itilTicket,
    required String localPath,
    required String name,
    String? mime,
    int? sizeBytes,
  }) async {
    final opUuid = _uuid.v4();
    final rowId = _uuid.v4();
    await _db.transaction(() async {
      await _db
          .into(_db.attachments)
          .insert(
            AttachmentsCompanion.insert(
              localId: rowId,
              ticketLocalId: ticketLocalId,
              name: Value(name),
              mime: Value(mime),
              localPath: Value(localPath),
              sizeBytes: Value(sizeBytes),
              opUuid: Value(opUuid),
              dateCreation: Value(_now()),
            ),
          );
      await _enqueue(
        opUuid: opUuid,
        opType: OpType.attachmentUpload,
        ticketLocalId: ticketLocalId,
        ticketServerId: ticketServerId,
        itemtype: itemtype,
        targetLocalId: rowId,
        payload: {'localPath': localPath, 'name': name},
      );
    });
  }

  /// Optimistically add a followup and enqueue its create op.
  Future<void> addFollowup({
    required String ticketLocalId,
    required int ticketServerId,
    String itemtype = itilTicket,
    required String content,
    required bool isPrivate,
    int? authorId,
    String? authorName,
  }) async {
    final opUuid = _uuid.v4();
    final rowId = _uuid.v4();
    // The marker rides inside the content so a lost POST can be recovered.
    final wire = '$content\n${opMarker(opUuid)}';
    await _db.transaction(() async {
      await _db
          .into(_db.timelineItems)
          .insert(
            TimelineItemsCompanion.insert(
              localId: rowId,
              ticketLocalId: ticketLocalId,
              itemType: 'followup',
              content: Value(content),
              isPrivate: Value(isPrivate),
              dateCreation: Value(_now()),
              authorId: Value(authorId),
              authorName: Value(authorName),
            ),
          );
      await _enqueue(
        opUuid: opUuid,
        opType: OpType.followupCreate,
        ticketLocalId: ticketLocalId,
        ticketServerId: ticketServerId,
        itemtype: itemtype,
        targetLocalId: rowId,
        payload: {'content': wire, 'isPrivate': isPrivate},
      );
    });
  }

  Future<void> addTask({
    required String ticketLocalId,
    required int ticketServerId,
    String itemtype = itilTicket,
    required String content,
    required bool isPrivate,
    int? durationSeconds,
    int? authorId,
    String? authorName,
  }) async {
    final opUuid = _uuid.v4();
    final rowId = _uuid.v4();
    final wire = '$content\n${opMarker(opUuid)}';
    await _db.transaction(() async {
      await _db
          .into(_db.timelineItems)
          .insert(
            TimelineItemsCompanion.insert(
              localId: rowId,
              ticketLocalId: ticketLocalId,
              itemType: 'task',
              content: Value(content),
              isPrivate: Value(isPrivate),
              dateCreation: Value(_now()),
              authorId: Value(authorId),
              authorName: Value(authorName),
              taskDuration: Value(durationSeconds),
              taskState: const Value(1),
            ),
          );
      await _enqueue(
        opUuid: opUuid,
        opType: OpType.taskCreate,
        ticketLocalId: ticketLocalId,
        ticketServerId: ticketServerId,
        itemtype: itemtype,
        targetLocalId: rowId,
        payload: {
          'content': wire,
          'isPrivate': isPrivate,
          'durationSeconds': durationSeconds,
          'state': 1,
        },
      );
    });
  }

  /// Toggle a task's done/todo state optimistically.
  Future<void> setTaskState({
    required String ticketLocalId,
    required int ticketServerId,
    String itemtype = itilTicket,
    required String taskLocalId,
    required int taskServerId,
    required int state,
  }) async {
    await _db.transaction(() async {
      await (_db.update(_db.timelineItems)
            ..where((t) => t.localId.equals(taskLocalId)))
          .write(TimelineItemsCompanion(taskState: Value(state)));
      await _enqueue(
        opUuid: _uuid.v4(),
        opType: OpType.taskSetState,
        ticketLocalId: ticketLocalId,
        ticketServerId: ticketServerId,
        itemtype: itemtype,
        targetLocalId: taskLocalId,
        targetServerId: taskServerId,
        payload: {'state': state},
      );
    });
  }

  /// Generic optimistic ticket-field edit: apply the drift change and enqueue a
  /// ticketPatch op whose payload is the PATCH body.
  Future<void> patchTicket({
    required String ticketLocalId,
    required int ticketServerId,
    String itemtype = itilTicket,
    required TicketsCompanion optimistic,
    required Map<String, Object?> apiBody,
  }) async {
    await _db.transaction(() async {
      await (_db.update(
        _db.tickets,
      )..where((t) => t.localId.equals(ticketLocalId))).write(optimistic);
      await _enqueue(
        opUuid: _uuid.v4(),
        opType: OpType.ticketPatch,
        ticketLocalId: ticketLocalId,
        ticketServerId: ticketServerId,
        itemtype: itemtype,
        payload: apiBody,
      );
    });
  }

  Future<void> setStatus({
    required String ticketLocalId,
    required int ticketServerId,
    String itemtype = itilTicket,
    required int status,
  }) => patchTicket(
    ticketLocalId: ticketLocalId,
    ticketServerId: ticketServerId,
    itemtype: itemtype,
    optimistic: TicketsCompanion(status: Value(status)),
    apiBody: {'status': status},
  );

  /// Set urgency. Priority is derived (urgency × impact) — update it locally too
  /// via the GLPI matrix so the UI reacts instantly; the server recomputes and
  /// confirms on the next refresh.
  Future<void> setUrgency({
    required String ticketLocalId,
    required int ticketServerId,
    String itemtype = itilTicket,
    required int urgency,
    required int impact,
  }) => patchTicket(
    ticketLocalId: ticketLocalId,
    ticketServerId: ticketServerId,
    itemtype: itemtype,
    optimistic: TicketsCompanion(
      urgency: Value(urgency),
      priority: Value(computePriority(urgency, impact)),
    ),
    apiBody: {'urgency': urgency},
  );

  Future<void> setImpact({
    required String ticketLocalId,
    required int ticketServerId,
    String itemtype = itilTicket,
    required int urgency,
    required int impact,
  }) => patchTicket(
    ticketLocalId: ticketLocalId,
    ticketServerId: ticketServerId,
    itemtype: itemtype,
    optimistic: TicketsCompanion(
      impact: Value(impact),
      priority: Value(computePriority(urgency, impact)),
    ),
    apiBody: {'impact': impact},
  );

  Future<void> setType({
    required String ticketLocalId,
    required int ticketServerId,
    String itemtype = itilTicket,
    required int type,
  }) => patchTicket(
    ticketLocalId: ticketLocalId,
    ticketServerId: ticketServerId,
    itemtype: itemtype,
    optimistic: TicketsCompanion(type: Value(type)),
    apiBody: {'type': type},
  );

  Future<void> setCategory({
    required String ticketLocalId,
    required int ticketServerId,
    String itemtype = itilTicket,
    required int categoryId,
    required String categoryName,
  }) => patchTicket(
    ticketLocalId: ticketLocalId,
    ticketServerId: ticketServerId,
    itemtype: itemtype,
    optimistic: TicketsCompanion(
      categoryId: Value(categoryId),
      categoryName: Value(categoryName),
    ),
    apiBody: {
      'category': {'id': categoryId},
    },
  );

  /// Add an actor (assignee/observer/requester), optimistically.
  Future<void> addActor({
    required String ticketLocalId,
    required int ticketServerId,
    String itemtype = itilTicket,
    required String role,
    required String memberType,
    required int memberId,
    required String displayName,
  }) async {
    await _db.transaction(() async {
      await _db
          .into(_db.ticketTeam)
          .insert(
            TicketTeamCompanion.insert(
              localId: _uuid.v4(),
              ticketLocalId: ticketLocalId,
              role: role,
              memberType: memberType,
              memberId: memberId,
              displayName: Value(displayName),
            ),
          );
      await _enqueue(
        opUuid: _uuid.v4(),
        opType: OpType.teamAdd,
        ticketLocalId: ticketLocalId,
        ticketServerId: ticketServerId,
        itemtype: itemtype,
        payload: {'type': memberType, 'role': role, 'memberId': memberId},
      );
    });
  }

  /// Add a solution: optimistic solution row + ticket → Solved, and enqueue.
  Future<void> addSolution({
    required String ticketLocalId,
    required int ticketServerId,
    String itemtype = itilTicket,
    required String content,
    int? authorId,
    String? authorName,
  }) async {
    final opUuid = _uuid.v4();
    final rowId = _uuid.v4();
    final wire = '$content\n${opMarker(opUuid)}';
    await _db.transaction(() async {
      await _db
          .into(_db.timelineItems)
          .insert(
            TimelineItemsCompanion.insert(
              localId: rowId,
              ticketLocalId: ticketLocalId,
              itemType: 'solution',
              content: Value(content),
              dateCreation: Value(_now()),
              authorId: Value(authorId),
              authorName: Value(authorName),
              solutionStatus: const Value(2), // waiting
            ),
          );
      // Adding a solution moves the ticket to Solved (mirrors GLPI).
      await (_db.update(_db.tickets)
            ..where((t) => t.localId.equals(ticketLocalId)))
          .write(const TicketsCompanion(status: Value(5)));
      await _enqueue(
        opUuid: opUuid,
        opType: OpType.solutionCreate,
        ticketLocalId: ticketLocalId,
        ticketServerId: ticketServerId,
        itemtype: itemtype,
        targetLocalId: rowId,
        payload: {'content': wire},
      );
    });
  }

  /// Approve (3) / refuse (4) a solution.
  Future<void> answerSolution({
    required String ticketLocalId,
    required int ticketServerId,
    String itemtype = itilTicket,
    required String solutionLocalId,
    required int solutionServerId,
    required int status,
  }) async {
    await _db.transaction(() async {
      await (_db.update(_db.timelineItems)
            ..where((t) => t.localId.equals(solutionLocalId)))
          .write(TimelineItemsCompanion(solutionStatus: Value(status)));
      await _enqueue(
        opUuid: _uuid.v4(),
        opType: OpType.solutionAnswer,
        ticketLocalId: ticketLocalId,
        ticketServerId: ticketServerId,
        itemtype: itemtype,
        targetLocalId: solutionLocalId,
        targetServerId: solutionServerId,
        payload: {'status': status},
      );
    });
  }

  /// Request an approval (validation) from a user.
  Future<void> requestValidation({
    required String ticketLocalId,
    required int ticketServerId,
    String itemtype = itilTicket,
    required int approverId,
    required String approverName,
    required String comment,
  }) async {
    final opUuid = _uuid.v4();
    final rowId = _uuid.v4();
    final wire = '$comment\n${opMarker(opUuid)}';
    await _db.transaction(() async {
      await _db
          .into(_db.timelineItems)
          .insert(
            TimelineItemsCompanion.insert(
              localId: rowId,
              ticketLocalId: ticketLocalId,
              itemType: 'validation',
              content: Value(comment),
              dateCreation: Value(_now()),
              validationStatus: const Value(2), // waiting
              approverId: Value(approverId),
              approverType: const Value('User'),
            ),
          );
      await _enqueue(
        opUuid: opUuid,
        opType: OpType.validationCreate,
        ticketLocalId: ticketLocalId,
        ticketServerId: ticketServerId,
        itemtype: itemtype,
        targetLocalId: rowId,
        payload: {
          'approverType': 'User',
          'approverId': approverId,
          'comment': wire,
        },
      );
    });
  }

  /// Answer a validation: approve (3) / refuse (4) with an optional comment.
  Future<void> answerValidation({
    required String ticketLocalId,
    required int ticketServerId,
    String itemtype = itilTicket,
    required String validationLocalId,
    required int validationServerId,
    required int status,
    String? comment,
  }) async {
    await _db.transaction(() async {
      await (_db.update(
        _db.timelineItems,
      )..where((t) => t.localId.equals(validationLocalId))).write(
        TimelineItemsCompanion(
          validationStatus: Value(status),
          approvalComment: Value(comment),
        ),
      );
      await _enqueue(
        opUuid: _uuid.v4(),
        opType: OpType.validationAnswer,
        ticketLocalId: ticketLocalId,
        ticketServerId: ticketServerId,
        itemtype: itemtype,
        targetLocalId: validationLocalId,
        targetServerId: validationServerId,
        payload: {'status': status, 'comment': comment},
      );
    });
  }

  /// Remove an actor, optimistically.
  Future<void> removeActor({
    required String ticketLocalId,
    required int ticketServerId,
    String itemtype = itilTicket,
    required String role,
    required String memberType,
    required int memberId,
  }) async {
    await _db.transaction(() async {
      await (_db.delete(_db.ticketTeam)..where(
            (t) =>
                t.ticketLocalId.equals(ticketLocalId) &
                t.role.equals(role) &
                t.memberType.equals(memberType) &
                t.memberId.equals(memberId),
          ))
          .go();
      await _enqueue(
        opUuid: _uuid.v4(),
        opType: OpType.teamRemove,
        ticketLocalId: ticketLocalId,
        ticketServerId: ticketServerId,
        itemtype: itemtype,
        payload: {'type': memberType, 'role': role, 'memberId': memberId},
      );
    });
  }

  Future<void> _enqueue({
    required String opUuid,
    required String opType,
    required String ticketLocalId,
    required int ticketServerId,
    required Map<String, Object?> payload,
    String itemtype = itilTicket,
    String? targetLocalId,
    int? targetServerId,
    Map<String, Object?>? baseSnapshot,
  }) {
    return _db
        .into(_db.pendingOps)
        .insert(
          PendingOpsCompanion.insert(
            opUuid: opUuid,
            opType: opType,
            itemtype: Value(itemtype),
            ticketLocalId: ticketLocalId,
            ticketServerId: ticketServerId,
            targetLocalId: Value(targetLocalId),
            targetServerId: Value(targetServerId),
            payload: Value(jsonEncode(payload)),
            baseSnapshot: Value(
              baseSnapshot == null ? null : jsonEncode(baseSnapshot),
            ),
            createdAt: _now(),
            // Pinned, not followed: a create drained after an entity switch
            // must still file into the entity it was written in.
            entityId: Value(_entity()?.id),
            entityRecursive: Value(_entity()?.recursive),
          ),
        );
  }
}
