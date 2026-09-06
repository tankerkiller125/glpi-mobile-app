import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/dto/change_dto.dart';
import '../../../core/api/itil_type.dart';
import '../../../core/models/capabilities.dart';
import '../../../core/models/ticket_detail.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/widgets/section_heading.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../change_providers.dart';

/// The "Schedule & risk" section on a Change: its window (with the source
/// that derived it), the freezes the window crosses, and the standing
/// collision warnings. Read-only — the informing half of glpi-change; the
/// web side is where windows get moved. Renders nothing when the object
/// isn't a synced Change or the server lacks `glpichange.schedule` — the
/// conditional-section pattern from [AnalysisSection].
class ChangeScheduleSection extends ConsumerWidget {
  const ChangeScheduleSection({super.key, required this.item});

  final TicketDetail item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (item.itemtype != itilChange) return const SizedBox.shrink();
    final serverId = item.serverId;
    if (serverId == null) return const SizedBox.shrink();
    final caps = ref.watch(capabilitiesProvider).value ?? Capabilities.empty;
    if (!caps.has(Cap.change, Cap.changeSchedule)) {
      return const SizedBox.shrink();
    }

    final sched = ref.watch(changeScheduleProvider(serverId)).value;
    if (sched == null) return const SizedBox.shrink();

    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(l.changeScheduleTitle),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.event_outlined, size: 18, color: scheme.outline),
              const SizedBox(width: 8),
              Expanded(
                child: sched.hasWindow
                    ? Text(
                        '${formatDateTime(sched.windowBegin)} → '
                        '${formatDateTime(sched.windowEnd)}'
                        '${sched.windowSourceLabel.isEmpty ? '' : ' · ${sched.windowSourceLabel}'}',
                        style: theme.textTheme.bodyMedium,
                      )
                    : Text(
                        l.changeWindowNone,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.outline,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),
            ],
          ),
          for (final freeze in sched.freezes) _FreezeRow(freeze: freeze),
          for (final collision in sched.collisions)
            _CollisionRow(collision: collision),
          if (sched.freezes.isEmpty && sched.collisions.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l.changeNoConflicts,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.outline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FreezeRow extends StatelessWidget {
  const _FreezeRow({required this.freeze});

  final FreezeDto freeze;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.ac_unit, size: 16, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${l.changeFreeze}: ${freeze.title} · '
              '${formatDateTime(freeze.begin)} → ${formatDateTime(freeze.end)}'
              '${freeze.reason.isEmpty ? '' : '\n${freeze.reason}'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollisionRow extends StatelessWidget {
  const _CollisionRow({required this.collision});

  final ChangeCollisionDto collision;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // A dismissed warning stays visible but reads as settled: hiding it
    // would make the mobile picture disagree with the web page.
    final muted = collision.isDismissed;
    final ink = muted ? scheme.outline : scheme.onSurface;
    // Localize the kind and prefer the other item's human name over a raw
    // itemtype class + id.
    final kindLabel = switch (collision.kind) {
      'freeze' => l.changeFreeze,
      'shared_ci' => l.changeCollisionSharedCi,
      'impact_ci' => l.changeCollisionImpactCi,
      final k => k,
    };
    final label = [
      kindLabel,
      collision.otherName ??
          (collision.otherItemsId > 0
              ? '${collision.otherItemtype} #${collision.otherItemsId}'
              : null),
    ].whereType<String>().join(' · ');
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            muted ? Icons.check_circle_outline : Icons.warning_amber_outlined,
            size: 16,
            color: muted ? scheme.outline : scheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              muted && collision.dismissReason.isNotEmpty
                  ? '$label — '
                        '${l.changeCollisionDismissed(collision.dismissReason)}'
                  : label,
              style: theme.textTheme.bodySmall?.copyWith(color: ink),
            ),
          ),
        ],
      ),
    );
  }
}
