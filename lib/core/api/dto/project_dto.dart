/// A GLPI project (`/Project`).
class ProjectDto {
  const ProjectDto({
    required this.id,
    required this.name,
    required this.code,
    required this.content,
    required this.statusName,
    required this.priority,
    required this.percentDone,
    required this.planStartDate,
    required this.planEndDate,
    required this.managerName,
    required this.entityName,
    required this.dateMod,
  });

  final int id;
  final String name;
  final String? code;
  final String content;
  final String? statusName;
  final int priority;
  final int percentDone;
  final String? planStartDate;
  final String? planEndDate;
  final String? managerName;
  final String? entityName;
  final String? dateMod;

  static String? _named(Object? v) => v is Map ? v['name'] as String? : null;

  factory ProjectDto.fromJson(Map<String, Object?> json) => ProjectDto(
    id: (json['id'] as num).toInt(),
    name: (json['name'] ?? '') as String,
    code: json['code'] as String?,
    content: (json['content'] ?? json['comment'] ?? '') as String? ?? '',
    statusName: _named(json['status']),
    priority: (json['priority'] as num?)?.toInt() ?? 3,
    percentDone: (json['percent_done'] as num?)?.toInt() ?? 0,
    planStartDate: json['plan_start_date'] as String?,
    planEndDate: json['plan_end_date'] as String?,
    managerName: _named(json['user']),
    entityName: _named(json['entity']),
    dateMod: json['date_mod'] as String?,
  );
}

/// A task inside a project (`/Project/{id}/Task`).
class ProjectTaskDto {
  const ProjectTaskDto({
    required this.id,
    required this.parentTaskId,
    required this.name,
    required this.content,
    required this.statusName,
    required this.percentDone,
    required this.planStartDate,
    required this.planEndDate,
    required this.isMilestone,
    required this.assigneeName,
  });

  final int id;
  final int? parentTaskId;
  final String name;
  final String content;
  final String? statusName;
  final int percentDone;
  final String? planStartDate;
  final String? planEndDate;
  final bool isMilestone;
  final String? assigneeName;

  static String? _named(Object? v) => v is Map ? v['name'] as String? : null;
  static int? _id(Object? v) => v is Map ? (v['id'] as num?)?.toInt() : null;

  factory ProjectTaskDto.fromJson(Map<String, Object?> json) => ProjectTaskDto(
    id: (json['id'] as num).toInt(),
    parentTaskId: _id(json['parent_task']),
    name: (json['name'] ?? '') as String,
    content: (json['content'] ?? json['comment'] ?? '') as String? ?? '',
    statusName: _named(json['status']),
    percentDone: (json['percent_done'] as num?)?.toInt() ?? 0,
    planStartDate: json['plan_start_date'] as String?,
    planEndDate: json['plan_end_date'] as String?,
    isMilestone: json['is_milestone'] == true,
    assigneeName: _named(json['user']),
  );
}
