import 'package:flutter/material.dart';

/// A labelled read-only (or tap-to-edit) field row. Used by every detail
/// screen — tickets, changes, problems, assets and management records — so a
/// field reads the same wherever it appears.
class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Tappable rows show a pencil affordance; null means read-only.
  final VoidCallback? onTap;

  /// Replaces the pencil when the row needs its own affordance (a call button,
  /// a spinner while an edit syncs).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.outline),
            const SizedBox(width: 12),
            SizedBox(
              width: 92,
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.edit_outlined,
                size: 16,
                color: theme.colorScheme.outline,
              ),
          ],
        ),
      ),
    );
  }
}
