import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/repositories/ticket_repository.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/widgets/section_heading.dart';
import '../queue_controls.dart';
import '../queue_providers.dart';

/// Modal filter/sort sheet for the queue. Selections apply immediately (the
/// list is a reactive local query), so there's no explicit "apply".
class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const FilterSheet(),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controls = ref.watch(queueControlsProvider);
    final notifier = ref.read(queueControlsProvider.notifier);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    'Filter & sort',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const Spacer(),
                if (controls.hasActiveFilters)
                  TextButton(
                    onPressed: notifier.clear,
                    child: const Text('Reset'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const SectionHeading('Status'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (final s in openTicketStatuses)
                  FilterChip(
                    label: Text(statusLabel(s)),
                    selected: controls.statuses.contains(s),
                    onSelected: (_) => notifier.toggleStatus(s),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const SectionHeading('Priority'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (final p in const [5, 4, 3, 2])
                  FilterChip(
                    label: Text(priorityLabel(p)),
                    selected: controls.priorities.contains(p),
                    onSelected: (_) => notifier.togglePriority(p),
                  ),
              ],
            ),
            if (ref.watch(queueCategoriesProvider).isNotEmpty) ...[
              const SizedBox(height: 16),
              const SectionHeading('Category'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final cat in ref.watch(queueCategoriesProvider))
                    FilterChip(
                      label: Text(cat),
                      selected: controls.categories.contains(cat),
                      onSelected: (_) => notifier.toggleCategory(cat),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const SectionHeading('Sort by'),
            const SizedBox(height: 6),
            SegmentedButton<QueueSort>(
              segments: const [
                ButtonSegment(
                  value: QueueSort.activity,
                  label: Text('Activity'),
                ),
                ButtonSegment(value: QueueSort.oldest, label: Text('Oldest')),
                ButtonSegment(
                  value: QueueSort.priority,
                  label: Text('Priority'),
                ),
              ],
              selected: {controls.sort},
              onSelectionChanged: (s) => notifier.setSort(s.first),
            ),
          ],
        ),
      ),
    );
  }
}
