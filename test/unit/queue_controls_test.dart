import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/models/ticket_list_item.dart';
import 'package:glpi_mobile/features/queue/queue_controls.dart';
import 'package:glpi_mobile/features/queue/queue_providers.dart';

TicketListItem item({
  required int id,
  required String name,
  int status = 1,
  int priority = 3,
  String? category,
  DateTime? created,
  DateTime? due,
}) => TicketListItem(
  localId: 'l$id',
  serverId: id,
  itemtype: 'Ticket',
  name: name,
  status: status,
  priority: priority,
  categoryName: category,
  entityName: null,
  dateMod: created,
  dateCreation: created,
  timeToResolve: due,
  assignedUserIds: const {},
  assignedGroupIds: const {},
  requesterName: null,
);

void main() {
  final tickets = [
    item(id: 1, name: 'Email outage', priority: 5, category: 'Network'),
    item(id: 2, name: 'VPN setup', priority: 3, status: 2),
    item(id: 3, name: 'Server migration', priority: 2, category: 'Hardware'),
  ];

  test('search matches name and category, case-insensitively', () {
    final r = applyControlsForTest(
      tickets,
      const QueueControls(search: 'server'),
    );
    expect(r.map((t) => t.serverId), [3]);

    final byCat = applyControlsForTest(
      tickets,
      const QueueControls(search: 'network'),
    );
    expect(byCat.map((t) => t.serverId), [1]);
  });

  test('status and priority filters intersect', () {
    final r = applyControlsForTest(tickets, const QueueControls(statuses: {2}));
    expect(r.map((t) => t.serverId), [2]);

    final hi = applyControlsForTest(
      tickets,
      const QueueControls(priorities: {5}),
    );
    expect(hi.map((t) => t.serverId), [1]);
  });

  test('priority sort orders highest first', () {
    final r = applyControlsForTest(
      tickets,
      const QueueControls(sort: QueueSort.priority),
    );
    expect(r.map((t) => t.priority), [5, 3, 2]);
  });

  test('empty filters return everything', () {
    final r = applyControlsForTest(tickets, const QueueControls());
    expect(r, hasLength(3));
  });
}
