import 'planning_event.dart';

/// A reminder (Tools › Reminders): a note with an optional planning window.
class Reminder {
  const Reminder({
    required this.localId,
    required this.serverId,
    required this.name,
    required this.content,
    required this.beginViewDate,
    required this.endViewDate,
    required this.isPlanned,
    required this.begin,
    required this.end,
    required this.state,
    required this.isMine,
    required this.pending,
  });

  final String localId;
  final int? serverId;
  final String name;
  final String content;

  /// Visibility window (independent of the planning window).
  final DateTime? beginViewDate;
  final DateTime? endViewDate;

  final bool isPlanned;
  final DateTime? begin;
  final DateTime? end;
  final int state;

  /// Reminders shared by other users render read-only.
  final bool isMine;
  final bool pending;

  bool get isEditable => isMine && serverId != null;
  String get stateLabel => PlanningState.label(state);
}
