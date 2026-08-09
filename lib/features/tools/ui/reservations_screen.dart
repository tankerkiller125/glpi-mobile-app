import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/dto/tools_dto.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatting.dart';
import 'reservation_booking.dart';

/// Reservations: browse bookable items and book or cancel a slot. GLPI rejects
/// overlapping bookings server-side, so a clash lands in Needs Attention.
class ReservationsScreen extends ConsumerStatefulWidget {
  const ReservationsScreen({super.key});

  @override
  ConsumerState<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends ConsumerState<ReservationsScreen> {
  bool _mine = false;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Items')),
                ButtonSegment(value: true, label: Text('Mine')),
              ],
              selected: {_mine},
              onSelectionChanged: (s) => setState(() => _mine = s.first),
            ),
          ),
        ),
      ),
      body: _mine ? _buildMine() : _buildItems(),
    );
  }

  Widget _buildItems() {
    final items = ref.watch(reservationItemsProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search items…',
              prefixIcon: Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(reservationItemsProvider),
            child: switch (items) {
              AsyncData(:final value) => Builder(
                builder: (context) {
                  final q = _query.trim().toLowerCase();
                  final list = q.isEmpty
                      ? value
                      : value
                            .where((i) => i.name.toLowerCase().contains(q))
                            .toList();
                  if (list.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('No reservable items')),
                      ],
                    );
                  }
                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) => ListTile(
                      leading: const Icon(Icons.inventory_2_outlined),
                      title: Text(
                        list[i].name.isEmpty
                            ? '${list[i].itemtype} #${list[i].itemsId}'
                            : list[i].name,
                      ),
                      subtitle: Text(list[i].itemtype),
                      trailing: const Icon(Icons.event_available_outlined),
                      onTap: () => bookReservation(context, ref, list[i]),
                    ),
                  );
                },
              ),
              AsyncError() => ListView(
                children: const [
                  SizedBox(height: 80),
                  Center(child: Text('Reservations need a connection')),
                ],
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMine() {
    final reservations = ref.watch(reservationsProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(reservationsProvider),
      child: switch (reservations) {
        AsyncData(:final value) when value.isEmpty => ListView(
          children: const [
            SizedBox(height: 80),
            Center(child: Text('No reservations')),
          ],
        ),
        AsyncData(:final value) => ListView.separated(
          itemCount: value.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final r = value[i];
            return Dismissible(
              key: ValueKey(r.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Theme.of(context).colorScheme.errorContainer,
                child: const Icon(Icons.delete_outline),
              ),
              confirmDismiss: (_) => _confirmCancel(r),
              child: ListTile(
                leading: const Icon(Icons.event_busy_outlined),
                title: Text(
                  '${formatDateTime(DateTime.tryParse(r.begin))} → '
                  '${formatDateTime(DateTime.tryParse(r.end))}',
                ),
                subtitle: Text(
                  [
                    if (r.userName.isNotEmpty) r.userName,
                    if (r.comment.isNotEmpty) r.comment,
                  ].join(' · '),
                ),
              ),
            );
          },
        ),
        AsyncError() => ListView(
          children: const [
            SizedBox(height: 80),
            Center(child: Text('Reservations need a connection')),
          ],
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Future<bool> _confirmCancel(ReservationDto r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel reservation?'),
        content: const Text('The slot will be released.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel it'),
          ),
        ],
      ),
    );
    if (ok != true) return false;
    await ref.read(ticketActionsProvider)?.deleteReservation(r.id);
    ref.invalidate(reservationsProvider);
    return true;
  }
}
