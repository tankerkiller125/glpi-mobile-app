/// A link between two ITIL objects (ticket↔ticket, change↔ticket,
/// change↔problem, problem↔ticket …), as served by the plugin.
class ItilLinkDto {
  const ItilLinkDto({
    required this.itemtype,
    required this.id,
    required this.name,
    required this.status,
    required this.linkType,
  });

  final String itemtype; // the *other* object's type
  final int id;
  final String name;
  final int status;
  final int linkType;

  factory ItilLinkDto.fromJson(Map<String, Object?> json) => ItilLinkDto(
    itemtype: '${json['itemtype'] ?? 'Ticket'}',
    id: (json['id'] as num).toInt(),
    name: (json['name'] ?? '') as String,
    status: (json['status'] as num?)?.toInt() ?? 1,
    linkType: (json['link_type'] as num?)?.toInt() ?? 1,
  );
}

/// The Change/Problem analysis fields the HL API doesn't expose.
class ItilExtraDto {
  const ItilExtraDto({required this.fields});

  /// Raw field name → value (e.g. `impactcontent`, `rolloutplancontent`).
  final Map<String, String> fields;

  String operator [](String key) => fields[key] ?? '';

  bool get isEmpty => fields.values.every((v) => v.trim().isEmpty);

  factory ItilExtraDto.fromJson(Map<String, Object?> json) => ItilExtraDto(
    fields: {
      for (final e in json.entries)
        if (e.value is String) e.key: e.value as String,
    },
  );
}
