import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../api/glpi_api.dart';
import '../api/itil_type.dart';
import '../db/app_database.dart';
import '../models/attachment.dart';

const _uuid = Uuid();

/// Reads a ticket's attachments from the local DB (reactive) and syncs them
/// from GLPI. New attachments are persisted to app storage (so they survive
/// until the upload op drains) and written by [OutboxWriter]; downloads are
/// cached to disk keyed by document id.
class AttachmentRepository {
  AttachmentRepository(this._db, this._api);

  final AppDatabase _db;
  final GlpiApi _api;

  /// Reactive list for a ticket, newest last (upload order).
  Stream<List<Attachment>> watch(String ticketLocalId) {
    final q = _db.select(_db.attachments)
      ..where((a) => a.ticketLocalId.equals(ticketLocalId))
      ..orderBy([(a) => OrderingTerm(expression: a.dateCreation)]);
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          Attachment(
            localId: r.localId,
            serverDocId: r.serverDocId,
            name: r.name,
            filename: r.filename,
            mime: r.mime,
            localPath: r.localPath,
          ),
      ],
    );
  }

  /// Pull the ticket's server-side documents and replace the synced set,
  /// leaving pending (not-yet-uploaded) rows untouched.
  Future<void> refresh(
    String ticketLocalId,
    int ticketServerId, {
    String itemtype = itilTicket,
  }) async {
    final docs = await _api.listAttachments(ticketServerId, itemtype: itemtype);
    await _db.transaction(() async {
      // Drop previously-synced rows for this ticket; keep pending ones.
      await (_db.delete(_db.attachments)..where(
            (a) =>
                a.ticketLocalId.equals(ticketLocalId) &
                a.serverDocId.isNotNull(),
          ))
          .go();
      for (final d in docs) {
        await _db
            .into(_db.attachments)
            .insert(
              AttachmentsCompanion.insert(
                localId: _uuid.v4(),
                ticketLocalId: ticketLocalId,
                serverDocId: Value(d.id),
                name: Value(d.name),
                filename: Value(d.filename),
                mime: Value(d.mime),
                dateCreation: Value(d.date),
              ),
            );
      }
    });
  }

  /// Copy a picked file into persistent app storage so it survives until the
  /// upload op runs (image_picker/camera hand back cache paths). Returns the
  /// stored path + size.
  Future<({String path, int size})> importFile(
    String sourcePath,
    String filename,
  ) async {
    final dir = Directory(
      p.join((await getApplicationSupportDirectory()).path, 'attachments'),
    );
    await dir.create(recursive: true);
    final dest = p.join(dir.path, '${_uuid.v4()}_$filename');
    final file = await File(sourcePath).copy(dest);
    return (path: dest, size: await file.length());
  }

  /// [localFileFor] by attachment id (loads the current row first) — the shape
  /// providers key on, so downloads memoize per attachment.
  Future<String?> localFileForId(String attachmentLocalId) async {
    final r = await (_db.select(
      _db.attachments,
    )..where((a) => a.localId.equals(attachmentLocalId))).getSingleOrNull();
    if (r == null) return null;
    return localFileFor(
      Attachment(
        localId: r.localId,
        serverDocId: r.serverDocId,
        name: r.name,
        filename: r.filename,
        mime: r.mime,
        localPath: r.localPath,
      ),
    );
  }

  /// A short JSON/HTML body is an API error, not a file — caching it would
  /// leave a permanently broken "document" on disk.
  static bool _looksLikeErrorBody(List<int> bytes) {
    if (bytes.length > 2048) return false;
    final first = bytes.first;
    return first == 0x7b || first == 0x3c; // '{' or '<'
  }

  /// Download (once) and cache a GLPI Document by id, for the standalone
  /// Document records in Management. Returns the on-device path.
  Future<String?> cachedDocument(int documentId, {String? filename}) =>
      localFileFor(
        Attachment(
          localId: 'doc-$documentId',
          serverDocId: documentId,
          name: filename ?? 'document',
          filename: filename,
          mime: null,
          localPath: null,
        ),
      );

  /// Local file path for showing an attachment: a pending upload uses its own
  /// [localPath]; a server document is downloaded once and cached by id.
  Future<String?> localFileFor(Attachment a) async {
    if (a.localPath != null && await File(a.localPath!).exists()) {
      return a.localPath;
    }
    final id = a.serverDocId;
    if (id == null) return null;
    final dir = Directory(
      p.join((await getTemporaryDirectory()).path, 'doc-cache'),
    );
    await dir.create(recursive: true);
    final ext = p.extension(a.filename ?? a.name);
    final cached = File(p.join(dir.path, 'doc-$id$ext'));
    if (await cached.exists() && await cached.length() > 0) {
      // A previous attempt may have cached an API error body; re-download
      // rather than serving a permanently broken file.
      if (!_looksLikeErrorBody(await cached.readAsBytes())) return cached.path;
      await cached.delete();
    }
    try {
      final bytes = await _api.downloadDocument(id);
      if (bytes.isEmpty || _looksLikeErrorBody(bytes)) return null;
      await cached.writeAsBytes(bytes, flush: true);
      return cached.path;
    } on Exception {
      return null; // offline / failed — the tile shows a placeholder
    }
  }
}
