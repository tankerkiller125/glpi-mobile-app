import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/dto/signal_dto.dart';
import '../../core/providers.dart';

/// The alert list's server-side filter: which states, one optional severity.
typedef AlertQuery = ({Set<String> states, AlertSeverity? severity});

class AlertFilter extends Notifier<AlertQuery> {
  @override
  // Every live state by default — on instances where escalation cuts tickets
  // immediately, most live alerts sit in `ticketed`, and a triage view that
  // hid them would read as "all quiet" during an outage.
  AlertQuery build() =>
      (states: {'open', 'acked', 'ticketed', 'suppressed'}, severity: null);

  /// Toggle one state chip. The last remaining state can't be removed — an
  /// empty filter would silently mean "server default", which reads as a bug.
  void toggleState(String s) {
    final next = {...state.states};
    if (!next.remove(s)) next.add(s);
    if (next.isEmpty) return;
    state = (states: next, severity: state.severity);
  }

  /// Select one severity, or null for all. Tapping the active chip clears it.
  void setSeverity(AlertSeverity? severity) {
    state = (
      states: state.states,
      severity: severity == state.severity ? null : severity,
    );
  }
}

final alertFilterProvider = NotifierProvider<AlertFilter, AlertQuery>(
  AlertFilter.new,
);

/// The filtered alert list. Read-through only — alerts are live escalation
/// state, so a stale cache would be worse than an empty list.
final alertsProvider = FutureProvider<List<AlertDto>>((ref) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return const [];
  final filter = ref.watch(alertFilterProvider);
  return api.listAlerts(
    state: (filter.states.toList()..sort()).join(','),
    severity: filter.severity?.wire,
  );
});

/// One alert with its page log. Null while signed out.
final alertDetailProvider = FutureProvider.family<AlertDetailDto?, int>((
  ref,
  id,
) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return null;
  return api.getAlert(id);
});

/// Every on-call rota visible to this user.
final oncallProvider = FutureProvider<List<OncallRotaDto>>((ref) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return const [];
  return api.listOncallRotas();
});
