import 'package:flutter/material.dart';

import '../theme/glpi_colors.dart';

/// GLPI planning states (`Planning::INFO/TODO/DONE`).
class PlanningState {
  static const int information = 0;
  static const int todo = 1;
  static const int done = 2;

  static String label(int v) => switch (v) {
    todo => 'To do',
    done => 'Done',
    _ => 'Information',
  };
}

/// A calendar entry as the UI renders it.
class PlanningEvent {
  const PlanningEvent({
    required this.localId,
    required this.eventItemtype,
    required this.eventServerId,
    required this.parentItemtype,
    required this.parentServerId,
    required this.parentName,
    required this.title,
    required this.begin,
    required this.end,
    required this.isAllDay,
    required this.state,
    required this.pending,
  });

  final String localId;
  final String eventItemtype;
  final int? eventServerId;
  final String? parentItemtype;
  final int? parentServerId;
  final String parentName;
  final String title;
  final DateTime begin;
  final DateTime end;
  final bool isAllDay;
  final int state;

  /// Still queued in the outbox (rendered dimmed with a "syncing…" hint).
  final bool pending;

  bool get isTask => eventItemtype.endsWith('Task');
  bool get isDone => state == PlanningState.done;

  /// Tasks are the only events with a meaningful done-toggle.
  bool get canToggleDone => isTask && eventServerId != null;

  /// "Ticket #7 · Email outage", or empty for standalone events.
  String get parentLabel {
    if (parentItemtype == null || parentServerId == null) return '';
    final name = parentName.isEmpty ? '' : ' · $parentName';
    return '$parentItemtype #$parentServerId$name';
  }

  String get typeLabel => switch (eventItemtype) {
    'TicketTask' => 'Ticket task',
    'ChangeTask' => 'Change task',
    'ProblemTask' => 'Problem task',
    'ProjectTask' => 'Project task',
    'Reminder' => 'Reminder',
    'PlanningExternalEvent' => 'Event',
    _ => eventItemtype,
  };

  IconData get icon => switch (eventItemtype) {
    'TicketTask' => Icons.confirmation_number_outlined,
    'ChangeTask' => Icons.published_with_changes,
    'ProblemTask' => Icons.troubleshoot,
    'ProjectTask' => Icons.account_tree_outlined,
    'Reminder' => Icons.sticky_note_2_outlined,
    _ => Icons.event_outlined,
  };

  Color color(GlpiColors c) => switch (eventItemtype) {
    'TicketTask' => c.planningTicket,
    'ChangeTask' => c.planningChange,
    'ProblemTask' => c.planningProblem,
    'ProjectTask' => c.planningProject,
    'Reminder' => c.planningReminder,
    _ => c.planningEvent,
  };
}
