import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/dto/form_dto.dart';
import '../../../core/api/itil_type.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/accessible_refresh.dart';
import '../../../core/widgets/glpi_illustration.dart';
import '../../../core/widgets/rights_gate.dart';

/// GLPI's Service Catalog, arranged the way the instance arranged it.
///
/// Tickets are filed through GLPI's own intake config rather than an
/// app-invented field set — and an instance that has organised that intake into
/// a category tree gets the tree here too. One screen per level: opening a
/// category pushes a route, so Back *is* the breadcrumb.
///
/// The two display decisions are the server's, not the app's:
///
///  - **Expand categories** (an entity setting, inherited like every other) —
///    on, a category is a section with its forms already under it; off, it is a
///    row you open. Deciding it here would mean a phone that disagrees with the
///    portal the same technician uses at a desk.
///  - **Order** — pinned first, then categories, then the entity's sort
///    strategy. The server sorts; the app renders in the order it was given and
///    never re-sorts.
class ServiceCatalogScreen extends ConsumerStatefulWidget {
  const ServiceCatalogScreen({super.key, this.categoryId = 0, this.title});

  /// 0 is the root of the tree.
  final int categoryId;

  /// The category's name, passed down so the app bar is right on the first
  /// frame instead of after the fetch.
  final String? title;

  @override
  ConsumerState<ServiceCatalogScreen> createState() =>
      _ServiceCatalogScreenState();
}

class _ServiceCatalogScreenState extends ConsumerState<ServiceCatalogScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _filter = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  /// Typing is not a request. Debounced because each keystroke would otherwise
  /// be a fuzzy match across every category on the server.
  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _filter = value.trim());
    });
  }

  ServiceCatalogQuery get _query =>
      (category: widget.categoryId, filter: _filter);

  @override
  Widget build(BuildContext context) {
    final page = ref.watch(serviceCatalogProvider(_query));

    // GLPI's own artwork for whatever this level draws, fetched in one request
    // and kept for the session. Deferred a frame: this runs during build, and
    // the cache notifies listeners when the icons land.
    final illustrations = page.value?.illustrationIds ?? const <String>[];
    if (illustrations.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(illustrationCacheProvider.notifier).ensure(illustrations);
      });
    }

    return RightsGate(
      allows: (r) => r.canCreateItil(itilTicket),
      title: 'New ticket',
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title ??
                page.value?.title.ifEmpty('New request') ??
                'New request',
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Semantics(
                label: 'Search the service catalog',
                textField: true,
                child: TextField(
                  controller: _search,
                  onChanged: _onSearch,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search forms…',
                    isDense: true,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear the search',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _search.clear();
                              _onSearch('');
                            },
                          ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: switch (page) {
          AsyncData(:final value) when value.isEmpty => _Empty(
            message: _filter.isNotEmpty
                ? 'Nothing in the catalog matches “$_filter”.'
                : null,
            onRetry: () => ref.invalidate(serviceCatalogProvider(_query)),
            // Nothing published at all — offer the plain ticket form rather than
            // leaving the technician at a dead end.
            onFallback: _filter.isEmpty && widget.categoryId == 0
                ? () => context.push(Routes.createTicket)
                : null,
          ),
          AsyncData(:final value) => AccessibleRefresh(
            onRefresh: () async =>
                ref.invalidate(serviceCatalogProvider(_query)),
            child: ReadableWidth(
              child: _CatalogList(page: value, searching: _filter.isNotEmpty),
            ),
          ),
          AsyncError() => _Empty(
            message:
                'Could not load the service catalog. Check your connection and '
                'try again.',
            onRetry: () => ref.invalidate(serviceCatalogProvider(_query)),
          ),
          _ => const Center(
            child: CircularProgressIndicator(semanticsLabel: 'Loading'),
          ),
        },
      ),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

/// One level, rendered.
class _CatalogList extends StatelessWidget {
  const _CatalogList({required this.page, required this.searching});

  final ServiceCatalogPageDto page;

  /// A search spans every category, so its results are shown flat — a section
  /// heading for a category the reader did not open would be a lie about where
  /// they are.
  final bool searching;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expand = page.expandCategories && !searching;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Where in the tree this is. The app bar has the current category; the
        // path above it is what says which "Access Requests" this is.
        if (page.ancestors.length > 1 && !searching)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              page.ancestors.map((a) => a.name).join(' › '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        for (final item in page.items)
          if (item.isCategory && expand)
            _CategorySection(category: item)
          else
            _CatalogTile(item: item),
        if (page.total > page.items.length)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Showing ${page.items.length} of ${page.total}. '
              'Search to narrow it down.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
      ],
    );
  }
}

/// A category with its forms under it — GLPI's *expand categories* setting.
class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category});

  final ServiceCatalogItemDto category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(category.name, style: theme.textTheme.titleMedium),
              ),
              if (category.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    category.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (category.children.isEmpty)
          // The server drops empty categories, so this only happens when every
          // child is a type this app does not know how to open.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Nothing here yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          )
        else
          for (final child in category.children) _CatalogTile(item: child),
      ],
    );
  }
}

/// One row: a form to fill in, a category to open, or an article to read.
class _CatalogTile extends StatelessWidget {
  const _CatalogTile({required this.item});

  final ServiceCatalogItemDto item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: SizedBox(
        width: 44,
        height: 44,
        child: GlpiIllustration(
          id: item.illustration,
          fallback: _icon(item),
          size: 44,
        ),
      ),
      title: Row(
        children: [
          Flexible(child: Text(item.name)),
          if (item.pinned)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(
                Icons.push_pin,
                size: 14,
                color: theme.colorScheme.outline,
              ),
            ),
        ],
      ),
      subtitle: item.description.isEmpty
          ? null
          : Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _open(context),
    );
  }

  void _open(BuildContext context) {
    switch (item.kind) {
      case ServiceCatalogItemKind.form:
        context.push(Routes.form(item.id));
      case ServiceCatalogItemKind.category:
        context.push(Routes.catalogCategory(item.id, item.name));
      case ServiceCatalogItemKind.kb:
        // The catalog lists knowledge articles beside the forms — "read this
        // before you file" is the whole point of them being there.
        context.push(Routes.kbArticle(item.id));
      case ServiceCatalogItemKind.unknown:
        break;
    }
  }

  /// GLPI's illustration slug, mapped to a rough icon. Unknown slugs — and
  /// every illustration a future GLPI ships — land on a generic one rather
  /// than on nothing.
  IconData _icon(ServiceCatalogItemDto item) {
    if (item.kind == ServiceCatalogItemKind.category) {
      return Icons.folder_outlined;
    }
    if (item.kind == ServiceCatalogItemKind.kb) {
      return Icons.menu_book_outlined;
    }
    final s = item.illustration.toLowerCase();
    if (s.contains('issue') || s.contains('incident')) {
      return Icons.report_problem_outlined;
    }
    if (s.contains('service') || s.contains('request')) {
      return Icons.support_agent_outlined;
    }
    if (s.contains('hardware') ||
        s.contains('device') ||
        s.contains('laptop')) {
      return Icons.devices_outlined;
    }
    if (s.contains('account') || s.contains('user') || s.contains('scim')) {
      return Icons.person_outline;
    }
    return Icons.assignment_outlined;
  }
}

class _Empty extends StatelessWidget {
  const _Empty({this.message, required this.onRetry, this.onFallback});

  final String? message;
  final VoidCallback onRetry;
  final VoidCallback? onFallback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              message ??
                  'No forms are published in the service catalog for your '
                      'account.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            if (onFallback != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onFallback,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Create a ticket directly'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
