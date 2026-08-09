import 'package:flutter/material.dart';

/// Semantic GLPI colors (ticket status, priority, SLA) as a ThemeExtension so
/// both light and dark themes carry hand-tuned variants. Deliberately NOT
/// derived from the seed color: status/priority meanings must stay stable.
@immutable
class GlpiColors extends ThemeExtension<GlpiColors> {
  const GlpiColors({
    required this.statusNew,
    required this.statusAssigned,
    required this.statusPlanned,
    required this.statusPending,
    required this.statusSolved,
    required this.statusClosed,
    required this.priorityVeryLow,
    required this.priorityLow,
    required this.priorityMedium,
    required this.priorityHigh,
    required this.priorityVeryHigh,
    required this.priorityMajor,
    required this.slaOk,
    required this.slaWarn,
    required this.slaBreach,
    required this.planningTicket,
    required this.planningChange,
    required this.planningProblem,
    required this.planningProject,
    required this.planningReminder,
    required this.planningEvent,
  });

  final Color statusNew;
  final Color statusAssigned;
  final Color statusPlanned;
  final Color statusPending;
  final Color statusSolved;
  final Color statusClosed;
  final Color priorityVeryLow;
  final Color priorityLow;
  final Color priorityMedium;
  final Color priorityHigh;
  final Color priorityVeryHigh;
  final Color priorityMajor;
  final Color slaOk;
  final Color slaWarn;
  final Color slaBreach;

  /// Calendar event colors, one per GLPI planning type.
  final Color planningTicket;
  final Color planningChange;
  final Color planningProblem;
  final Color planningProject;
  final Color planningReminder;
  final Color planningEvent;

  static const light = GlpiColors(
    statusNew: Color(0xFF43A047),
    statusAssigned: Color(0xFF1E88E5),
    statusPlanned: Color(0xFF8E24AA),
    statusPending: Color(0xFFFB8C00),
    statusSolved: Color(0xFF00897B),
    statusClosed: Color(0xFF757575),
    priorityVeryLow: Color(0xFF90A4AE),
    priorityLow: Color(0xFF66BB6A),
    priorityMedium: Color(0xFFFFB300),
    priorityHigh: Color(0xFFFB8C00),
    priorityVeryHigh: Color(0xFFE53935),
    priorityMajor: Color(0xFFB71C1C),
    slaOk: Color(0xFF43A047),
    slaWarn: Color(0xFFFFB300),
    slaBreach: Color(0xFFE53935),
    planningTicket: Color(0xFF1E88E5),
    planningChange: Color(0xFF8E24AA),
    planningProblem: Color(0xFF00897B),
    planningProject: Color(0xFFFB8C00),
    planningReminder: Color(0xFFFFB300),
    planningEvent: Color(0xFF43A047),
  );

  static const dark = GlpiColors(
    statusNew: Color(0xFF66BB6A),
    statusAssigned: Color(0xFF42A5F5),
    statusPlanned: Color(0xFFBA68C8),
    statusPending: Color(0xFFFFA726),
    statusSolved: Color(0xFF26A69A),
    statusClosed: Color(0xFF9E9E9E),
    priorityVeryLow: Color(0xFFB0BEC5),
    priorityLow: Color(0xFF81C784),
    priorityMedium: Color(0xFFFFCA28),
    priorityHigh: Color(0xFFFFA726),
    priorityVeryHigh: Color(0xFFEF5350),
    priorityMajor: Color(0xFFE57373),
    slaOk: Color(0xFF66BB6A),
    slaWarn: Color(0xFFFFCA28),
    slaBreach: Color(0xFFEF5350),
    planningTicket: Color(0xFF42A5F5),
    planningChange: Color(0xFFBA68C8),
    planningProblem: Color(0xFF26A69A),
    planningProject: Color(0xFFFFA726),
    planningReminder: Color(0xFFFFCA28),
    planningEvent: Color(0xFF66BB6A),
  );

  Color statusColor(int status) => switch (status) {
    1 => statusNew,
    2 => statusAssigned,
    3 => statusPlanned,
    4 => statusPending,
    5 => statusSolved,
    6 => statusClosed,
    _ => statusClosed,
  };

  /// SLA due-date color by time remaining: breach once past, warn inside the
  /// warning window (default 4h), otherwise ok.
  Color slaColor(
    Duration remaining, {
    Duration warn = const Duration(hours: 4),
  }) {
    if (remaining.isNegative) return slaBreach;
    if (remaining <= warn) return slaWarn;
    return slaOk;
  }

  Color priorityColor(int priority) => switch (priority) {
    1 => priorityVeryLow,
    2 => priorityLow,
    3 => priorityMedium,
    4 => priorityHigh,
    5 => priorityVeryHigh,
    6 => priorityMajor,
    _ => priorityMedium,
  };

  @override
  GlpiColors copyWith({
    Color? statusNew,
    Color? statusAssigned,
    Color? statusPlanned,
    Color? statusPending,
    Color? statusSolved,
    Color? statusClosed,
    Color? priorityVeryLow,
    Color? priorityLow,
    Color? priorityMedium,
    Color? priorityHigh,
    Color? priorityVeryHigh,
    Color? priorityMajor,
    Color? slaOk,
    Color? slaWarn,
    Color? slaBreach,
    Color? planningTicket,
    Color? planningChange,
    Color? planningProblem,
    Color? planningProject,
    Color? planningReminder,
    Color? planningEvent,
  }) {
    return GlpiColors(
      statusNew: statusNew ?? this.statusNew,
      statusAssigned: statusAssigned ?? this.statusAssigned,
      statusPlanned: statusPlanned ?? this.statusPlanned,
      statusPending: statusPending ?? this.statusPending,
      statusSolved: statusSolved ?? this.statusSolved,
      statusClosed: statusClosed ?? this.statusClosed,
      priorityVeryLow: priorityVeryLow ?? this.priorityVeryLow,
      priorityLow: priorityLow ?? this.priorityLow,
      priorityMedium: priorityMedium ?? this.priorityMedium,
      priorityHigh: priorityHigh ?? this.priorityHigh,
      priorityVeryHigh: priorityVeryHigh ?? this.priorityVeryHigh,
      priorityMajor: priorityMajor ?? this.priorityMajor,
      slaOk: slaOk ?? this.slaOk,
      slaWarn: slaWarn ?? this.slaWarn,
      slaBreach: slaBreach ?? this.slaBreach,
      planningTicket: planningTicket ?? this.planningTicket,
      planningChange: planningChange ?? this.planningChange,
      planningProblem: planningProblem ?? this.planningProblem,
      planningProject: planningProject ?? this.planningProject,
      planningReminder: planningReminder ?? this.planningReminder,
      planningEvent: planningEvent ?? this.planningEvent,
    );
  }

  @override
  GlpiColors lerp(GlpiColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return GlpiColors(
      statusNew: l(statusNew, other.statusNew),
      statusAssigned: l(statusAssigned, other.statusAssigned),
      statusPlanned: l(statusPlanned, other.statusPlanned),
      statusPending: l(statusPending, other.statusPending),
      statusSolved: l(statusSolved, other.statusSolved),
      statusClosed: l(statusClosed, other.statusClosed),
      priorityVeryLow: l(priorityVeryLow, other.priorityVeryLow),
      priorityLow: l(priorityLow, other.priorityLow),
      priorityMedium: l(priorityMedium, other.priorityMedium),
      priorityHigh: l(priorityHigh, other.priorityHigh),
      priorityVeryHigh: l(priorityVeryHigh, other.priorityVeryHigh),
      priorityMajor: l(priorityMajor, other.priorityMajor),
      slaOk: l(slaOk, other.slaOk),
      slaWarn: l(slaWarn, other.slaWarn),
      slaBreach: l(slaBreach, other.slaBreach),
      planningTicket: l(planningTicket, other.planningTicket),
      planningChange: l(planningChange, other.planningChange),
      planningProblem: l(planningProblem, other.planningProblem),
      planningProject: l(planningProject, other.planningProject),
      planningReminder: l(planningReminder, other.planningReminder),
      planningEvent: l(planningEvent, other.planningEvent),
    );
  }
}
