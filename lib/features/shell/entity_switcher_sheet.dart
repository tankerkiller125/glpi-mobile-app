import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/models/entity_node.dart';
import '../../core/providers.dart';
import '../../core/utils/layout.dart';
import '../../core/widgets/section_heading.dart';

/// Switch the working entity (and profile) without signing out.
///
/// GLPI scopes almost everything by entity — which tickets exist, which
/// categories and locations are offered, and, for writes, which entity a new
/// ticket is filed into. A technician covering several client entities needs to
/// move between them the way they do in the web UI.
///
/// Switching drops the caches that belonged to the old context and refetches;
/// work still queued in the outbox is kept and stays pinned to the entity it
/// was written in.
class EntitySwitcherSheet extends ConsumerStatefulWidget {
  const EntitySwitcherSheet({super.key});

  /// Returns true when the context actually changed.
  static Future<bool> show(BuildContext context) async =>
      await showModalBottomSheet<bool>(
        context: context,
        constraints: sheetConstraints(context),
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => const EntitySwitcherSheet(),
      ) ??
      false;

  @override
  ConsumerState<EntitySwitcherSheet> createState() =>
      _EntitySwitcherSheetState();
}

class _EntitySwitcherSheetState extends ConsumerState<EntitySwitcherSheet> {
  int? _entityId;
  String? _entityName;
  int? _profileId;
  bool? _recursive;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final account = switch (ref.watch(authControllerProvider)) {
      Ready(:final account) => account,
      _ => null,
    };
    if (account == null) return const SizedBox.shrink();

    _entityId ??= account.entityId;
    _entityName ??= account.entityName;
    _profileId ??= account.profileId;
    _recursive ??= account.entityRecursive;

    final tree = ref.watch(entityTreeProvider);
    final session = ref.watch(sessionInfoProvider).value;
    final profiles = session?.profiles ?? const [];

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Semantics(
                header: true,
                child: Text(
                  'Working context',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  // Only worth showing when there is a genuine choice.
                  if (profiles.length > 1) ...[
                    _header(theme, 'Profile'),
                    RadioGroup<int>(
                      groupValue: _profileId,
                      onChanged: (v) => setState(() {
                        _profileId = v;
                        // The allowed entities depend on the profile.
                        ref.invalidate(entityTreeProvider);
                      }),
                      child: Column(
                        children: [
                          for (final p in profiles)
                            RadioListTile<int>(
                              dense: true,
                              title: Text(p.name),
                              value: p.id,
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 16),
                  ],
                  _header(theme, 'Entity'),
                  switch (tree) {
                    AsyncData(:final value) when value.isEmpty => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No entities available'),
                    ),
                    AsyncData(:final value) => RadioGroup<int>(
                      groupValue: _entityId,
                      onChanged: (v) => setState(() {
                        _entityId = v;
                        _entityName = _labelFor(value, v);
                      }),
                      child: Column(
                        children: [
                          for (final (node, depth) in EntityNode.flatten(value))
                            RadioListTile<int>(
                              dense: true,
                              value: node.id,
                              title: Padding(
                                padding: EdgeInsets.only(left: depth * 16.0),
                                // The tree is expressed purely as indentation,
                                // which a screen reader cannot see; say the
                                // depth instead.
                                child: Semantics(
                                  label: depth == 0
                                      ? node.label
                                      : 'Level ${depth + 1}, ${node.label}',
                                  excludeSemantics: true,
                                  child: Text(node.label),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    AsyncError() => ListTile(
                      leading: const Icon(Icons.cloud_off),
                      title: const Text('Entities need a connection'),
                      trailing: TextButton(
                        onPressed: () => ref.invalidate(entityTreeProvider),
                        child: const Text('Retry'),
                      ),
                    ),
                    _ => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: CircularProgressIndicator(
                          semanticsLabel: 'Loading',
                        ),
                      ),
                    ),
                  },
                  SwitchListTile(
                    dense: true,
                    title: const Text('Include sub-entities'),
                    value: _recursive ?? true,
                    onChanged: (v) => setState(() => _recursive = v),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Cached tickets and reference data are reloaded for the new '
                    'entity. Anything still waiting to sync is kept, and is '
                    'filed in the entity it was written in.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _busy || _entityId == null ? null : _apply,
                    child: _busy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              semanticsLabel: 'Switching',
                            ),
                          )
                        : const Text('Switch'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(ThemeData theme, String text) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
    child: SectionHeading(text),
  );

  static String? _labelFor(List<EntityNode> roots, int? id) {
    for (final (node, _) in EntityNode.flatten(roots)) {
      if (node.id == id) return node.label;
    }
    return null;
  }

  Future<void> _apply() async {
    final account = switch (ref.read(authControllerProvider)) {
      Ready(:final account) => account,
      _ => null,
    };
    if (account == null) return;
    setState(() => _busy = true);

    final profiles = ref.read(sessionInfoProvider).value?.profiles ?? const [];
    final profileId = _profileId ?? account.profileId!;
    final profileName = profiles
        .where((p) => p.id == profileId)
        .map((p) => p.name)
        .firstOrNull;

    final changed = await ref
        .read(contextSwitcherProvider)
        .switchTo(
          profileId: profileId,
          profileName: profileName ?? account.profileName ?? '',
          entityId: _entityId!,
          entityName: _entityName ?? account.entityName ?? '',
          recursive: _recursive ?? true,
        );
    if (!mounted) return;
    Navigator.pop(context, changed);
  }
}
