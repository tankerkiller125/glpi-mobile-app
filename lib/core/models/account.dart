/// The signed-in account: server, user identity, and the active GLPI context
/// (profile + entity). Secrets (OAuth credentials) never live here — they stay
/// in secure storage. Authentication is brokered by the GLPI plugin, so the app
/// holds no OAuth client id or secret.
class Account {
  const Account({
    required this.serverUrl,
    required this.userId,
    required this.username,
    required this.displayName,
    this.profileId,
    this.profileName,
    this.entityId,
    this.entityName,
    this.entityRecursive = true,
    this.groupIds = const [],
  });

  /// Normalized origin, no trailing slash (e.g. `https://glpi.example.com`).
  final String serverUrl;
  final int userId;
  final String username;
  final String displayName;
  final int? profileId;
  final String? profileName;
  final int? entityId;
  final String? entityName;
  final bool entityRecursive;
  final List<int> groupIds;

  bool get hasContext => profileId != null && entityId != null;

  Account copyWith({
    int? profileId,
    String? profileName,
    int? entityId,
    String? entityName,
    bool? entityRecursive,
    List<int>? groupIds,
  }) {
    return Account(
      serverUrl: serverUrl,
      userId: userId,
      username: username,
      displayName: displayName,
      profileId: profileId ?? this.profileId,
      profileName: profileName ?? this.profileName,
      entityId: entityId ?? this.entityId,
      entityName: entityName ?? this.entityName,
      entityRecursive: entityRecursive ?? this.entityRecursive,
      groupIds: groupIds ?? this.groupIds,
    );
  }

  Map<String, Object?> toJson() => {
    'serverUrl': serverUrl,
    'userId': userId,
    'username': username,
    'displayName': displayName,
    'profileId': profileId,
    'profileName': profileName,
    'entityId': entityId,
    'entityName': entityName,
    'entityRecursive': entityRecursive,
    'groupIds': groupIds,
  };

  factory Account.fromJson(Map<String, Object?> json) => Account(
    serverUrl: json['serverUrl'] as String,
    userId: (json['userId'] as num).toInt(),
    username: json['username'] as String,
    displayName: json['displayName'] as String,
    profileId: (json['profileId'] as num?)?.toInt(),
    profileName: json['profileName'] as String?,
    entityId: (json['entityId'] as num?)?.toInt(),
    entityName: json['entityName'] as String?,
    entityRecursive: json['entityRecursive'] as bool? ?? true,
    groupIds: (json['groupIds'] as List<Object?>? ?? const [])
        .map((e) => (e as num).toInt())
        .toList(),
  );
}
