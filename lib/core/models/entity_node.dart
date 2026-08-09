/// One node of `GET /api.php/v2.3/Session/EntityTree`.
class EntityNode {
  const EntityNode({
    required this.id,
    required this.label,
    required this.children,
  });

  final int id;
  final String label;
  final List<EntityNode> children;

  factory EntityNode.fromJson(Map<String, Object?> json) => EntityNode(
    id: (json['key'] as num).toInt(),
    label: json['label'] as String? ?? '',
    children: (json['children'] as List<Object?>? ?? const [])
        .map((e) => EntityNode.fromJson(e! as Map<String, Object?>))
        .toList(),
  );

  static List<EntityNode> listFromJson(List<Object?> json) =>
      json.map((e) => EntityNode.fromJson(e! as Map<String, Object?>)).toList();

  /// Depth-first flatten with indentation levels for a simple picker list.
  static List<(EntityNode, int)> flatten(
    List<EntityNode> roots, [
    int depth = 0,
  ]) {
    final out = <(EntityNode, int)>[];
    for (final n in roots) {
      out.add((n, depth));
      out.addAll(flatten(n.children, depth + 1));
    }
    return out;
  }
}
