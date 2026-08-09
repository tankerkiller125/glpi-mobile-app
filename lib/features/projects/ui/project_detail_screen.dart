import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/project.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/widgets/due_badge.dart';
import '../../../core/widgets/rich_content.dart';
import 'project_task_sheet.dart';

/// A project: progress header, planning facts, and its task tree.
class ProjectDetailScreen extends ConsumerStatefulWidget {
  const ProjectDetailScreen({super.key, required this.localId});

  final String localId;

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  bool _refreshedOnce = false;

  Future<void> _refresh() async {
    final project = ref.read(projectDetailProvider(widget.localId)).value;
    final serverId = project?.serverId;
    if (serverId == null) return;
    try {
      await ref
          .read(projectRepositoryProvider)
          ?.refreshTasks(widget.localId, serverId);
    } on Exception {
      // Offline: cached tasks keep showing.
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(projectDetailProvider(widget.localId));
    final project = async.value;
    if (!_refreshedOnce && project?.serverId != null) {
      _refreshedOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          project == null ? 'Project' : 'Project #${project.serverId ?? ''}',
        ),
      ),
      body: switch (async) {
        AsyncData(value: final p?) => RefreshIndicator(
          onRefresh: _refresh,
          child: _Body(project: p),
        ),
        AsyncData() => const Center(child: Text('Project not found')),
        AsyncError() => const Center(child: Text('Could not load the project')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.glpiColors;
    final tasks =
        ref.watch(projectTasksProvider(project.localId)).value ??
        const <ProjectTask>[];
    final due = project.planEndDate;
    final remaining = due?.difference(DateTime.now());

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(project.name, style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (project.percentDone / 100).clamp(0, 1),
                        minHeight: 8,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        color: project.isComplete
                            ? colors.slaOk
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${project.percentDone}% done',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Row(
                icon: Icons.flag_outlined,
                label: 'Status',
                value: project.statusName ?? '—',
              ),
              _Row(
                icon: Icons.priority_high,
                label: 'Priority',
                value: priorityLabel(project.priority),
              ),
              _Row(
                icon: Icons.person_outline,
                label: 'Manager',
                value: project.managerName ?? '—',
              ),
              _Row(
                icon: Icons.play_arrow_outlined,
                label: 'Starts',
                value: project.planStartDate == null
                    ? '—'
                    : formatDateTime(project.planStartDate),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 18,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 92,
                      child: Text(
                        'Ends',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                    Text(
                      due == null ? '—' : formatDateTime(due),
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (due != null && !project.isComplete) ...[
                      const SizedBox(width: 8),
                      DueBadge(
                        text: formatDueRelative(due),
                        color: colors.slaColor(
                          remaining!,
                          warn: Project.dueWarnWindow,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if ((project.code ?? '').isNotEmpty)
                _Row(icon: Icons.tag, label: 'Code', value: project.code!),
              if ((project.entityName ?? '').isNotEmpty)
                _Row(
                  icon: Icons.business_outlined,
                  label: 'Entity',
                  value: project.entityName!,
                ),
              if (project.content.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Description', style: theme.textTheme.labelLarge),
                const SizedBox(height: 4),
                RichContent(project.content),
              ],
              const SizedBox(height: 8),
              const Divider(),
              Row(
                children: [
                  Text('Tasks', style: theme.textTheme.labelLarge),
                  const SizedBox(width: 4),
                  if (tasks.isNotEmpty)
                    Text(
                      '(${tasks.length})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () =>
                        ProjectTaskSheet.show(context, project: project),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add task'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Text(
              'No tasks yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          )
        else
          for (final t in tasks) _TaskRow(project: project, task: t),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.project, required this.task});

  final Project project;
  final ProjectTask task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.glpiColors;
    final due = task.planEndDate;
    final remaining = due?.difference(DateTime.now());
    final atRisk =
        !task.isComplete &&
        remaining != null &&
        remaining <= const Duration(days: 3);

    return Opacity(
      opacity: task.pending ? 0.55 : 1,
      child: InkWell(
        onTap: () =>
            ProjectTaskSheet.show(context, project: project, task: task),
        child: Padding(
          // Children indent one level per depth.
          padding: EdgeInsets.fromLTRB(16.0 + task.depth * 16, 8, 16, 8),
          child: Row(
            children: [
              Icon(
                task.isMilestone
                    ? Icons.flag
                    : (task.isComplete
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked),
                size: 18,
                color: task.isComplete
                    ? colors.slaOk
                    : theme.colorScheme.outline,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: task.depth == 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.pending)
                      Text(
                        'syncing…',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      )
                    else if ((task.assigneeName ?? '').isNotEmpty)
                      Text(
                        task.assigneeName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                  ],
                ),
              ),
              if (atRisk) ...[
                DueBadge(
                  text: formatDueRelative(due),
                  color: colors.slaColor(
                    remaining,
                    warn: const Duration(days: 3),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                '${task.percentDone}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.outline),
          const SizedBox(width: 12),
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
