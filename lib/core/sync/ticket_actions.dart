import 'dart:async';

import 'package:drift/drift.dart' show Value;

import '../api/itil_type.dart';
import '../db/app_database.dart';
import '../models/catalog_item.dart';
import '../models/itil_link.dart';
import '../models/planning_event.dart';
import '../models/project.dart';
import '../models/reminder.dart';
import '../models/ticket_detail.dart';
import '../models/timeline_entry.dart';
import 'outbox_writer.dart';
import 'sync_service.dart';

/// UI-facing write facade: performs the optimistic DB write via [OutboxWriter],
/// then kicks the sync engine. All methods return immediately after the local
/// commit — never blocking on the network.
class TicketActions {
  TicketActions({
    required OutboxWriter writer,
    required SyncService sync,
    required this.userId,
    required this.userName,
  }) // Private fields can't be named initializing formals.
    // ignore: prefer_initializing_formals
    : _writer = writer,
       // ignore: prefer_initializing_formals
       _sync = sync;

  final OutboxWriter _writer;
  final SyncService _sync;
  final int userId;
  final String userName;

  /// Create a new ticket optimistically; returns its local id for navigation.
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
  }) async {
    final localId = await _writer.createTicket(
      name: name,
      content: content,
      type: type,
      urgency: urgency,
      impact: impact,
      itemtype: itemtype,
      categoryId: categoryId,
      categoryName: categoryName,
      assignToMe: assignToMe,
      myUserId: userId,
      myUserName: userName,
    );
    unawaited(_sync.kick());
    return localId;
  }

  /// Submit a service-catalog form (offline-first). Returns the local id of the
  /// placeholder ticket, so the caller can navigate straight to it.
  Future<String> submitForm({
    required int formId,
    required Map<int, Object?> answers,
    required String placeholderTitle,
    String placeholderContent = '',
    List<({String path, String name, String? mime, int size})> files = const [],
  }) async {
    final localId = await _writer.submitForm(
      formId: formId,
      answers: answers,
      placeholderTitle: placeholderTitle,
      placeholderContent: placeholderContent,
      files: files,
      myUserName: userName,
    );
    unawaited(_sync.kick());
    return localId;
  }

  // --- Planning ---

  /// Reschedule and/or re-state a planned event (offline-first).
  Future<void> planEvent(
    PlanningEvent event, {
    DateTime? begin,
    DateTime? end,
    int? state,
  }) async {
    final serverId = event.eventServerId;
    if (serverId == null) return; // not yet created server-side
    await _writer.planEvent(
      eventLocalId: event.localId,
      eventItemtype: event.eventItemtype,
      eventServerId: serverId,
      parentItemtype: event.parentItemtype ?? event.eventItemtype,
      parentServerId: event.parentServerId ?? 0,
      begin: begin,
      end: end,
      state: state,
    );
    unawaited(_sync.kick());
  }

  /// Toggle a planned task between "to do" and "done".
  Future<void> toggleEventDone(PlanningEvent event) => planEvent(
    event,
    state: event.isDone ? PlanningState.todo : PlanningState.done,
  );

  /// Create a standalone event (`PlanningExternalEvent`) or a `Reminder`.
  Future<String> createPlanningItem({
    required String kind,
    required String name,
    String text = '',
    required DateTime begin,
    required DateTime end,
    int state = PlanningState.todo,
    bool isAllDay = false,
  }) async {
    final localId = await _writer.createPlanningItem(
      kind: kind,
      name: name,
      text: text,
      begin: begin,
      end: end,
      state: state,
      isAllDay: isAllDay,
    );
    unawaited(_sync.kick());
    return localId;
  }

  Future<void> patchPlanningItem(
    PlanningEvent event, {
    String? name,
    String? text,
    DateTime? begin,
    DateTime? end,
    int? state,
  }) async {
    final serverId = event.eventServerId;
    if (serverId == null) return;
    await _writer.patchPlanningItem(
      eventLocalId: event.localId,
      kind: event.eventItemtype,
      serverId: serverId,
      name: name,
      text: text,
      begin: begin,
      end: end,
      state: state,
    );
    unawaited(_sync.kick());
  }

  Future<void> deletePlanningItem(PlanningEvent event) async {
    final serverId = event.eventServerId;
    if (serverId == null) return;
    await _writer.deletePlanningItem(
      eventLocalId: event.localId,
      kind: event.eventItemtype,
      serverId: serverId,
    );
    unawaited(_sync.kick());
  }

  // --- Tools ---

  Future<String> createReminder({
    required String name,
    String content = '',
    bool isPlanned = false,
    DateTime? begin,
    DateTime? end,
    int state = 0,
  }) async {
    final id = await _writer.createReminder(
      name: name,
      content: content,
      isPlanned: isPlanned,
      begin: begin,
      end: end,
      state: state,
    );
    unawaited(_sync.kick());
    return id;
  }

  Future<void> patchReminder(
    Reminder reminder, {
    String? name,
    String? content,
    bool? isPlanned,
    DateTime? begin,
    DateTime? end,
    int? state,
  }) async {
    final serverId = reminder.serverId;
    if (serverId == null) return;
    await _writer.patchReminder(
      localId: reminder.localId,
      serverId: serverId,
      name: name,
      content: content,
      isPlanned: isPlanned,
      begin: begin,
      end: end,
      state: state,
    );
    unawaited(_sync.kick());
  }

  Future<void> deleteReminder(Reminder reminder) async {
    final serverId = reminder.serverId;
    if (serverId == null) return;
    await _writer.deleteReminder(localId: reminder.localId, serverId: serverId);
    unawaited(_sync.kick());
  }

  Future<void> addKbComment(int articleId, String comment) async {
    await _writer.addKbComment(articleId: articleId, comment: comment);
    unawaited(_sync.kick());
  }

  Future<void> createRssFeed({
    required String name,
    required String url,
  }) async {
    await _writer.createRssFeed(name: name, url: url);
    unawaited(_sync.kick());
  }

  Future<void> deleteRssFeed(int id) async {
    await _writer.deleteRssFeed(id);
    unawaited(_sync.kick());
  }

  Future<void> createReservation({
    required int reservationItemId,
    required DateTime begin,
    required DateTime end,
    String comment = '',
  }) async {
    await _writer.createReservation(
      reservationItemId: reservationItemId,
      begin: begin,
      end: end,
      comment: comment,
    );
    unawaited(_sync.kick());
  }

  Future<void> deleteReservation(int id) async {
    await _writer.deleteReservation(id);
    unawaited(_sync.kick());
  }

  /// Link an asset to an ITIL object (offline-first). Passing a ticket that
  /// hasn't synced yet is fine — the op carries the 0 sentinel and the drainer
  /// resolves the real id once the create lands.
  Future<void> linkAssetToItil({
    required String ownerLocalId,
    required int ownerServerId,
    required String itemtype,
    required String assetItemtype,
    required int assetId,
  }) async {
    await _writer.addItemLink(
      ownerLocalId: ownerLocalId,
      ownerServerId: ownerServerId,
      itemtype: itemtype,
      targetItemtype: assetItemtype,
      targetServerId: assetId,
    );
    unawaited(_sync.kick());
  }

  Future<void> unlinkAssetFromItil({
    required String ownerLocalId,
    required int ownerServerId,
    required String itemtype,
    required String assetItemtype,
    required int assetId,
  }) async {
    await _writer.removeItemLink(
      ownerLocalId: ownerLocalId,
      ownerServerId: ownerServerId,
      itemtype: itemtype,
      targetItemtype: assetItemtype,
      targetServerId: assetId,
    );
    unawaited(_sync.kick());
  }

  /// Edit an asset / management record (offline-first). Only the fields a
  /// technician changes in the field are editable; the rest stay read-only.
  Future<void> patchCatalogItem(
    CatalogItem item, {
    int? statusId,
    String? statusName,
    int? locationId,
    String? locationName,
    int? userId,
    String? userName,
    String? comment,
  }) async {
    // GLPI's high-level API keys writes by *schema* field name, not by DB
    // column: a PATCH carrying `states_id` returns 200 and changes nothing.
    final api = <String, Object?>{
      'status': ?statusId,
      'location': ?locationId,
      'user': ?userId,
      'comment': ?comment,
    };
    if (api.isEmpty) return;
    await _writer.patchCatalogItem(
      localId: item.localId,
      serverId: item.serverId,
      domain: item.domain,
      itemtype: item.itemtype,
      promoted: CatalogItemsCompanion(
        statusName: statusName == null
            ? const Value.absent()
            : Value(statusName),
        locationName: locationName == null
            ? const Value.absent()
            : Value(locationName),
        userName: userName == null ? const Value.absent() : Value(userName),
        pending: const Value(true),
      ),
      apiBody: api,
    );
    unawaited(_sync.kick());
  }

  // --- Projects ---

  Future<void> patchProjectTask(
    ProjectTask task, {
    String? name,
    String? content,
    int? percentDone,
    DateTime? planStart,
    DateTime? planEnd,
  }) async {
    final serverId = task.serverId;
    if (serverId == null) return; // not yet created server-side
    await _writer.patchProjectTask(
      taskLocalId: task.localId,
      taskServerId: serverId,
      name: name,
      content: content,
      percentDone: percentDone,
      planStart: planStart,
      planEnd: planEnd,
    );
    unawaited(_sync.kick());
  }

  Future<String> createProjectTask(
    Project project, {
    required String name,
    String content = '',
    int? parentTaskServerId,
    int percentDone = 0,
    DateTime? planStart,
    DateTime? planEnd,
  }) async {
    final localId = await _writer.createProjectTask(
      projectLocalId: project.localId,
      projectServerId: project.serverId ?? 0,
      name: name,
      content: content,
      parentTaskServerId: parentTaskServerId,
      percentDone: percentDone,
      planStart: planStart,
      planEnd: planEnd,
    );
    unawaited(_sync.kick());
    return localId;
  }

  /// Link another ITIL object to this one (offline-first).
  Future<void> addLink(
    TicketDetail item, {
    required String targetItemtype,
    required int targetId,
    required String targetName,
    int targetStatus = 1,
    int linkType = ItilLinkType.linkTo,
  }) async {
    await _writer.addLink(
      ownerLocalId: item.localId,
      ownerServerId: item.serverId ?? 0,
      itemtype: item.itemtype,
      targetItemtype: targetItemtype,
      targetServerId: targetId,
      targetName: targetName,
      targetStatus: targetStatus,
      linkType: linkType,
    );
    unawaited(_sync.kick());
  }

  /// Remove a link (offline-first).
  Future<void> removeLink(TicketDetail item, ItilLink link) async {
    await _writer.removeLink(
      ownerLocalId: item.localId,
      ownerServerId: item.serverId ?? 0,
      itemtype: item.itemtype,
      targetItemtype: link.itemtype,
      targetServerId: link.serverId,
    );
    unawaited(_sync.kick());
  }

  /// Edit Change/Problem analysis fields (offline-first).
  Future<void> patchExtra(TicketDetail item, Map<String, String> fields) async {
    await _writer.patchExtra(
      ownerLocalId: item.localId,
      ownerServerId: item.serverId ?? 0,
      itemtype: item.itemtype,
      fields: fields,
    );
    unawaited(_sync.kick());
  }

  /// Attach a file (optimistically) to a ticket. Works for a not-yet-synced
  /// ticket too: the 0 sentinel is resolved to the real id once it's created.
  /// Attach a file to any GLPI item (ITIL object, asset, management record).
  Future<void> addAttachment({
    required String ownerLocalId,
    required int ownerServerId,
    required String itemtype,
    required String localPath,
    required String name,
    String? mime,
    int? sizeBytes,
  }) async {
    await _writer.addAttachment(
      ticketLocalId: ownerLocalId,
      ticketServerId: ownerServerId,
      itemtype: itemtype,
      localPath: localPath,
      name: name,
      mime: mime,
      sizeBytes: sizeBytes,
    );
    unawaited(_sync.kick());
  }

  Future<void> addFollowup(
    TicketDetail ticket, {
    required String content,
    required bool isPrivate,
  }) async {
    await _writer.addFollowup(
      ticketLocalId: ticket.localId,
      ticketServerId: ticket.serverId!,
      itemtype: ticket.itemtype,
      content: content,
      isPrivate: isPrivate,
      authorId: userId,
      authorName: userName,
    );
    unawaited(_sync.kick());
  }

  Future<void> addTask(
    TicketDetail ticket, {
    required String content,
    required bool isPrivate,
    int? durationSeconds,
  }) async {
    await _writer.addTask(
      ticketLocalId: ticket.localId,
      ticketServerId: ticket.serverId!,
      itemtype: ticket.itemtype,
      content: content,
      isPrivate: isPrivate,
      durationSeconds: durationSeconds,
      authorId: userId,
      authorName: userName,
    );
    unawaited(_sync.kick());
  }

  Future<void> toggleTask(TicketDetail ticket, TimelineEntry task) async {
    if (task.serverId == null) return; // can't toggle an unsynced task yet
    await _writer.setTaskState(
      ticketLocalId: ticket.localId,
      ticketServerId: ticket.serverId!,
      itemtype: ticket.itemtype,
      taskLocalId: task.localId,
      taskServerId: task.serverId!,
      state: task.isTaskDone ? 1 : 2,
    );
    unawaited(_sync.kick());
  }

  Future<void> setStatus(TicketDetail ticket, int status) async {
    await _writer.setStatus(
      ticketLocalId: ticket.localId,
      ticketServerId: ticket.serverId!,
      itemtype: ticket.itemtype,
      status: status,
    );
    unawaited(_sync.kick());
  }

  Future<void> setUrgency(TicketDetail ticket, int urgency) async {
    await _writer.setUrgency(
      ticketLocalId: ticket.localId,
      ticketServerId: ticket.serverId!,
      itemtype: ticket.itemtype,
      urgency: urgency,
      impact: ticket.impact,
    );
    unawaited(_sync.kick());
  }

  Future<void> setImpact(TicketDetail ticket, int impact) async {
    await _writer.setImpact(
      ticketLocalId: ticket.localId,
      ticketServerId: ticket.serverId!,
      itemtype: ticket.itemtype,
      urgency: ticket.urgency,
      impact: impact,
    );
    unawaited(_sync.kick());
  }

  Future<void> setType(TicketDetail ticket, int type) async {
    await _writer.setType(
      ticketLocalId: ticket.localId,
      ticketServerId: ticket.serverId!,
      itemtype: ticket.itemtype,
      type: type,
    );
    unawaited(_sync.kick());
  }

  Future<void> setCategory(
    TicketDetail ticket, {
    required int categoryId,
    required String categoryName,
  }) async {
    await _writer.setCategory(
      ticketLocalId: ticket.localId,
      ticketServerId: ticket.serverId!,
      itemtype: ticket.itemtype,
      categoryId: categoryId,
      categoryName: categoryName,
    );
    unawaited(_sync.kick());
  }

  Future<void> assignSelf(TicketDetail ticket) => addActor(
    ticket,
    role: 'assigned',
    type: 'User',
    id: userId,
    name: userName,
  );

  Future<void> addActor(
    TicketDetail ticket, {
    required String role,
    required String type,
    required int id,
    required String name,
  }) async {
    await _writer.addActor(
      ticketLocalId: ticket.localId,
      ticketServerId: ticket.serverId!,
      itemtype: ticket.itemtype,
      role: role,
      memberType: type,
      memberId: id,
      displayName: name,
    );
    unawaited(_sync.kick());
  }

  Future<void> removeActor(TicketDetail ticket, TicketActor actor) async {
    await _writer.removeActor(
      ticketLocalId: ticket.localId,
      ticketServerId: ticket.serverId!,
      itemtype: ticket.itemtype,
      role: actor.role,
      memberType: actor.type,
      memberId: actor.id,
    );
    unawaited(_sync.kick());
  }

  Future<void> addSolution(TicketDetail ticket, String content) async {
    await _writer.addSolution(
      ticketLocalId: ticket.localId,
      ticketServerId: ticket.serverId!,
      itemtype: ticket.itemtype,
      content: content,
      authorId: userId,
      authorName: userName,
    );
    unawaited(_sync.kick());
  }

  Future<void> answerSolution(
    TicketDetail ticket,
    TimelineEntry solution, {
    required bool accept,
  }) async {
    if (solution.serverId == null) return;
    await _writer.answerSolution(
      ticketLocalId: ticket.localId,
      ticketServerId: ticket.serverId!,
      itemtype: ticket.itemtype,
      solutionLocalId: solution.localId,
      solutionServerId: solution.serverId!,
      status: accept ? 3 : 4,
    );
    unawaited(_sync.kick());
  }

  Future<void> requestApproval(
    TicketDetail ticket, {
    required int approverId,
    required String approverName,
    required String comment,
  }) async {
    await _writer.requestValidation(
      ticketLocalId: ticket.localId,
      ticketServerId: ticket.serverId!,
      itemtype: ticket.itemtype,
      approverId: approverId,
      approverName: approverName,
      comment: comment,
    );
    unawaited(_sync.kick());
  }

  Future<void> answerValidation(
    TicketDetail ticket,
    TimelineEntry validation, {
    required bool accept,
    String? comment,
  }) async {
    if (validation.serverId == null) return;
    await _writer.answerValidation(
      ticketLocalId: ticket.localId,
      ticketServerId: ticket.serverId!,
      itemtype: ticket.itemtype,
      validationLocalId: validation.localId,
      validationServerId: validation.serverId!,
      status: accept ? 3 : 4,
      comment: comment,
    );
    unawaited(_sync.kick());
  }

  /// Is the current user the requested approver of this validation?
  bool isMyValidation(TimelineEntry validation) =>
      validation.approverType == 'User' && validation.approverId == userId;
}
