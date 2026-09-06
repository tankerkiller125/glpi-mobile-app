import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/dto/major_dto.dart';
import '../../core/providers.dart';

/// Open major incidents. Read-through only — a major incident's state is the
/// one thing that must never be shown stale.
final majorIncidentsProvider = FutureProvider<List<MajorIncidentDto>>((
  ref,
) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return const [];
  return api.listMajorIncidents();
});

/// One incident with its comms log. Null while signed out.
final majorIncidentDetailProvider =
    FutureProvider.family<MajorIncidentDetailDto?, int>((ref, id) async {
      final api = ref.watch(glpiApiProvider);
      if (api == null) return null;
      return api.getMajorIncident(id);
    });

/// A ticket's major-incident binding (keyed by the ticket's *server* id):
/// drives the banner on ticket detail and the declare/attach offers.
final majorTicketInfoProvider = FutureProvider.family<MajorTicketInfoDto, int>((
  ref,
  ticketsId,
) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return MajorTicketInfoDto.none;
  return api.getMajorForTicket(ticketsId);
});
