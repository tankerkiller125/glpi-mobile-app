import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/models/ticket_list_item.dart';
import '../../core/providers.dart';
import 'queue_controls.dart';

enum QueueScope { mine, groups, unassigned }

/// Filters the cached queue for a tab. GLPI's RSQL team filters are broken, so
/// this split happens locally over each ticket's cached team members.
List<TicketListItem> _scopeFilter(
  List<TicketListItem> all,
  QueueScope scope,
  int userId,
  Set<int> groupIds,
) {
  return switch (scope) {
    QueueScope.mine => all.where((t) => t.assignedToUser(userId)).toList(),
    QueueScope.groups =>
      groupIds.isEmpty
          ? const []
          : all.where((t) => t.assignedToAnyGroup(groupIds)).toList(),
    QueueScope.unassigned => all.where((t) => t.isUnassigned).toList(),
  };
}

/// Applies search text, status/priority filters, and sort — all locally, so it
/// works fully offline.
List<TicketListItem> _applyControls(
  List<TicketListItem> items,
  QueueControls c,
) {
  final search = c.search.trim().toLowerCase();
  final out = items.where((t) {
    if (c.statuses.isNotEmpty && !c.statuses.contains(t.status)) return false;
    if (c.priorities.isNotEmpty && !c.priorities.contains(t.priority)) {
      return false;
    }
    if (c.categories.isNotEmpty &&
        !c.categories.contains(t.categoryName ?? '')) {
      return false;
    }
    if (search.isNotEmpty) {
      final hay =
          '${t.serverId ?? ''} ${t.name} ${t.categoryName ?? ''} '
                  '${t.entityName ?? ''} ${t.requesterName ?? ''}'
              .toLowerCase();
      if (!hay.contains(search)) return false;
    }
    return true;
  }).toList();

  int byDateDesc(DateTime? a, DateTime? b) =>
      (b ?? DateTime(0)).compareTo(a ?? DateTime(0));
  switch (c.sort) {
    case QueueSort.activity:
      out.sort((a, b) => byDateDesc(a.dateMod, b.dateMod));
    case QueueSort.oldest:
      out.sort(
        (a, b) => (a.dateCreation ?? DateTime(0)).compareTo(
          b.dateCreation ?? DateTime(0),
        ),
      );
    case QueueSort.priority:
      out.sort((a, b) => b.priority.compareTo(a.priority));
  }
  return out;
}

/// Distinct category names present in the cached queue, for the filter sheet.
final queueCategoriesProvider = Provider<List<String>>((ref) {
  final queue = ref.watch(queueProvider).value ?? const [];
  final names = <String>{
    for (final t in queue)
      if ((t.categoryName ?? '').isNotEmpty) t.categoryName!,
  };
  final sorted = names.toList()..sort();
  return sorted;
});

/// Test seam for the pure filter/sort logic.
List<TicketListItem> applyControlsForTest(
  List<TicketListItem> items,
  QueueControls controls,
) => _applyControls(items, controls);

final scopedQueueProvider =
    Provider.family<AsyncValue<List<TicketListItem>>, QueueScope>((ref, scope) {
      final queue = ref.watch(queueProvider);
      final controls = ref.watch(queueControlsProvider);
      final auth = ref.watch(authControllerProvider);
      final account = switch (auth) {
        Ready(:final account) => account,
        _ => null,
      };
      if (account == null) return const AsyncValue.data([]);
      return queue.whenData((all) {
        final scoped = _scopeFilter(
          all,
          scope,
          account.userId,
          account.groupIds.toSet(),
        );
        return _applyControls(scoped, controls);
      });
    });
