/// DTOs for the glpi-signal plugin (`/GlpiSignal/*`): monitoring alerts and
/// on-call rotas. Parsed tolerantly — related records may arrive nested
/// (`{"entity": {"id": 1, "name": "Acme"}}`) or flat (`entities_id` +
/// `entity_name`) depending on the plugin version.
library;

int? _idOf(Object? v) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  if (v is Map) return (v['id'] as num?)?.toInt();
  return null;
}

/// A server date as an SQL wall-clock string. Accepts what the wire sends:
/// an SQL string as-is, or unix seconds (the on-call route's handoff field),
/// converted to local time. Zero/empty means "none".
String? _dateOf(Object? v) {
  if (v is String) return v.isEmpty ? null : v;
  if (v is num) {
    if (v <= 0) return null;
    final t = DateTime.fromMillisecondsSinceEpoch(v.toInt() * 1000).toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} '
        '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }
  return null;
}

String? _nameOf(Object? v) {
  if (v is String && v.isNotEmpty) return v;
  if (v is Map) {
    final name = v['name'] ?? v['completename'] ?? v['display_name'];
    if (name is String && name.isNotEmpty) return name;
  }
  return null;
}

/// Alert severity, normalised from whatever the server sends (a name like
/// `"critical"` or a GLPI urgency-style number). Unknowns rank lowest rather
/// than throwing — a new severity must never break the list.
enum AlertSeverity {
  critical,
  high,
  medium,
  low,
  info;

  /// The wire name, used for the `severity=` filter parameter.
  String get wire => name;

  static AlertSeverity parse(Object? raw) {
    if (raw is num) {
      return switch (raw.toInt()) {
        >= 5 => critical,
        4 => high,
        3 => medium,
        2 => low,
        _ => info,
      };
    }
    return switch ('$raw'.toLowerCase()) {
      'critical' || 'crit' || 'disaster' => critical,
      'high' || 'major' || 'error' => high,
      'medium' || 'warning' || 'warn' || 'average' => medium,
      'low' || 'minor' => low,
      _ => info,
    };
  }
}

/// Dig the alert rows out of the list response. The plugin wraps them in
/// `{"alerts": [...], "start": n, "limit": n, "total": n}`; a bare array (or
/// a wrapper with a differently named rows key) is accepted too.
List<Map<String, Object?>> alertRowsFromJson(Object? json) {
  if (json is List) return json.whereType<Map<String, Object?>>().toList();
  if (json is Map) {
    Object? rows = json['alerts'];
    if (rows is! List) {
      for (final v in json.values) {
        if (v is List) {
          rows = v;
          break;
        }
      }
    }
    if (rows is List) return rows.whereType<Map<String, Object?>>().toList();
  }
  return const [];
}

/// An alert row (`GET /GlpiSignal/alerts`).
class AlertDto {
  const AlertDto({
    required this.id,
    required this.name,
    required this.severity,
    required this.state,
    required this.host,
    required this.itemtype,
    required this.itemsId,
    required this.ticketsId,
    required this.eventCount,
    required this.firstSeen,
    required this.lastSeen,
    required this.ackUserId,
    required this.ackUserName,
    required this.entityId,
    required this.entityName,
  });

  final int id;
  final String name;
  final AlertSeverity severity;

  /// `open` | `acked` | `ticketed` | `suppressed` | `closed`.
  final String state;
  final String host;
  final String itemtype;
  final int? itemsId;

  /// The bound GLPI ticket, if escalation created one.
  final int? ticketsId;
  final int eventCount;
  final String? firstSeen;
  final String? lastSeen;
  final int? ackUserId;
  final String? ackUserName;
  final int? entityId;
  final String? entityName;

  bool get isOpen => state == 'open';
  bool get isClosed => state == 'closed';

  /// Still a live concern — the server's AlertState::live(): everything but
  /// `closed`. A ticketed alert is live; a ticket is not an acknowledgement.
  bool get isLive => !isClosed;

  /// Live and unclaimed: the states where offering "acknowledge" makes sense
  /// (`open`, `ticketed`, `suppressed`).
  bool get needsAck => isLive && state != 'acked';

  factory AlertDto.fromJson(Map<String, Object?> json) => AlertDto(
    id: (json['id'] as num).toInt(),
    name: '${json['name'] ?? ''}',
    severity: AlertSeverity.parse(json['severity']),
    state: '${json['state'] ?? 'open'}',
    host: '${json['host'] ?? ''}',
    itemtype: '${json['itemtype'] ?? ''}',
    itemsId: _idOf(json['items_id'] ?? json['item']),
    ticketsId: switch (_idOf(json['tickets_id'] ?? json['ticket'])) {
      null || 0 => null,
      final id => id,
    },
    eventCount: (json['event_count'] as num?)?.toInt() ?? 1,
    firstSeen: json['first_seen'] as String?,
    lastSeen: json['last_seen'] as String?,
    ackUserId: switch (_idOf(json['users_id_ack'] ?? json['ack_user'])) {
      null || 0 => null,
      final id => id,
    },
    ackUserName: _nameOf(json['ack_user'] ?? json['ack_user_name']),
    entityId: _idOf(json['entity'] ?? json['entities_id']),
    entityName: _nameOf(json['entity'] ?? json['entity_name']),
  );
}

/// One page-log entry on an alert: who/what was paged and how it went.
class AlertPageDto {
  const AlertPageDto({
    required this.date,
    required this.target,
    required this.status,
    required this.message,
  });

  final String? date;
  final String target;
  final String status;
  final String message;

  factory AlertPageDto.fromJson(Map<String, Object?> json) => AlertPageDto(
    date: (json['date'] ?? json['created_at']) as String?,
    target: _nameOf(json['target'] ?? json['user'] ?? json['channel']) ?? '',
    status: '${json['status'] ?? ''}',
    message: '${json['message'] ?? json['detail'] ?? ''}',
  );
}

/// A full alert (`GET /GlpiSignal/alerts/{id}`): the row plus its page log.
class AlertDetailDto {
  const AlertDetailDto({required this.alert, required this.log});

  final AlertDto alert;
  final List<AlertPageDto> log;

  factory AlertDetailDto.fromJson(Map<String, Object?> json) {
    // The row may arrive at the top level or wrapped under `alert`.
    final row = json['alert'];
    final rawLog = json['log'] ?? json['pages'] ?? json['page_log'];
    return AlertDetailDto(
      alert: AlertDto.fromJson(
        row is Map<String, Object?> && row.containsKey('id') ? row : json,
      ),
      log: rawLog is List
          ? rawLog
                .whereType<Map<String, Object?>>()
                .map(AlertPageDto.fromJson)
                .toList()
          : const [],
    );
  }
}

/// Dig the rota rows out of the on-call response. The plugin wraps them in
/// `{"rotas": [...]}`; a bare array is accepted too.
List<Map<String, Object?>> oncallRowsFromJson(Object? json) {
  if (json is List) return json.whereType<Map<String, Object?>>().toList();
  if (json is Map) {
    Object? rows = json['rotas'];
    if (rows is! List) {
      for (final v in json.values) {
        if (v is List) {
          rows = v;
          break;
        }
      }
    }
    if (rows is List) return rows.whereType<Map<String, Object?>>().toList();
  }
  return const [];
}

/// One on-call rota (`GET /GlpiSignal/oncall`): who holds the pager now and
/// who takes it next.
class OncallRotaDto {
  const OncallRotaDto({
    required this.id,
    required this.name,
    required this.oncallUserId,
    required this.oncallUserName,
    required this.amIOnCall,
    required this.nextHandoff,
    required this.nextUserName,
  });

  final int id;
  final String name;
  final int? oncallUserId;
  final String? oncallUserName;

  /// Server-computed: is the signed-in user the current on-call?
  final bool amIOnCall;
  final String? nextHandoff;
  final String? nextUserName;

  factory OncallRotaDto.fromJson(Map<String, Object?> json) {
    // Live wire shape: `layers: [{on_call: [{id,name}], ...}]` with a
    // rota-level `next_handoff` (unix seconds) and `next_incoming` list.
    final layers = json['layers'];
    if (layers is List && layers.isNotEmpty) {
      final oncall = <Object?>[
        for (final layer in layers.whereType<Map<Object?, Object?>>())
          ...switch (layer['on_call']) {
            final List<Object?> people => people,
            _ => const <Object?>[],
          },
      ];
      final names = <String>[];
      for (final n in oncall.map(_nameOf).whereType<String>()) {
        if (!names.contains(n)) names.add(n);
      }
      return OncallRotaDto(
        id: (json['id'] as num).toInt(),
        name: '${json['name'] ?? ''}',
        oncallUserId: oncall.isEmpty ? null : _idOf(oncall.first),
        oncallUserName: names.isEmpty ? null : names.join(', '),
        amIOnCall: json['am_i_on_call'] == true,
        nextHandoff: _dateOf(json['next_handoff'] ?? json['handoff_at']),
        nextUserName: switch (json['next_incoming']) {
          final List<Object?> people when people.isNotEmpty =>
            people.map(_nameOf).whereType<String>().join(', '),
          _ => _nameOf(json['next_user'] ?? json['next_user_name']),
        },
      );
    }
    // Older assumed shapes: the current on-call as one record or a list.
    Object? current =
        json['oncall_user'] ?? json['oncall_users'] ?? json['users_id'];
    if (current is List && current.isNotEmpty) {
      final names = current.map(_nameOf).whereType<String>().toList();
      return OncallRotaDto(
        id: (json['id'] as num).toInt(),
        name: '${json['name'] ?? ''}',
        oncallUserId: _idOf(current.first),
        oncallUserName: names.isEmpty ? null : names.join(', '),
        amIOnCall: json['am_i_on_call'] == true,
        nextHandoff: _dateOf(json['next_handoff'] ?? json['handoff_at']),
        nextUserName: _nameOf(json['next_user'] ?? json['next_user_name']),
      );
    }
    if (current is List) current = null;
    return OncallRotaDto(
      id: (json['id'] as num).toInt(),
      name: '${json['name'] ?? ''}',
      oncallUserId: switch (_idOf(current)) {
        null || 0 => null,
        final id => id,
      },
      oncallUserName: _nameOf(current ?? json['oncall_user_name']),
      amIOnCall: json['am_i_on_call'] == true,
      nextHandoff: _dateOf(json['next_handoff'] ?? json['handoff_at']),
      nextUserName: _nameOf(json['next_user'] ?? json['next_user_name']),
    );
  }
}
