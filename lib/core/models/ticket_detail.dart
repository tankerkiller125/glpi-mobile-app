import '../api/itil_type.dart';

/// Full ticket view for the detail screen: the ticket plus its actors.
class TicketDetail {
  const TicketDetail({
    required this.localId,
    required this.serverId,
    required this.itemtype,
    required this.name,
    required this.content,
    required this.status,
    required this.priority,
    required this.urgency,
    required this.impact,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.entityName,
    required this.locationName,
    required this.recipientName,
    required this.dateCreation,
    required this.dateMod,
    required this.timeToResolve,
    required this.actors,
  });

  final String localId;
  final int? serverId;
  final String itemtype; // Ticket | Change | Problem
  final String name;
  final String content;
  final int status;
  final int priority; // derived from urgency × impact
  final int urgency;
  final int impact;
  final int type; // 1 Incident, 2 Request
  final int? categoryId;
  final String? categoryName;
  final String? entityName;
  final String? locationName;
  final String? recipientName; // "Created by"
  final DateTime? dateCreation;
  final DateTime? dateMod;
  final DateTime? timeToResolve; // SLA/internal resolution due date
  final List<TicketActor> actors;

  /// Still being worked — SLA countdowns only matter before it's resolved.
  /// Status ids differ per ITIL type, hence the lookup.
  bool get isOpen => itilOpenStatuses(itemtype).contains(status);

  Iterable<TicketActor> byRole(String role) =>
      actors.where((a) => a.role == role);
}

class TicketActor {
  const TicketActor({
    required this.role,
    required this.type,
    required this.id,
    required this.displayName,
  });

  final String role; // requester | assigned | observer
  final String type; // User | Group | Supplier
  final int id;
  final String displayName;

  bool get isGroup => type == 'Group';
}
