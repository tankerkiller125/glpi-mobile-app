import 'package:flutter_riverpod/flutter_riverpod.dart';

enum QueueSort { activity, oldest, priority }

/// Search text, status/priority/category filters, and sort — applied locally
/// over the cached queue (offline-capable; no server round-trip).
class QueueControls {
  const QueueControls({
    this.search = '',
    this.statuses = const {},
    this.priorities = const {},
    this.categories = const {},
    this.sort = QueueSort.activity,
  });

  final String search;
  final Set<int> statuses; // empty = all
  final Set<int> priorities; // empty = all
  final Set<String> categories; // empty = all; matched by category name
  final QueueSort sort;

  bool get hasActiveFilters =>
      statuses.isNotEmpty ||
      priorities.isNotEmpty ||
      categories.isNotEmpty ||
      sort != QueueSort.activity;

  int get activeFilterCount =>
      (statuses.isNotEmpty ? 1 : 0) +
      (priorities.isNotEmpty ? 1 : 0) +
      (categories.isNotEmpty ? 1 : 0) +
      (sort != QueueSort.activity ? 1 : 0);

  QueueControls copyWith({
    String? search,
    Set<int>? statuses,
    Set<int>? priorities,
    Set<String>? categories,
    QueueSort? sort,
  }) => QueueControls(
    search: search ?? this.search,
    statuses: statuses ?? this.statuses,
    priorities: priorities ?? this.priorities,
    categories: categories ?? this.categories,
    sort: sort ?? this.sort,
  );
}

class QueueControlsNotifier extends Notifier<QueueControls> {
  @override
  QueueControls build() => const QueueControls();

  void setSearch(String value) => state = state.copyWith(search: value);
  void setSort(QueueSort sort) => state = state.copyWith(sort: sort);

  void toggleStatus(int status) {
    final next = {...state.statuses};
    next.contains(status) ? next.remove(status) : next.add(status);
    state = state.copyWith(statuses: next);
  }

  void togglePriority(int priority) {
    final next = {...state.priorities};
    next.contains(priority) ? next.remove(priority) : next.add(priority);
    state = state.copyWith(priorities: next);
  }

  void toggleCategory(String category) {
    final next = {...state.categories};
    next.contains(category) ? next.remove(category) : next.add(category);
    state = state.copyWith(categories: next);
  }

  void clear() => state = const QueueControls();
}

final queueControlsProvider =
    NotifierProvider<QueueControlsNotifier, QueueControls>(
      QueueControlsNotifier.new,
    );
