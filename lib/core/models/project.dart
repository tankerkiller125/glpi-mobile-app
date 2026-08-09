/// A project as the list/detail screens render it.
class Project {
  const Project({
    required this.localId,
    required this.serverId,
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
  });

  final String localId;
  final int? serverId;
  final String name;
  final String? code;
  final String content;
  final String? statusName;
  final int priority;
  final int percentDone;
  final DateTime? planStartDate;
  final DateTime? planEndDate;
  final String? managerName;
  final String? entityName;

  bool get isComplete => percentDone >= 100;

  /// Projects run for weeks, so "at risk" uses a 7-day window (tickets use 4h).
  static const Duration dueWarnWindow = Duration(days: 7);
}

/// A project task. [depth] is computed when the tree is flattened for display.
class ProjectTask {
  const ProjectTask({
    required this.localId,
    required this.serverId,
    required this.parentTaskServerId,
    required this.name,
    required this.content,
    required this.statusName,
    required this.percentDone,
    required this.planStartDate,
    required this.planEndDate,
    required this.isMilestone,
    required this.assigneeName,
    required this.pending,
    this.depth = 0,
  });

  final String localId;
  final int? serverId;
  final int? parentTaskServerId;
  final String name;
  final String content;
  final String? statusName;
  final int percentDone;
  final DateTime? planStartDate;
  final DateTime? planEndDate;
  final bool isMilestone;
  final String? assigneeName;
  final bool pending;
  final int depth;

  bool get isComplete => percentDone >= 100;

  ProjectTask withDepth(int d) => ProjectTask(
    localId: localId,
    serverId: serverId,
    parentTaskServerId: parentTaskServerId,
    name: name,
    content: content,
    statusName: statusName,
    percentDone: percentDone,
    planStartDate: planStartDate,
    planEndDate: planEndDate,
    isMilestone: isMilestone,
    assigneeName: assigneeName,
    pending: pending,
    depth: d,
  );
}

/// Flatten a task list into parent-then-children order with depth, so the UI
/// can indent without building a nested widget tree.
List<ProjectTask> flattenProjectTasks(List<ProjectTask> tasks) {
  final byParent = <int?, List<ProjectTask>>{};
  final knownIds = tasks.map((t) => t.serverId).whereType<int>().toSet();
  for (final t in tasks) {
    // A task whose parent isn't in this project renders at the root.
    final parent =
        (t.parentTaskServerId != null &&
            knownIds.contains(t.parentTaskServerId))
        ? t.parentTaskServerId
        : null;
    byParent.putIfAbsent(parent, () => []).add(t);
  }
  final out = <ProjectTask>[];
  void walk(int? parent, int depth) {
    for (final t in byParent[parent] ?? const <ProjectTask>[]) {
      out.add(t.withDepth(depth));
      if (t.serverId != null) walk(t.serverId, depth + 1);
    }
  }

  walk(null, 0);
  return out;
}
