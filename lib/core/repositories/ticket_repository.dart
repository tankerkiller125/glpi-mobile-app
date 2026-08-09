import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../api/dto/ticket_dto.dart';
import '../api/glpi_api.dart';
import '../api/itil_type.dart';
import '../api/rsql.dart';
import '../db/app_database.dart';
import '../models/ticket_detail.dart';
import '../models/ticket_list_item.dart';
import '../sync/outbox_op.dart';
import '../utils/formatting.dart';

const _uuid = Uuid();

/// Open-ish statuses (New, Assigned, Planned, Pending) — the working queue.
const openTicketStatuses = [1, 2, 3, 4];

/// Reads tickets from the local DB (reactive) and syncs them from GLPI.
///
/// v1 pulls ONE scope — all open tickets in the active entity context — since
/// GLPI 11's RSQL team filters are broken; the Mine/Groups/Unassigned split is
/// done locally from the cached team rows.
class TicketRepository {
  TicketRepository(this._db, this._api);

  final AppDatabase _db;
  final GlpiApi _api;

  static const scopeKey = 'tickets:open';

  /// Reactive queue: tickets joined with their team members, newest activity
  /// first. Emits on every local change (including future optimistic writes).
  Stream<List<TicketListItem>> watchQueue({String itemtype = itilTicket}) {
    final query = _db.select(_db.tickets)
      ..where(
        (t) =>
            t.itemtype.equals(itemtype) &
            t.status.isIn(itilOpenStatuses(itemtype)),
      )
      ..orderBy([
        (t) => OrderingTerm(expression: t.dateMod, mode: OrderingMode.desc),
      ]);

    return query.watch().asyncMap((rows) async {
      if (rows.isEmpty) return const <TicketListItem>[];
      final teams = await _db.select(_db.ticketTeam).get();
      final byTicket = <String, List<TicketTeamData>>{};
      for (final m in teams) {
        byTicket.putIfAbsent(m.ticketLocalId, () => []).add(m);
      }
      return [
        for (final t in rows) _toItem(t, byTicket[t.localId] ?? const []),
      ];
    });
  }

  TicketListItem _toItem(Ticket t, List<TicketTeamData> team) {
    final assignedUsers = <int>{};
    final assignedGroups = <int>{};
    String? requester;
    for (final m in team) {
      if (m.role == 'assigned') {
        if (m.memberType == 'Group') {
          assignedGroups.add(m.memberId);
        } else {
          assignedUsers.add(m.memberId);
        }
      } else if (m.role == 'requester' && requester == null) {
        requester = m.displayName;
      }
    }
    return TicketListItem(
      localId: t.localId,
      serverId: t.serverId,
      itemtype: t.itemtype,
      name: t.name,
      status: t.status,
      priority: t.priority,
      categoryName: t.categoryName,
      entityName: t.entityLabel,
      dateMod: parseGlpiDateTime(t.dateMod),
      dateCreation: parseGlpiDateTime(t.dateCreation),
      timeToResolve: parseGlpiDateTime(t.timeToResolve),
      assignedUserIds: assignedUsers,
      assignedGroupIds: assignedGroups,
      requesterName: requester,
    );
  }

  /// Reactive single-ticket detail (ticket row + actors). Watches BOTH the
  /// tickets and ticket_team tables (via a join) so actor add/remove re-emits,
  /// not just ticket-field edits.
  Stream<TicketDetail?> watchTicket(String localId) {
    final query = _db.select(_db.tickets).join([
      leftOuterJoin(
        _db.ticketTeam,
        _db.ticketTeam.ticketLocalId.equalsExp(_db.tickets.localId),
      ),
    ])..where(_db.tickets.localId.equals(localId));

    return query.watch().map((rows) {
      if (rows.isEmpty) return null;
      final row = rows.first.readTable(_db.tickets);
      final team = rows
          .map((r) => r.readTableOrNull(_db.ticketTeam))
          .whereType<TicketTeamData>()
          .toList();
      return TicketDetail(
        localId: row.localId,
        serverId: row.serverId,
        itemtype: row.itemtype,
        name: row.name,
        content: row.content,
        status: row.status,
        priority: row.priority,
        urgency: row.urgency,
        impact: row.impact,
        type: row.type,
        categoryId: row.categoryId,
        categoryName: row.categoryName,
        entityName: row.entityLabel,
        locationName: row.locationName,
        recipientName: row.recipientName,
        dateCreation: parseGlpiDateTime(row.dateCreation),
        dateMod: parseGlpiDateTime(row.dateMod),
        timeToResolve: parseGlpiDateTime(row.timeToResolve),
        actors: [
          for (final m in team)
            TicketActor(
              role: m.role,
              type: m.memberType,
              id: m.memberId,
              displayName: m.displayName,
            ),
        ],
      );
    });
  }

  /// Refresh a single ticket's canonical fields + actors from the server.
  Future<void> refreshTicket(
    String localId,
    int serverId, {
    String itemtype = itilTicket,
  }) async {
    final dto = await _api.getTicket(serverId, itemtype: itemtype);
    await _upsert([dto], itemtype: itemtype);
  }

  /// The local id for a cached server ticket id, or null if not cached.
  Future<String?> localIdForServerId(
    int serverId, {
    String itemtype = itilTicket,
  }) async {
    final row =
        await (_db.select(_db.tickets)..where(
              (t) => t.serverId.equals(serverId) & t.itemtype.equals(itemtype),
            ))
            .getSingleOrNull();
    return row?.localId;
  }

  /// Resolve a server ticket id to a local id for deep-linking from a push,
  /// fetching + caching the ticket on a miss. Null if it can't be fetched.
  Future<String?> openByServerId(
    int serverId, {
    String itemtype = itilTicket,
  }) async {
    final cached = await localIdForServerId(serverId, itemtype: itemtype);
    if (cached != null) return cached;
    try {
      await _upsert([
        await _api.getTicket(serverId, itemtype: itemtype),
      ], itemtype: itemtype);
    } on Exception {
      return null;
    }
    return localIdForServerId(serverId, itemtype: itemtype);
  }

  /// Pull the open-ticket scope from GLPI and upsert into the local DB.
  /// Returns the number of tickets synced.
  /// Drop cached rows the server no longer returns for this scope.
  ///
  /// The queue is "open objects in the current entity", and a plain upsert
  /// never forgets: a ticket that was closed, reassigned, or left behind by an
  /// entity switch would sit in the list indefinitely. Rows an outbox op still
  /// owns are never touched — deleting one would strand the op.
  Future<void> _pruneOutOfScope(String itemtype, Set<int> seen) async {
    final ops = await (_db.select(
      _db.pendingOps,
    )..where((o) => o.status.isNotValue(OpStatus.done))).get();
    final owned = ops.map((o) => o.ticketLocalId).toSet();

    await (_db.delete(_db.tickets)..where(
          (t) =>
              t.itemtype.equals(itemtype) &
              t.serverId.isNotNull() &
              t.serverId.isNotIn(seen) &
              t.localId.isNotIn(owned),
        ))
        .go();
  }

  Future<int> refreshQueue({String itemtype = itilTicket}) async {
    final filter = Rsql.inList('status', itilOpenStatuses(itemtype));
    var start = 0;
    var synced = 0;
    final seen = <int>{};
    while (true) {
      final page = await _api.searchTickets(
        filter: filter,
        sort: 'date_mod:desc',
        start: start,
        limit: 100,
        itemtype: itemtype,
      );
      if (page.items.isEmpty) break;
      await _upsert(page.items, itemtype: itemtype);
      seen.addAll(page.items.map((t) => t.id));
      synced += page.items.length;
      start += page.items.length;
      if (start >= page.total) break;
    }
    await _pruneOutOfScope(itemtype, seen);
    await _db
        .into(_db.syncState)
        .insertOnConflictUpdate(
          SyncStateCompanion.insert(
            scopeKey: '$scopeKey:$itemtype',
            lastSuccessAt: Value(DateTime.now().toUtc().toIso8601String()),
          ),
        );
    return synced;
  }

  Future<void> _upsert(
    List<TicketDto> dtos, {
    String itemtype = itilTicket,
  }) async {
    await _db.transaction(() async {
      for (final dto in dtos) {
        // Resolve existing local row by (itemtype, server id), or mint a UUID.
        final existing =
            await (_db.select(_db.tickets)..where(
                  (t) =>
                      t.serverId.equals(dto.id) & t.itemtype.equals(itemtype),
                ))
                .getSingleOrNull();
        final localId = existing?.localId ?? _uuid.v4();

        await _db
            .into(_db.tickets)
            .insertOnConflictUpdate(
              TicketsCompanion.insert(
                localId: localId,
                serverId: Value(dto.id),
                itemtype: Value(itemtype),
                name: dto.name,
                content: Value(dto.content),
                status: dto.status,
                priority: Value(dto.priority),
                urgency: Value(dto.urgency),
                impact: Value(dto.impact),
                type: Value(dto.type),
                categoryId: Value(dto.categoryId),
                categoryName: Value(dto.categoryName),
                entityId: Value(dto.entityId),
                entityLabel: Value(dto.entityName),
                requestTypeName: Value(dto.requestTypeName),
                locationId: Value(dto.locationId),
                locationName: Value(dto.locationName),
                recipientName: Value(dto.recipientName),
                dateCreation: Value(dto.dateCreation),
                dateMod: Value(dto.dateMod),
                timeToResolve: Value(dto.timeToResolve),
              ),
            );

        // Replace the team set for this ticket.
        await (_db.delete(
          _db.ticketTeam,
        )..where((m) => m.ticketLocalId.equals(localId))).go();
        for (final member in dto.team) {
          await _db
              .into(_db.ticketTeam)
              .insert(
                TicketTeamCompanion.insert(
                  localId: _uuid.v4(),
                  ticketLocalId: localId,
                  role: member.role,
                  memberType: member.type,
                  memberId: member.id,
                  displayName: Value(member.displayName),
                ),
              );
        }
      }
    });
  }
}
