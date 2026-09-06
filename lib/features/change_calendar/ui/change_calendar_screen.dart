import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/dto/change_dto.dart';
import '../../../core/api/itil_type.dart';
import '../../../core/models/capabilities.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/accent_pill.dart';
import '../../../core/widgets/accessible_refresh.dart';
import '../../../core/widgets/capability_gate.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../change_providers.dart';

/// The change calendar as an agenda: every change, release and freeze in a
/// rolling window (a week back, eight weeks forward), grouped by day with
/// type and severity badges. Server-side only — schedule truth must never be
/// read stale, so there is no offline cache; the planning screen's agenda
/// idiom, without its day-picker chrome.
class ChangeCalendarScreen extends ConsumerWidget {
  const ChangeCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final events = ref.watch(changeCalendarProvider);

    return CapabilityGate(
      plugin: Cap.change,
      feature: Cap.changeCalendar,
      title: l.changeCalendarTitle,
      child: Scaffold(
        appBar: AppBar(title: Text(l.changeCalendarTitle)),
        body: AccessibleRefresh(
          onRefresh: () async => ref.refresh(changeCalendarProvider.future),
          // Cap the measure: full-width tablet rows strand the kind pill.
          child: ReadableWidth(
            child: switch (events) {
              AsyncData(:final value) when value.isEmpty => ListView(
                children: [
                  const SizedBox(height: 80),
                  Center(
                    child: Text(
                      l.changeCalendarEmpty,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
              AsyncData(:final value) => _Agenda(events: value),
              AsyncError() => ListView(
                children: [
                  const SizedBox(height: 80),
                  Center(child: Text(l.kedbNeedsConnection)),
                ],
              ),
              _ => const Center(
                child: CircularProgressIndicator(semanticsLabel: 'Loading'),
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _Agenda extends StatelessWidget {
  const _Agenda({required this.events});

  final List<ChangeCalendarEventDto> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = [...events]
      ..sort(
        (a, b) =>
            (a.start ?? DateTime(2100)).compareTo(b.start ?? DateTime(2100)),
      );
    // Group by start day; multi-day entries appear at their start with their
    // full window spelled out on the tile.
    final byDay = <DateTime, List<ChangeCalendarEventDto>>{};
    for (final e in sorted) {
      final s = e.start;
      final day = s == null ? DateTime(2100) : DateTime(s.year, s.month, s.day);
      byDay.putIfAbsent(day, () => []).add(e);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (final entry in byDay.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Semantics(
              header: true,
              child: Text(
                formatDateTime(entry.key).split(',').first,
                style: theme.textTheme.labelLarge,
              ),
            ),
          ),
          for (final e in entry.value) _EventTile(event: e),
        ],
      ],
    );
  }
}

class _EventTile extends ConsumerWidget {
  const _EventTile({required this.event});

  final ChangeCalendarEventDto event;

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    if (event.type == ChangeCalendarEventDto.kindChange) {
      // Changes open in the app's own ITIL detail, cached like any other.
      final repo = ref.read(ticketRepositoryProvider);
      if (repo == null) return;
      final localId = await repo.openByServerId(event.id, itemtype: itilChange);
      if (localId == null || !context.mounted) return;
      await context.push(Routes.ticket(localId));
      return;
    }
    // Releases and freezes have no app detail; show what the feed carries.
    final l = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Text(
          '${formatDateTime(event.start)} → ${formatDateTime(event.end)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (icon, typeLabel, accent) = switch (event.type) {
      ChangeCalendarEventDto.kindFreeze => (
        Icons.ac_unit,
        l.changeFreeze,
        scheme.error,
      ),
      ChangeCalendarEventDto.kindRelease => (
        Icons.rocket_launch_outlined,
        l.changeRelease,
        scheme.tertiary,
      ),
      _ => (
        Icons.published_with_changes_outlined,
        l.changeTypeChange,
        scheme.primary,
      ),
    };
    final badge = switch (event.type) {
      ChangeCalendarEventDto.kindFreeze => event.severity ?? '',
      ChangeCalendarEventDto.kindRelease => event.releaseState ?? '',
      _ =>
        event.changeStatus == null
            ? ''
            : statusLabel(event.changeStatus!, itemtype: itilChange),
    };

    return ListTile(
      leading: Icon(icon, color: accent),
      title: Text(event.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '$typeLabel · ${formatDateTime(event.start)} → '
        '${formatDateTime(event.end)}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: badge.isEmpty
          ? null
          : AccentPill(
              label: badge,
              accent: accent,
              semanticsLabel: '$typeLabel: $badge',
            ),
      onTap: () => _open(context, ref),
    );
  }
}
