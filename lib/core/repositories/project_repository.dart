import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../api/dto/project_dto.dart';
import '../api/glpi_api.dart';
import '../db/app_database.dart';
import '../models/project.dart';
import '../utils/formatting.dart';

const _uuid = Uuid();

/// Projects and their tasks: reactive reads from drift, synced from
/// `/Project` + `/Project/{id}/Task`.
class ProjectRepository {
  ProjectRepository(this._db, this._api);

  final AppDatabase _db;
  final GlpiApi _api;

  /// Open projects first (incomplete), then finished ones; newest activity up.
  Stream<List<Project>> watchProjects() {
    final q = _db.select(_db.projects)
      ..orderBy([
        (p) => OrderingTerm(expression: p.percentDone),
        (p) => OrderingTerm(expression: p.dateMod, mode: OrderingMode.desc),
      ]);
    return q.watch().map((rows) => rows.map(_toProject).toList());
  }

  Stream<Project?> watchProject(String localId) {
    final q = _db.select(_db.projects)..where((p) => p.localId.equals(localId));
    return q.watchSingleOrNull().map((r) => r == null ? null : _toProject(r));
  }

  /// Tasks of a project, already flattened parent-then-child with depth.
  Stream<List<ProjectTask>> watchTasks(String projectLocalId) {
    final q = _db.select(_db.projectTasks)
      ..where((t) => t.projectLocalId.equals(projectLocalId))
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
    return q.watch().map(
      (rows) => flattenProjectTasks(rows.map(_toTask).toList()),
    );
  }

  Project _toProject(ProjectRow r) => Project(
    localId: r.localId,
    serverId: r.serverId,
    name: r.name,
    code: r.code,
    content: r.content,
    statusName: r.statusName,
    priority: r.priority,
    percentDone: r.percentDone,
    planStartDate: _date(r.planStartDate),
    planEndDate: _date(r.planEndDate),
    managerName: r.managerName,
    entityName: r.entityLabel,
  );

  ProjectTask _toTask(ProjectTaskRow r) => ProjectTask(
    localId: r.localId,
    serverId: r.serverId,
    parentTaskServerId: r.parentTaskServerId,
    name: r.name,
    content: r.content,
    statusName: r.statusName,
    percentDone: r.percentDone,
    planStartDate: _date(r.planStartDate),
    planEndDate: _date(r.planEndDate),
    isMilestone: r.isMilestone,
    assigneeName: r.assigneeName,
    pending: r.pending,
  );

  static DateTime? _date(String? s) => parseGlpiDateTime(s);

  /// The local id for a server project, fetching it on a miss (deep links).
  Future<String?> openByServerId(int serverId) async {
    final cached = await (_db.select(
      _db.projects,
    )..where((p) => p.serverId.equals(serverId))).getSingleOrNull();
    if (cached != null) return cached.localId;
    try {
      await _upsert([await _api.getProject(serverId)]);
    } on Exception {
      return null;
    }
    final row = await (_db.select(
      _db.projects,
    )..where((p) => p.serverId.equals(serverId))).getSingleOrNull();
    return row?.localId;
  }

  Future<int> refreshProjects() async {
    var start = 0;
    var synced = 0;
    while (true) {
      final page = await _api.listProjects(start: start, limit: 100);
      if (page.items.isEmpty) break;
      await _upsert(page.items);
      synced += page.items.length;
      start += page.items.length;
      if (start >= page.total) break;
    }
    return synced;
  }

  /// Pull a project's tasks, replacing the synced set but keeping queued rows.
  Future<void> refreshTasks(String projectLocalId, int projectServerId) async {
    final tasks = await _api.listProjectTasks(projectServerId);
    await _db.transaction(() async {
      await (_db.delete(_db.projectTasks)..where(
            (t) =>
                t.projectLocalId.equals(projectLocalId) &
                t.pending.equals(false),
          ))
          .go();
      for (final t in tasks) {
        final queued =
            await (_db.select(_db.projectTasks)..where(
                  (r) =>
                      r.projectLocalId.equals(projectLocalId) &
                      r.serverId.equals(t.id) &
                      r.pending.equals(true),
                ))
                .getSingleOrNull();
        if (queued != null) continue;
        await _db
            .into(_db.projectTasks)
            .insert(
              ProjectTasksCompanion.insert(
                localId: _uuid.v4(),
                projectLocalId: projectLocalId,
                serverId: Value(t.id),
                parentTaskServerId: Value(t.parentTaskId),
                name: t.name,
                content: Value(t.content),
                statusName: Value(t.statusName),
                percentDone: Value(t.percentDone),
                planStartDate: Value(t.planStartDate),
                planEndDate: Value(t.planEndDate),
                isMilestone: Value(t.isMilestone),
                assigneeName: Value(t.assigneeName),
              ),
            );
      }
    });
  }

  Future<void> _upsert(List<ProjectDto> dtos) async {
    await _db.transaction(() async {
      for (final d in dtos) {
        final existing = await (_db.select(
          _db.projects,
        )..where((p) => p.serverId.equals(d.id))).getSingleOrNull();
        await _db
            .into(_db.projects)
            .insertOnConflictUpdate(
              ProjectsCompanion.insert(
                localId: existing?.localId ?? _uuid.v4(),
                serverId: Value(d.id),
                name: d.name,
                code: Value(d.code),
                content: Value(d.content),
                statusName: Value(d.statusName),
                priority: Value(d.priority),
                percentDone: Value(d.percentDone),
                planStartDate: Value(d.planStartDate),
                planEndDate: Value(d.planEndDate),
                managerName: Value(d.managerName),
                entityLabel: Value(d.entityName),
                dateMod: Value(d.dateMod),
              ),
            );
      }
    });
  }
}
