/// A timeline entry as shown in ticket detail.
class TimelineEntry {
  const TimelineEntry({
    required this.localId,
    required this.serverId,
    required this.type,
    required this.content,
    required this.isPrivate,
    required this.dateCreation,
    required this.authorId,
    required this.authorName,
    required this.taskDuration,
    required this.taskState,
    this.solutionStatus,
    this.validationStatus,
    this.approverId,
    this.approverType,
    this.approvalComment,
  });

  final String localId;
  final int? serverId;
  final String type; // followup | task | solution | validation | document
  final String content;
  final bool isPrivate;
  final DateTime? dateCreation;
  final int? authorId;
  final String? authorName;
  final int? taskDuration; // seconds
  final int? taskState; // 1 todo, 2 done

  // Solution / validation approval status: 2 waiting, 3 accepted, 4 refused.
  final int? solutionStatus;
  final int? validationStatus;
  // Validation-only.
  final int? approverId;
  final String? approverType; // User | Group
  final String? approvalComment;

  bool get isTaskDone => taskState == 2;

  /// The approval status for whichever kind this is (solution or validation).
  int? get approvalStatus =>
      type == 'solution' ? solutionStatus : validationStatus;

  bool get isWaitingApproval => approvalStatus == 2;
}
