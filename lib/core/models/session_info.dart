/// Parsed subset of `GET /api.php/v2.3/session`.
///
/// Note: `/Administration/User/Me` does NOT include group membership, but this
/// endpoint does (see docs/api-notes.md) — it is the one source for the
/// profile picker and the Groups queue tab.
class SessionInfo {
  const SessionInfo({
    required this.userId,
    required this.username,
    required this.friendlyName,
    required this.groupIds,
    required this.profiles,
    required this.activeProfileId,
  });

  final int userId;
  final String username;
  final String friendlyName;
  final List<int> groupIds;
  final List<SessionProfile> profiles;
  final int? activeProfileId;

  factory SessionInfo.fromJson(Map<String, Object?> json) {
    final profilesRaw = json['profiles'] as Map<String, Object?>? ?? const {};
    final active = json['active_profile'] as Map<String, Object?>?;
    return SessionInfo(
      userId: (json['user_id'] as num).toInt(),
      username: json['name'] as String? ?? '',
      friendlyName: json['friendly_name'] as String? ?? '',
      groupIds: (json['groups'] as List<Object?>? ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
      profiles:
          profilesRaw.entries
              .map(
                (e) => SessionProfile.fromJson(
                  int.parse(e.key),
                  e.value as Map<String, Object?>,
                ),
              )
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name)),
      activeProfileId: (active?['id'] as num?)?.toInt(),
    );
  }
}

class SessionProfile {
  const SessionProfile({
    required this.id,
    required this.name,
    required this.entities,
  });

  final int id;
  final String name;

  /// Entities this profile is authorized on (with recursion flags) — the
  /// allowed roots for the entity picker.
  final List<ProfileEntity> entities;

  factory SessionProfile.fromJson(int id, Map<String, Object?> json) =>
      SessionProfile(
        id: id,
        name: json['name'] as String? ?? 'Profile $id',
        entities: (json['entities'] as List<Object?>? ?? const [])
            .map((e) => ProfileEntity.fromJson(e! as Map<String, Object?>))
            .toList(),
      );
}

class ProfileEntity {
  const ProfileEntity({
    required this.id,
    required this.name,
    required this.isRecursive,
  });

  final int id;
  final String name;
  final bool isRecursive;

  factory ProfileEntity.fromJson(Map<String, Object?> json) => ProfileEntity(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    isRecursive: (json['is_recursive'] as num? ?? 0) != 0,
  );
}
