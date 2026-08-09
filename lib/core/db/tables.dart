import 'package:drift/drift.dart';

/// Cached tickets. `localId` (UUID) is the stable PK; `serverId` is the GLPI id.
/// The UI reads only from this table via reactive queries; the sync engine is
/// the only writer from the network.
class Tickets extends Table {
  TextColumn get localId => text()();
  IntColumn get serverId => integer().nullable()();

  /// Which GLPI ITIL object this row is: Ticket | Change | Problem.
  TextColumn get itemtype => text().withDefault(const Constant('Ticket'))();

  TextColumn get name => text()();
  TextColumn get content => text().withDefault(const Constant(''))();
  IntColumn get status => integer()();
  IntColumn get priority => integer().withDefault(const Constant(3))();
  IntColumn get urgency => integer().withDefault(const Constant(3))();
  IntColumn get impact => integer().withDefault(const Constant(3))();
  IntColumn get type => integer().withDefault(const Constant(1))();

  IntColumn get categoryId => integer().nullable()();
  TextColumn get categoryName => text().nullable()();
  IntColumn get entityId => integer().nullable()();
  // Named entityLabel, not entityName: drift's TableInfo already defines an
  // `entityName` member (the SQL table name), which a column can't shadow.
  TextColumn get entityLabel => text().nullable()();
  TextColumn get requestTypeName => text().nullable()();
  IntColumn get locationId => integer().nullable()();
  TextColumn get locationName => text().nullable()();
  // The ticket's creator (user_recipient) — "Created by".
  TextColumn get recipientName => text().nullable()();

  /// Server clock, ISO-8601 UTC strings (never the device clock).
  TextColumn get dateCreation => text().nullable()();
  TextColumn get dateMod => text().nullable()();
  TextColumn get timeToResolve => text().nullable()();
  TextColumn get timeToOwn => text().nullable()();

  @override
  Set<Column> get primaryKey => {localId};
}

/// Actors on a ticket (requester / assigned / observer), users and groups.
/// The Mine/Groups/Unassigned tabs are local queries over this table, because
/// GLPI 11's RSQL `team.*` filters are broken (see docs/api-notes.md).
class TicketTeam extends Table {
  TextColumn get localId => text()();
  TextColumn get ticketLocalId =>
      text().references(Tickets, #localId, onDelete: KeyAction.cascade)();
  TextColumn get role => text()(); // requester | assigned | observer
  TextColumn get memberType => text()(); // User | Group | Supplier
  IntColumn get memberId => integer()();
  TextColumn get displayName => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {localId};
}

/// Merged timeline entries for a ticket (single table with a type
/// discriminator, mirroring the server's merged `/Timeline` response).
class TimelineItems extends Table {
  TextColumn get localId => text()();
  TextColumn get ticketLocalId =>
      text().references(Tickets, #localId, onDelete: KeyAction.cascade)();
  IntColumn get serverId => integer().nullable()();

  TextColumn get itemType =>
      text()(); // followup | task | solution | validation | document
  TextColumn get content => text().withDefault(const Constant(''))();
  BoolColumn get isPrivate => boolean().withDefault(const Constant(false))();
  TextColumn get dateCreation => text().nullable()();
  IntColumn get authorId => integer().nullable()();
  TextColumn get authorName => text().nullable()();

  IntColumn get taskDuration => integer().nullable()();
  IntColumn get taskState => integer().nullable()();
  IntColumn get solutionStatus => integer().nullable()();
  IntColumn get validationStatus => integer().nullable()();
  // Validation-only: the requested approver and their reply.
  IntColumn get approverId => integer().nullable()();
  TextColumn get approverType => text().nullable()();
  TextColumn get approvalComment => text().nullable()();

  @override
  Set<Column> get primaryKey => {localId};
}

/// Reference dropdowns (categories, locations, request types) cached generically
/// by `kind`.
class DropdownItems extends Table {
  TextColumn get kind => text()(); // itilcategory | location | requesttype
  IntColumn get serverId => integer()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {kind, serverId};
}

/// The offline outbox. Every mutation writes one row here in the same
/// transaction as its optimistic local change; the sync engine drains it.
class PendingOps extends Table {
  IntColumn get id => integer().autoIncrement()(); // global FIFO order
  TextColumn get opUuid => text()(); // idempotency marker, embedded in creates
  TextColumn get opType => text()();

  /// ITIL type of the target object (Ticket | Change | Problem).
  TextColumn get itemtype => text().withDefault(const Constant('Ticket'))();
  TextColumn get ticketLocalId => text()(); // partition key for serial ordering
  IntColumn get ticketServerId => integer()();
  TextColumn get targetLocalId => text().nullable()(); // e.g. the timeline row
  IntColumn get targetServerId => integer().nullable()(); // e.g. task server id
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  TextColumn get baseSnapshot =>
      text().nullable()(); // for PATCH conflict check
  TextColumn get status => text().withDefault(
    const Constant('pending'),
  )(); // pending|inflight|failedRetryable|needsAttention|done
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get nextRetryAt => text().nullable()();
  TextColumn get lastError => text().nullable()();
  TextColumn get createdAt => text()();

  /// The GLPI entity context this op was composed in. A queued create files
  /// into whatever entity the request header names, so an op drained after the
  /// technician switched entities would land in the wrong one — it is pinned
  /// here instead of following the active context.
  IntColumn get entityId => integer().nullable()();
  BoolColumn get entityRecursive => boolean().nullable()();
}

/// A running task timer, persisted so elapsed time survives app kill.
class ActiveTimers extends Table {
  TextColumn get ticketLocalId => text()();
  IntColumn get ticketServerId => integer()();
  TextColumn get ticketName => text().withDefault(const Constant(''))();
  TextColumn get startedAt => text()(); // ISO UTC

  @override
  Set<Column> get primaryKey => {ticketLocalId};
}

/// Small key-value store for cached instance config (e.g. the priority matrix),
/// so admin-configured settings survive restarts and offline use.
class AppConfig extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Per-scope incremental-sync bookkeeping.
class SyncState extends Table {
  TextColumn get scopeKey => text()();
  TextColumn get watermark => text().nullable()(); // max date_mod seen
  TextColumn get lastSuccessAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {scopeKey};
}

/// A ticket attachment (GLPI Document). Server-known ones carry [serverDocId];
/// locally-added ones are "pending" (serverDocId null) until the upload op
/// drains, and keep [localPath] pointing at the on-device file to upload. The
/// same [localPath] doubles as the cache path once an image is downloaded.
@DataClassName('AttachmentRow')
class Attachments extends Table {
  TextColumn get localId => text()();
  TextColumn get ticketLocalId =>
      text().references(Tickets, #localId, onDelete: KeyAction.cascade)();
  IntColumn get serverDocId => integer().nullable()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get filename => text().nullable()();
  TextColumn get mime => text().nullable()();
  TextColumn get localPath =>
      text().nullable()(); // on-device file (upload/cache)
  IntColumn get sizeBytes => integer().nullable()();
  TextColumn get opUuid => text().nullable()(); // upload idempotency marker
  TextColumn get dateCreation => text().nullable()();

  @override
  Set<Column> get primaryKey => {localId};
}

/// A link between two ITIL objects (ticket↔ticket, change↔ticket, …). Rows are
/// stored from the perspective of the local object, so [targetItemtype]/
/// [targetServerId] describe the *other* end.
@DataClassName('ItilLinkRow')
class ItilLinks extends Table {
  TextColumn get localId => text()();
  TextColumn get ownerLocalId =>
      text().references(Tickets, #localId, onDelete: KeyAction.cascade)();
  TextColumn get targetItemtype => text()();
  IntColumn get targetServerId => integer()();
  TextColumn get targetName => text().withDefault(const Constant(''))();
  IntColumn get targetStatus => integer().withDefault(const Constant(1))();
  IntColumn get linkType => integer().withDefault(const Constant(1))();

  /// Set while an add/remove is still queued in the outbox.
  BoolColumn get pending => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {localId};
}

/// Change/Problem analysis fields (impact, cause, symptom, plans, checklists),
/// cached per object so they read offline.
@DataClassName('ItilExtraRow')
class ItilExtras extends Table {
  TextColumn get ownerLocalId =>
      text().references(Tickets, #localId, onDelete: KeyAction.cascade)();
  TextColumn get fieldsJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {ownerLocalId};
}

/// A calendar event from GLPI's planning: ITIL/project tasks, reminders and
/// external events, normalized by the plugin's `/GlpiMobile/planning` feed.
/// Rows created locally (offline) have a null [eventServerId] until they drain.
@DataClassName('PlanningEventRow')
class PlanningEvents extends Table {
  TextColumn get localId => text()();
  TextColumn get eventItemtype => text()(); // TicketTask | Reminder | …
  IntColumn get eventServerId => integer().nullable()();
  TextColumn get parentItemtype => text().nullable()(); // Ticket | Change | …
  IntColumn get parentServerId => integer().nullable()();
  TextColumn get parentName => text().nullable()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get begin => text()(); // 'YYYY-MM-DD HH:MM:SS', server clock
  TextColumn get end => text()();
  BoolColumn get isAllDay => boolean().withDefault(const Constant(false))();
  IntColumn get state =>
      integer().withDefault(const Constant(0))(); // 0 info 1 todo 2 done
  BoolColumn get pending => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {localId};
}

/// GLPI projects (Tools › Projects).
@DataClassName('ProjectRow')
class Projects extends Table {
  TextColumn get localId => text()();
  IntColumn get serverId => integer().nullable()();
  TextColumn get name => text()();
  TextColumn get code => text().nullable()();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get statusName => text().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(3))();
  IntColumn get percentDone => integer().withDefault(const Constant(0))();
  TextColumn get planStartDate => text().nullable()();
  TextColumn get planEndDate => text().nullable()();
  TextColumn get managerName => text().nullable()();
  TextColumn get entityLabel => text().nullable()();
  TextColumn get dateMod => text().nullable()();

  @override
  Set<Column> get primaryKey => {localId};
}

/// Tasks inside a project, flattened (a task's parent is [parentTaskServerId]).
@DataClassName('ProjectTaskRow')
class ProjectTasks extends Table {
  TextColumn get localId => text()();
  TextColumn get projectLocalId =>
      text().references(Projects, #localId, onDelete: KeyAction.cascade)();
  IntColumn get serverId => integer().nullable()();
  IntColumn get parentTaskServerId => integer().nullable()();
  TextColumn get name => text()();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get statusName => text().nullable()();
  IntColumn get percentDone => integer().withDefault(const Constant(0))();
  TextColumn get planStartDate => text().nullable()();
  TextColumn get planEndDate => text().nullable()();
  BoolColumn get isMilestone => boolean().withDefault(const Constant(false))();
  TextColumn get assigneeName => text().nullable()();
  BoolColumn get pending => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {localId};
}

/// Reminders (Tools › Reminders). Personal notes with an optional planning
/// window; shared ones (not authored by me) render read-only.
@DataClassName('ReminderRow')
class Reminders extends Table {
  TextColumn get localId => text()();
  IntColumn get serverId => integer().nullable()();
  TextColumn get name => text()();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get beginViewDate => text().nullable()();
  TextColumn get endViewDate => text().nullable()();
  BoolColumn get isPlanned => boolean().withDefault(const Constant(false))();
  TextColumn get begin => text().nullable()();
  TextColumn get end => text().nullable()();
  IntColumn get state => integer().withDefault(const Constant(0))();
  BoolColumn get isMine => boolean().withDefault(const Constant(true))();
  BoolColumn get pending => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {localId};
}

/// Knowledge base categories (tree, `completename` holds the full path).
@DataClassName('KbCategoryRow')
class KbCategories extends Table {
  IntColumn get serverId => integer()();
  TextColumn get name => text()();
  TextColumn get completename => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {serverId};
}

/// Knowledge base articles. Only opened articles cache their body, so list
/// rows may have empty [contentHtml] until read.
@DataClassName('KbArticleRow')
class KbArticles extends Table {
  IntColumn get serverId => integer()();
  TextColumn get name => text()();
  TextColumn get contentHtml => text().withDefault(const Constant(''))();
  IntColumn get categoryId => integer().nullable()();
  TextColumn get categoryName => text().nullable()();
  BoolColumn get isFaq => boolean().withDefault(const Constant(false))();
  IntColumn get views => integer().withDefault(const Constant(0))();
  TextColumn get dateMod => text().nullable()();

  /// Set when the user pinned it for offline reading.
  BoolColumn get keepOffline => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {serverId};
}

/// Any GLPI asset or management record, stored generically.
///
/// A few columns are promoted so lists can search and sort in SQL; the full
/// server payload lives in [fieldsJson] so the schema survives GLPI's custom
/// fields and custom asset definitions without a migration per itemtype.
@DataClassName('CatalogItemRow')
class CatalogItems extends Table {
  TextColumn get localId => text()();

  /// 'assets' or 'management' — which browser owns the row.
  TextColumn get domain => text()();
  TextColumn get itemtype => text()();
  IntColumn get serverId => integer()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get serial => text().nullable()();
  TextColumn get otherserial => text().nullable()();
  TextColumn get statusName => text().nullable()();
  TextColumn get locationName => text().nullable()();
  TextColumn get userName => text().nullable()();
  TextColumn get groupName => text().nullable()();
  TextColumn get manufacturerName => text().nullable()();
  TextColumn get modelName => text().nullable()();
  TextColumn get typeName => text().nullable()();
  TextColumn get entityLabel => text().nullable()();

  /// Whichever date drives this itemtype's expiry badge (contracts, certs…).
  TextColumn get expiryDate => text().nullable()();
  TextColumn get dateMod => text().nullable()();
  TextColumn get fieldsJson => text().withDefault(const Constant('{}'))();
  BoolColumn get pending => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {localId};
}
