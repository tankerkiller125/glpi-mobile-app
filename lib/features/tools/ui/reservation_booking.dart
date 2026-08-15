import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/dto/tools_dto.dart';
import '../../../core/providers.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/date_time_field.dart';

/// Book a slot on a reservable item. Shared by the Reservations screen and the
/// asset detail's "Reserve" action so both queue the same offline-first op.
Future<void> bookReservation(
  BuildContext context,
  WidgetRef ref,
  ReservationItemDto item,
) async {
  // Default to the next full hour, for one hour.
  final now = DateTime.now();
  var begin = DateTime(now.year, now.month, now.day, now.hour + 1);
  var end = begin.add(const Duration(hours: 1));
  final comment = TextEditingController();

  final ok = await showModalBottomSheet<bool>(
    context: context,
    constraints: sheetConstraints(context),
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setSheetState) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Reserve ${item.name.isEmpty ? item.itemtype : item.name}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            DateTimeField(
              label: 'From',
              value: begin,
              onChanged: (v) => setSheetState(() {
                final d = end.difference(begin);
                begin = v;
                end = v.add(d.isNegative ? const Duration(hours: 1) : d);
              }),
            ),
            DateTimeField(
              label: 'To',
              value: end,
              onChanged: (v) => setSheetState(() => end = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: comment,
              decoration: const InputDecoration(
                labelText: 'Comment',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.check),
              label: const Text('Reserve'),
            ),
          ],
        ),
      ),
    ),
  );
  if (ok != true) return;
  await ref
      .read(ticketActionsProvider)
      ?.createReservation(
        reservationItemId: item.id,
        begin: begin,
        end: end,
        comment: comment.text.trim(),
      );
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reservation queued — clashes appear in Sync'),
      ),
    );
  }
}
