import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/models/entity_node.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';

class ContextScreen extends ConsumerStatefulWidget {
  const ContextScreen({super.key});

  @override
  ConsumerState<ContextScreen> createState() => _ContextScreenState();
}

class _ContextScreenState extends ConsumerState<ContextScreen> {
  int? _profileId;
  int? _entityId;
  String? _entityName;
  bool _recursive = true;

  String? _labelFor(List<EntityNode> roots, int? id) {
    for (final (node, _) in EntityNode.flatten(roots)) {
      if (node.id == id) return node.label;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = ref.watch(authControllerProvider);
    if (auth is! NeedsContext) {
      // Router redirects momentarily; render nothing meanwhile.
      return const Scaffold(body: SizedBox.shrink());
    }
    final session = auth.session;
    final tree = ref.watch(entityTreeProvider);
    _profileId ??=
        session.activeProfileId ??
        (session.profiles.isNotEmpty ? session.profiles.first.id : null);

    return Scaffold(
      appBar: AppBar(title: Text(l.contextTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Semantics(
              header: true,
              child: Text(
                l.profileLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            RadioGroup<int>(
              groupValue: _profileId,
              onChanged: (v) => setState(() => _profileId = v),
              child: Column(
                children: [
                  for (final p in session.profiles)
                    RadioListTile<int>(title: Text(p.name), value: p.id),
                ],
              ),
            ),
            const Divider(height: 32),
            Semantics(
              header: true,
              child: Text(
                l.entityLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            switch (tree) {
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
                        title: Padding(
                          padding: EdgeInsets.only(left: depth * 16.0),
                          child: Text(node.label),
                        ),
                        value: node.id,
                      ),
                  ],
                ),
              ),
              AsyncError() => ListTile(
                leading: const Icon(Icons.error_outline),
                title: Text(l.genericError),
                trailing: TextButton(
                  onPressed: () => ref.invalidate(entityTreeProvider),
                  child: Text(l.retry),
                ),
              ),
              _ => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(semanticsLabel: 'Loading'),
                ),
              ),
            },
            SwitchListTile(
              title: Text(l.entityRecursive),
              value: _recursive,
              onChanged: (v) => setState(() => _recursive = v),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _profileId == null || _entityId == null
                  ? null
                  : () {
                      final profile = session.profiles.firstWhere(
                        (p) => p.id == _profileId,
                      );
                      ref
                          .read(authControllerProvider.notifier)
                          .pickContext(
                            profileId: profile.id,
                            profileName: profile.name,
                            entityId: _entityId!,
                            entityName: _entityName ?? '',
                            recursive: _recursive,
                          );
                    },
              child: Text(l.confirm),
            ),
          ],
        ),
      ),
    );
  }
}
