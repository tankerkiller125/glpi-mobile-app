import '../api/itil_type.dart';

/// Parse a GLPI timestamp as **server wall-clock**, not an absolute instant.
///
/// GLPI's high-level API serializes datetimes that are stored in the server's
/// own timezone with a `+00:00` suffix, so `DateTime.parse().toLocal()` shifts
/// them by the device's offset — a task planned for 09:00 would show as 05:00.
/// GLPI's web UI shows server-local times, so we strip any zone designator and
/// keep the wall-clock reading. (The plugin's planning feed already returns
/// naive strings; this makes every other source agree with it.)
DateTime? parseGlpiDateTime(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  var s = raw.trim();
  // Drop a trailing 'Z' or '+HH:MM' / '-HH:MM' offset.
  s = s.replaceFirst(RegExp(r'(Z|[+-]\d{2}:?\d{2})$'), '');
  return DateTime.tryParse(s.replaceFirst('T', ' '));
}

/// Compact relative age like `4h`, `3d`, `2w` from a past timestamp.
String relativeAge(DateTime? when, {DateTime? now}) {
  if (when == null) return '';
  final ref = now ?? DateTime.now();
  var diff = ref.difference(when);
  if (diff.isNegative) diff = Duration.zero;
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  if (diff.inDays < 30) return '${diff.inDays ~/ 7}w';
  if (diff.inDays < 365) return '${diff.inDays ~/ 30}mo';
  return '${diff.inDays ~/ 365}y';
}

/// Compact "time until" / "overdue" label for a due date (e.g. an SLA target):
/// `in 2d`, `in 3h 20m`, `due now`, `overdue 5h`, `overdue 2d`.
String formatDueRelative(DateTime? due, {DateTime? now}) {
  if (due == null) return '';
  final ref = now ?? DateTime.now();
  final diff = due.difference(ref);
  final overdue = diff.isNegative;
  final d = diff.abs();
  final String mag;
  if (d.inMinutes < 1) {
    return 'due now';
  } else if (d.inMinutes < 60) {
    mag = '${d.inMinutes}m';
  } else if (d.inHours < 24) {
    final m = d.inMinutes % 60;
    mag = m > 0 ? '${d.inHours}h ${m}m' : '${d.inHours}h';
  } else {
    mag = '${d.inDays}d';
  }
  return overdue ? 'overdue $mag' : 'in $mag';
}

/// Seconds → compact duration like `6h`, `1h 30m`, `45m`.
String formatDuration(int? seconds) {
  if (seconds == null || seconds <= 0) return '';
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  if (h > 0 && m > 0) return '${h}h ${m}m';
  if (h > 0) return '${h}h';
  return '${m}m';
}

/// GLPI status id → short label. Ids differ per ITIL type (Changes add
/// evaluation/testing/…, Problems use different wording), so the type decides.
String statusLabel(int status, {String itemtype = itilTicket}) =>
    itilStatuses(itemtype)[status] ?? 'Status $status';

/// GLPI priority id → label. 1 Very low … 6 Major.
String priorityLabel(int priority) => switch (priority) {
  1 => 'Very low',
  2 => 'Low',
  3 => 'Medium',
  4 => 'High',
  5 => 'Very high',
  6 => 'Major',
  _ => 'Priority $priority',
};

/// GLPI urgency/impact id → label (same 1–5 scale).
String urgencyLabel(int urgency) => switch (urgency) {
  1 => 'Very low',
  2 => 'Low',
  3 => 'Medium',
  4 => 'High',
  5 => 'Very high',
  _ => 'Level $urgency',
};

/// GLPI ticket type: 1 Incident, 2 Request.
String typeLabel(int type) => switch (type) {
  1 => 'Incident',
  2 => 'Request',
  _ => 'Type $type',
};

/// Absolute date without the time — for purchase/warranty/expiry rows, where
/// the hour is noise.
String formatDate(DateTime? when) {
  if (when == null) return '';
  return formatDateTime(when).split(',').first;
}

/// Absolute date like `3 Aug 2026, 14:05` from an ISO timestamp.
String formatDateTime(DateTime? when) {
  if (when == null) return '';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final l = when.toLocal();
  final hh = l.hour.toString().padLeft(2, '0');
  final mm = l.minute.toString().padLeft(2, '0');
  return '${l.day} ${months[l.month - 1]} ${l.year}, $hh:$mm';
}
