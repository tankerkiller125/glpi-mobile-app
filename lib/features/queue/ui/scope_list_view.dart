import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/ticket_list_item.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/two_pane.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../ticket/ui/ticket_detail_screen.dart';
import '../queue_providers.dart';
import 'ticket_card.dart';

/// Which ticket the two-pane layout is showing, per scope. Kept per scope so
/// moving between Mine / Groups / Unassigned doesn't show a ticket that isn't
/// in the list you are looking at.
final selectedTicketProvider =
    NotifierProvider<SelectedTicket, Map<QueueScope, String>>(
      SelectedTicket.new,
    );

class SelectedTicket extends Notifier<Map<QueueScope, String>> {
  @override
  Map<QueueScope, String> build() => const {};

  void select(QueueScope scope, String localId) =>
      state = {...state, scope: localId};
}

/// The ticket list for one queue scope (a bottom-nav destination in the
/// Assistance module). Reads the cached, filtered, reactive queue.
///
/// On a wide window the list keeps its place and the ticket opens beside it;
/// on a phone tapping a card pushes the detail as its own screen.
class ScopeListView extends ConsumerWidget {
  const ScopeListView({super.key, required this.scope});

  final QueueScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(scopedQueueProvider(scope));
    final twoPane = windowSizeOf(context).hasTwoPanes;

    Future<void> refresh() async {
      final repo = ref.read(ticketRepositoryProvider);
      if (repo == null) return;
      try {
        await repo.refreshQueue();
      } on Exception {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l.offlineBanner)));
        }
      }
    }

    final tickets = async.value ?? const <TicketListItem>[];
    // Fall back to the first ticket so the detail pane is never empty while
    // the list has something in it.
    final selected = twoPane
        ? (ref.watch(selectedTicketProvider)[scope] ??
              (tickets.isEmpty ? null : tickets.first.localId))
        : null;

    final list = RefreshIndicator(
      onRefresh: refresh,
      child: switch (async) {
        AsyncData(:final value) when value.isEmpty => _EmptyList(
          label: l.queueEmpty,
        ),
        AsyncData(:final value) => _TicketList(
          tickets: value,
          selectedLocalId: selected,
          onTap: (localId) {
            if (twoPane) {
              ref.read(selectedTicketProvider.notifier).select(scope, localId);
            } else {
              context.push(Routes.ticket(localId));
            }
          },
        ),
        AsyncError() => _EmptyList(label: l.genericError),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );

    if (!twoPane) return list;
    return TwoPane(
      // The new-ticket action follows the list, not the window: floating over
      // the detail pane it would sit on the reply box.
      start: Stack(
        children: [
          Positioned.fill(child: list),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: 'newTicketPane',
              onPressed: () => context.push(Routes.catalog),
              tooltip: 'New ticket',
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      end: selected == null
          // Not the list's "no tickets" message — this pane is empty for a
          // different reason, and saying so tells the user what to do.
          ? _EmptyList(
              icon: Icons.touch_app_outlined,
              label: tickets.isEmpty
                  ? l.queueEmpty
                  : 'Select a ticket to see it here',
            )
          : TicketDetailScreen(
              // Keyed so switching tickets rebuilds the detail state rather
              // than reusing the previous ticket's.
              key: ValueKey(selected),
              localId: selected,
              embedded: true,
            ),
    );
  }
}

class _TicketList extends StatelessWidget {
  const _TicketList({
    required this.tickets,
    required this.onTap,
    this.selectedLocalId,
  });

  final List<TicketListItem> tickets;
  final void Function(String localId) onTap;
  final String? selectedLocalId;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tickets.length,
      itemBuilder: (context, i) => TicketCard(
        ticket: tickets[i],
        selected: tickets[i].localId == selectedLocalId,
        onTap: () => onTap(tickets[i].localId),
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.label, this.icon = Icons.inbox_outlined});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 56,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 12),
                Text(label, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
