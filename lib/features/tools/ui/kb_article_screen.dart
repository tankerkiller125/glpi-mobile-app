import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/utils/html_text.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/rich_content.dart';
import '../../ticket/ui/compose_sheet.dart';

/// Read a knowledge base article. When opened from a ticket/change/problem, a
/// bottom action bar offers to reuse it as a reply or a solution — the point of
/// having the KB on a phone at all.
class KbArticleScreen extends ConsumerStatefulWidget {
  const KbArticleScreen({
    super.key,
    required this.articleId,
    this.sourceTicketLocalId,
  });

  final int articleId;
  final String? sourceTicketLocalId;

  @override
  ConsumerState<KbArticleScreen> createState() => _KbArticleScreenState();
}

class _KbArticleScreenState extends ConsumerState<KbArticleScreen> {
  bool _loadedOnce = false;

  @override
  Widget build(BuildContext context) {
    if (!_loadedOnce) {
      _loadedOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(toolsRepositoryProvider)?.loadArticle(widget.articleId);
      });
    }
    final theme = Theme.of(context);
    final article = ref.watch(kbArticleProvider(widget.articleId)).value;
    final comments =
        ref.watch(kbCommentsProvider(widget.articleId)).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        actions: [
          if (article != null)
            IconButton(
              tooltip: 'Keep offline',
              icon: const Icon(Icons.bookmark_outline),
              onPressed: () async {
                await ref
                    .read(toolsRepositoryProvider)
                    ?.setKeepOffline(widget.articleId, true);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved for offline reading')),
                  );
                }
              },
            ),
        ],
      ),
      // A knowledge-base article read across a full tablet width is a wall of
      // text; cap the measure.
      body: article == null
          ? const Center(child: CircularProgressIndicator())
          : ReadableWidth(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Text(article.name, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (article.isFaq) ...[
                        Icon(
                          Icons.star,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text('FAQ', style: theme.textTheme.bodySmall),
                        const SizedBox(width: 10),
                      ],
                      if ((article.categoryName ?? '').isNotEmpty)
                        Expanded(
                          child: Text(
                            article.categoryName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RichContent(
                    article.content,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  Text('Comments', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  if (comments.isEmpty)
                    Text(
                      'No comments',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    )
                  else
                    for (final c in comments)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${c.authorName} · '
                              '${relativeAge(DateTime.tryParse(c.dateCreation ?? ''))}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            RichContent(c.comment, selectable: false),
                          ],
                        ),
                      ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _addComment(context),
                    icon: const Icon(Icons.add_comment_outlined, size: 18),
                    label: const Text('Add a comment'),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: widget.sourceTicketLocalId == null || article == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _use(context, asSolution: false),
                        icon: const Icon(Icons.reply, size: 18),
                        label: const Text('Add as reply'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _use(context, asSolution: true),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Use as solution'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _addComment(BuildContext context) async {
    final text = await ComposeSheet.show(
      context,
      title: 'Add a comment',
      hint: 'Your comment…',
      submitLabel: 'Post',
      rich: true,
    );
    if (text == null || text.trim().isEmpty) return;
    await ref
        .read(ticketActionsProvider)
        ?.addKbComment(widget.articleId, text.trim());
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Comment queued')));
    }
  }

  /// Push the article body back to the ITIL object it was opened from, and
  /// record the KB↔object link so GLPI knows the article was used.
  Future<void> _use(BuildContext context, {required bool asSolution}) async {
    final article = ref.read(kbArticleProvider(widget.articleId)).value;
    final localId = widget.sourceTicketLocalId;
    final actions = ref.read(ticketActionsProvider);
    if (article == null || localId == null || actions == null) return;
    final detail = ref.read(ticketDetailProvider(localId)).value;
    if (detail == null) return;

    final body = sanitizeGlpiHtml(article.content);
    if (asSolution) {
      await actions.addSolution(detail, body);
    } else {
      await actions.addFollowup(detail, content: body, isPrivate: false);
    }
    // Link the article to the object (plugin links endpoint).
    await actions.addLink(
      detail,
      targetItemtype: 'KnowbaseItem',
      targetId: article.id,
      targetName: article.name,
    );
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          asSolution ? 'Solution queued from article' : 'Reply queued',
        ),
      ),
    );
  }
}

/// GLPI article bodies are HTML; present them as readable plain text.
