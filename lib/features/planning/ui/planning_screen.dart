import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/planning_event.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/utils/layout.dart';
import 'event_editor_sheet.dart';
import 'planning_event_tile.dart';
import 'reschedule_sheet.dart';

/// The technician's calendar: everything GLPI has planned for them — ITIL and
/// project tasks, reminders and standalone events — in a day or week view.
class PlanningScreen extends ConsumerStatefulWidget {
  const PlanningScreen({super.key});

  @override
  ConsumerState<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends ConsumerState<PlanningScreen> {
  bool _weekView = false;
  bool _loadedOnce = false;

  /// The feed is fetched in a generous window so scrolling nearby days is
  /// instant and works offline: a week back, four weeks forward.
  Future<void> _refresh() async {
    final repo = ref.read(planningRepositoryProvider);
    if (repo == null) return;
    final day = ref.read(planningDayProvider);
    try {
      await repo.refresh(
        day.subtract(const Duration(days: 7)),
        day.add(const Duration(days: 28)),
      );
    } on Exception {
      // Offline: cached events keep showing.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadedOnce) {
      _loadedOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    }
    final day = ref.watch(planningDayProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning'),
        actions: [
          IconButton(
            tooltip: 'Today',
            icon: const Icon(Icons.today_outlined),
            onPressed: () {
              final now = DateTime.now();
              ref.read(planningDayProvider.notifier).set(now);
              _refresh();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Day')),
                ButtonSegment(value: true, label: Text('Week')),
              ],
              selected: {_weekView},
              onSelectionChanged: (s) => setState(() => _weekView = s.first),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _DateStrip(
            selected: day,
            onSelect: (d) {
              ref.read(planningDayProvider.notifier).set(d);
              _refresh();
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _weekView ? const _WeekAgenda() : const _DayList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(context),
        tooltip: 'Add to planning',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    final kind = await showModalBottomSheet<String>(
      context: context,
      constraints: sheetConstraints(context),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.event_outlined),
              title: const Text('New event'),
              subtitle: const Text('A standalone entry in your calendar'),
              onTap: () => Navigator.pop(context, 'PlanningExternalEvent'),
            ),
            ListTile(
              leading: const Icon(Icons.sticky_note_2_outlined),
              title: const Text('New reminder'),
              subtitle: const Text('A note, optionally scheduled'),
              onTap: () => Navigator.pop(context, 'Reminder'),
            ),
          ],
        ),
      ),
    );
    if (kind == null || !context.mounted) return;
    // New entries default to 09:00–10:00 on the day being viewed.
    final day = ref.read(planningDayProvider);
    await EventEditorSheet.show(
      context,
      kind: kind,
      initialBegin: DateTime(day.year, day.month, day.day, 9),
      initialEnd: DateTime(day.year, day.month, day.day, 10),
    );
  }
}

/// Horizontally scrolling two-week date picker.
class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.selected, required this.onSelect});

  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final start = selected.subtract(const Duration(days: 3));
    return SizedBox(
      height: 68,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: 14,
        itemBuilder: (context, i) {
          final d = DateTime(start.year, start.month, start.day + i);
          final isSelected = _sameDay(d, selected);
          final isToday = _sameDay(d, today);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onSelect(d),
              child: Container(
                width: 48,
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : null,
                  border: isToday && !isSelected
                      ? Border.all(color: theme.colorScheme.primary)
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _weekdayLetter(d.weekday),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.outline,
                      ),
                    ),
                    Text(
                      '${d.day}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isSelected ? theme.colorScheme.onPrimary : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The selected day's events: all-day first, then chronological.
class _DayList extends ConsumerWidget {
  const _DayList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(planningDayEventsProvider).value ?? const [];
    if (events.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.event_available_outlined,
                  size: 44,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 12),
                Text(
                  'Nothing planned',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: events.length,
      itemBuilder: (context, i) => PlanningEventTile(event: events[i]),
    );
  }
}

/// The week containing the selected day, grouped into day sections.
class _WeekAgenda extends ConsumerWidget {
  const _WeekAgenda();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final day = ref.watch(planningDayProvider);
    final monday = day.subtract(Duration(days: day.weekday - 1));
    final events = ref.watch(planningWeekEventsProvider).value ?? const [];

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (var i = 0; i < 7; i++) ...[
          Builder(
            builder: (context) {
              final d = DateTime(monday.year, monday.month, monday.day + i);
              final dayEvents = events
                  .where(
                    (e) =>
                        !e.begin.isAfter(
                          DateTime(d.year, d.month, d.day, 23, 59, 59),
                        ) &&
                        !e.end.isBefore(DateTime(d.year, d.month, d.day)),
                  )
                  .toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () => ref.read(planningDayProvider.notifier).set(d),
                    child: Container(
                      color: _sameDay(d, day)
                          ? theme.colorScheme.secondaryContainer.withValues(
                              alpha: 0.4,
                            )
                          : null,
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                      child: Row(
                        children: [
                          Text(
                            '${_weekdayName(d.weekday)} ${d.day} '
                            '${_monthName(d.month)}',
                            style: theme.textTheme.labelLarge,
                          ),
                          const Spacer(),
                          if (dayEvents.isNotEmpty)
                            Text(
                              '${dayEvents.length}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (dayEvents.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        '—',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    )
                  else
                    for (final e in dayEvents)
                      PlanningEventTile(event: e, compact: true),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _weekdayLetter(int weekday) =>
    const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][weekday - 1];

String _weekdayName(int weekday) =>
    const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];

String _monthName(int month) => const [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
][month - 1];

/// Shared open-the-underlying-object behavior for planning tiles.
Future<void> openPlanningTarget(
  BuildContext context,
  WidgetRef ref,
  PlanningEvent event,
) async {
  // ITIL tasks deep-link to their parent object.
  final parentType = event.parentItemtype;
  final parentId = event.parentServerId;
  if (parentType != null &&
      parentId != null &&
      parentType != 'Project' &&
      event.isTask) {
    final repo = ref.read(ticketRepositoryProvider);
    if (repo == null) return;
    final localId = await repo.openByServerId(parentId, itemtype: parentType);
    if (localId == null || !context.mounted) return;
    await context.push(Routes.ticket(localId));
    return;
  }
  // Project tasks open their project (Phase 2).
  if (parentType == 'Project' && parentId != null) {
    final repo = ref.read(projectRepositoryProvider);
    if (repo == null) return;
    final localId = await repo.openByServerId(parentId);
    if (localId == null || !context.mounted) return;
    await context.push(Routes.project(localId));
    return;
  }
  // Reminders and standalone events open their editor.
  if (!context.mounted) return;
  await EventEditorSheet.show(context, existing: event);
}

/// Long-press action shared by the tiles.
Future<void> reschedulePlanningEvent(
  BuildContext context,
  PlanningEvent event,
) => RescheduleSheet.show(context, event: event);

/// Formats an event's time range for a tile ("09:00–10:30" / "All day").
String planningTimeRange(PlanningEvent e) {
  if (e.isAllDay) return 'All day';
  String hm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';
  return '${hm(e.begin)}–${hm(e.end)}';
}

/// Re-exported so tiles can show "in 2h" style hints without another import.
String planningRelative(DateTime when) => relativeAge(when);
