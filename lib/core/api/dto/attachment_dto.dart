/// A ticket attachment (GLPI Document) as returned by the plugin's
/// `/GlpiMobile/tickets/{id}/documents` endpoints.
class AttachmentDto {
  const AttachmentDto({
    required this.id,
    required this.name,
    required this.filename,
    required this.mime,
    this.date,
  });

  final int id; // GLPI document id
  final String name;
  final String filename;
  final String mime;
  final String? date;

  bool get isImage => mime.startsWith('image/');

  factory AttachmentDto.fromJson(Map<String, Object?> json) => AttachmentDto(
    id: (json['id'] as num).toInt(),
    name: (json['name'] ?? json['filename'] ?? '') as String,
    filename: (json['filename'] ?? '') as String,
    mime: (json['mime'] ?? '') as String,
    date: json['date'] as String?,
  );
}
