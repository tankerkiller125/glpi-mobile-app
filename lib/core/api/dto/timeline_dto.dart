/// One entry of the GLPI merged timeline (`{type, item}`). A single flattened
/// shape with a discriminator, mirroring how the server merges sub-items and
/// how the UI renders them in one list.
class TimelineEntryDto {
  const TimelineEntryDto({
    required this.type,
    required this.id,
    required this.content,
    required this.isPrivate,
    required this.dateCreation,
    required this.authorId,
    required this.authorName,
    required this.taskDuration,
    required this.taskState,
    required this.solutionStatus,
    required this.validationStatus,
    required this.approverId,
    required this.approverType,
    required this.approvalComment,
  });

  /// One of: followup, task, solution, validation, document, other.
  final String type;
  final int id;
  final String content;
  final bool isPrivate;
  final String? dateCreation;
  final int? authorId;
  final String? authorName;

  // Task-only.
  final int? taskDuration; // seconds
  final int? taskState; // 0 info, 1 todo, 2 done

  // Solution / validation status enums: 2 waiting, 3 accepted, 4 refused.
  final int? solutionStatus;
  final int? validationStatus;

  // Validation-only: who must approve, and the approver's reply.
  final int? approverId;
  final String? approverType; // User | Group
  final String? approvalComment;

  factory TimelineEntryDto.fromJson(Map<String, Object?> json) {
    final rawType = (json['type'] as String? ?? '').toLowerCase();
    final normType = _normalizeType(rawType);
    final item = json['item'] as Map<String, Object?>? ?? const {};
    final user = item['user'] as Map<String, Object?>?;
    final requester = item['requester'] as Map<String, Object?>?;

    // Validations carry `submission_comment` instead of `content`, and the
    // author is the requester.
    final isValidation = normType == 'validation';
    final content = isValidation
        ? (item['submission_comment'] as String? ?? '')
        : (item['content'] as String? ?? '');
    final author = isValidation ? requester : user;

    return TimelineEntryDto(
      type: normType,
      id: (item['id'] as num?)?.toInt() ?? 0,
      content: content,
      isPrivate: item['is_private'] == true || item['is_private'] == 1,
      dateCreation:
          (item['date_creation'] ?? item['date'] ?? item['submission_date'])
              as String?,
      authorId: (author?['id'] as num?)?.toInt(),
      authorName: author?['name'] as String?,
      taskDuration: (item['duration'] as num?)?.toInt(),
      taskState: (item['state'] as num?)?.toInt(),
      solutionStatus: normType == 'solution'
          ? (item['status'] as num?)?.toInt()
          : null,
      validationStatus: isValidation ? (item['status'] as num?)?.toInt() : null,
      approverId: (item['requested_approver_id'] as num?)?.toInt(),
      approverType: item['requested_approver_type'] as String?,
      approvalComment: item['approval_comment'] as String?,
    );
  }

  static String _normalizeType(String raw) {
    if (raw.contains('followup')) return 'followup';
    if (raw.contains('task')) return 'task';
    if (raw.contains('solution')) return 'solution';
    if (raw.contains('validation')) return 'validation';
    if (raw.contains('document')) return 'document';
    return raw.isEmpty ? 'other' : raw;
  }
}
