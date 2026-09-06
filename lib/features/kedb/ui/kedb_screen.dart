import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/capabilities.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/capability_gate.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../kedb_providers.dart';

/// The known-error library: entity-scoped search over title and symptom,
/// modeled on the KB browser. When opened from a ticket ([sourceTicketLocalId]
/// set), the detail view carries that context so "Use workaround" can act on
/// the ticket. Server-side only — the KEDB has no offline shelf; a known
/// error is exactly the kind of record that must never be read stale.
/// The word for a known-error lifecycle status, localized. The server's
/// vocabulary (KnownError::statuses): known / workaround_available /
/// fix_in_progress / resolved_retired; unknowns pass through raw.
String kedbStatusLabel(AppLocalizations l, String status) => switch (status) {
  'known' => l.kedbStatusKnown,
  'workaround_available' => l.kedbHasWorkaround,
  'fix_in_progress' => l.kedbStatusFixInProgress,
  'resolved_retired' => l.kedbStatusRetired,
  _ => status,
};

class KedbScreen extends ConsumerStatefulWidget {
  const KedbScreen({super.key, this.sourceTicketLocalId});

  final String? sourceTicketLocalId;

  @override
  ConsumerState<KedbScreen> createState() => _KedbScreenState();
}

class _KedbScreenState extends ConsumerState<KedbScreen> {
  final _search = TextEditingController();
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onQueryChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => setState(() => _query = v),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return CapabilityGate(
      plugin: Cap.kedb,
      feature: Cap.kedbSearch,
      title: l.kedbTitle,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.kedbTitle),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(
              MediaQuery.textScalerOf(context).scale(64).clamp(64.0, 130.0),
            ),
            child: ReadableWidth(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: l.kedbSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: const OutlineInputBorder(),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l.kedbClearSearch,
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                  onChanged: _onQueryChanged,
                ),
              ),
            ),
          ),
        ),
        // Same measure cap as the search bar above and the KE detail page.
        body: ReadableWidth(
          child: switch (ref.watch(kedbSearchProvider(_query))) {
            AsyncData(:final value) when value.isEmpty => Center(
              child: Text(
                _query.isEmpty ? l.kedbEmpty : l.kedbNoMatches,
                style: TextStyle(color: theme.colorScheme.outline),
              ),
            ),
            AsyncData(:final value) => ListView.separated(
              itemCount: value.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final row = value[i];
                return ListTile(
                  leading: Icon(
                    row.hasWorkaround
                        ? Icons.healing_outlined
                        : Icons.report_problem_outlined,
                    color: row.hasWorkaround ? theme.colorScheme.primary : null,
                  ),
                  title: Text(
                    row.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    [
                      if (row.status.isNotEmpty) kedbStatusLabel(l, row.status),
                      // The workaround marker adds nothing when the status
                      // already says exactly that.
                      if (row.hasWorkaround &&
                          row.status != 'workaround_available')
                        l.kedbHasWorkaround,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => context.push(
                    Uri(
                      path: Routes.knownError(row.id),
                      queryParameters: widget.sourceTicketLocalId == null
                          ? null
                          : {'source': widget.sourceTicketLocalId},
                    ).toString(),
                  ),
                );
              },
            ),
            AsyncError() => Center(child: Text(l.kedbNeedsConnection)),
            _ => const Center(
              child: CircularProgressIndicator(semanticsLabel: 'Loading'),
            ),
          },
        ),
      ),
    );
  }
}
