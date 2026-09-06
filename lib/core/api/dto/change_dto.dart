/// DTOs for the glpi-change plugin (`/GlpiChange/*`): the combined
/// change/release/freeze calendar feed, one change's scheduling picture
/// (window + live warnings + crossed freezes), and the freezes in force.
/// All timestamps are GLPI server wall-clock SQL strings, parsed with the
/// app's zone-stripping rule.
library;

import '../../utils/formatting.dart';

int _intOf(Object? v) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

/// One calendar event (`GET /GlpiChange/calendar?from=&to=`). The `state` /
/// `severity` vocabulary differs per kind, exactly as the web calendar's
/// cells carry it: a change has a numeric GLPI status, a release a state
/// string, a freeze a severity string.
class ChangeCalendarEventDto {
  const ChangeCalendarEventDto({
    required this.type,
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.changeStatus,
    required this.releaseState,
    required this.severity,
  });

  static const kindChange = 'change';
  static const kindRelease = 'release';
  static const kindFreeze = 'freeze';

  final String type;
  final int id;
  final String title;
  final DateTime? start;
  final DateTime? end;

  /// GLPI Change status id — only for [kindChange].
  final int? changeStatus;

  /// Release state string ("scheduled", …) — only for [kindRelease].
  final String? releaseState;

  /// Freeze severity string ("policy", …) — only for [kindFreeze].
  final String? severity;

  factory ChangeCalendarEventDto.fromJson(Map<String, Object?> json) {
    final type = '${json['type'] ?? ''}';
    final state = json['state'];
    return ChangeCalendarEventDto(
      type: type,
      id: _intOf(json['id']),
      title: '${json['title'] ?? json['name'] ?? ''}',
      start: parseGlpiDateTime(json['start'] as String?),
      end: parseGlpiDateTime(json['end'] as String?),
      changeStatus: type == kindChange && state != null ? _intOf(state) : null,
      releaseState: type == kindRelease && state != null ? '$state' : null,
      severity: type == kindFreeze ? json['severity'] as String? : null,
    );
  }
}

/// A change freeze (calendar row shape shared by `/freezes/active` and the
/// schedule payload's `freezes`).
class FreezeDto {
  const FreezeDto({
    required this.id,
    required this.title,
    required this.begin,
    required this.end,
    required this.severity,
    required this.reason,
  });

  final int id;
  final String title;
  final DateTime? begin;
  final DateTime? end;
  final String severity;
  final String reason;

  /// Whether [when] falls inside this freeze (inclusive bounds — a task
  /// planned exactly at the boundary is still inside the freeze).
  bool contains(DateTime when) {
    final b = begin;
    final e = end;
    if (b == null || e == null) return false;
    return !when.isBefore(b) && !when.isAfter(e);
  }

  /// Whether the [from]–[to] range overlaps this freeze at all.
  bool overlaps(DateTime from, DateTime to) {
    final b = begin;
    final e = end;
    if (b == null || e == null) return false;
    return !from.isAfter(e) && !to.isBefore(b);
  }

  factory FreezeDto.fromJson(Map<String, Object?> json) => FreezeDto(
    id: _intOf(json['id']),
    title: '${json['title'] ?? json['name'] ?? ''}',
    begin: parseGlpiDateTime(json['begin'] as String?),
    end: parseGlpiDateTime(json['end'] as String?),
    severity: '${json['severity'] ?? ''}',
    reason: '${json['reason'] ?? ''}',
  );
}

/// One live scheduling warning against a change window.
class ChangeCollisionDto {
  const ChangeCollisionDto({
    required this.id,
    required this.kind,
    required this.otherItemtype,
    required this.otherItemsId,
    required this.otherName,
    required this.isDismissed,
    required this.dismissReason,
  });

  final int id;

  /// `freeze` | `shared_ci` | … — the warning's vocabulary.
  final String kind;
  final String otherItemtype;
  final int otherItemsId;

  /// The other item's human name, when the `detail` blob carries one —
  /// far better on screen than an itemtype class + id.
  final String? otherName;
  final bool isDismissed;
  final String dismissReason;

  factory ChangeCollisionDto.fromJson(Map<String, Object?> json) =>
      ChangeCollisionDto(
        id: _intOf(json['id']),
        kind: '${json['kind'] ?? ''}',
        otherItemtype: '${json['other_itemtype'] ?? ''}',
        otherItemsId: _intOf(json['other_items_id']),
        otherName: switch (json['detail']) {
          {'name': final String name} when name.isNotEmpty => name,
          _ => null,
        },
        isDismissed: json['is_dismissed'] == true || json['is_dismissed'] == 1,
        dismissReason: '${json['dismiss_reason'] ?? ''}',
      );
}

/// `GET /GlpiChange/changes/{id}/schedule`: the window (with the source that
/// derived it), the standing warnings, and the freezes the window crosses.
class ChangeScheduleDto {
  const ChangeScheduleDto({
    required this.windowBegin,
    required this.windowEnd,
    required this.windowSource,
    required this.windowSourceLabel,
    required this.collisions,
    required this.freezes,
  });

  final DateTime? windowBegin;
  final DateTime? windowEnd;
  final String windowSource;
  final String windowSourceLabel;
  final List<ChangeCollisionDto> collisions;
  final List<FreezeDto> freezes;

  bool get hasWindow => windowBegin != null && windowEnd != null;

  factory ChangeScheduleDto.fromJson(Map<String, Object?> json) {
    final window = json['window'];
    final w = window is Map ? window : const {};
    final collisions = json['collisions'];
    final freezes = json['freezes'];
    return ChangeScheduleDto(
      windowBegin: parseGlpiDateTime(w['begin'] as String?),
      windowEnd: parseGlpiDateTime(w['end'] as String?),
      windowSource: '${w['source'] ?? ''}',
      windowSourceLabel: '${w['source_label'] ?? w['source'] ?? ''}',
      collisions: collisions is List
          ? collisions
                .whereType<Map<String, Object?>>()
                .map(ChangeCollisionDto.fromJson)
                .toList()
          : const [],
      freezes: freezes is List
          ? freezes
                .whereType<Map<String, Object?>>()
                .map(FreezeDto.fromJson)
                .toList()
          : const [],
    );
  }
}
