import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/a11y/a11y.dart';
import '../../../core/models/project.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/widgets/accessible_refresh.dart';
import '../../../core/widgets/due_badge.dart';
import '../../../core/widgets/rights_gate.dart';
import '../../../core/widgets/status_chip.dart';

/// Projects list: progress at a glance, at-risk end dates flagged.
class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  String _query = '';
  bool _loadedOnce = false;

  Future<void> _refresh() async {
    try {
      await ref.read(projectRepositoryProvider)?.refreshProjects();
    } on Exception {
      // Offline: the cached list keeps showing.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadedOnce) {
      _loadedOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    }
    final all = ref.watch(projectsProvider).value ?? const <Project>[];
    final q = _query.trim().toLowerCase();
    final projects = q.isEmpty
        ? all
        : all
              .where(
                (p) =>
                    p.name.toLowerCase().contains(q) ||
                    (p.code ?? '').toLowerCase().contains(q),
              )
              .toList();

    return RightsGate(
      allows: (r) => r.canViewProjects,
      title: 'Projects',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Projects'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search projects…',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),
        ),
        body: AccessibleRefresh(
          onRefresh: _refresh,
          child: projects.isEmpty
              ? ListView(
                  children: [
                    const SizedBox(height: 100),
                    Center(
                      child: Text(
                        all.isEmpty ? 'No projects' : 'No matches',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: projects.length,
                  itemBuilder: (context, i) =>
                      _ProjectCard(project: projects[i]),
                ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.glpiColors;
    final due = project.planEndDate;
    final remaining = due?.difference(DateTime.now());
    final showDue =
        !project.isComplete &&
        remaining != null &&
        remaining <= Project.dueWarnWindow;

    // One node per card: a progress bar, a percentage and a coloured dot are
    // four fragments otherwise, none of which says what it belongs to.
    final spoken = semanticSentence([
      project.name,
      if ((project.code ?? '').isNotEmpty) project.code,
      'Priority ${priorityLabel(project.priority)}',
      '${project.percentDone} percent done',
      if ((project.statusName ?? '').isNotEmpty) project.statusName,
      if ((project.managerName ?? '').isNotEmpty)
        'Manager ${project.managerName}',
      if (showDue) spokenDueRelative(due),
    ]);

    return Semantics(
      container: true,
      button: true,
      label: spoken,
      onTap: () => context.push(Routes.project(project.localId)),
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: InkWell(
          onTap: () => context.push(Routes.project(project.localId)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PriorityDot(priority: project.priority),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: project.name,
                          children: [
                            if ((project.code ?? '').isNotEmpty)
                              TextSpan(
                                text: '  ${project.code}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                          ],
                        ),
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${project.percentDone}%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: project.isComplete
                            ? colors.slaOk
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: (project.percentDone / 100).clamp(0, 1),
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: project.isComplete
                        ? colors.slaOk
                        : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if ((project.statusName ?? '').isNotEmpty) ...[
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        project.statusName!,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 10),
                    ],
                    if ((project.managerName ?? '').isNotEmpty)
                      Expanded(
                        child: Text(
                          project.managerName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      const Spacer(),
                    if (showDue)
                      DueBadge(
                        text: formatDueRelative(due),
                        color: colors.slaColor(
                          remaining,
                          warn: Project.dueWarnWindow,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
