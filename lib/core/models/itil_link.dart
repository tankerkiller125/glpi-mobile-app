import '../api/itil_type.dart';

/// A relationship from the object being viewed to another ITIL object.
class ItilLink {
  const ItilLink({
    required this.localId,
    required this.itemtype,
    required this.serverId,
    required this.name,
    required this.status,
    required this.linkType,
    required this.pending,
  });

  final String localId;
  final String itemtype; // the linked object's type
  final int serverId;
  final String name;
  final int status;
  final int linkType;

  /// Still queued in the outbox (shown greyed with a sync hint).
  final bool pending;

  String get typeLabel => itilLabel(itemtype);
  String get statusLabel => itilStatuses(itemtype)[status] ?? 'Status $status';
  String get relationLabel => ItilLinkType.label(linkType);
}
