/// DTOs for the glpi-major plugin (`/GlpiMajor/*`): major incidents, their
/// comms updates, and the declare/attach offer for a ticket. Parsed tolerantly
/// — related records may arrive nested (`{"commander": {"id": 2, "name": …}}`)
/// or flat (`users_id_commander` + `commander_name`).
library;

int? _idOf(Object? v) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  if (v is Map) return (v['id'] as num?)?.toInt();
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

/// A major incident row (`GET /GlpiMajor/incidents`).
/// Dig the incident rows out of the list response. The plugin wraps them in
/// `{"incidents": [...]}`; a bare array is accepted too.
List<Map<String, Object?>> majorRowsFromJson(Object? json) {
  if (json is List) return json.whereType<Map<String, Object?>>().toList();
  if (json is Map) {
    Object? rows = json['incidents'];
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

class MajorIncidentDto {
  const MajorIncidentDto({
    required this.id,
    required this.title,
    required this.state,
    required this.ticketsId,
    required this.entityName,
    required this.commanderId,
    required this.commanderName,
    required this.declaredAt,
    required this.nextUpdateAt,
  });

  final int id;
  final String title;

  /// `open` while the incident is being worked; anything else reads as over.
  final String state;

  /// The driving GLPI ticket.
  final int? ticketsId;
  final String? entityName;
  final int? commanderId;
  final String? commanderName;
  final String? declaredAt;

  /// When the commander promised the next comms update.
  final String? nextUpdateAt;

  /// Anything but a terminal state. The server's vocabulary is
  /// `investigating` / `identified` / `monitoring` / `resolved`.
  bool get isOpen => state != 'resolved' && state != 'closed';

  factory MajorIncidentDto.fromJson(Map<String, Object?> json) =>
      MajorIncidentDto(
        id: (json['id'] as num).toInt(),
        title: '${json['title'] ?? json['name'] ?? ''}',
        state: '${json['state'] ?? 'open'}',
        ticketsId: switch (_idOf(json['tickets_id'] ?? json['ticket'])) {
          null || 0 => null,
          final id => id,
        },
        entityName: _nameOf(json['entity'] ?? json['entity_name']),
        commanderId: _idOf(json['commander'] ?? json['users_id_commander']),
        commanderName: _nameOf(json['commander'] ?? json['commander_name']),
        declaredAt: json['declared_at'] as String?,
        nextUpdateAt: json['next_update_at'] as String?,
      );
}

/// One comms update on a major incident.
class MajorUpdateDto {
  const MajorUpdateDto({
    required this.id,
    required this.audience,
    required this.content,
    required this.author,
    required this.createdAt,
  });

  final int id;

  /// `internal` | `customer`.
  final String audience;
  final String content;
  final String author;
  final String? createdAt;

  bool get isCustomer => audience == 'customer';

  factory MajorUpdateDto.fromJson(Map<String, Object?> json) => MajorUpdateDto(
    id: (json['id'] as num).toInt(),
    audience: '${json['audience'] ?? 'internal'}',
    content: '${json['content'] ?? ''}',
    author: _nameOf(json['author']) ?? '',
    createdAt: json['created_at'] as String?,
  );
}

/// A full major incident (`GET /GlpiMajor/incidents/{id}`): the record plus
/// its comms log.
class MajorIncidentDetailDto {
  const MajorIncidentDetailDto({required this.incident, required this.updates});

  final MajorIncidentDto incident;
  final List<MajorUpdateDto> updates;

  factory MajorIncidentDetailDto.fromJson(Map<String, Object?> json) {
    final row = json['incident'];
    final rawUpdates = json['updates'];
    return MajorIncidentDetailDto(
      incident: MajorIncidentDto.fromJson(
        row is Map<String, Object?> && row.containsKey('id') ? row : json,
      ),
      updates: rawUpdates is List
          ? rawUpdates
                .whereType<Map<String, Object?>>()
                .map(MajorUpdateDto.fromJson)
                .toList()
          : const [],
    );
  }
}

/// An open incident this ticket could attach to.
class MajorAttachOfferDto {
  const MajorAttachOfferDto({required this.id, required this.title});

  final int id;
  final String title;

  factory MajorAttachOfferDto.fromJson(Map<String, Object?> json) =>
      MajorAttachOfferDto(
        id: (json['id'] as num).toInt(),
        title: '${json['title'] ?? json['name'] ?? ''}',
      );
}

/// `GET /GlpiMajor/ticket/{tickets_id}`: this ticket's relationship to major
/// incidents. The three states are mutually exclusive:
///
/// * [incident] — this ticket IS the incident's driving ticket;
/// * [attachedTo] — this ticket is attached to someone else's incident;
/// * neither — [offerAttach] lists the open incidents it could attach to.
class MajorTicketInfoDto {
  const MajorTicketInfoDto({
    required this.incident,
    required this.attachedTo,
    required this.offerAttach,
  });

  static const none = MajorTicketInfoDto(
    incident: null,
    attachedTo: null,
    offerAttach: [],
  );

  final MajorIncidentDto? incident;
  final MajorIncidentDto? attachedTo;
  final List<MajorAttachOfferDto> offerAttach;

  /// Whichever incident this ticket is bound to, either way round.
  MajorIncidentDto? get bound => incident ?? attachedTo;

  factory MajorTicketInfoDto.fromJson(Map<String, Object?> json) {
    MajorIncidentDto? row(Object? v) =>
        v is Map<String, Object?> && v['id'] is num
        ? MajorIncidentDto.fromJson(v)
        : null;
    final offers = json['offer_attach'];
    return MajorTicketInfoDto(
      incident: row(json['incident']),
      attachedTo: row(json['attached_to']),
      offerAttach: offers is List
          ? offers
                .whereType<Map<String, Object?>>()
                .map(MajorAttachOfferDto.fromJson)
                .toList()
          : const [],
    );
  }
}
