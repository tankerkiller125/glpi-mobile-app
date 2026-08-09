import 'package:flutter/material.dart';

import '../utils/formatting.dart';

/// A labelled date+time picker button. Shared by the planning editors and the
/// dynamic-form date question so scheduling looks the same everywhere.
class DateTimeField extends StatelessWidget {
  const DateTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.dateOnly = false,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  /// Skips the time step (used for visibility windows).
  final bool dateOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _pick(context),
              icon: const Icon(Icons.event, size: 18),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  value == null
                      ? 'Not set'
                      : (dateOnly
                            ? formatDateTime(value).split(',').first
                            : formatDateTime(value)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final base = value ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return;
    if (dateOnly) {
      onChanged(DateTime(date.year, date.month, date.day));
      return;
    }
    if (!context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    onChanged(
      DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? base.hour,
        time?.minute ?? base.minute,
      ),
    );
  }
}
