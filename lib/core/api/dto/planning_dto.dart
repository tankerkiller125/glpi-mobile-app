/// One calendar entry from the plugin's `/GlpiMobile/planning` feed — the six
/// GLPI planning types normalized to a single shape.
class PlanningEventDto {
  const PlanningEventDto({
    required this.eventItemtype,
    required this.eventId,
    required this.parentItemtype,
    required this.parentId,
    required this.parentName,
    required this.title,
    required this.begin,
    required this.end,
    required this.isAllDay,
    required this.state,
  });

  final String eventItemtype; // TicketTask | ChangeTask | … | Reminder
  final int eventId;
  final String? parentItemtype; // Ticket | Change | Problem | Project
  final int? parentId;
  final String parentName;
  final String title;
  final String begin; // 'YYYY-MM-DD HH:MM:SS'
  final String end;
  final bool isAllDay;
  final int state; // 0 information, 1 to do, 2 done

  factory PlanningEventDto.fromJson(Map<String, Object?> json) {
    final parentType = json['parent_itemtype'] as String?;
    final parentId = (json['parent_id'] as num?)?.toInt() ?? 0;
    return PlanningEventDto(
      eventItemtype: '${json['event_itemtype'] ?? ''}',
      eventId: (json['event_id'] as num?)?.toInt() ?? 0,
      parentItemtype: (parentType == null || parentType.isEmpty)
          ? null
          : parentType,
      parentId: parentId == 0 ? null : parentId,
      parentName: '${json['parent_name'] ?? ''}',
      title: '${json['title'] ?? ''}',
      begin: '${json['begin'] ?? ''}',
      end: '${json['end'] ?? ''}',
      isAllDay: json['is_all_day'] == true,
      state: (json['state'] as num?)?.toInt() ?? 0,
    );
  }
}
