/// Minimal RSQL builder for GLPI 11's `filter` param.
/// `;` = AND, `,` = OR. Only scalar/dotted property paths — do NOT use for
/// `team.*` paths, which are broken server-side (see docs/api-notes.md).
class Rsql {
  const Rsql._(this._expr);
  final String _expr;

  static Rsql raw(String expr) => Rsql._(expr);

  static Rsql eq(String field, Object value) => Rsql._('$field==${_v(value)}');
  static Rsql ne(String field, Object value) => Rsql._('$field!=${_v(value)}');
  static Rsql gt(String field, Object value) =>
      Rsql._('$field=gt=${_v(value)}');
  static Rsql ge(String field, Object value) =>
      Rsql._('$field=ge=${_v(value)}');
  static Rsql lt(String field, Object value) =>
      Rsql._('$field=lt=${_v(value)}');
  static Rsql le(String field, Object value) =>
      Rsql._('$field=le=${_v(value)}');
  static Rsql like(String field, String value) =>
      Rsql._('$field=like=${_v(value)}');
  static Rsql inList(String field, Iterable<Object> values) =>
      Rsql._('$field=in=(${values.map(_v).join(',')})');

  Rsql and(Rsql other) => Rsql._('$_expr;${other._expr}');
  Rsql or(Rsql other) => Rsql._('($_expr,${other._expr})');

  @override
  String toString() => _expr;

  static String _v(Object value) {
    if (value is num) return value.toString();
    // Quote strings; escape embedded quotes.
    final s = value.toString().replaceAll('"', r'\"');
    return '"$s"';
  }
}
