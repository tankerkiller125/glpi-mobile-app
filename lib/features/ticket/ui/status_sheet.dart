import 'package:flutter/material.dart';

import '../../../core/a11y/contrast.dart';
import '../../../core/api/itil_type.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/utils/layout.dart';

/// Status picker. GLPI doesn't expose allowed transitions, so all statuses are
/// offered; a rejected change surfaces in Needs Attention.
class StatusSheet extends StatelessWidget {
  const StatusSheet({
    super.key,
    required this.current,
    this.itemtype = itilTicket,
  });

  final int current;

  /// Changes and Problems have their own status sets (evaluation, testing,
  /// under observation …), so the list comes from the ITIL type.
  final String itemtype;

  static Future<int?> show(
    BuildContext context, {
    required int current,
    String itemtype = itilTicket,
  }) => showModalBottomSheet<int>(
    context: context,
    constraints: sheetConstraints(context),
    showDragHandle: true,
    builder: (_) => StatusSheet(current: current, itemtype: itemtype),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.glpiColors;
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
                  'Change status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final s in itilStatuses(itemtype).keys)
            ListTile(
              leading: Icon(
                Icons.circle,
                size: 14,
                color: ensureContrast(
                  colors.statusColor(s),
                  Theme.of(context).colorScheme.surface,
                  minRatio: wcagAaGraphics,
                ),
              ),
              title: Text(statusLabel(s, itemtype: itemtype)),
              // The tick is decoration; `selected` is what says "current".
              selected: s == current,
              trailing: s == current ? const Icon(Icons.check, size: 18) : null,
              onTap: () => Navigator.pop(context, s),
            ),
        ],
      ),
    );
  }
}
