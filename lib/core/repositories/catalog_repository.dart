import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../api/dto/catalog_dto.dart';
import '../api/glpi_api.dart';
import '../db/app_database.dart';
import '../models/catalog_item.dart';

const _uuid = Uuid();

/// The generic browser behind both **Assets** and **Management**.
///
/// GLPI exposes ~30 itemtypes through one uniform contract, so rather than a
/// screen per type the app stores them in one table keyed by
/// `(domain, itemtype, serverId)` with the raw payload in a JSON column.
class CatalogRepository {
  CatalogRepository(this._db, this._api);

  final AppDatabase _db;
  final GlpiApi _api;

  /// Itemtype directories are stable; cache them in AppConfig so the hub can
  /// render offline.
  Future<List<ItemtypeInfo>> itemtypes(String domain) async {
    final key = 'itemtypes:$domain';
    try {
      final list = await _api.listItemtypes(domain);
      await _db
          .into(_db.appConfig)
          .insertOnConflictUpdate(
            AppConfigCompanion.insert(
              key: key,
              value: jsonEncode([
                for (final i in list) {'itemtype': i.itemtype, 'name': i.name},
              ]),
            ),
          );
      return list;
    } on Exception {
      final row = await (_db.select(
        _db.appConfig,
      )..where((c) => c.key.equals(key))).getSingleOrNull();
      if (row == null) return const [];
      return (jsonDecode(row.value) as List)
          .whereType<Map<String, Object?>>()
          .map(ItemtypeInfo.fromJson)
          .toList();
    }
  }

  Stream<List<CatalogItem>> watchList(String domain, String itemtype) {
    final q = _db.select(_db.catalogItems)
      ..where((c) => c.domain.equals(domain) & c.itemtype.equals(itemtype))
      ..orderBy([(c) => OrderingTerm(expression: c.name)]);
    return q.watch().map((rows) => rows.map(_toModel).toList());
  }

  Stream<CatalogItem?> watchItem(String localId) {
    final q = _db.select(_db.catalogItems)
      ..where((c) => c.localId.equals(localId));
    return q.watchSingleOrNull().map((r) => r == null ? null : _toModel(r));
  }

  CatalogItem _toModel(CatalogItemRow r) => CatalogItem(
    localId: r.localId,
    domain: r.domain,
    itemtype: r.itemtype,
    serverId: r.serverId,
    name: r.name,
    serial: r.serial,
    otherserial: r.otherserial,
    statusName: r.statusName,
    locationName: r.locationName,
    userName: r.userName,
    groupName: r.groupName,
    manufacturerName: r.manufacturerName,
    modelName: r.modelName,
    typeName: r.typeName,
    entityName: r.entityLabel,
    expiryDate: r.expiryDate,
    fields: jsonDecode(r.fieldsJson) as Map<String, Object?>,
    pending: r.pending,
  );

  /// Pull one itemtype's list (optionally filtered) into the cache.
  Future<int> refreshList(
    String domain,
    String itemtype, {
    String? search,
    int? statusId,
  }) async {
    final page = await _api.listCatalogItems(
      domain,
      itemtype,
      search: search,
      statusId: statusId,
      limit: 100,
    );
    await _upsert(domain, page.items);
    return page.total;
  }

  /// How many records a type holds — powers the hub's count badges.
  Future<int> countOf(String domain, String itemtype) async {
    try {
      final page = await _api.listCatalogItems(domain, itemtype, limit: 1);
      return page.total;
    } on Exception {
      return -1; // unknown (offline)
    }
  }

  /// Full record + Infocom, cached for offline reading.
  Future<CatalogItem?> loadItem(
    String domain,
    String itemtype,
    int serverId,
  ) async {
    try {
      final dto = await _api.getCatalogItem(domain, itemtype, serverId);
      var fields = dto.fields;
      try {
        // The raw row fills in what the HL schema omits (phone/email/address
        // on Supplier and Contact, contract dates, custom columns). HL values
        // win: they carry resolved names where the row has bare ids.
        final raw = await _api.getRawRecord(itemtype, serverId);
        if (raw.isNotEmpty) fields = {...raw, ...fields};
      } on Exception {
        // The plugin may be older than the app; the HL payload still renders.
      }
      if (domain == 'Assets') {
        try {
          final infocom = await _api.getInfocom(itemtype, serverId);
          if (infocom != null) {
            fields = {...fields, '_infocom': infocom};
          }
        } on Exception {
          // Financial data is optional.
        }
      }
      await _upsert(domain, [
        CatalogItemDto(
          id: dto.id,
          itemtype: itemtype,
          name: dto.name,
          fields: fields,
        ),
      ]);
    } on Exception {
      // Offline: fall through to whatever is cached.
    }
    final row =
        await (_db.select(_db.catalogItems)..where(
              (c) =>
                  c.domain.equals(domain) &
                  c.itemtype.equals(itemtype) &
                  c.serverId.equals(serverId),
            ))
            .getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  /// Search across the primary asset types at once (the hub's search-all and
  /// the barcode lookup). Falls back to the local cache when offline.
  Future<List<CatalogItem>> searchAcross(
    String domain,
    List<String> itemtypes,
    String query,
  ) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final out = <CatalogItem>[];
    var online = false;
    for (final t in itemtypes) {
      try {
        final page = await _api.listCatalogItems(
          domain,
          t,
          search: q,
          limit: 20,
        );
        online = true;
        await _upsert(domain, page.items);
        out.addAll(
          page.items.map(
            (d) => CatalogItem(
              localId: '',
              domain: domain,
              itemtype: t,
              serverId: d.id,
              name: d.name,
              serial: d.serial,
              otherserial: d.otherserial,
              statusName: d.statusName,
              locationName: d.locationName,
              userName: d.userName,
              groupName: d.groupName,
              manufacturerName: d.manufacturerName,
              modelName: d.modelName,
              typeName: d.typeName,
              entityName: d.entityName,
              expiryDate: d.expiryDate,
              fields: d.fields,
              pending: false,
            ),
          ),
        );
      } on Exception {
        // Try the next type; the cache fallback below covers a full outage.
      }
    }
    if (online) return out;

    final lower = q.toLowerCase();
    final rows = await (_db.select(
      _db.catalogItems,
    )..where((c) => c.domain.equals(domain))).get();
    return [
      for (final r in rows)
        if (r.name.toLowerCase().contains(lower) ||
            (r.serial ?? '').toLowerCase() == lower ||
            (r.otherserial ?? '').toLowerCase() == lower)
          _toModel(r),
    ];
  }

  /// The local row id for a server record, so detail routes can address it.
  Future<String?> localIdFor(
    String domain,
    String itemtype,
    int serverId,
  ) async {
    final row =
        await (_db.select(_db.catalogItems)..where(
              (c) =>
                  c.domain.equals(domain) &
                  c.itemtype.equals(itemtype) &
                  c.serverId.equals(serverId),
            ))
            .getSingleOrNull();
    return row?.localId;
  }

  Future<void> _upsert(String domain, List<CatalogItemDto> dtos) async {
    await _db.transaction(() async {
      for (final d in dtos) {
        final existing =
            await (_db.select(_db.catalogItems)..where(
                  (c) =>
                      c.domain.equals(domain) &
                      c.itemtype.equals(d.itemtype) &
                      c.serverId.equals(d.id),
                ))
                .getSingleOrNull();
        // Never let a lean list row overwrite a fully-loaded detail payload.
        final merged = existing == null
            ? d.fields
            : {
                ...(jsonDecode(existing.fieldsJson) as Map<String, Object?>),
                ...d.fields,
              };
        await _db
            .into(_db.catalogItems)
            .insertOnConflictUpdate(
              CatalogItemsCompanion.insert(
                localId: existing?.localId ?? _uuid.v4(),
                domain: domain,
                itemtype: d.itemtype,
                serverId: d.id,
                name: Value(d.name),
                serial: Value(d.serial),
                otherserial: Value(d.otherserial),
                statusName: Value(d.statusName),
                locationName: Value(d.locationName),
                userName: Value(d.userName),
                groupName: Value(d.groupName),
                manufacturerName: Value(d.manufacturerName),
                modelName: Value(d.modelName),
                typeName: Value(d.typeName),
                entityLabel: Value(d.entityName),
                expiryDate: Value(d.expiryDate),
                dateMod: Value(d.dateMod),
                fieldsJson: Value(jsonEncode(merged)),
                pending: Value(existing?.pending ?? false),
              ),
            );
      }
    });
  }
}
