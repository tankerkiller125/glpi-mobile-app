import 'dart:convert';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';

import '../api/dto/attachment_dto.dart';
import '../api/errors.dart';
import '../api/glpi_api.dart';
import '../api/hl_client.dart' show EntityScope;
import '../db/app_database.dart';
import 'outbox_op.dart';

/// Exponential backoff ladder (seconds) indexed by attempt count.
const _backoffSeconds = [5, 30, 120, 600, 1800];

/// A server (5xx/unexpected) op is abandoned to needs-attention after this many
/// attempts. Network errors never count toward this — offline for a week must
/// not kill the queue.
const _maxServerAttempts = 10;

/// Drains the outbox: sends each pending op to GLPI in FIFO order per ticket,
/// with backoff, failure classification, and duplicate-POST recovery.
///
/// Single-flight: callers must not run two drains concurrently (SyncService
/// guards this). Returns true if any op transitioned to done.
class OutboxDrainer {
  OutboxDrainer(this._db, this._api, {this.myUserId});

  final AppDatabase _db;
  final GlpiApi _api;
  final int? myUserId;

  final _rng = Random();

  Future<bool> drain() async {
    // Interrupted ops (app killed mid-send) are suspect — back to pending so
    // create ops get a dedup probe (attempts is already > 0).
    await (_db.update(_db.pendingOps)
          ..where((o) => o.status.equals(OpStatus.inflight)))
        .write(const PendingOpsCompanion(status: Value(OpStatus.pending)));

    final ops =
        await (_db.select(_db.pendingOps)
              ..where(
                (o) =>
                    o.status.isIn([OpStatus.pending, OpStatus.failedRetryable]),
              )
              ..orderBy([(o) => OrderingTerm(expression: o.id)]))
            .get();

    final blocked = <String>{};
    var progressed = false;
    final now = clock.now();

    for (final op in ops) {
      if (blocked.contains(op.ticketLocalId)) continue;
      if (op.nextRetryAt != null) {
        final retryAt = DateTime.tryParse(op.nextRetryAt!);
        if (retryAt != null && now.isBefore(retryAt)) {
          blocked.add(op.ticketLocalId); // preserve per-partition order
          continue;
        }
      }

      final outcome = await _process(op);
      switch (outcome) {
        case _Outcome.done:
          progressed = true;
        case _Outcome.retryLater:
        case _Outcome.needsAttention:
          // Both cascade: later ops for this ticket must wait / not run.
          blocked.add(op.ticketLocalId);
        case _Outcome.authStop:
          return progressed; // pause the whole drain until re-auth
      }
    }
    return progressed;
  }

  /// Every request an op makes — the write itself, its duplicate-POST probe,
  /// an attachment upload — runs in the entity the op was composed in, not
  /// whichever entity happens to be active now.
  Future<_Outcome> _process(PendingOp op) =>
      EntityScope.run(op.entityId, op.entityRecursive, () => _processIn(op));

  Future<_Outcome> _processIn(PendingOp op) async {
    await (_db.update(_db.pendingOps)..where((o) => o.id.equals(op.id))).write(
      PendingOpsCompanion(
        status: const Value(OpStatus.inflight),
        attempts: Value(op.attempts + 1),
      ),
    );

    // Ops queued against a not-yet-created ticket carry the 0 sentinel; resolve
    // the real id live (a prior op in this same pass may have just created it —
    // FIFO-per-partition guarantees the create/submit ran first).
    var ticketServerId = op.ticketServerId;
    if (ticketServerId == 0 &&
        op.opType != OpType.ticketCreate &&
        op.opType != OpType.formSubmit &&
        op.opType != OpType.eventCreate &&
        op.opType != OpType.reminderCreate &&
        op.opType != OpType.projectTaskCreate &&
        op.opType != OpType.projectTaskPatch &&
        op.opType != OpType.rssCreate &&
        op.opType != OpType.reservationCreate &&
        op.opType != OpType.catalogPatch) {
      ticketServerId = await _ticketServerId(op.ticketLocalId) ?? 0;
      if (ticketServerId == 0) {
        // The create hasn't landed yet — hold this partition, don't POST to /0.
        await (_db.update(_db.pendingOps)..where((o) => o.id.equals(op.id)))
            .write(const PendingOpsCompanion(status: Value(OpStatus.pending)));
        return _Outcome.retryLater;
      }
    }

    try {
      // Duplicate-POST recovery: a retried create may have actually succeeded
      // before the response was lost. Probe for our marker before re-POSTing.
      if (op.attempts > 0) {
        if (op.opType == OpType.ticketCreate) {
          final existingId = await _api.findTicketByMarker(
            op.opUuid,
            itemtype: op.itemtype,
          );
          if (existingId != null) {
            await _completeTicketCreate(op, existingId);
            return _Outcome.done;
          }
        } else if (_isCreate(op.opType)) {
          final existingId = await _probeForMarker(op, ticketServerId);
          if (existingId != null) {
            await _adoptCreate(op, existingId);
            return _Outcome.done;
          }
        }
      }

      // A form submission runs GLPI's own answer handler, which creates the
      // ticket via the form's destination config. The endpoint is idempotent by
      // marker, so a retry returns the original result instead of filing twice.
      if (op.opType == OpType.formSubmit) {
        final payload = jsonDecode(op.payload) as Map<String, Object?>;
        final rawAnswers = (payload['answers'] as Map).cast<String, Object?>();
        final result = await _api.submitForm(
          (payload['formId'] as num).toInt(),
          answers: rawAnswers.map((k, v) => MapEntry(int.parse(k), v)),
          marker: op.opUuid,
        );
        final ticketId = result.ticketId;
        if (ticketId == null) {
          // The form created no ticket (destination misconfigured server-side);
          // nothing to link the local placeholder to.
          throw const GlpiUnexpectedError('form submission created no ticket');
        }
        await _completeTicketCreate(op, ticketId);
        return _Outcome.done;
      }

      // Attachment upload streams a file from disk and stamps the created
      // document back onto the local row; the endpoint is idempotent by marker,
      // so a retry after a lost response just re-adopts the same document.
      if (op.opType == OpType.attachmentUpload) {
        final payload = jsonDecode(op.payload) as Map<String, Object?>;
        final dto = await _api.uploadAttachment(
          ticketServerId,
          filePath: payload['localPath'] as String,
          name: payload['name'] as String,
          marker: op.opUuid,
          itemtype: op.itemtype,
        );
        await _completeAttachment(op, dto);
        return _Outcome.done;
      }

      final newServerId = await _execute(op, ticketServerId);
      if (op.opType == OpType.ticketCreate) {
        await _completeTicketCreate(op, newServerId!);
      } else if (_isPlanning(op.opType)) {
        await _completePlanning(op, newServerId);
      } else if (op.opType == OpType.projectTaskPatch ||
          op.opType == OpType.projectTaskCreate) {
        await _completeProjectTask(op, newServerId);
      } else if (op.opType == OpType.catalogPatch) {
        await _completeCatalogPatch(op);
      } else {
        await _markDone(op, newServerId);
      }
      return _Outcome.done;
    } on GlpiError catch (e) {
      return _classify(op, e);
    }
  }

  /// Ops whose optimistic row lives in `planning_events`.
  bool _isPlanning(String t) =>
      t == OpType.taskPlan ||
      t == OpType.eventCreate ||
      t == OpType.eventPatch ||
      t == OpType.eventDelete ||
      t == OpType.reminderCreate ||
      t == OpType.reminderPatch ||
      t == OpType.reminderDelete;

  bool _isCreate(String t) =>
      t == OpType.followupCreate ||
      t == OpType.taskCreate ||
      t == OpType.solutionCreate ||
      t == OpType.validationCreate;

  Future<int?> _execute(PendingOp op, int ticketServerId) async {
    final payload = jsonDecode(op.payload) as Map<String, Object?>;
    switch (op.opType) {
      case OpType.ticketCreate:
        return _api.createTicket(payload, itemtype: op.itemtype);
      case OpType.followupCreate:
        return _api.createFollowup(
          ticketServerId,
          content: payload['content'] as String,
          isPrivate: payload['isPrivate'] as bool? ?? false,
          itemtype: op.itemtype,
        );
      case OpType.taskCreate:
        return _api.createTask(
          ticketServerId,
          content: payload['content'] as String,
          isPrivate: payload['isPrivate'] as bool? ?? false,
          durationSeconds: (payload['durationSeconds'] as num?)?.toInt(),
          state: (payload['state'] as num?)?.toInt() ?? 1,
          itemtype: op.itemtype,
        );
      case OpType.taskPlan:
        // ITIL tasks live under their parent; project tasks have their own route.
        if ((payload['eventItemtype'] as String?) == 'ProjectTask') {
          await _api.patchProjectTask(op.targetServerId!, {
            'plan_start_date': ?payload['plannedBegin'],
            'plan_end_date': ?payload['plannedEnd'],
          });
        } else {
          await _api.planItilTask(
            ticketServerId,
            op.targetServerId!,
            itemtype: op.itemtype,
            plannedBegin: payload['plannedBegin'] as String?,
            plannedEnd: payload['plannedEnd'] as String?,
            state: (payload['state'] as num?)?.toInt(),
          );
        }
        return null;
      case OpType.eventCreate:
        return _api.createExternalEvent({
          'name': payload['name'],
          'text': payload['text'],
          'date_begin': payload['begin'],
          'date_end': payload['end'],
          'state': payload['state'],
        });
      case OpType.eventPatch:
        await _api.patchExternalEvent(
          op.targetServerId!,
          _planningPatchBody(payload),
        );
        return null;
      case OpType.eventDelete:
        await _api.deleteExternalEvent(op.targetServerId!);
        return null;
      case OpType.reminderCreate:
        return _api.createReminder({
          'name': payload['name'],
          'text': payload['text'],
          'date_begin': payload['begin'],
          'date_end': payload['end'],
          'state': payload['state'],
          'is_planned': true,
        });
      case OpType.reminderPatch:
        await _api.patchReminder(
          op.targetServerId!,
          _planningPatchBody(payload),
        );
        return null;
      case OpType.reminderDelete:
        await _api.deleteReminder(op.targetServerId!);
        return null;
      case OpType.kbCommentCreate:
        return _api.createKbComment(
          ticketServerId,
          payload['comment'] as String,
        );
      case OpType.rssCreate:
        return _api.createRssFeed(payload);
      case OpType.rssPatch:
        await _api.patchRssFeed(op.targetServerId!, payload);
        return null;
      case OpType.rssDelete:
        await _api.deleteRssFeed(op.targetServerId!);
        return null;
      case OpType.reservationCreate:
        return _api.createReservation(payload);
      case OpType.reservationDelete:
        await _api.deleteReservation(op.targetServerId!);
        return null;
      case OpType.itemLinkAdd:
        await _api.addItilItem(
          op.itemtype,
          ticketServerId,
          targetItemtype: payload['targetItemtype'] as String,
          targetId: (payload['targetId'] as num).toInt(),
        );
        return null;
      case OpType.itemLinkRemove:
        await _api.removeItilItem(
          op.itemtype,
          ticketServerId,
          targetItemtype: payload['targetItemtype'] as String,
          targetId: (payload['targetId'] as num).toInt(),
        );
        return null;
      case OpType.catalogPatch:
        await _api.patchCatalogItem(
          payload['domain'] as String,
          op.itemtype,
          op.targetServerId!,
          (payload['fields'] as Map).cast<String, Object?>(),
        );
        return null;
      case OpType.projectTaskPatch:
        await _api.patchProjectTask(op.targetServerId!, payload);
        return null;
      case OpType.projectTaskCreate:
        return _api.createProjectTask(ticketServerId, payload);
      case OpType.linkAdd:
        await _api.addItilLink(
          op.itemtype,
          ticketServerId,
          targetItemtype: payload['targetItemtype'] as String,
          targetId: (payload['targetId'] as num).toInt(),
          linkType: (payload['linkType'] as num?)?.toInt() ?? 1,
        );
        return null;
      case OpType.linkRemove:
        await _api.removeItilLink(
          op.itemtype,
          ticketServerId,
          targetItemtype: payload['targetItemtype'] as String,
          targetId: (payload['targetId'] as num).toInt(),
        );
        return null;
      case OpType.extraPatch:
        await _api.patchItilExtra(op.itemtype, ticketServerId, payload);
        return null;
      case OpType.taskSetState:
        await _api.setTaskState(
          ticketServerId,
          op.targetServerId!,
          (payload['state'] as num).toInt(),
          itemtype: op.itemtype,
        );
        return null;
      case OpType.ticketPatch:
        // payload IS the PATCH body (status/priority/urgency/type/category…).
        await _api.patchTicket(ticketServerId, payload, itemtype: op.itemtype);
        return null;
      case OpType.teamAdd:
        await _api.addTeamMember(
          ticketServerId,
          type: payload['type'] as String,
          role: payload['role'] as String,
          memberId: (payload['memberId'] as num).toInt(),
          itemtype: op.itemtype,
        );
        return null;
      case OpType.teamRemove:
        await _api.removeTeamMember(
          ticketServerId,
          type: payload['type'] as String,
          role: payload['role'] as String,
          memberId: (payload['memberId'] as num).toInt(),
          itemtype: op.itemtype,
        );
        return null;
      case OpType.solutionCreate:
        return _api.createSolution(
          ticketServerId,
          content: payload['content'] as String,
          itemtype: op.itemtype,
        );
      case OpType.solutionAnswer:
        await _api.setSolutionStatus(
          ticketServerId,
          op.targetServerId!,
          (payload['status'] as num).toInt(),
          itemtype: op.itemtype,
        );
        return null;
      case OpType.validationCreate:
        return _api.createValidation(
          ticketServerId,
          approverType: payload['approverType'] as String,
          approverId: (payload['approverId'] as num).toInt(),
          comment: payload['comment'] as String,
          itemtype: op.itemtype,
        );
      case OpType.validationAnswer:
        await _api.answerValidation(
          ticketServerId,
          op.targetServerId!,
          status: (payload['status'] as num).toInt(),
          comment: payload['comment'] as String?,
          itemtype: op.itemtype,
        );
        return null;
      default:
        throw GlpiUnexpectedError('unknown op type ${op.opType}');
    }
  }

  /// GLPI names the planning window `date_begin`/`date_end` on the wire even
  /// though the columns are `begin`/`end`.
  static Map<String, Object?> _planningPatchBody(
    Map<String, Object?> payload,
  ) => {
    'name': ?payload['name'],
    'text': ?payload['text'],
    'date_begin': ?payload['begin'],
    'date_end': ?payload['end'],
    'state': ?payload['state'],
  };

  /// Finalize a planning write: stamp the created id (creates) and clear the
  /// pending flag so the row stops showing "syncing…".
  Future<void> _completePlanning(PendingOp op, int? newServerId) async {
    await _db.transaction(() async {
      // A reminder's optimistic row lives in `reminders`, not `planning_events`.
      if (op.itemtype == 'Reminder' && op.targetLocalId != null) {
        await (_db.update(
          _db.reminders,
        )..where((r) => r.localId.equals(op.targetLocalId!))).write(
          RemindersCompanion(
            serverId: newServerId == null
                ? const Value.absent()
                : Value(newServerId),
            pending: const Value(false),
          ),
        );
      }
      if (op.targetLocalId != null) {
        await (_db.update(
          _db.planningEvents,
        )..where((e) => e.localId.equals(op.targetLocalId!))).write(
          PlanningEventsCompanion(
            eventServerId: newServerId == null
                ? const Value.absent()
                : Value(newServerId),
            pending: const Value(false),
          ),
        );
      }
      await _finish(op);
    });
  }

  /// Stamp a created project task's id and clear its pending flag.
  Future<void> _completeProjectTask(PendingOp op, int? newServerId) async {
    await _db.transaction(() async {
      if (op.targetLocalId != null) {
        await (_db.update(
          _db.projectTasks,
        )..where((t) => t.localId.equals(op.targetLocalId!))).write(
          ProjectTasksCompanion(
            serverId: newServerId == null
                ? const Value.absent()
                : Value(newServerId),
            pending: const Value(false),
          ),
        );
      }
      await _finish(op);
    });
  }

  /// Clear a catalog row's pending flag once its edit lands.
  Future<void> _completeCatalogPatch(PendingOp op) async {
    await _db.transaction(() async {
      if (op.targetLocalId != null) {
        await (_db.update(_db.catalogItems)
              ..where((c) => c.localId.equals(op.targetLocalId!)))
            .write(const CatalogItemsCompanion(pending: Value(false)));
      }
      await _finish(op);
    });
  }

  /// The cached server id for a local ticket, or null if not yet created.
  Future<int?> _ticketServerId(String ticketLocalId) async {
    final row = await (_db.select(
      _db.tickets,
    )..where((t) => t.localId.equals(ticketLocalId))).getSingleOrNull();
    return row?.serverId;
  }

  /// Re-read the timeline and find the server id of a create we may have
  /// already posted (matched by our idempotency marker).
  Future<int?> _probeForMarker(PendingOp op, int ticketServerId) async {
    final entries = await _api.getTimeline(
      ticketServerId,
      itemtype: op.itemtype,
    );
    for (final e in entries) {
      if (contentHasMarker(e.content, op.opUuid)) return e.id;
    }
    return null;
  }

  Future<void> _adoptCreate(PendingOp op, int serverId) =>
      _markDone(op, serverId);

  /// Stamp the uploaded document onto its local attachment row (clears the
  /// pending marker), so it stops showing as "Sending…".
  Future<void> _completeAttachment(PendingOp op, AttachmentDto dto) async {
    await _db.transaction(() async {
      if (op.targetLocalId != null) {
        await (_db.update(
          _db.attachments,
        )..where((a) => a.localId.equals(op.targetLocalId!))).write(
          AttachmentsCompanion(
            serverDocId: Value(dto.id),
            filename: Value(dto.filename),
            mime: Value(dto.mime),
            opUuid: const Value(null),
          ),
        );
      }
      await _finish(op);
    });
  }

  /// Finalize a ticketCreate: stamp the real server id onto the local ticket
  /// row. Dependent ops resolve that id live at execution time (see _process),
  /// so there's nothing else to rewrite.
  Future<void> _completeTicketCreate(PendingOp op, int newServerId) async {
    await _db.transaction(() async {
      await (_db.update(_db.tickets)
            ..where((t) => t.localId.equals(op.ticketLocalId)))
          .write(TicketsCompanion(serverId: Value(newServerId)));
      await _finish(op);
    });
  }

  Future<void> _markDone(PendingOp op, int? newServerId) async {
    await _db.transaction(() async {
      // A synced link stops showing its "syncing…" hint.
      if (op.opType == OpType.linkAdd && op.targetLocalId != null) {
        await (_db.update(_db.itilLinks)
              ..where((l) => l.localId.equals(op.targetLocalId!)))
            .write(const ItilLinksCompanion(pending: Value(false)));
      }
      // Stamp the server id onto the optimistic timeline row so it stops being
      // "pending" and won't be re-created on the next sync.
      if (newServerId != null && op.targetLocalId != null) {
        await (_db.update(_db.timelineItems)
              ..where((t) => t.localId.equals(op.targetLocalId!)))
            .write(TimelineItemsCompanion(serverId: Value(newServerId)));
      }
      await _finish(op);
    });
  }

  Future<void> _finish(PendingOp op) =>
      (_db.update(_db.pendingOps)..where((o) => o.id.equals(op.id))).write(
        const PendingOpsCompanion(
          status: Value(OpStatus.done),
          nextRetryAt: Value(null),
          lastError: Value(null),
        ),
      );

  Future<_Outcome> _classify(PendingOp op, GlpiError e) async {
    switch (e) {
      case GlpiNetworkError():
        // Don't count toward permanence; retry with backoff.
        await _scheduleRetry(op, e, countTowardMax: false);
        return _Outcome.retryLater;
      case GlpiServerError():
        if (op.attempts >= _maxServerAttempts) {
          await _fail(op, e);
          return _Outcome.needsAttention;
        }
        await _scheduleRetry(op, e, countTowardMax: true);
        return _Outcome.retryLater;
      case GlpiAuthError():
        // 401 refresh is the interceptor's job; if it bubbles here, re-auth is
        // required. Leave the op pending and stop the drain.
        await (_db.update(_db.pendingOps)..where((o) => o.id.equals(op.id)))
            .write(const PendingOpsCompanion(status: Value(OpStatus.pending)));
        return _Outcome.authStop;
      case GlpiValidationError():
      case GlpiForbiddenError():
      case GlpiNotFoundError():
      case GlpiUnexpectedError():
        await _fail(op, e);
        return _Outcome.needsAttention;
    }
  }

  Future<void> _scheduleRetry(
    PendingOp op,
    GlpiError e, {
    required bool countTowardMax,
  }) async {
    final idx = min(
      op.attempts - 1,
      _backoffSeconds.length - 1,
    ).clamp(0, _backoffSeconds.length - 1);
    final base = _backoffSeconds[idx];
    final jittered = base + _rng.nextInt((base * 0.4).ceil().clamp(1, 1 << 30));
    final next = clock.now().add(Duration(seconds: jittered));
    await (_db.update(_db.pendingOps)..where((o) => o.id.equals(op.id))).write(
      PendingOpsCompanion(
        status: const Value(OpStatus.failedRetryable),
        nextRetryAt: Value(next.toUtc().toIso8601String()),
        lastError: Value(e.message),
      ),
    );
  }

  Future<void> _fail(PendingOp op, GlpiError e) =>
      (_db.update(_db.pendingOps)..where((o) => o.id.equals(op.id))).write(
        PendingOpsCompanion(
          status: const Value(OpStatus.needsAttention),
          lastError: Value(e.message),
        ),
      );
}

enum _Outcome { done, retryLater, needsAttention, authStop }
