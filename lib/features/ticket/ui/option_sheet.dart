import 'package:flutter/material.dart';

import '../../../core/a11y/contrast.dart';
import '../../../core/utils/layout.dart';

/// A generic single-choice bottom sheet used for priority / urgency / type
/// edits. Returns the chosen value's id, or null if dismissed.
class OptionSheet extends StatelessWidget {
  const OptionSheet({
    super.key,
    required this.title,
    required this.options,
    required this.current,
  });

  final String title;
  final List<OptionItem> options;
  final int current;

  static Future<int?> show(
    BuildContext context, {
    required String title,
    required List<OptionItem> options,
    required int current,
  }) => showModalBottomSheet<int>(
    context: context,
    constraints: sheetConstraints(context),
    showDragHandle: true,
    builder: (_) =>
        OptionSheet(title: title, options: options, current: current),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final o in options)
            ListTile(
              leading: o.color == null
                  ? null
                  : Icon(
                      Icons.circle,
                      size: 14,
                      color: ensureContrast(
                        o.color!,
                        Theme.of(context).colorScheme.surface,
                        minRatio: wcagAaGraphics,
                      ),
                    ),
              title: Text(o.label),
              // `selected` is what makes a reader say "selected" — the trailing
              // tick is invisible to it, and it was the only signal of which
              // option is live.
              selected: o.value == current,
              trailing: o.value == current
                  ? const Icon(Icons.check, size: 18)
                  : null,
              onTap: () => Navigator.pop(context, o.value),
            ),
        ],
      ),
    );
  }
}

class OptionItem {
  const OptionItem({required this.value, required this.label, this.color});
  final int value;
  final String label;
  final Color? color;
}
