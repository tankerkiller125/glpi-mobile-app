/// A user from `/Administration/User` (for the assignee picker).
class UserRef {
  const UserRef({required this.id, required this.username, this.realname});

  final int id;
  final String username;
  final String? realname;

  String get displayName =>
      (realname != null && realname!.isNotEmpty) ? realname! : username;

  factory UserRef.fromJson(Map<String, Object?> json) => UserRef(
    id: (json['id'] as num).toInt(),
    username: (json['username'] ?? json['name'] ?? '') as String,
    realname: json['realname'] as String?,
  );
}
