import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/errors.dart';
import '../../../core/models/capabilities.dart';
import '../../../core/providers.dart';
import '../../../core/sync/connectivity.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/utils/html_text.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/capability_gate.dart';
import '../../../core/widgets/rich_content.dart';
import '../../../core/widgets/section_heading.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../kedb_providers.dart';

/// One known error in full: symptom, workaround, root cause, lifecycle and
/// linked records. When reached from a ticket ([sourceTicketLocalId] set) and
/// the server allows hit recording, a bottom bar offers "Use workaround" —
/// records the `used` hit, stages the snippet into that ticket's reply
/// composer, and returns there.
class KedbDetailScreen extends ConsumerWidget {
  const KedbDetailScreen({
    super.key,
    required this.keId,
    this.sourceTicketLocalId,
  });

  final int keId;
  final String? sourceTicketLocalId;

  Future<void> _useOnTicket(BuildContext context, WidgetRef ref) async {
    final api = ref.read(glpiApiProvider);
    final source = sourceTicketLocalId;
    if (api == null || source == null) return;
    final detail = ref.read(kedbDetailProvider(keId)).value;
    if (detail == null) return;
    final ticket = ref.read(ticketDetailProvider(source)).value;
    final ticketsId = ticket?.serverId;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (ticketsId == null) return;
    try {
      final result = await api.kedbRecordHit(
        keId: keId,
        ticketsId: ticketsId,
        action: 'used',
      );
      ref
          .read(pendingComposerTextProvider.notifier)
          .set(result.snippet ?? htmlToPlainText(detail.workaround));
      ref.read(kedbHandledProvider(ticketsId).notifier).hide(keId);
      messenger.showSnackBar(SnackBar(content: Text(l.kedbWorkaroundInserted)));
      navigator.pop(); // back to the ticket, where the composer is waiting
    } on GlpiError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final caps = ref.watch(capabilitiesProvider).value ?? Capabilities.empty;
    final online = ref.watch(connectivityProvider).value ?? true;
    final detailAsync = ref.watch(kedbDetailProvider(keId));
    final detail = detailAsync.value;

    return CapabilityGate(
      plugin: Cap.kedb,
      feature: Cap.kedbSearch,
      title: l.kedbTitle,
      child: Scaffold(
        appBar: AppBar(title: Text(l.kedbBanner)),
        body: switch (detailAsync) {
          AsyncError() => Center(child: Text(l.kedbNeedsConnection)),
          AsyncData(:final value) when value != null => ReadableWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Text(value.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 6),
                Text(
                  [
                    if (value.statusLabel.isNotEmpty) value.statusLabel,
                    if (value.dateIdentified != null)
                      '${l.kedbIdentified} '
                          '${relativeAge(parseGlpiDateTime(value.dateIdentified))}',
                    if (value.useCount > 0) l.kedbUseCount(value.useCount),
                  ].join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                if (value.symptom.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SectionHeading(l.kedbSymptom),
                  const SizedBox(height: 4),
                  RichContent(value.symptom),
                ],
                if (value.hasWorkaround) ...[
                  const SizedBox(height: 16),
                  SectionHeading(l.kedbWorkaround),
                  const SizedBox(height: 4),
                  RichContent(value.workaround),
                ],
                if (value.rootCause.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SectionHeading(l.kedbRootCause),
                  const SizedBox(height: 4),
                  RichContent(value.rootCause),
                ],
                if (value.software.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SectionHeading(l.kedbSoftware),
                  const SizedBox(height: 4),
                  Text(value.software.join(', ')),
                ],
                if (value.problemName != null) ...[
                  const SizedBox(height: 16),
                  SectionHeading(l.kedbProblem),
                  const SizedBox(height: 4),
                  Text(value.problemName!),
                ],
              ],
            ),
          ),
          _ => const Center(
            child: CircularProgressIndicator(semanticsLabel: 'Loading'),
          ),
        },
        bottomNavigationBar:
            sourceTicketLocalId == null ||
                detail == null ||
                !detail.hasWorkaround ||
                !caps.has(Cap.kedb, Cap.kedbHits)
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: FilledButton.icon(
                    onPressed: online ? () => _useOnTicket(context, ref) : null,
                    icon: const Icon(Icons.healing_outlined, size: 18),
                    label: Text(l.kedbUseWorkaround),
                  ),
                ),
              ),
      ),
    );
  }
}
