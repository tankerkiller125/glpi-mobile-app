import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/dto/entitle_dto.dart';
import '../../core/providers.dart';

/// The entitlement answer for an entity, keyed by GLPI entity id. The server
/// runs the cache-or-fetch and the degrade rules (`fresh`/`stale`/`silent`);
/// the app renders the envelope verbatim. Errors read as null — the card
/// section shows nothing rather than an error on a ticket, mirroring the web
/// card's own "never clutter" rule.
final entitlementProvider = FutureProvider.family<EntitlementDto?, int>((
  ref,
  entitiesId,
) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return null;
  try {
    return await api.getEntitlement(entitiesId);
  } on Exception {
    return null;
  }
});
