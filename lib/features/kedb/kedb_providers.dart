import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/dto/kedb_dto.dart';
import '../../core/providers.dart';

/// The known-error offers for a ticket, keyed by the ticket's *server* id.
///
/// The server records a `shown` hit for every match it returns, so this is
/// deliberately a cached family: one fetch per ticket per session, however
/// often the detail screen rebuilds. Failures read as "no offers" — the
/// banner is a suggestion, never worth an error state on the ticket.
final kedbMatchesProvider = FutureProvider.family<List<KedbMatchDto>, int>((
  ref,
  ticketsId,
) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return const [];
  try {
    return await api.kedbMatchesForTicket(ticketsId);
  } on Exception {
    return const [];
  }
});

/// Matches the technician has dealt with this session (dismissed, or used —
/// an applied workaround has served its purpose), keyed by ticket server id.
/// Session-local on purpose: the server keeps the durable audit trail.
class KedbHandled extends Notifier<Set<int>> {
  KedbHandled(this.ticketsId);

  final int ticketsId;

  @override
  Set<int> build() => const {};

  void hide(int keId) => state = {...state, keId};
}

final kedbHandledProvider = NotifierProvider.family<KedbHandled, Set<int>, int>(
  KedbHandled.new,
);

/// KE library search (read-through; the library is server-side only).
final kedbSearchProvider = FutureProvider.family<List<KedbRowDto>, String>((
  ref,
  query,
) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return const [];
  return api.searchKnownErrors(query: query);
});

/// One KE in full, for the detail view.
final kedbDetailProvider = FutureProvider.family<KedbDetailDto?, int>((
  ref,
  id,
) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return null;
  return api.getKnownError(id);
});
