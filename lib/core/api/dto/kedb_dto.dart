/// DTOs for the glpi-kedb plugin (`/GlpiKedb/*`): the known-error matches a
/// ticket gets offered, the used/dismissed hit answer, and the KE library
/// (search rows + full record). Parsed tolerantly — a field the server drops
/// or renames degrades to empty, never a throw.
library;

int _intOf(Object? v) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

/// One known-error offer for a ticket (`GET /GlpiKedb/match/ticket/{id}`).
///
/// The server records a `shown` hit for every row it returns, so the caller
/// must fetch these once per ticket view — not per rebuild.
class KedbMatchDto {
  const KedbMatchDto({
    required this.id,
    required this.title,
    required this.status,
    required this.workaround,
    required this.hasWorkaround,
    required this.symptom,
    required this.reasons,
    required this.weight,
  });

  final int id;
  final String title;
  final String status;

  /// Plain text — the server strips tags before sending.
  final String workaround;
  final bool hasWorkaround;

  /// Not in the current match contract; parsed when a newer server adds it.
  final String symptom;

  /// Why this KE matched ("category", "keyword", …).
  final List<String> reasons;
  final int weight;

  /// What the banner shows under the title: the symptom when the server
  /// sends one, else the workaround text.
  String get snippet => symptom.isNotEmpty ? symptom : workaround;

  factory KedbMatchDto.fromJson(Map<String, Object?> json) => KedbMatchDto(
    id: _intOf(json['id']),
    title: '${json['title'] ?? json['name'] ?? ''}',
    status: '${json['status'] ?? ''}',
    workaround: '${json['workaround'] ?? ''}'.trim(),
    hasWorkaround:
        json['has_workaround'] == true ||
        '${json['workaround'] ?? ''}'.trim().isNotEmpty,
    symptom: '${json['symptom'] ?? ''}'.trim(),
    reasons: json['reasons'] is List
        ? [for (final r in json['reasons'] as List) '$r']
        : const [],
    weight: _intOf(json['weight']),
  );
}

/// `POST /GlpiKedb/hits` answer. `used` returns the followup [snippet];
/// `dismissed` returns only the acknowledgement.
class KedbHitResultDto {
  const KedbHitResultDto({required this.ok, required this.snippet});

  final bool ok;
  final String? snippet;

  factory KedbHitResultDto.fromJson(Object? json) {
    if (json is! Map) return const KedbHitResultDto(ok: false, snippet: null);
    final snippet = json['snippet'];
    return KedbHitResultDto(
      ok: json['ok'] == true,
      snippet: snippet is String && snippet.trim().isNotEmpty ? snippet : null,
    );
  }
}

/// A KE library row (`GET /GlpiKedb/knownerrors`).
class KedbRowDto {
  const KedbRowDto({
    required this.id,
    required this.title,
    required this.status,
    required this.hasWorkaround,
  });

  final int id;
  final String title;
  final String status;
  final bool hasWorkaround;

  factory KedbRowDto.fromJson(Map<String, Object?> json) => KedbRowDto(
    id: _intOf(json['id']),
    title: '${json['title'] ?? json['name'] ?? ''}',
    status: '${json['status'] ?? ''}',
    hasWorkaround: json['has_workaround'] == true,
  );
}

/// Digs the row list out of the confirmed `{total, start, limit, rows}`
/// wrapper; accepts a bare array; anything else reads as empty.
List<Map<String, Object?>> kedbRowsFromJson(Object? json) {
  Object? rows = json;
  if (json is Map) {
    rows = json['rows'];
    if (rows is! List) {
      // Fall back to the first list-valued key, like the alerts parser.
      rows = json.values.whereType<List<Object?>>().firstOrNull;
    }
  }
  if (rows is! List) return const [];
  return rows.whereType<Map<String, Object?>>().toList();
}

/// One KE in full (`GET /GlpiKedb/knownerrors/{id}`). The symptom,
/// workaround and root cause arrive as stored — HTML — and render through
/// the app's rich-content widget.
class KedbDetailDto {
  const KedbDetailDto({
    required this.id,
    required this.title,
    required this.status,
    required this.statusLabel,
    required this.symptom,
    required this.workaround,
    required this.rootCause,
    required this.dateIdentified,
    required this.dateRetired,
    required this.useCount,
    required this.software,
    required this.problemId,
    required this.problemName,
  });

  final int id;
  final String title;
  final String status;
  final String statusLabel;
  final String symptom;
  final String workaround;
  final String rootCause;
  final String? dateIdentified;
  final String? dateRetired;
  final int useCount;
  final List<String> software;
  final int? problemId;
  final String? problemName;

  bool get hasWorkaround => workaround.trim().isNotEmpty;

  factory KedbDetailDto.fromJson(Map<String, Object?> json) {
    final lifecycle = json['lifecycle'];
    final lc = lifecycle is Map ? lifecycle : const {};
    final problem = json['problem'];
    return KedbDetailDto(
      id: _intOf(json['id']),
      title: '${json['title'] ?? json['name'] ?? ''}',
      status: '${json['status'] ?? ''}',
      statusLabel: '${json['status_label'] ?? json['status'] ?? ''}',
      symptom: '${json['symptom'] ?? ''}',
      workaround: '${json['workaround'] ?? ''}',
      rootCause: '${json['root_cause'] ?? ''}',
      dateIdentified: lc['date_identified'] as String?,
      dateRetired: lc['date_retired'] as String?,
      useCount: _intOf(lc['use_count']),
      software: json['software'] is List
          ? [for (final s in json['software'] as List) '$s']
          : const [],
      problemId: problem is Map ? _intOf(problem['id']) : null,
      problemName: problem is Map ? problem['name'] as String? : null,
    );
  }
}
