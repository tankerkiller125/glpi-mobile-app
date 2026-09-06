/// DTOs for the glpi-presence plugin (`/GlpiPresence/*`): who else is on this
/// ticket, whether they are typing, and who has picked the work up.
///
/// Times arrive as unix seconds from the server's own clock, alongside the
/// server's `server_time` — "claimed 40 minutes ago" is computed against that
/// rather than against the phone's clock, which may be wrong by an hour.
library;

int _intOf(Object? v) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

/// One technician currently on the item.
class PresenceParticipantDto {
  const PresenceParticipantDto({
    required this.usersId,
    required this.name,
    required this.initials,
    required this.typing,
    required this.typingKind,
    required this.since,
  });

  final int usersId;
  final String name;
  final String initials;

  /// Typing anywhere — across a person's tabs and devices — counts as typing.
  final bool typing;

  /// What they are typing: a followup, a task, a solution. Null when the
  /// server does not say.
  final String? typingKind;

  /// Unix seconds, server clock.
  final int since;

  factory PresenceParticipantDto.fromJson(Map<String, Object?> json) =>
      PresenceParticipantDto(
        usersId: _intOf(json['users_id']),
        name: '${json['name'] ?? ''}',
        initials: '${json['initials'] ?? ''}',
        typing: json['typing'] == true,
        typingKind: json['typing_kind'] == null
            ? null
            : '${json['typing_kind']}',
        since: _intOf(json['since']),
      );
}

/// The soft claim on an item: somebody saying they are doing this.
class PresenceClaimDto {
  const PresenceClaimDto({
    required this.usersId,
    required this.name,
    required this.since,
    required this.idle,
  });

  final int usersId;
  final String name;
  final int since;

  /// Seconds since the holder last did anything. A claim expires on idleness
  /// rather than on disconnect, which is why this is worth showing.
  final int idle;

  factory PresenceClaimDto.fromJson(Map<String, Object?> json) =>
      PresenceClaimDto(
        usersId: _intOf(json['users_id']),
        name: '${json['name'] ?? ''}',
        since: _intOf(json['since']),
        idle: _intOf(json['idle']),
      );
}

/// The item's presence state, as every presence route returns it.
class PresenceStateDto {
  const PresenceStateDto({
    required this.serverTime,
    required this.you,
    required this.canClaim,
    required this.presenceTtl,
    required this.participants,
    required this.claim,
  });

  static const empty = PresenceStateDto(
    serverTime: 0,
    you: 0,
    canClaim: false,
    presenceTtl: 90,
    participants: [],
    claim: null,
  );

  final int serverTime;

  /// The signed-in user's id, so "you" can be told apart from everyone else
  /// without the app having to correlate accounts.
  final int you;
  final bool canClaim;

  /// How long the server keeps a participant after their last beat. The app
  /// beats well inside this, and much more slowly than the browser does.
  final int presenceTtl;
  final List<PresenceParticipantDto> participants;
  final PresenceClaimDto? claim;

  /// Everyone except the signed-in user — what the bar is actually about.
  List<PresenceParticipantDto> get others => [
    for (final p in participants)
      if (p.usersId != you) p,
  ];

  bool get claimedByYou => claim != null && claim!.usersId == you;
  bool get claimedByOther => claim != null && claim!.usersId != you;

  factory PresenceStateDto.fromJson(Map<String, Object?> json) {
    final claim = json['claim'];
    return PresenceStateDto(
      serverTime: _intOf(json['server_time']),
      you: _intOf(json['you']),
      canClaim: json['can_claim'] == true,
      presenceTtl: json['presence_ttl'] == null
          ? 90
          : _intOf(json['presence_ttl']),
      participants: json['participants'] is List
          ? [
              for (final p in json['participants'] as List)
                if (p is Map)
                  PresenceParticipantDto.fromJson(p.cast<String, Object?>()),
            ]
          : const [],
      claim: claim is Map
          ? PresenceClaimDto.fromJson(claim.cast<String, Object?>())
          : null,
    );
  }
}
