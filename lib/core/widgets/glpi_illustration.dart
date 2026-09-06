import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../providers.dart';

/// GLPI's own service-catalog artwork, drawn in the app.
///
/// The instance's illustrations are what a requester sees on the portal, so a
/// technician filing the same request from a phone should be looking at the
/// same pictures — a catalog that invents its own icons reads as a different
/// system, which for a list of *your own company's* request types is exactly
/// the wrong impression.
///
/// GLPI keeps them in one 1.8 MB SVG sprite referenced by fragment, which an
/// app cannot use; the companion plugin lifts out the symbols asked for. This
/// cache holds them for the session, keyed by id, so a list of ten forms
/// sharing three illustrations fetches three.
class IllustrationCache extends Notifier<Map<String, String>> {
  /// Ids already asked for, whether or not the server had them. Kept apart
  /// from the map so a miss is not re-requested on every rebuild — an id the
  /// server cannot draw would otherwise be a request per frame.
  final Set<String> _requested = {};

  @override
  Map<String, String> build() => const {};

  /// Fetch whatever in [ids] is not already known. Safe to call on every
  /// build: it is a no-op once the ids have been seen.
  Future<void> ensure(Iterable<String> ids) async {
    final wanted = <String>[
      for (final id in ids)
        if (id.isNotEmpty && !_requested.contains(id)) id,
    ];
    if (wanted.isEmpty) return;

    final api = ref.read(glpiApiProvider);
    if (api == null) return;

    _requested.addAll(wanted);
    final fetched = await api.fetchIllustrations(wanted);
    if (fetched.isEmpty) return;

    state = {...state, ...fetched};
  }
}

final illustrationCacheProvider =
    NotifierProvider<IllustrationCache, Map<String, String>>(
      IllustrationCache.new,
    );

/// One illustration, with a fallback for everything that can go wrong: no
/// illustration set, a server too old to serve them, an id it does not have,
/// or markup this renderer will not parse.
///
/// The fallback is not an error state — it is the app's own icon, which is
/// what every build before this one drew.
class GlpiIllustration extends ConsumerWidget {
  const GlpiIllustration({
    super.key,
    required this.id,
    required this.fallback,
    this.size = 40,
  });

  /// GLPI's illustration id (`report-issue`, or `custom:something.svg`).
  final String id;

  /// Drawn until — or instead of — the artwork.
  final IconData fallback;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final svg = ref.watch(illustrationCacheProvider)[id];

    if (svg == null) {
      return Icon(fallback, size: size * 0.6, color: theme.colorScheme.primary);
    }

    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      fit: BoxFit.contain,
      // The artwork carries its own palette — the same one the portal paints —
      // so it is deliberately not tinted to the app's theme.
      placeholderBuilder: (_) =>
          Icon(fallback, size: size * 0.6, color: theme.colorScheme.primary),
    );
  }
}
