/// Parsed ticket from the GLPI HL API list/detail response.
///
/// GLPI returns nested `{id, name}` objects for status/category/entity and a
/// merged `team` array; this flattens what the app needs.
class TicketDto {
  const TicketDto({
    required this.id,
    required this.name,
    required this.content,
    required this.status,
    required this.priority,
    required this.urgency,
    required this.impact,
    required this.type,
    required this.dateCreation,
    required this.dateMod,
    required this.timeToResolve,
    required this.categoryId,
    required this.categoryName,
    required this.entityId,
    required this.entityName,
    required this.requestTypeName,
    required this.locationId,
    required this.locationName,
    required this.recipientName,
    required this.team,
  });

  final int id;
  final String name;
  final String content;
  final int status;
  final int priority;
  final int urgency;
  final int impact;
  final int type;
  final String? dateCreation;
  final String? dateMod;

  /// SLA/internal resolution due date. The HL API exposes it as `resolution_date`
  /// (the DB `time_to_resolve` column); `date_solve` is the *actual* solve time.
  final String? timeToResolve;
  final int? categoryId;
  final String? categoryName;
  final int? entityId;
  final String? entityName;
  final String? requestTypeName;
  final int? locationId;
  final String? locationName;
  final String? recipientName;
  final List<TeamMemberDto> team;

  factory TicketDto.fromJson(Map<String, Object?> json) {
    final status = json['status'];
    final category = json['category'];
    final entity = json['entity'];
    final requestType = json['request_type'];
    final location = json['location'];
    final recipient = json['user_recipient'];
    return TicketDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      content: json['content'] as String? ?? '',
      status: status is Map ? (status['id'] as num).toInt() : 1,
      priority: (json['priority'] as num?)?.toInt() ?? 3,
      urgency: (json['urgency'] as num?)?.toInt() ?? 3,
      impact: (json['impact'] as num?)?.toInt() ?? 3,
      type: (json['type'] as num?)?.toInt() ?? 1,
      dateCreation: json['date_creation'] as String?,
      dateMod: json['date_mod'] as String?,
      timeToResolve: json['resolution_date'] as String?,
      categoryId: category is Map ? (category['id'] as num?)?.toInt() : null,
      categoryName: category is Map ? category['name'] as String? : null,
      entityId: entity is Map ? (entity['id'] as num?)?.toInt() : null,
      entityName: entity is Map ? entity['name'] as String? : null,
      requestTypeName: requestType is Map
          ? requestType['name'] as String?
          : null,
      locationId: location is Map ? (location['id'] as num?)?.toInt() : null,
      locationName: location is Map
          ? location['completename'] as String?
          : null,
      recipientName: recipient is Map ? recipient['name'] as String? : null,
      team: (json['team'] as List<Object?>? ?? const [])
          .whereType<Map<String, Object?>>()
          .map(TeamMemberDto.fromJson)
          .toList(),
    );
  }
}

class TeamMemberDto {
  const TeamMemberDto({
    required this.id,
    required this.role,
    required this.type,
    required this.displayName,
  });

  final int id;
  final String role; // requester | assigned | observer
  final String type; // User | Group | Supplier
  final String displayName;

  factory TeamMemberDto.fromJson(Map<String, Object?> json) => TeamMemberDto(
    id: (json['id'] as num?)?.toInt() ?? 0,
    role: json['role'] as String? ?? '',
    type: json['type'] as String? ?? 'User',
    displayName: (json['display_name'] ?? json['name'] ?? '') as String,
  );
}
