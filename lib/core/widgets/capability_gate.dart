import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../providers.dart';

/// Renders [child] only when the server advertises `plugin.feature`.
///
/// Routes for optional modules stay registered so push routes and deep links
/// always resolve; a screen reached without its capability shows a graceful
/// "not available on this server" scaffold instead of crashing or 404ing.
/// While the capability map is still loading (first launch, nothing cached
/// yet) it shows a spinner rather than a premature "unavailable".
class CapabilityGate extends ConsumerWidget {
  const CapabilityGate({
    super.key,
    required this.plugin,
    required this.feature,
    required this.title,
    required this.child,
  });

  /// Plugin directory name (`glpisignal`) and feature flag (`alerts`).
  final String plugin;
  final String feature;

  /// App-bar title for the placeholder scaffolds, so the user still sees
  /// which module they tried to open.
  final String title;

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final caps = ref.watch(capabilitiesProvider);
    // `.value` keeps the previous map during a refresh, so an invalidate on
    // app resume never flashes the module away.
    final known = caps.value;
    if (known == null) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading'),
        ),
      );
    }
    if (!known.has(plugin, feature)) {
      final theme = Theme.of(context);
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.extension_off_outlined,
                  size: 48,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  l.capabilityUnavailableTitle,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l.capabilityUnavailableBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return child;
  }
}
