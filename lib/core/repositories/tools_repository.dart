import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../api/dto/tools_dto.dart';
import '../api/glpi_api.dart';
import '../db/app_database.dart';
import '../models/reminder.dart';
import '../utils/formatting.dart';

const _uuid = Uuid();

/// Tools module data: reminders and the knowledge base cache. RSS feeds and
/// reservations are small and read-through, so they stay on the API provider.
class ToolsRepository {
  ToolsRepository(this._db, this._api, {this.myUserId});

  final AppDatabase _db;
  final GlpiApi _api;

  /// Used to decide which reminders the signed-in user may edit.
  final int? myUserId;

  // --- Reminders ---

  Stream<List<Reminder>> watchReminders() {
    final q = _db.select(_db.reminders)
      ..orderBy([
        (r) => OrderingTerm(expression: r.isPlanned, mode: OrderingMode.desc),
        (r) => OrderingTerm(expression: r.name),
      ]);
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          Reminder(
            localId: r.localId,
            serverId: r.serverId,
            name: r.name,
            content: r.content,
            beginViewDate: _date(r.beginViewDate),
            endViewDate: _date(r.endViewDate),
            isPlanned: r.isPlanned,
            begin: _date(r.begin),
            end: _date(r.end),
            state: r.state,
            isMine: r.isMine,
            pending: r.pending,
          ),
      ],
    );
  }

  static DateTime? _date(String? s) => parseGlpiDateTime(s);

  /// Replace the synced reminders, keeping any the outbox still owns.
  Future<void> refreshReminders() async {
    final rows = await _api.listReminders();
    final dtos = rows.map(ReminderDto.fromJson).toList();
    await _db.transaction(() async {
      await (_db.delete(
        _db.reminders,
      )..where((r) => r.pending.equals(false))).go();
      for (final d in dtos) {
        final queued =
            await (_db.select(_db.reminders)..where(
                  (r) => r.serverId.equals(d.id) & r.pending.equals(true),
                ))
                .getSingleOrNull();
        if (queued != null) continue;
        await _db
            .into(_db.reminders)
            .insert(
              RemindersCompanion.insert(
                localId: _uuid.v4(),
                serverId: Value(d.id),
                name: d.name,
                content: Value(d.text),
                beginViewDate: Value(d.dateViewBegin),
                endViewDate: Value(d.dateViewEnd),
                isPlanned: Value(d.isPlanned),
                begin: Value(d.dateBegin),
                end: Value(d.dateEnd),
                state: Value(d.state),
                // Shared reminders authored by someone else are read-only.
                isMine: Value(myUserId == null || d.userId == myUserId),
              ),
            );
      }
    });
  }

  // --- Knowledge base ---

  /// Cached articles, newest first — the offline shelf.
  Stream<List<KbArticleDto>> watchCachedArticles() {
    final q = _db.select(_db.kbArticles)
      ..orderBy([
        (a) => OrderingTerm(expression: a.dateMod, mode: OrderingMode.desc),
      ]);
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          KbArticleDto(
            id: r.serverId,
            name: r.name,
            content: r.contentHtml,
            isFaq: r.isFaq,
            views: r.views,
            dateMod: r.dateMod,
            categoryId: r.categoryId,
            categoryName: r.categoryName,
          ),
      ],
    );
  }

  Stream<KbArticleDto?> watchArticle(int serverId) {
    final q = _db.select(_db.kbArticles)
      ..where((a) => a.serverId.equals(serverId));
    return q.watchSingleOrNull().map(
      (r) => r == null
          ? null
          : KbArticleDto(
              id: r.serverId,
              name: r.name,
              content: r.contentHtml,
              isFaq: r.isFaq,
              views: r.views,
              dateMod: r.dateMod,
              categoryId: r.categoryId,
              categoryName: r.categoryName,
            ),
    );
  }

  /// Server search with a local-cache fallback so the KB still works offline.
  Future<List<KbArticleDto>> searchArticles({
    String query = '',
    bool faqOnly = false,
    int? categoryId,
  }) async {
    try {
      final results = await _api.searchKbArticles(
        query: query,
        faqOnly: faqOnly,
        categoryId: categoryId,
      );
      // Cache list rows (without bodies) so they're browsable offline.
      await _cacheArticles(results, withContent: false);
      return results;
    } on Exception {
      return _searchCache(query: query, faqOnly: faqOnly);
    }
  }

  Future<List<KbArticleDto>> _searchCache({
    String query = '',
    bool faqOnly = false,
  }) async {
    final rows = await _db.select(_db.kbArticles).get();
    final q = query.trim().toLowerCase();
    return [
      for (final r in rows)
        if ((!faqOnly || r.isFaq) &&
            (q.isEmpty ||
                r.name.toLowerCase().contains(q) ||
                r.contentHtml.toLowerCase().contains(q)))
          KbArticleDto(
            id: r.serverId,
            name: r.name,
            content: r.contentHtml,
            isFaq: r.isFaq,
            views: r.views,
            dateMod: r.dateMod,
            categoryId: r.categoryId,
            categoryName: r.categoryName,
          ),
    ];
  }

  /// Fetch + cache an article's body (so it reads offline afterwards).
  Future<KbArticleDto?> loadArticle(int id) async {
    try {
      final a = await _api.getKbArticle(id);
      await _cacheArticles([a], withContent: true);
      return a;
    } on Exception {
      final row = await (_db.select(
        _db.kbArticles,
      )..where((r) => r.serverId.equals(id))).getSingleOrNull();
      if (row == null) return null;
      return KbArticleDto(
        id: row.serverId,
        name: row.name,
        content: row.contentHtml,
        isFaq: row.isFaq,
        views: row.views,
        dateMod: row.dateMod,
        categoryId: row.categoryId,
        categoryName: row.categoryName,
      );
    }
  }

  Future<void> _cacheArticles(
    List<KbArticleDto> articles, {
    required bool withContent,
  }) async {
    await _db.transaction(() async {
      for (final a in articles) {
        final existing = await (_db.select(
          _db.kbArticles,
        )..where((r) => r.serverId.equals(a.id))).getSingleOrNull();
        await _db
            .into(_db.kbArticles)
            .insertOnConflictUpdate(
              KbArticlesCompanion.insert(
                serverId: Value(a.id),
                name: a.name,
                // Never blank an already-cached body with a list row.
                contentHtml: Value(
                  withContent || a.content.isNotEmpty
                      ? a.content
                      : (existing?.contentHtml ?? ''),
                ),
                categoryId: Value(a.categoryId),
                categoryName: Value(a.categoryName),
                isFaq: Value(a.isFaq),
                views: Value(a.views),
                dateMod: Value(a.dateMod),
                keepOffline: Value(existing?.keepOffline ?? false),
              ),
            );
      }
    });
  }

  Future<void> setKeepOffline(int serverId, bool keep) async {
    await (_db.update(_db.kbArticles)
          ..where((a) => a.serverId.equals(serverId)))
        .write(KbArticlesCompanion(keepOffline: Value(keep)));
  }

  Stream<List<KbCategoryDto>> watchCategories() {
    final q = _db.select(_db.kbCategories)
      ..orderBy([(c) => OrderingTerm(expression: c.completename)]);
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          KbCategoryDto(
            id: r.serverId,
            name: r.name,
            completename: r.completename,
          ),
      ],
    );
  }

  Future<void> refreshCategories() async {
    final cats = await _api.listKbCategories();
    await _db.transaction(() async {
      await _db.delete(_db.kbCategories).go();
      for (final c in cats) {
        await _db
            .into(_db.kbCategories)
            .insertOnConflictUpdate(
              KbCategoriesCompanion.insert(
                serverId: Value(c.id),
                name: c.name,
                completename: Value(c.completename),
              ),
            );
      }
    });
  }
}
