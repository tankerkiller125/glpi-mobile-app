import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/dto/user_ref.dart';
import '../../../core/providers.dart';
import '../../../core/utils/layout.dart';

/// Live user search for adding an actor. Returns the chosen [UserRef], or null.
class UserPicker extends ConsumerStatefulWidget {
  const UserPicker({super.key, required this.title});

  final String title;

  static Future<UserRef?> show(BuildContext context, {required String title}) =>
      showModalBottomSheet<UserRef>(
        context: context,
        constraints: sheetConstraints(context),
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => UserPicker(title: title),
      );

  @override
  ConsumerState<UserPicker> createState() => _UserPickerState();
}

class _UserPickerState extends ConsumerState<UserPicker> {
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => setState(() => _query = v),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(userSearchProvider(_query));

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
                  decoration: InputDecoration(
                    labelText: widget.title,
                    hintText: 'Search users…',
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: _onChanged,
                ),
              ),
              Expanded(
                child: switch (results) {
                  AsyncData(:final value) when value.isEmpty => const Center(
                    child: Text('No matching users'),
                  ),
                  AsyncData(:final value) => ListView(
                    children: [
                      for (final u in value)
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(u.displayName),
                          subtitle: u.displayName == u.username
                              ? null
                              : Text(u.username),
                          onTap: () => Navigator.pop(context, u),
                        ),
                    ],
                  ),
                  AsyncError() => const Center(child: Text('Search failed')),
                  _ => const Center(child: CircularProgressIndicator()),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
