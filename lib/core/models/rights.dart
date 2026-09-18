/// What the signed-in profile may do, from `GET /session`'s
/// `active_profile.rights` — the same bitmask map GLPI itself builds its menus
/// from (`$_SESSION['glpiactiveprofile']`).
///
/// ```json
/// {"active_profile": {"interface": "central",
///                     "rights": {"ticket": 429063, "project": 1151, ...}}}
/// ```
///
/// Two rules, both GLPI's own (`Session::haveRight`):
///
/// * a right is held when the profile's value **and**s non-zero with the bit;
/// * a **missing key means no right**. Helpdesk profiles ship 26 keys where a
///   central one ships 160, and everything absent is simply denied.
///
/// So an unparseable or unfetched map denies everything rather than showing a
/// technician doors that answer 403 — [empty] is the safe default, and the
/// last-known map is cached so gating survives going offline.
library;

/// GLPI's standard right bits (`src/autoload/constants.php`) plus the
/// per-itemtype extras the app gates on. Named rather than inlined: a bare
/// `1024` means eight different things across these classes.
abstract final class R {
  // Standard rights, every itemtype.
  static const read = 1;
  static const update = 2;
  static const create = 4;
  static const delete = 8;
  static const purge = 16;
  static const readNote = 32;
  static const updateNote = 64;
  static const unlock = 128;

  // CommonITILObject (Ticket / Change / Problem).
  static const readMy = 1;
  static const readAll = 1024;
  static const survey = 131072;

  // Ticket only.
  static const readGroup = 2048;
  static const readAssign = 4096;
  static const assign = 8192;
  static const steal = 16384;
  static const own = 32768;
  static const changePriority = 65536;
  static const readNewTicket = 262144;

  // ITILSubItemRights — followups and tasks.
  static const seePublic = 1;
  static const updateMy = 2;
  static const addMy = 4;
  static const updateAll = 1024;
  static const addAsGroup = 2048;
  static const addAllItem = 4096;
  static const seePrivate = 8192;
  static const seePrivateGroups = 65536;

  // TicketValidation. ChangeValidation keeps the CommonITILValidation
  // defaults instead: CREATE to request, [validate] to answer.
  static const createRequest = 1024;
  static const createIncident = 2048;
  static const validateRequest = 4096;
  static const validateIncident = 8192;

  /// CommonITILValidation::VALIDATE — ChangeValidation's answer right.
  static const validate = 1024;

  // KnowbaseItem.
  static const knowbaseAdmin = 1024;
  static const readFaq = 2048;
  static const publishFaq = 4096;
  static const comments = 8192;

  // Reminder / RSSFeed: a personal one needs no public right.
  static const personal = 128;

  /// ReservationItem::RESERVEANITEM — book an item without seeing every
  /// reservation.
  static const reserveAnItem = 1024;

  // Project / ProjectTask.
  static const projectTaskUpdateMy = 1024;

  // Planning.
  static const planningReadGroup = 1024;
  static const planningReadAll = 2048;
}

/// The `rights` map keys the app reads, as GLPI spells them (a class's
/// `static $rightname`, which is often not its class name — a Supplier is
/// `contact_enterprise`, a NetworkEquipment is `networking`).
abstract final class Rn {
  static const ticket = 'ticket';
  static const change = 'change';
  static const problem = 'problem';
  static const followup = 'followup';
  static const task = 'task';
  static const ticketValidation = 'ticketvalidation';
  static const changeValidation = 'changevalidation';
  static const ticketCost = 'ticketcost';
  static const project = 'project';
  static const projectTask = 'projecttask';
  static const knowbase = 'knowbase';
  static const reminder = 'reminder_public';
  static const rssfeed = 'rssfeed_public';
  static const reservation = 'reservation';
  static const planning = 'planning';
  static const externalEvent = 'externalevent';
  static const document = 'document';
}

/// Itemtype → rightname for everything `/Assets` and `/Management` can list.
/// Only the ones that differ from `itemtype.toLowerCase()` need an entry.
const _rightnameOverrides = <String, String>{
  'NetworkEquipment': 'networking',
  'SoftwareLicense': 'license',
  'Software': 'software',
  'Contact': 'contact_enterprise',
  'Supplier': 'contact_enterprise',
  'DatabaseInstance': 'database',
  'Item_DeviceSimcard': 'devicesimcard_pinpuk',
  'Ticket': Rn.ticket,
  'Change': Rn.change,
  'Problem': Rn.problem,
  'Reminder': Rn.reminder,
  'RSSFeed': Rn.rssfeed,
  'KnowbaseItem': Rn.knowbase,
  'ReservationItem': Rn.reservation,
  'PlanningExternalEvent': Rn.externalEvent,
};

/// The profile rights of the active GLPI context (profile × entity).
class Rights {
  const Rights(this._values, {this.interface = ''});

  /// Nothing granted — no map fetched or cached yet, or a malformed one.
  /// Gates read this as "hide", never as "allow".
  static const empty = Rights({});

  final Map<String, int> _values;

  /// `central` for a technician profile, `helpdesk` for self-service. GLPI
  /// hands helpdesk profiles a different application entirely; the app only
  /// uses this to explain itself, never to grant.
  final String interface;

  bool get isEmpty => _values.isEmpty;

  /// True for a self-service profile — one whose GLPI web session would land
  /// on the helpdesk interface rather than the central one.
  bool get isHelpdesk => interface == 'helpdesk';

  /// The raw bitmask for [rightname]; 0 when the profile has no such key.
  int valueOf(String rightname) => _values[rightname] ?? 0;

  /// `Session::haveRight` — [rightname] carries [bit].
  bool has(String rightname, int bit) => (valueOf(rightname) & bit) != 0;

  /// `Session::haveRightsOr` — [rightname] carries at least one of [bits].
  bool hasAny(String rightname, List<int> bits) =>
      bits.any((bit) => has(rightname, bit));

  // --- Assistance (ITIL) -------------------------------------------------

  /// `Ticket::canView()`: any of the read flavours, or the right to answer an
  /// approval — an approver sees the tickets waiting on them.
  bool get canViewTickets =>
      hasAny(Rn.ticket, [
        R.readAll,
        R.readMy,
        R.update,
        R.readAssign,
        R.readGroup,
        R.own,
        R.readNewTicket,
      ]) ||
      hasAny(Rn.ticketValidation, [R.validateRequest, R.validateIncident]);

  /// `Change::canView()`.
  bool get canViewChanges => hasAny(Rn.change, [R.readAll, R.readMy]);

  /// `Problem::canView()`.
  bool get canViewProblems => hasAny(Rn.problem, [R.readAll, R.readMy]);

  /// The queue's module switcher asks this per ITIL itemtype.
  bool canViewItil(String itemtype) => switch (itemtype) {
    'Ticket' => canViewTickets,
    'Change' => canViewChanges,
    'Problem' => canViewProblems,
    _ => false,
  };

  bool canCreateItil(String itemtype) => has(_rightnameOf(itemtype), R.create);

  /// Editing an ITIL object's own fields (status, category, priority…).
  bool canUpdateItil(String itemtype) => has(_rightnameOf(itemtype), R.update);

  /// `Ticket::canAssign()` — editing who a ticket is assigned to. Changes and
  /// problems have no assign bit of their own; their actors are part of the
  /// object, so UPDATE is the gate.
  bool canAssignItil(String itemtype) => switch (itemtype) {
    'Ticket' => has(Rn.ticket, R.assign),
    _ => canUpdateItil(itemtype),
  };

  /// `Ticket::canAssignToMe()` — taking the ticket. GLPI's stock Technician
  /// profile holds OWN ("associate myself") without ASSIGN, and OWN only
  /// applies while nobody else has it; STEAL is what takes an assigned one.
  bool canTakeItil(String itemtype, {required bool alreadyAssigned}) =>
      switch (itemtype) {
        'Ticket' =>
          has(Rn.ticket, R.steal) ||
              (has(Rn.ticket, R.own) && !alreadyAssigned),
        _ => canUpdateItil(itemtype),
      };

  /// Adding a reply. GLPI splits this by whose ticket it is; the app offers
  /// the composer when any add flavour is held.
  bool get canAddFollowup =>
      hasAny(Rn.followup, [R.addMy, R.addAsGroup, R.addAllItem]);

  /// Private followups and tasks are invisible without this.
  bool get canSeePrivateFollowups =>
      hasAny(Rn.followup, [R.seePrivate, R.seePrivateGroups]);

  bool get canAddTask => hasAny(Rn.task, [R.addMy, R.addAsGroup, R.addAllItem]);

  bool get canUpdateTask => hasAny(Rn.task, [R.updateMy, R.updateAll]);

  /// A solution is written through the ITIL object itself.
  bool canAddSolution(String itemtype) => canUpdateItil(itemtype);

  /// `TicketValidation::getCreateRights()` for tickets;
  /// `CommonITILValidation`'s plain CREATE for changes.
  bool canRequestApproval(String itemtype) => switch (itemtype) {
    'Ticket' => hasAny(Rn.ticketValidation, [
      R.createRequest,
      R.createIncident,
    ]),
    'Change' => has(Rn.changeValidation, R.create),
    _ => false,
  };

  /// `getValidateRights()` — answering, not requesting.
  bool canAnswerApproval(String itemtype) => switch (itemtype) {
    'Ticket' => hasAny(Rn.ticketValidation, [
      R.validateRequest,
      R.validateIncident,
    ]),
    'Change' => has(Rn.changeValidation, R.validate),
    _ => false,
  };

  /// Attaching a photo or file to a ticket writes a Document.
  bool get canAddDocument => has(Rn.document, R.create);

  // --- Modules -----------------------------------------------------------

  /// `Planning`'s own right, which is read-only for most technicians.
  bool get canViewPlanning =>
      hasAny(Rn.planning, [R.readMy, R.planningReadGroup, R.planningReadAll]);

  /// Moving a calendar entry, or ticking it done, writes to whatever object
  /// it belongs to — and each of those has its own right. A technician with
  /// read-only planning sees the calendar and changes nothing in it.
  bool canEditPlanningEvent(String eventItemtype) => switch (eventItemtype) {
    'TicketTask' || 'ChangeTask' || 'ProblemTask' => canUpdateTask,
    'ProjectTask' => canUpdateProjectTask,
    'Reminder' => hasAny(Rn.reminder, [R.update, R.personal]),
    'PlanningExternalEvent' => has(Rn.externalEvent, R.update),
    _ => false,
  };

  /// Planning entries the app can create are PlanningExternalEvents.
  bool get canCreatePlanningEvent => has(Rn.externalEvent, R.create);

  /// `ProjectTask::canView()` — a project task reader needs no project right.
  bool get canViewProjects =>
      hasAny(Rn.project, [R.readAll, R.readMy]) ||
      has(Rn.projectTask, R.readMy);

  bool get canUpdateProjects => has(Rn.project, R.update);

  bool get canCreateProjectTask => has(Rn.projectTask, R.create);

  bool get canUpdateProjectTask =>
      hasAny(Rn.projectTask, [R.update, R.projectTaskUpdateMy]);

  /// `KnowbaseItem::canView()` — READ is the full base, READFAQ the public
  /// subset a self-service profile gets.
  bool get canViewKb => hasAny(Rn.knowbase, [R.read, R.readFaq]);

  bool get canCommentKb => has(Rn.knowbase, R.comments);

  /// `Reminder::canView()` / `RSSFeed::canView()`: PERSONAL alone is enough,
  /// since your own are always yours.
  bool get canViewReminders => hasAny(Rn.reminder, [R.read, R.personal]);

  bool get canCreateReminder => hasAny(Rn.reminder, [R.create, R.personal]);

  bool get canViewRss => hasAny(Rn.rssfeed, [R.read, R.personal]);

  bool get canCreateRss => hasAny(Rn.rssfeed, [R.create, R.personal]);

  /// `Reservation::canView()` — RESERVEANITEM sees only your own bookings,
  /// which is still a reason to open the module.
  bool get canViewReservations =>
      hasAny(Rn.reservation, [R.read, R.reserveAnItem]);

  bool get canBookReservations =>
      hasAny(Rn.reservation, [R.create, R.reserveAnItem]);

  /// `Reservation::canDelete()` — cancelling asks for RESERVEANITEM alone,
  /// not DELETE.
  bool get canCancelReservations => has(Rn.reservation, R.reserveAnItem);

  // --- Assets and Management hubs ----------------------------------------

  /// Whether [itemtype] may be listed: its rightname carries READ.
  ///
  /// Unknown itemtypes (a custom asset class, or one a newer GLPI adds) fall
  /// back to GLPI's own conventions — `asset_<system name>` for custom
  /// assets, else the lowercased class name — and are hidden when neither key
  /// is present, exactly as `Session::haveRight` would deny them.
  bool canReadItemtype(String itemtype) =>
      has(_rightnameOf(itemtype), R.read) ||
      has('asset_${itemtype.toLowerCase()}', R.read);

  bool canUpdateItemtype(String itemtype) =>
      has(_rightnameOf(itemtype), R.update) ||
      has('asset_${itemtype.toLowerCase()}', R.update);

  bool canCreateItemtype(String itemtype) =>
      has(_rightnameOf(itemtype), R.create) ||
      has('asset_${itemtype.toLowerCase()}', R.create);

  /// True when at least one itemtype of a hub is readable, so the drawer can
  /// drop a hub that would only ever open empty.
  bool canViewAnyOf(List<String> itemtypes) => itemtypes.any(canReadItemtype);

  static String _rightnameOf(String itemtype) =>
      _rightnameOverrides[itemtype] ?? itemtype.toLowerCase();

  // --- Parsing -----------------------------------------------------------

  /// Read the map out of a `GET /session` body.
  ///
  /// Non-integer values (GLPI serialises a few profile columns as strings or
  /// JSON blobs — `ticket_status`, `comment`) are dropped rather than coerced:
  /// they are profile *settings*, not rights, and nothing here asks for them.
  factory Rights.fromSessionJson(Object? json) {
    if (json is! Map) return empty;
    final profile = json['active_profile'];
    if (profile is! Map) return empty;
    final raw = profile['rights'];
    if (raw is! Map) return empty;
    final values = <String, int>{};
    raw.forEach((key, value) {
      final bits = switch (value) {
        final int v => v,
        final num v => v.toInt(),
        _ => null,
      };
      if (bits != null && bits != 0) values['$key'] = bits;
    });
    return Rights(
      values,
      interface: switch (profile['interface']) {
        final String v => v,
        _ => '',
      },
    );
  }

  /// The cached shape, which is also what [Rights.fromJson] reads back.
  Map<String, Object?> toJson() => {'interface': interface, 'rights': _values};

  factory Rights.fromJson(Object? json) {
    if (json is! Map) return empty;
    final raw = json['rights'];
    if (raw is! Map) return empty;
    return Rights(
      {
        for (final e in raw.entries)
          if (e.value is num) '${e.key}': (e.value as num).toInt(),
      },
      interface: switch (json['interface']) {
        final String v => v,
        _ => '',
      },
    );
  }
}

/// The itemtypes GLPI 11 offers under each hub, as `/Assets` and `/Management`
/// return them.
///
/// The hubs themselves are driven by the server's list; this fixed copy only
/// answers "is this hub worth a drawer row at all", which the drawer must
/// decide before any list has loaded. A server that adds an itemtype the app
/// has never heard of still shows it in the hub — it just doesn't, on its own,
/// bring back a hub the profile has no rights in.
abstract final class HubTypes {
  static const assets = [
    'Computer',
    'Monitor',
    'NetworkEquipment',
    'Peripheral',
    'Phone',
    'Printer',
    'SoftwareLicense',
    'Certificate',
    'Unmanaged',
    'Appliance',
  ];

  static const management = [
    'Budget',
    'Cluster',
    'Contact',
    'Contract',
    'Database',
    'DatabaseInstance',
    'Datacenter',
    'Document',
    'Domain',
    'SoftwareLicense',
    'Line',
    'Supplier',
  ];
}
