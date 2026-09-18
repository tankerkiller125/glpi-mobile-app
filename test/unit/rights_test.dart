import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/models/rights.dart';
import 'package:glpi_mobile/core/models/session_info.dart';

/// Real `GET /session` bodies, captured from GLPI 11.0.8's stock profiles
/// (Super-Admin, Technician, Observer, Self-Service) and trimmed to identity +
/// `active_profile`. The bitmasks are GLPI's own, so these tests fail if the
/// app's reading of them ever drifts from the server's.
Rights _rightsOf(String fixture) => SessionInfo.fromJson(
  jsonDecode(File('test/fixtures/$fixture').readAsStringSync())
      as Map<String, Object?>,
).rights;

void main() {
  late Rights admin;
  late Rights tech;
  late Rights observer;
  late Rights selfService;

  setUp(() {
    admin = _rightsOf('session.json');
    tech = _rightsOf('session_technician.json');
    observer = _rightsOf('session_observer.json');
    selfService = _rightsOf('session_selfservice.json');
  });

  group('parsing', () {
    test('reads the active profile\'s bitmasks and interface', () {
      expect(tech.interface, 'central');
      expect(tech.isHelpdesk, isFalse);
      expect(selfService.interface, 'helpdesk');
      expect(selfService.isHelpdesk, isTrue);
      expect(tech.valueOf('ticket'), 429063);
    });

    test(
      'a missing key is no right, exactly as Session::haveRight reads it',
      () {
        // A Self-Service profile ships 26 keys where a central one ships 160;
        // everything absent is denied rather than inherited.
        expect(selfService.valueOf('project'), 0);
        expect(selfService.has('project', R.read), isFalse);
        expect(selfService.canViewProjects, isFalse);
      },
    );

    test('a malformed or absent map denies everything', () {
      expect(Rights.fromSessionJson(null).isEmpty, isTrue);
      expect(Rights.fromSessionJson(const {}).isEmpty, isTrue);
      expect(
        Rights.fromSessionJson(const {'active_profile': 'nope'}).isEmpty,
        isTrue,
      );
      expect(Rights.empty.canViewTickets, isFalse);
      expect(Rights.empty.canViewAnyOf(HubTypes.assets), isFalse);
    });

    test('non-numeric profile columns are dropped, not coerced', () {
      // `ticket_status` is a JSON blob and `comment` a string; neither is a
      // right, and neither may end up as one.
      final rights = Rights.fromSessionJson(const {
        'active_profile': {
          'interface': 'central',
          'rights': {'ticket': 1, 'ticket_status': '{"1":{"2":true}}'},
        },
      });
      expect(rights.valueOf('ticket'), 1);
      expect(rights.valueOf('ticket_status'), 0);
    });

    test('round-trips through the cached shape', () {
      final cached = Rights.fromJson(jsonDecode(jsonEncode(tech.toJson())));
      expect(cached.interface, tech.interface);
      expect(cached.valueOf('ticket'), tech.valueOf('ticket'));
      expect(cached.canViewProjects, isTrue);
    });
  });

  group('assistance', () {
    test('every stock profile can see tickets, including self-service', () {
      // Self-Service holds READMY | CREATE (5) — their own tickets.
      expect(selfService.valueOf('ticket'), 5);
      for (final r in [admin, tech, observer, selfService]) {
        expect(r.canViewTickets, isTrue);
      }
    });

    test('changes and problems are central-only', () {
      expect(tech.canViewChanges, isTrue);
      expect(tech.canViewProblems, isTrue);
      expect(observer.canViewChanges, isTrue);
      expect(selfService.canViewChanges, isFalse);
      expect(selfService.canViewProblems, isFalse);
      expect(selfService.canViewItil('Change'), isFalse);
    });

    test('an approver can see tickets on the validation right alone', () {
      final approver = Rights.fromSessionJson(const {
        'active_profile': {
          'interface': 'central',
          // No ticket right at all, but may answer requests (4096).
          'rights': {'ticketvalidation': 4096},
        },
      });
      expect(approver.canViewTickets, isTrue);
      expect(approver.canAnswerApproval('Ticket'), isTrue);
      expect(approver.canRequestApproval('Ticket'), isFalse);
    });

    test('writing is separate from reading', () {
      // Observer holds followup 5 (SEEPUBLIC | ADDMY) and task 1 (SEEPUBLIC):
      // it may reply on its own tickets and add no tasks at all.
      expect(observer.canAddFollowup, isTrue);
      expect(observer.canAddTask, isFalse);
      expect(observer.canUpdateItil('Ticket'), isFalse);
      expect(observer.canAssignItil('Ticket'), isFalse);
      expect(tech.canAddFollowup, isTrue);
      expect(tech.canAddTask, isTrue);
      // Self-Service may reply to its own ticket but never take one.
      expect(selfService.canAddFollowup, isTrue);
      expect(
        selfService.canTakeItil('Ticket', alreadyAssigned: false),
        isFalse,
      );
    });

    test('taking a ticket is OWN/STEAL, not the assign right', () {
      // GLPI's stock Technician holds ticket 429063 = READALL | READMY |
      // READGROUP | READNEWTICKET | SURVEY | OWN | CREATE | UPDATE — OWN but
      // neither ASSIGN nor STEAL. So it can take an unassigned ticket, cannot
      // steal an assigned one, and cannot edit the assignee field.
      expect(tech.canTakeItil('Ticket', alreadyAssigned: false), isTrue);
      expect(tech.canTakeItil('Ticket', alreadyAssigned: true), isFalse);
      expect(tech.canAssignItil('Ticket'), isFalse);
      // Self-Service has neither, so it never takes anything.
      expect(
        selfService.canTakeItil('Ticket', alreadyAssigned: false),
        isFalse,
      );
      final steal = Rights.fromSessionJson(const {
        'active_profile': {
          'interface': 'central',
          'rights': {'ticket': 16384},
        },
      });
      expect(steal.canTakeItil('Ticket', alreadyAssigned: true), isTrue);
    });

    test('changes have no assign bit — their actors ride on UPDATE', () {
      expect(tech.canUpdateItil('Change'), isTrue);
      expect(tech.canAssignItil('Change'), isTrue);
      expect(observer.canAssignItil('Change'), isFalse);
    });

    test('approvals: ticket and change rights are spelled differently', () {
      // TicketValidation has its own create/validate bits; ChangeValidation
      // uses plain CREATE and CommonITILValidation::VALIDATE.
      // Technician: ticketvalidation 3088 = CREATEREQUEST | CREATEINCIDENT
      // (+ PURGE) — it may ask, not answer. Observer holds the two VALIDATE
      // bits as well, so it answers.
      expect(tech.canRequestApproval('Ticket'), isTrue);
      expect(tech.canAnswerApproval('Ticket'), isFalse);
      expect(observer.canAnswerApproval('Ticket'), isTrue);
      // ChangeValidation: changevalidation 20 = CREATE | PURGE, no VALIDATE.
      expect(tech.canRequestApproval('Change'), isTrue);
      expect(tech.canAnswerApproval('Change'), isFalse);
      expect(observer.canAnswerApproval('Change'), isTrue);
      // Problems have no validation object at all.
      expect(tech.canRequestApproval('Problem'), isFalse);
    });
  });

  group('modules', () {
    test('planning is readable but not writable for a technician', () {
      expect(tech.canViewPlanning, isTrue);
      expect(tech.canCreatePlanningEvent, isFalse);
      expect(admin.canCreatePlanningEvent, isTrue);
      expect(selfService.canViewPlanning, isFalse);
    });

    test('a planning entry follows the right of what it belongs to', () {
      expect(tech.canEditPlanningEvent('TicketTask'), isTrue);
      expect(tech.canEditPlanningEvent('PlanningExternalEvent'), isFalse);
      expect(observer.canEditPlanningEvent('TicketTask'), isFalse);
      expect(admin.canEditPlanningEvent('ProjectTask'), isTrue);
      expect(tech.canEditPlanningEvent('Whatever'), isFalse);
    });

    test('projects open on either the project or the task right', () {
      expect(tech.canViewProjects, isTrue);
      // projecttask 1025 = READMY | UPDATEMY: it may edit its own tasks and
      // add none.
      expect(tech.canUpdateProjectTask, isTrue);
      expect(tech.canCreateProjectTask, isFalse);
      final taskOnly = Rights.fromSessionJson(const {
        'active_profile': {
          'interface': 'central',
          'rights': {'projecttask': 1},
        },
      });
      expect(taskOnly.canViewProjects, isTrue);
    });

    test('the knowledge base opens on READ or on the FAQ subset', () {
      expect(tech.canViewKb, isTrue);
      expect(tech.canCommentKb, isTrue);
      // Self-Service gets READFAQ (2048) only: the public FAQ, no comments.
      expect(selfService.valueOf('knowbase'), 2048);
      expect(selfService.canViewKb, isTrue);
      expect(selfService.canCommentKb, isFalse);
    });

    test('reminders and feeds open on the personal right alone', () {
      final personalOnly = Rights.fromSessionJson(const {
        'active_profile': {
          'interface': 'central',
          'rights': {'reminder_public': 128, 'rssfeed_public': 128},
        },
      });
      expect(personalOnly.canViewReminders, isTrue);
      expect(personalOnly.canCreateReminder, isTrue);
      expect(personalOnly.canViewRss, isTrue);
      expect(selfService.canViewReminders, isTrue);
      expect(selfService.canCreateReminder, isFalse);
    });

    test('reservations: booking and cancelling are RESERVEANITEM', () {
      expect(tech.canViewReservations, isTrue);
      expect(tech.canBookReservations, isTrue);
      expect(tech.canCancelReservations, isTrue);
      final readOnly = Rights.fromSessionJson(const {
        'active_profile': {
          'interface': 'central',
          'rights': {'reservation': 1},
        },
      });
      expect(readOnly.canViewReservations, isTrue);
      expect(readOnly.canBookReservations, isFalse);
      expect(readOnly.canCancelReservations, isFalse);
      // Self-Service holds RESERVEANITEM (1024) without READ.
      expect(selfService.valueOf('reservation'), 1024);
      expect(selfService.canViewReservations, isTrue);
      expect(selfService.canBookReservations, isTrue);
      // Observer holds READ | RESERVEANITEM, so it books too.
      expect(observer.canViewReservations, isTrue);
      expect(observer.canBookReservations, isTrue);
    });
  });

  group('hubs', () {
    test('an itemtype maps to the rightname GLPI gives its class', () {
      // NetworkEquipment is `networking`, a Supplier is `contact_enterprise`.
      expect(tech.canReadItemtype('NetworkEquipment'), isTrue);
      expect(observer.canReadItemtype('Supplier'), isTrue);
      expect(observer.canReadItemtype('Contact'), isTrue);
      expect(tech.canReadItemtype('Computer'), isTrue);
    });

    test('a right without READ is not a right to list', () {
      // The technician's `contract` is 96: READNOTE | UPDATENOTE, no READ —
      // and GLPI answers /Management/Contract with a 403 for exactly that.
      expect(tech.valueOf('contract'), 96);
      expect(tech.canReadItemtype('Contract'), isFalse);
      expect(tech.valueOf('domain'), 0);
      expect(tech.canReadItemtype('Domain'), isFalse);
      expect(observer.canReadItemtype('Contract'), isTrue);
    });

    test('hubs disappear when nothing in them is readable', () {
      expect(tech.canViewAnyOf(HubTypes.assets), isTrue);
      expect(tech.canViewAnyOf(HubTypes.management), isTrue);
      expect(selfService.canViewAnyOf(HubTypes.assets), isFalse);
      expect(selfService.canViewAnyOf(HubTypes.management), isFalse);
    });

    test('a custom asset falls back to GLPI\'s asset_<system name> key', () {
      final custom = Rights.fromSessionJson(const {
        'active_profile': {
          'interface': 'central',
          'rights': {'asset_rackunit': 3},
        },
      });
      expect(custom.canReadItemtype('RackUnit'), isTrue);
      expect(custom.canUpdateItemtype('RackUnit'), isTrue);
      expect(custom.canCreateItemtype('RackUnit'), isFalse);
      // An itemtype with neither key stays hidden rather than guessed at.
      expect(custom.canReadItemtype('SomethingElse'), isFalse);
    });

    test('editing an asset is UPDATE, listing it is READ', () {
      expect(observer.canReadItemtype('Computer'), isTrue);
      expect(observer.canUpdateItemtype('Computer'), isFalse);
      expect(tech.canUpdateItemtype('Computer'), isTrue);
    });
  });
}
