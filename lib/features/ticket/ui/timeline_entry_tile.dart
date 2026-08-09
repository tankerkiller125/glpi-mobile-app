import 'package:flutter/material.dart';

import '../../../core/models/timeline_entry.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/utils/html_text.dart';
import '../../../core/widgets/rich_content.dart';

/// Renders one merged-timeline entry. Followups are chat bubbles; tasks show a
/// done/todo checkbox + duration; solutions/validations are bordered cards.
/// Private items are muted with a lock icon and label (never color-only).
/// Rows not yet synced (serverId == null) show a "Sending…" affordance.
class TimelineEntryTile extends StatelessWidget {
  const TimelineEntryTile({
    super.key,
    required this.entry,
    this.onToggleTask,
    this.onReview,
  });

  final TimelineEntry entry;
  final VoidCallback? onToggleTask;

  /// Called with `accept` when the current user reviews a waiting solution or
  /// validation. Null when the user can't act on this entry.
  final void Function(bool accept)? onReview;

  @override
  Widget build(BuildContext context) {
    return switch (entry.type) {
      'task' => _TaskCard(entry: entry, onToggle: onToggleTask),
      'solution' => _ApprovableCard(
        entry: entry,
        label: 'Solution',
        icon: Icons.check_circle_outline,
        onReview: onReview,
      ),
      'validation' => _ApprovableCard(
        entry: entry,
        label: 'Approval',
        icon: Icons.how_to_reg_outlined,
        onReview: onReview,
      ),
      _ => _FollowupBubble(entry: entry),
    };
  }
}

/// Approval status pill for solutions/validations (2 waiting / 3 accepted /
/// 4 refused).
class _ApprovalBadge extends StatelessWidget {
  const _ApprovalBadge({required this.status});
  final int status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      3 => ('Approved', context.glpiColors.statusSolved),
      4 => ('Refused', context.glpiColors.priorityVeryHigh),
      _ => ('Waiting', context.glpiColors.statusPending),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Trailing "Sending…" or failed marker for an unsynced row.
class _PendingMark extends StatelessWidget {
  const _PendingMark({required this.entry});
  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    if (entry.serverId != null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Sending…',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.entry});
  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        if (entry.authorName != null)
          Text(
            entry.authorName!,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        const SizedBox(width: 8),
        Text(
          relativeAge(entry.dateCreation),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        if (entry.isPrivate) ...[
          const SizedBox(width: 8),
          const _PrivateBadge(),
        ],
        _PendingMark(entry: entry),
      ],
    );
  }
}

/// Amber accent for private (internal-only) timeline items, tuned for light and
/// dark. Private notes must clearly read as not-visible-to-the-requester.
Color _privateAccent(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFFF5B84B)
    : const Color(0xFFB26A00);

/// A filled "PRIVATE" pill with a lock — the primary signal an item is internal.
class _PrivateBadge extends StatelessWidget {
  const _PrivateBadge();

  @override
  Widget build(BuildContext context) {
    final accent = _privateAccent(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock, size: 11, color: Colors.white),
          SizedBox(width: 3),
          Text(
            'PRIVATE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _privacyDecoration(BuildContext context, bool isPrivate) {
  final scheme = Theme.of(context).colorScheme;
  if (!isPrivate) {
    return BoxDecoration(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
    );
  }
  final accent = _privateAccent(context);
  return BoxDecoration(
    color: accent.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: accent.withValues(alpha: 0.6), width: 1.5),
  );
}

class _FollowupBubble extends StatelessWidget {
  const _FollowupBubble({required this.entry});
  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: _privacyDecoration(context, entry.isPrivate),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Meta(entry: entry),
          const SizedBox(height: 6),
          RichContent(entry.content),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.entry, this.onToggle});
  final TimelineEntry entry;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = formatDuration(entry.taskDuration);
    final canToggle = onToggle != null && entry.serverId != null;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: _privacyDecoration(context, entry.isPrivate),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: canToggle ? onToggle : null,
                borderRadius: BorderRadius.circular(4),
                child: Icon(
                  entry.isTaskDone
                      ? Icons.check_box_outlined
                      : Icons.check_box_outline_blank,
                  size: 18,
                  color: entry.isTaskDone
                      ? context.glpiColors.statusSolved
                      : theme.colorScheme.outline,
                ),
              ),
              const SizedBox(width: 6),
              Text('Task', style: theme.textTheme.labelLarge),
              const Spacer(),
              if (duration.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(duration, style: theme.textTheme.labelSmall),
                ),
            ],
          ),
          const SizedBox(height: 6),
          RichContent(entry.content),
          const SizedBox(height: 6),
          _Meta(entry: entry),
        ],
      ),
    );
  }
}

/// Solution or validation card: header + status badge, content, the reviewer's
/// comment, and approve/refuse buttons when the current user can act (waiting +
/// onReview provided).
class _ApprovableCard extends StatelessWidget {
  const _ApprovableCard({
    required this.entry,
    required this.label,
    required this.icon,
    this.onReview,
  });
  final TimelineEntry entry;
  final String label;
  final IconData icon;
  final void Function(bool accept)? onReview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = entry.approvalStatus;
    final canReview = onReview != null && entry.isWaitingApproval;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: scheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                ),
              ),
              const Spacer(),
              if (status != null) _ApprovalBadge(status: status),
            ],
          ),
          if (entry.content.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            RichContent(entry.content),
          ],
          if (entry.approvalComment != null &&
              entry.approvalComment!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Reviewer: ${htmlToPlainText(entry.approvalComment!)}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
          const SizedBox(height: 6),
          _Meta(entry: entry),
          if (canReview) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => onReview!(false),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Refuse'),
                  style: TextButton.styleFrom(
                    foregroundColor: context.glpiColors.priorityVeryHigh,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => onReview!(true),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approve'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
