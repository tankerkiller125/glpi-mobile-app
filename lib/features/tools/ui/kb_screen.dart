import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/dto/tools_dto.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/utils/layout.dart';

/// Knowledge base browser: server search with a local-cache fallback, FAQ and
/// category filters, plus an offline shelf of everything already read.
///
/// When opened from a ticket ([initialQuery] set), results carry that context
/// so the reader can offer "use as solution" / "add as reply".
class KbScreen extends ConsumerStatefulWidget {
  const KbScreen({super.key, this.initialQuery, this.sourceTicketLocalId});

  final String? initialQuery;

  /// Set when reached from an ITIL object, enabling the "use this" actions.
  final String? sourceTicketLocalId;

  @override
  ConsumerState<KbScreen> createState() => _KbScreenState();
}

class _KbScreenState extends ConsumerState<KbScreen> {
  late final _search = TextEditingController(text: widget.initialQuery ?? '');
  late String _query = widget.initialQuery ?? '';
  bool _faqOnly = false;
  int? _categoryId;
  bool _offlineShelf = false;
  Timer? _debounce;
  bool _loadedOnce = false;

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
    if (!_loadedOnce) {
      _loadedOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await ref.read(toolsRepositoryProvider)?.refreshCategories();
        } on Exception {
          // Categories are a nicety; search still works without them.
        }
      });
    }
    final theme = Theme.of(context);
    final categories = ref.watch(kbCategoriesProvider).value ?? const [];
    final selectedCategory = categories
        .where((c) => c.id == _categoryId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge base'),
        bottom: PreferredSize(
          // The search field and the chip row both grow with the user's font
          // scale; a fixed 108 clips them into a striped overflow at 200%.
          preferredSize: Size.fromHeight(
            MediaQuery.textScalerOf(context).scale(108).clamp(108.0, 220.0),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _search,
                  autofocus: widget.initialQuery != null,
                  decoration: InputDecoration(
                    hintText: 'Search articles…',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: const OutlineInputBorder(),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                          ),
                  ),
                  onChanged: _onQueryChanged,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: MediaQuery.textScalerOf(
                    context,
                  ).scale(34).clamp(34.0, 80.0),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      FilterChip(
                        label: const Text('FAQ'),
                        selected: _faqOnly,
                        onSelected: (v) => setState(() => _faqOnly = v),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text(
                          selectedCategory?.completename ?? 'Category',
                        ),
                        selected: _categoryId != null,
                        onSelected: (_) => _pickCategory(categories),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        avatar: const Icon(Icons.download_done, size: 16),
                        label: const Text('Saved'),
                        selected: _offlineShelf,
                        onSelected: (v) => setState(() => _offlineShelf = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _offlineShelf ? _buildCached() : _buildSearch(theme),
    );
  }

  Widget _buildCached() {
    final cached = ref.watch(kbCachedProvider).value ?? const [];
    if (cached.isEmpty) {
      return const Center(child: Text('No articles saved yet'));
    }
    return ListView.separated(
      itemCount: cached.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) =>
          _ArticleTile(article: cached[i], source: widget.sourceTicketLocalId),
    );
  }

  Widget _buildSearch(ThemeData theme) {
    final results = ref.watch(
      kbSearchProvider((
        text: _query,
        faqOnly: _faqOnly,
        categoryId: _categoryId,
      )),
    );
    return switch (results) {
      AsyncData(:final value) when value.isEmpty => Center(
        child: Text(
          _query.isEmpty ? 'No articles' : 'No matches',
          style: TextStyle(color: theme.colorScheme.outline),
        ),
      ),
      AsyncData(:final value) => ListView.separated(
        itemCount: value.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) =>
            _ArticleTile(article: value[i], source: widget.sourceTicketLocalId),
      ),
      AsyncError() => const Center(child: Text('Search needs a connection')),
      _ => const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Loading'),
      ),
    };
  }

  Future<void> _pickCategory(List<KbCategoryDto> categories) async {
    final picked = await showModalBottomSheet<int?>(
      context: context,
      constraints: sheetConstraints(context),
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('All categories'),
              onTap: () => Navigator.pop(context, -1),
            ),
            for (final c in categories)
              ListTile(
                dense: true,
                title: Text(c.completename),
                onTap: () => Navigator.pop(context, c.id),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    setState(() => _categoryId = picked == -1 ? null : picked);
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.article, this.source});

  final KbArticleDto article;
  final String? source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        article.isFaq ? Icons.star : Icons.article_outlined,
        color: article.isFaq ? theme.colorScheme.primary : null,
      ),
      title: Text(article.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          if ((article.categoryName ?? '').isNotEmpty) article.categoryName!,
          if (article.dateMod != null)
            'updated ${relativeAge(DateTime.tryParse(article.dateMod!))}',
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => context.push(
        Uri(
          path: Routes.kbArticle(article.id),
          queryParameters: source == null ? null : {'source': source},
        ).toString(),
      ),
    );
  }
}
