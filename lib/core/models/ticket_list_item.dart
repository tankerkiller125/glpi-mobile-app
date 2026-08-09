import '../api/itil_type.dart';

/// A ticket as shown in the queue, with just enough team info to compute which
/// tab (Mine / Groups / Unassigned) it belongs to and who requested it.
class TicketListItem {
  const TicketListItem({
    required this.localId,
    required this.serverId,
    required this.itemtype,
    required this.name,
    required this.status,
    required this.priority,
    required this.categoryName,
    required this.entityName,
    required this.dateMod,
    required this.dateCreation,
    required this.timeToResolve,
    required this.assignedUserIds,
    required this.assignedGroupIds,
    required this.requesterName,
  });

  final String localId;
  final int? serverId;
  final String itemtype;
  final String name;
  final int status;
  final int priority;
  final String? categoryName;
  final String? entityName;
  final DateTime? dateMod;
  final DateTime? dateCreation;
  final DateTime? timeToResolve; // SLA/internal resolution due date
  final Set<int> assignedUserIds;

  /// Open for this ITIL type — SLA countdown only matters here.
  bool get isOpen => itilOpenStatuses(itemtype).contains(status);
  final Set<int> assignedGroupIds;
  final String? requesterName;

  bool get isUnassigned => assignedUserIds.isEmpty && assignedGroupIds.isEmpty;

  bool assignedToUser(int userId) => assignedUserIds.contains(userId);

  bool assignedToAnyGroup(Set<int> groupIds) =>
      assignedGroupIds.any(groupIds.contains);
}
