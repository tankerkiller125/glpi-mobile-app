import 'dart:convert';

/// GLPI's DEFAULT priority matrix (urgency rows × impact cols, 1–5). Admins can
/// customize the grid per instance, so this is only a fallback used until the
/// real matrix has been fetched from `/Setup/Config/core/priority_matrix`.
const defaultPriorityMatrix = <List<int>>[
  //       impact: 1  2  3  4  5
  /* urgency 1 */ [1, 1, 2, 2, 2],
  /* urgency 2 */ [1, 2, 2, 3, 3],
  /* urgency 3 */ [2, 2, 3, 4, 4],
  /* urgency 4 */ [2, 3, 4, 4, 5],
  /* urgency 5 */ [2, 3, 4, 5, 5],
];

/// Holds the priority matrix in use. The server (`/Setup/Config`) is the source
/// of truth; the cached grid is loaded on startup and refreshed when online, so
/// optimistic priority matches THIS instance's admin-configured grid. Falls back
/// to [defaultPriorityMatrix] only when never fetched (e.g. first offline run).
class PriorityMatrix {
  PriorityMatrix._();

  static List<List<int>> _current = defaultPriorityMatrix;

  static List<List<int>> get current => _current;

  static bool _fromServer = false;

  /// True once the real instance matrix has been loaded (cache or network).
  static bool get isFromServer => _fromServer;

  static void set(List<List<int>> matrix, {bool fromServer = true}) {
    if (matrix.length == 5 && matrix.every((r) => r.length == 5)) {
      _current = matrix;
      _fromServer = fromServer;
    }
  }

  /// Parse GLPI's `priority_matrix` config JSON: `{"urgency":{"impact":priority}}`
  /// (both 1–5). Returns null if malformed.
  static List<List<int>>? parseGlpiJson(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, Object?>;
      final grid = <List<int>>[];
      for (var u = 1; u <= 5; u++) {
        final row = map['$u'] as Map<String, Object?>;
        grid.add([for (var i = 1; i <= 5; i++) (row['$i'] as num).toInt()]);
      }
      return grid;
    } on Object {
      return null;
    }
  }
}

/// Compute priority for urgency × impact (1–5) using the given matrix, or the
/// current cached/instance matrix when none is passed.
int computePriority(int urgency, int impact, {List<List<int>>? matrix}) {
  final m = matrix ?? PriorityMatrix.current;
  final u = urgency.clamp(1, 5);
  final i = impact.clamp(1, 5);
  return m[u - 1][i - 1];
}
