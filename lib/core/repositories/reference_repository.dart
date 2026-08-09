import 'package:drift/drift.dart';

import '../api/dto/dropdown_dto.dart';
import '../api/glpi_api.dart';
import '../db/app_database.dart';
import '../utils/priority_matrix.dart';

const _kPriorityMatrix = 'priority_matrix';

/// Caches GLPI reference dropdowns (categories, locations, request types) and
/// instance config (the priority matrix) used by the edit UI.
class ReferenceRepository {
  ReferenceRepository(this._db, this._api);

  final AppDatabase _db;
  final GlpiApi _api;

  /// Load the cached instance priority matrix into [PriorityMatrix] (survives
  /// restarts / offline). Call on startup, before any priority computation.
  Future<void> loadCachedPriorityMatrix() async {
    final row = await (_db.select(
      _db.appConfig,
    )..where((c) => c.key.equals(_kPriorityMatrix))).getSingleOrNull();
    if (row == null) return;
    final grid = PriorityMatrix.parseGlpiJson(row.value);
    if (grid != null) PriorityMatrix.set(grid);
  }

  /// Fetch this instance's admin-configured priority matrix and cache it, so
  /// optimistic priority matches the server's grid (not the hardcoded default).
  Future<void> refreshPriorityMatrix() async {
    try {
      final raw = await _api.getConfig('core', _kPriorityMatrix);
      if (raw == null) return;
      final grid = PriorityMatrix.parseGlpiJson(raw);
      if (grid == null) return;
      PriorityMatrix.set(grid);
      await _db
          .into(_db.appConfig)
          .insertOnConflictUpdate(
            AppConfigCompanion.insert(key: _kPriorityMatrix, value: raw),
          );
    } on Exception {
      // Keep the cached/default matrix on failure.
    }
  }

  Stream<List<DropdownItem>> watchDropdown(String kind) {
    final query = _db.select(_db.dropdownItems)
      ..where((d) => d.kind.equals(kind))
      ..orderBy([(d) => OrderingTerm(expression: d.name)]);
    return query.watch();
  }

  Future<void> refreshAll() async {
    await refreshPriorityMatrix();
    for (final kind in DropdownKinds.all) {
      try {
        final rows = await _api.listDropdown(kind);
        await _db.transaction(() async {
          await (_db.delete(
            _db.dropdownItems,
          )..where((d) => d.kind.equals(kind))).go();
          for (final r in rows) {
            await _db
                .into(_db.dropdownItems)
                .insert(
                  DropdownItemsCompanion.insert(
                    kind: kind,
                    serverId: r.id,
                    name: r.name,
                  ),
                );
          }
        });
      } on Exception {
        // Reference data is best-effort; keep any prior cache on failure.
      }
    }
  }
}
