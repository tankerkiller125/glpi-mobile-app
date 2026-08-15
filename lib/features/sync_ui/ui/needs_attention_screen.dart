import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/a11y/a11y.dart';
import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/sync/outbox_op.dart';
import '../../../core/utils/formatting.dart';
import '../../../l10n/generated/app_localizations.dart';

class NeedsAttentionScreen extends ConsumerWidget {
  const NeedsAttentionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final ops = ref.watch(needsAttentionProvider).value ?? const [];
    final sync = ref.read(syncServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.syncTitle),
        actions: [
          if (ops.isNotEmpty)
            TextButton(
              onPressed: () => sync?.retryAll(),
              child: const Text('Retry all'),
            ),
        ],
      ),
      body: ops.isEmpty
          ? _Empty(label: l.syncEmpty)
          : ListView.separated(
              itemCount: ops.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) => _OpTile(op: ops[i]),
            ),
    );
  }
}

class _OpTile extends ConsumerWidget {
  const _OpTile({required this.op});

  final PendingOp op;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sync = ref.read(syncServiceProvider);
    final what = describeOp(op.opType, op.ticketServerId);
    return ListTile(
      leading: const Icon(Icons.sync_problem_outlined),
      title: Text(what),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (op.lastError != null)
            Text(
              op.lastError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          Text(
            'Attempt ${op.attempts} · '
            '${spokenAge(DateTime.tryParse(op.createdAt))}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            // Every row has the same two buttons; the tooltip is what tells
            // them apart once you can't see which row you are on.
            tooltip: 'Retry: $what',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              sync?.retryOp(op.id);
              announce(context, 'Retrying $what');
            },
          ),
          IconButton(
            tooltip: 'Discard: $what',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Discard change?'),
                  content: Text(
                    'This ${describeOp(op.opType, op.ticketServerId).toLowerCase()} '
                    'will be permanently discarded.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Discard'),
                    ),
                  ],
                ),
              );
              if (ok != true) return;
              await sync?.discardOp(op.id);
              // The row simply vanishes; nothing else confirms it.
              if (context.mounted) announce(context, 'Discarded $what');
            },
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_done_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
