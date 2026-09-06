import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/dto/major_dto.dart';
import '../../../core/models/capabilities.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/accent_pill.dart';
import '../../../core/widgets/accessible_refresh.dart';
import '../../../core/widgets/capability_gate.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../major_providers.dart';

/// The word for an incident state, localized. Unknown states (a newer plugin)
/// show as-is rather than hiding the incident.
String majorStateLabel(AppLocalizations l, String state) => switch (state) {
  'open' => l.majorStateOpen,
  'investigating' => l.majorStateInvestigating,
  'identified' => l.majorStateIdentified,
  'monitoring' => l.majorStateMonitoring,
  'resolved' => l.majorStateResolved,
  'closed' => l.majorStateClosed,
  _ => state,
};

/// Open major incidents from the glpi-major plugin, newest first.
class MajorScreen extends ConsumerWidget {
  const MajorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final async = ref.watch(majorIncidentsProvider);

    return CapabilityGate(
      plugin: Cap.major,
      feature: Cap.majorView,
      title: l.majorTitle,
      child: Scaffold(
        appBar: AppBar(title: Text(l.majorTitle)),
        body: AccessibleRefresh(
          onRefresh: () async => ref.invalidate(majorIncidentsProvider),
          // Cap the measure: a full-width tablet row strands the state pill.
          child: ReadableWidth(
            child: switch (async) {
              AsyncData(:final value) when value.isEmpty => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        l.majorEmpty,
                        style: TextStyle(color: theme.colorScheme.outline),
                      ),
                    ),
                  ),
                ],
              ),
              AsyncData(:final value) => ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: value.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) => _IncidentTile(incident: value[i]),
              ),
              AsyncError() => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text(l.genericError)),
                  ),
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

class _IncidentTile extends StatelessWidget {
  const _IncidentTile({required this.incident});

  final MajorIncidentDto incident;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final declared = parseGlpiDateTime(incident.declaredAt);
    final nextUpdate = parseGlpiDateTime(incident.nextUpdateAt);

    return ListTile(
      leading: Icon(
        Icons.warning_amber_outlined,
        color: incident.isOpen
            ? theme.colorScheme.error
            : theme.colorScheme.outline,
      ),
      title: Text(incident.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          if (incident.commanderName != null) incident.commanderName!,
          if (declared != null) relativeAge(declared),
          if (incident.isOpen && nextUpdate != null)
            '${l.majorNextUpdate}: ${formatDueRelative(nextUpdate)}',
        ].join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: AccentPill(
        label: majorStateLabel(l, incident.state),
        accent: incident.isOpen
            ? theme.colorScheme.error
            : theme.colorScheme.outline,
      ),
      onTap: () => context.push(Routes.majorIncident(incident.id)),
    );
  }
}
