import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/utils/layout.dart';

/// Picks an ITIL category from the cached dropdown list, with a filter box.
/// Returns the chosen (id, name), or null.
class CategoryPicker extends ConsumerStatefulWidget {
  const CategoryPicker({super.key, required this.current});

  final int? current;

  static Future<(int, String)?> show(BuildContext context, int? current) =>
      showModalBottomSheet<(int, String)>(
        context: context,
        constraints: sheetConstraints(context),
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => CategoryPicker(current: current),
      );

  @override
  ConsumerState<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends ConsumerState<CategoryPicker> {
  String _filter = '';

  @override
  void initState() {
    super.initState();
    // Re-pull categories on open so newly-added GLPI categories (and sub-
    // categories) appear without an app restart. Cached list shows meanwhile.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(referenceRepositoryProvider)?.refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(categoriesProvider).value ?? const <DropdownItem>[];
    final q = _filter.trim().toLowerCase();
    final items = q.isEmpty
        ? all
        : all.where((c) => c.name.toLowerCase().contains(q)).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    hintText: 'Filter…',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => _filter = v),
                ),
              ),
              if (all.isEmpty)
                const Expanded(
                  child: Center(child: Text('No cached categories')),
                )
              else
                Expanded(
                  child: ListView(
                    children: [
                      for (final c in items)
                        ListTile(
                          leading: const Icon(Icons.folder_outlined),
                          title: Text(c.name),
                          // Announces "selected"; the tick alone doesn't.
                          selected: c.serverId == widget.current,
                          trailing: c.serverId == widget.current
                              ? const Icon(Icons.check, size: 18)
                              : null,
                          onTap: () =>
                              Navigator.pop(context, (c.serverId, c.name)),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
