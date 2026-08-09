/// Outbox operation types.
class OpType {
  static const ticketCreate = 'ticketCreate'; // create a whole ticket
  static const formSubmit = 'formSubmit'; // submit a service-catalog form
  static const attachmentUpload =
      'attachmentUpload'; // upload a ticket document
  static const linkAdd = 'linkAdd'; // link two ITIL objects
  static const linkRemove = 'linkRemove';
  static const extraPatch = 'extraPatch'; // Change/Problem analysis fields
  // Planning
  static const taskPlan = 'taskPlan'; // reschedule / re-state a planned task
  static const eventCreate = 'eventCreate'; // PlanningExternalEvent
  static const eventPatch = 'eventPatch';
  static const eventDelete = 'eventDelete';
  static const reminderCreate = 'reminderCreate';
  static const reminderPatch = 'reminderPatch';
  static const reminderDelete = 'reminderDelete';
  // Projects
  static const projectTaskPatch = 'projectTaskPatch';
  static const projectTaskCreate = 'projectTaskCreate';
  // Tools
  static const kbCommentCreate = 'kbCommentCreate';
  static const rssCreate = 'rssCreate';
  static const rssPatch = 'rssPatch';
  static const rssDelete = 'rssDelete';
  static const reservationCreate = 'reservationCreate';
  static const reservationDelete = 'reservationDelete';

  /// Generic edit of an asset / management record.
  static const catalogPatch = 'catalogPatch';

  /// Link/unlink an asset to an ITIL object.
  static const itemLinkAdd = 'itemLinkAdd';
  static const itemLinkRemove = 'itemLinkRemove';
  static const followupCreate = 'followupCreate';
  static const taskCreate = 'taskCreate';
  static const taskSetState = 'taskSetState';
  static const ticketPatch = 'ticketPatch'; // scalar fields: status, priority…
  static const teamAdd = 'teamAdd'; // add an actor (assignee/observer/…)
  static const teamRemove = 'teamRemove'; // remove an actor
  static const solutionCreate = 'solutionCreate';
  static const solutionAnswer = 'solutionAnswer'; // approve/refuse a solution
  static const validationCreate = 'validationCreate'; // request approval
  static const validationAnswer = 'validationAnswer'; // approve/refuse
}

/// Outbox row statuses.
class OpStatus {
  static const pending = 'pending';
  static const inflight = 'inflight';
  static const failedRetryable = 'failedRetryable';
  static const needsAttention = 'needsAttention';
  static const done = 'done';
}

/// Idempotency marker embedded in created followup/task content so a lost POST
/// response can be recovered by re-reading the timeline and matching the marker
/// (GLPI preserves HTML comments — see docs/api-notes.md). Stripped on render.
String opMarker(String opUuid) => '<!-- op:$opUuid -->';

final _markerPattern = RegExp(r'<!--\s*op:[0-9a-fA-F-]+\s*-->');

String stripOpMarker(String content) =>
    content.replaceAll(_markerPattern, '').trimRight();

bool contentHasMarker(String content, String opUuid) =>
    content.contains('op:$opUuid');

/// Human-readable summary of an op for the needs-attention list.
String describeOp(String opType, int? ticketServerId) {
  // A not-yet-created ticket carries the 0 sentinel — don't show "#0".
  final ref = (ticketServerId == null || ticketServerId == 0)
      ? ''
      : ' on #$ticketServerId';
  return switch (opType) {
    OpType.ticketCreate => 'New ticket',
    OpType.formSubmit => 'Form submission',
    OpType.attachmentUpload => 'Attachment$ref',
    OpType.linkAdd => 'Link$ref',
    OpType.linkRemove => 'Unlink$ref',
    OpType.extraPatch => 'Analysis edit$ref',
    OpType.taskPlan => 'Task schedule',
    OpType.eventCreate => 'New event',
    OpType.eventPatch => 'Event edit',
    OpType.eventDelete => 'Event delete',
    OpType.reminderCreate => 'New reminder',
    OpType.reminderPatch => 'Reminder edit',
    OpType.reminderDelete => 'Reminder delete',
    OpType.projectTaskPatch => 'Project task edit',
    OpType.projectTaskCreate => 'New project task',
    OpType.kbCommentCreate => 'KB comment',
    OpType.rssCreate => 'New RSS feed',
    OpType.rssPatch => 'RSS feed edit',
    OpType.rssDelete => 'RSS feed delete',
    OpType.reservationCreate => 'New reservation',
    OpType.reservationDelete => 'Cancel reservation',
    OpType.catalogPatch => 'Record edit',
    OpType.itemLinkAdd => 'Asset link',
    OpType.itemLinkRemove => 'Asset unlink',
    OpType.followupCreate => 'Reply$ref',
    OpType.taskCreate => 'Task$ref',
    OpType.taskSetState => 'Task update$ref',
    OpType.ticketPatch => 'Ticket edit$ref',
    OpType.teamAdd => 'Add actor$ref',
    OpType.teamRemove => 'Remove actor$ref',
    OpType.solutionCreate => 'Solution$ref',
    OpType.solutionAnswer => 'Solution review$ref',
    OpType.validationCreate => 'Approval request$ref',
    OpType.validationAnswer => 'Approval$ref',
    _ => 'Change$ref',
  };
}
