import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/dto/tools_dto.dart';
import '../../../core/providers.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/accessible_refresh.dart';

/// RSS feeds configured in GLPI. The app lists them and hands the URL off —
/// it deliberately doesn't parse feed items (that's a desktop reading task).
class RssScreen extends ConsumerWidget {
  const RssScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feeds = ref.watch(rssFeedsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('RSS feeds')),
      body: AccessibleRefresh(
        onRefresh: () async => ref.invalidate(rssFeedsProvider),
        child: switch (feeds) {
          AsyncData(:final value) when value.isEmpty => ListView(
            children: [
              const SizedBox(height: 100),
              Center(
                child: Text(
                  'No RSS feeds',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
          AsyncData(:final value) => ListView.separated(
            itemCount: value.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) => _FeedTile(feed: value[i]),
          ),
          AsyncError() => ListView(
            children: const [
              SizedBox(height: 100),
              Center(child: Text('RSS feeds need a connection')),
            ],
          ),
          _ => const Center(
            child: CircularProgressIndicator(semanticsLabel: 'Loading'),
          ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _add(context, ref),
        tooltip: 'Add feed',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final url = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      constraints: sheetConstraints(context),
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                'New RSS feed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: name,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: url,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Feed URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || name.text.trim().isEmpty) return;
    await ref
        .read(ticketActionsProvider)
        ?.createRssFeed(name: name.text.trim(), url: url.text.trim());
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Feed queued')));
    }
  }
}

class _FeedTile extends ConsumerWidget {
  const _FeedTile({required this.feed});

  final RssFeedDto feed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final host = Uri.tryParse(feed.url)?.host ?? feed.url;
    return ListTile(
      leading: const Icon(Icons.rss_feed),
      title: Text(feed.name),
      subtitle: Text(host, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: PopupMenuButton<String>(
        tooltip: 'Actions for ${feed.name}',
        onSelected: (v) async {
          if (v == 'copy') {
            await Clipboard.setData(ClipboardData(text: feed.url));
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Feed URL copied')));
            }
          } else if (v == 'delete') {
            await ref.read(ticketActionsProvider)?.deleteRssFeed(feed.id);
            if (context.mounted) ref.invalidate(rssFeedsProvider);
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'copy', child: Text('Copy URL')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      // No in-app browser dependency: copying the URL is the honest action.
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: feed.url));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feed URL copied to clipboard')),
          );
        }
      },
    );
  }
}
