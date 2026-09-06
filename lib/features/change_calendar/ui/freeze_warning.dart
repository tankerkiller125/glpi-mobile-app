import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../change_providers.dart';

/// A warning chip shown when a picked date range falls inside an active
/// change freeze — informing, never blocking, exactly like the plugin's web
/// side. Renders nothing when the server lacks `glpichange.freezes` (the
/// provider answers an empty list then), when nothing overlaps, or while the
/// freeze list is still loading.
class FreezeWarning extends ConsumerWidget {
  const FreezeWarning({super.key, required this.begin, this.end});

  final DateTime? begin;
  final DateTime? end;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final from = begin;
    if (from == null) return const SizedBox.shrink();
    final to = (end == null || end!.isBefore(from)) ? from : end!;
    final freezes = ref.watch(activeFreezesProvider).value ?? const [];
    final hit = freezes.where((f) => f.overlaps(from, to)).firstOrNull;
    if (hit == null) return const SizedBox.shrink();

    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        width: double.infinity,
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
                l.changeFreezeWarning(hit.title),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
