import 'package:flutter/material.dart';

import '../../../core/utils/formatting.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/section_heading.dart';

/// Inline, tappable duration control for the composer. Shows the current value
/// and opens a precise picker (hour/minute steppers + quick presets). Replaces
/// the old slider, which couldn't hit exact values.
class DurationField extends StatelessWidget {
  const DurationField({
    super.key,
    required this.minutes,
    required this.onChanged,
  });

  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = minutes > 0 ? formatDuration(minutes * 60) : 'Set duration';
    return Row(
      children: [
        Icon(Icons.timer_outlined, size: 18, color: theme.colorScheme.outline),
        const SizedBox(width: 8),
        Text('Duration', style: theme.textTheme.bodyMedium),
        const Spacer(),
        OutlinedButton(
          onPressed: () async {
            final result = await DurationPickerSheet.show(context, minutes);
            if (result != null) onChanged(result);
          },
          child: Text(label),
        ),
        if (minutes > 0)
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => onChanged(0),
          ),
      ],
    );
  }
}

/// Modal duration picker: quick presets + precise hour/minute steppers.
class DurationPickerSheet extends StatefulWidget {
  const DurationPickerSheet({super.key, required this.initialMinutes});

  final int initialMinutes;

  static Future<int?> show(BuildContext context, int initialMinutes) =>
      showModalBottomSheet<int>(
        useSafeArea: true,
        // Root navigator: from the embedded two-pane detail the nearest
        // navigator is the shell branch, whose barrier misses the rail,
        // bottom bar, and shell FAB (they overlap the sheet on a foldable).
        useRootNavigator: true,
        context: context,
        constraints: sheetConstraints(context),
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => DurationPickerSheet(initialMinutes: initialMinutes),
      );

  @override
  State<DurationPickerSheet> createState() => _DurationPickerSheetState();
}

class _DurationPickerSheetState extends State<DurationPickerSheet> {
  late int _minutes = widget.initialMinutes;

  static const _presets = [15, 30, 45, 60, 120, 240];

  int get _hours => _minutes ~/ 60;
  int get _mins => _minutes % 60;

  void _setHours(int h) =>
      setState(() => _minutes = (h.clamp(0, 23)) * 60 + _mins);
  void _setMins(int m) {
    // wrap minutes into hours, keep within 0..23h59m
    final total = (_hours * 60 + m).clamp(0, 23 * 60 + 59);
    setState(() => _minutes = total);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text('Task duration', style: theme.textTheme.titleMedium),
            ),
            const SizedBox(height: 12),
            Center(
              child: Semantics(
                // The steppers change this number and nothing else; a live
                // region is how a screen reader hears the result of a tap.
                liveRegion: true,
                label: _minutes > 0
                    ? 'Duration ${spokenDuration(_minutes * 60)}'
                    : 'No duration set',
                excludeSemantics: true,
                child: Text(
                  _minutes > 0 ? formatDuration(_minutes * 60) : 'None',
                  style: theme.textTheme.headlineMedium,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _Stepper(
              label: 'Hours',
              value: _hours,
              onDec: () => _setHours(_hours - 1),
              onInc: () => _setHours(_hours + 1),
            ),
            _Stepper(
              label: 'Minutes',
              value: _mins,
              step: 5,
              onDec: () => _setMins(_mins - 5),
              onInc: () => _setMins(_mins + 5),
            ),
            const SizedBox(height: 12),
            const SectionHeading('Quick set'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (final p in _presets)
                  ActionChip(
                    label: Text(formatDuration(p * 60)),
                    onPressed: () => setState(() => _minutes = p),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => _minutes = 0),
                  child: const Text('Clear'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.pop(context, _minutes),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onDec,
    required this.onInc,
    this.step = 1,
  });

  final String label;
  final int value;
  final VoidCallback onDec;
  final VoidCallback onInc;
  final int step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          IconButton.filledTonal(
            // "minus" says nothing about what it decreases.
            tooltip: 'Fewer ${label.toLowerCase()}',
            onPressed: value > 0 ? onDec : null,
            icon: const Icon(Icons.remove),
          ),
          Semantics(
            label: label,
            value: '$value',
            child: ExcludeSemantics(
              child: SizedBox(
                width: 48,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'More ${label.toLowerCase()}',
            onPressed: onInc,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
