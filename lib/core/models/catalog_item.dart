import 'package:flutter/material.dart';

/// A record in the generic Assets / Management browser.
class CatalogItem {
  const CatalogItem({
    required this.localId,
    required this.domain,
    required this.itemtype,
    required this.serverId,
    required this.name,
    required this.serial,
    required this.otherserial,
    required this.statusName,
    required this.locationName,
    required this.userName,
    required this.groupName,
    required this.manufacturerName,
    required this.modelName,
    required this.typeName,
    required this.entityName,
    required this.expiryDate,
    required this.fields,
    required this.pending,
  });

  final String localId;
  final String domain; // 'Assets' | 'Management'
  final String itemtype;
  final int serverId;
  final String name;
  final String? serial;
  final String? otherserial;
  final String? statusName;
  final String? locationName;
  final String? userName;
  final String? groupName;
  final String? manufacturerName;
  final String? modelName;
  final String? typeName;
  final String? entityName;
  final String? expiryDate;

  /// The verbatim server payload — the detail screen renders whatever GLPI
  /// returned, including custom fields.
  final Map<String, Object?> fields;
  final bool pending;

  String get displayName => name.isEmpty ? '$itemtype #$serverId' : name;

  /// Financial/warranty block, fetched alongside the record for assets.
  Map<String, Object?>? get infocom =>
      fields['_infocom'] as Map<String, Object?>?;

  String? get comment => fields['comment'] as String?;

  /// Contact fields — used by Management's tap-to-call rows.
  String? get phone => (fields['phone'] ?? fields['phonenumber']) as String?;
  String? get mobile => fields['mobile'] as String?;
  String? get email => fields['email'] as String?;
  String? get website => fields['website'] as String?;
  String? get address {
    final parts = [
      fields['address'],
      fields['postcode'],
      fields['town'],
      fields['country'],
    ].whereType<String>().where((s) => s.trim().isNotEmpty).toList();
    return parts.isEmpty ? null : parts.join(', ');
  }
}

/// Icon for an itemtype in the hub grid / list rows.
IconData catalogIcon(String itemtype) => switch (itemtype) {
  'Computer' => Icons.computer,
  'Monitor' => Icons.desktop_windows_outlined,
  'NetworkEquipment' => Icons.router_outlined,
  'Peripheral' => Icons.mouse_outlined,
  'Printer' => Icons.print_outlined,
  'Phone' => Icons.smartphone,
  'Software' || 'SoftwareLicense' => Icons.apps_outlined,
  'CartridgeItem' => Icons.opacity_outlined,
  'ConsumableItem' => Icons.inventory_2_outlined,
  'Rack' || 'Enclosure' => Icons.dns_outlined,
  'PDU' => Icons.power_outlined,
  'Cable' => Icons.cable,
  'Certificate' => Icons.verified_outlined,
  'Contract' => Icons.description_outlined,
  'Supplier' => Icons.local_shipping_outlined,
  'Contact' => Icons.contact_page_outlined,
  'Document' => Icons.folder_open_outlined,
  'Budget' => Icons.savings_outlined,
  'Line' => Icons.sim_card_outlined,
  'Datacenter' => Icons.location_city_outlined,
  'Cluster' => Icons.hub_outlined,
  'Domain' => Icons.language,
  'Appliance' => Icons.devices_outlined,
  'Database' || 'DatabaseInstance' => Icons.storage_outlined,
  _ => Icons.category_outlined,
};

/// Asset types worth searching in one sweep (hub search + barcode lookup).
/// These are the ones that carry a serial or asset tag.
const primaryAssetTypes = [
  'Computer',
  'Monitor',
  'NetworkEquipment',
  'Peripheral',
  'Printer',
  'Phone',
];

/// Management types the field techs need first. Note GLPI files
/// `SoftwareLicense` and `Certificate` under **Assets**, not Management, even
/// though its Management directory also lists SoftwareLicense (that route 404s)
/// — so they are searched with the assets, not here.
const managementTier1 = [
  'Document',
  'Contract',
  'Supplier',
  'Contact',
  'Line',
  'Budget',
];
