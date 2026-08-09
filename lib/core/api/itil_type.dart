/// The three GLPI ITIL object types the app works with. GLPI models them as
/// siblings of `CommonITILObject`, and its high-level API is already generic
/// (`/Assistance/{itemtype}/…`), so one code path serves all three.
library;

const String itilTicket = 'Ticket';
const String itilChange = 'Change';
const String itilProblem = 'Problem';

const List<String> itilTypes = [itilTicket, itilChange, itilProblem];

/// Singular display name.
String itilLabel(String itemtype) => switch (itemtype) {
  itilChange => 'Change',
  itilProblem => 'Problem',
  _ => 'Ticket',
};

/// Plural display name (module titles, empty states).
String itilLabelPlural(String itemtype) => switch (itemtype) {
  itilChange => 'Changes',
  itilProblem => 'Problems',
  _ => 'Tickets',
};

/// GLPI's status ids differ per type — Changes add evaluation/testing/etc.,
/// Problems drop the ticket-only "Assigned" wording. Sourced from
/// `Change::getAllStatusArray()` / `Problem::getAllStatusArray()`.
Map<int, String> itilStatuses(String itemtype) => switch (itemtype) {
  itilChange => const {
    1: 'New',
    9: 'Evaluation',
    10: 'Approval',
    7: 'Accepted',
    4: 'Pending',
    11: 'Testing',
    12: 'Qualification',
    5: 'Applied',
    8: 'Review',
    6: 'Closed',
    14: 'Cancelled',
    13: 'Refused',
  },
  itilProblem => const {
    1: 'New',
    7: 'Accepted',
    2: 'Processing (assigned)',
    3: 'Processing (planned)',
    4: 'Pending',
    5: 'Solved',
    8: 'Under observation',
    6: 'Closed',
  },
  _ => const {
    1: 'New',
    2: 'Assigned',
    3: 'Planned',
    4: 'Pending',
    5: 'Solved',
    6: 'Closed',
  },
};

/// Status ids that count as "still being worked" for a type — the working
/// queue, and the window where SLA countdowns matter.
List<int> itilOpenStatuses(String itemtype) => switch (itemtype) {
  itilChange => const [1, 9, 10, 7, 4, 11, 12, 8],
  itilProblem => const [1, 7, 2, 3, 4, 8],
  _ => const [1, 2, 3, 4],
};

/// Only Tickets and Changes support approvals (validations) in GLPI.
bool itilSupportsValidation(String itemtype) => itemtype != itilProblem;

/// Only Tickets carry the incident/request type field.
bool itilHasRequestType(String itemtype) => itemtype == itilTicket;

/// How two ITIL objects are linked. Values match GLPI's
/// `CommonITILObject_CommonITILObject` constants.
class ItilLinkType {
  static const int linkTo = 1;
  static const int duplicateOf = 2;
  static const int childOf = 3;
  static const int parentOf = 4;

  static String label(int value) => switch (value) {
    duplicateOf => 'Duplicate of',
    childOf => 'Child of',
    parentOf => 'Parent of',
    _ => 'Linked to',
  };

  /// GLPI only allows the parent/child/duplicate nuances between two objects of
  /// the same type; cross-type links are always a plain association.
  static const List<int> all = [linkTo, duplicateOf, childOf, parentOf];
}
