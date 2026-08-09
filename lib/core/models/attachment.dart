/// A ticket attachment for the UI: either uploaded (has [serverDocId]) or still
/// [pending] (queued locally, [localPath] points at the file being uploaded).
class Attachment {
  const Attachment({
    required this.localId,
    required this.serverDocId,
    required this.name,
    required this.filename,
    required this.mime,
    required this.localPath,
  });

  final String localId;
  final int? serverDocId;
  final String name;
  final String? filename;
  final String? mime;
  final String? localPath;

  bool get pending => serverDocId == null;

  bool get isImage {
    final m = mime ?? '';
    if (m.isNotEmpty) return m.startsWith('image/');
    final n = (filename ?? name).toLowerCase();
    return n.endsWith('.png') ||
        n.endsWith('.jpg') ||
        n.endsWith('.jpeg') ||
        n.endsWith('.gif') ||
        n.endsWith('.webp') ||
        n.endsWith('.heic');
  }
}
