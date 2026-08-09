/// One entry in GLPI's itemtype directory (`GET /Assets`, `GET /Management`).
class ItemtypeInfo {
  const ItemtypeInfo({required this.itemtype, required this.name});

  final String itemtype;
  final String name;

  factory ItemtypeInfo.fromJson(Map<String, Object?> json) => ItemtypeInfo(
    itemtype: '${json['itemtype'] ?? ''}',
    name: '${json['name'] ?? json['itemtype'] ?? ''}',
  );
}

/// A generic asset / management record. GLPI's schemas differ per itemtype, so
/// the app promotes the handful of fields every list needs and keeps the rest
/// of the payload verbatim in [fields] for the detail screen.
class CatalogItemDto {
  const CatalogItemDto({
    required this.id,
    required this.itemtype,
    required this.name,
    required this.fields,
  });

  final int id;
  final String itemtype;
  final String name;
  final Map<String, Object?> fields;

  static String? _named(Object? v) {
    if (v is Map) {
      final n = v['completename'] ?? v['name'];
      return n is String && n.isNotEmpty ? n : null;
    }
    return null;
  }

  String? get serial => fields['serial'] as String?;
  String? get otherserial => fields['otherserial'] as String?;
  String? get statusName => _named(fields['status']) ?? _named(fields['state']);
  String? get locationName => _named(fields['location']);
  String? get userName => _named(fields['user']);
  String? get groupName {
    final g = fields['group'];
    if (g is List && g.isNotEmpty) return _named(g.first);
    return _named(g);
  }

  String? get manufacturerName => _named(fields['manufacturer']);
  String? get modelName => _named(fields['model']);
  String? get typeName => _named(fields['type']);
  String? get entityName => _named(fields['entity']);
  String? get dateMod => fields['date_mod'] as String?;

  /// The date an expiry badge should watch, per itemtype. Contracts have no
  /// end column — GLPI stores a start plus a duration in months — so it is
  /// computed here, the same way the web UI does.
  String? get expiryDate {
    final explicit =
        (fields['date_expiration'] ??
                fields['date_end'] ??
                fields['expiration_date'])
            as String?;
    if (explicit != null && explicit.isNotEmpty) return explicit;

    final begin = (fields['date_begin'] ?? fields['begin_date']) as String?;
    final months = (fields['duration'] as num?)?.toInt() ?? 0;
    if (begin == null || begin.isEmpty || months <= 0) return null;
    final start = DateTime.tryParse(begin.replaceFirst('T', ' '));
    if (start == null) return null;
    final end = DateTime(start.year, start.month + months, start.day);
    return '${end.year.toString().padLeft(4, '0')}-'
        '${end.month.toString().padLeft(2, '0')}-'
        '${end.day.toString().padLeft(2, '0')}';
  }

  factory CatalogItemDto.fromJson(String itemtype, Map<String, Object?> json) =>
      CatalogItemDto(
        id: (json['id'] as num).toInt(),
        itemtype: itemtype,
        name: '${json['name'] ?? ''}',
        fields: json,
      );
}

/// A network port on an asset, with its resolved IP addresses.
class NetworkPortDto {
  const NetworkPortDto({
    required this.id,
    required this.name,
    required this.mac,
    required this.type,
    required this.ips,
  });

  final int id;
  final String name;
  final String mac;
  final String type;
  final List<String> ips;

  factory NetworkPortDto.fromJson(Map<String, Object?> json) => NetworkPortDto(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: '${json['name'] ?? ''}',
    mac: '${json['mac'] ?? ''}',
    type: '${json['type'] ?? ''}',
    ips: (json['ips'] as List? ?? const []).map((e) => '$e').toList(),
  );
}

/// Installed software: the true [total] plus the first page of titles.
class SoftwareListDto {
  const SoftwareListDto({required this.total, required this.items});

  final int total;
  final List<({String name, String version})> items;

  factory SoftwareListDto.fromJson(Map<String, Object?> json) =>
      SoftwareListDto(
        total: (json['total'] as num?)?.toInt() ?? 0,
        items: [
          for (final e in (json['items'] as List? ?? const []))
            if (e is Map)
              (name: '${e['name'] ?? ''}', version: '${e['version'] ?? ''}'),
        ],
      );
}

/// An ITIL object linked to an asset.
class AssetItilLinkDto {
  const AssetItilLinkDto({
    required this.itemtype,
    required this.id,
    required this.name,
    required this.status,
  });

  final String itemtype;
  final int id;
  final String name;
  final int status;

  factory AssetItilLinkDto.fromJson(Map<String, Object?> json) =>
      AssetItilLinkDto(
        itemtype: '${json['itemtype'] ?? ''}',
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: '${json['name'] ?? ''}',
        status: (json['status'] as num?)?.toInt() ?? 0,
      );
}

/// An asset linked to an ITIL object.
class LinkedAssetDto {
  const LinkedAssetDto({
    required this.itemtype,
    required this.id,
    required this.name,
    required this.serial,
    required this.typeLabel,
  });

  final String itemtype;
  final int id;
  final String name;
  final String serial;
  final String typeLabel;

  factory LinkedAssetDto.fromJson(Map<String, Object?> json) => LinkedAssetDto(
    itemtype: '${json['itemtype'] ?? ''}',
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: '${json['name'] ?? ''}',
    serial: '${json['serial'] ?? ''}',
    typeLabel: '${json['type_label'] ?? json['itemtype'] ?? ''}',
  );
}
