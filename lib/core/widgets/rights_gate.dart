import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../models/rights.dart';
import '../providers.dart';

/// Renders [child] only when the active GLPI profile is allowed to see it.
///
/// The drawer already hides what a profile can't open, so this is the second
/// lock: routes stay registered for push deep links and restored navigation
/// stacks, and a screen reached anyway — a notification about a ticket in a
/// module the profile lost since, a shared link — explains itself instead of
/// showing an empty list or a 403 snackbar.
///
/// While the rights map is still loading it shows a spinner rather than a
/// premature refusal; `.value` keeps the last-known map through a refresh, so
/// the resume-time refetch never flashes a screen away.
class RightsGate extends ConsumerWidget {
  const RightsGate({
    super.key,
    required this.allows,
    required this.title,
    required this.child,
  });

  /// The GLPI check this screen needs, e.g. `(r) => r.canViewProjects`.
  final bool Function(Rights) allows;

  /// App-bar title for the placeholder, so the user still sees which module
  /// they tried to open.
  final String title;

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rights = ref.watch(rightsProvider).value;
    if (rights == null) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading'),
        ),
      );
    }
    if (!allows(rights)) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const NotPermittedBody(),
      );
    }
    return child;
  }
}

/// The refusal itself, for screens that already have a Scaffold (the shell) —
/// a second one would draw a second app bar over the first.
class NotPermittedBody extends StatelessWidget {
  const NotPermittedBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(l.rightsUnavailableTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              l.rightsUnavailableBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
