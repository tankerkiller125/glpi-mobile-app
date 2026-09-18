import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../core/a11y/a11y.dart';
import '../../../core/api/itil_type.dart';
import '../../../core/models/attachment.dart';
import '../../../core/models/rights.dart';
import '../../../core/models/ticket_detail.dart';
import '../../../core/providers.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/section_heading.dart';

/// Attachments strip: horizontally-scrolling image thumbnails / file chips plus
/// an "add" button (camera or gallery). New files are queued through the
/// offline outbox and show a "sending" spinner until the upload drains.
///
/// Used by tickets/changes/problems and by asset & management records — GLPI
/// attaches Documents to any itemtype, so the section only needs the owner's
/// local row, its server id and its itemtype.
class AttachmentsSection extends ConsumerWidget {
  const AttachmentsSection({
    super.key,
    required this.ownerLocalId,
    required this.ownerServerId,
    required this.itemtype,
  });

  /// Convenience for the ITIL screens, which already hold a [TicketDetail].
  factory AttachmentsSection.forTicket(TicketDetail ticket, {Key? key}) =>
      AttachmentsSection(
        key: key,
        ownerLocalId: ticket.localId,
        ownerServerId: ticket.serverId ?? 0,
        itemtype: ticket.itemtype,
      );

  final String ownerLocalId;
  final int ownerServerId;
  final String itemtype;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items =
        ref.watch(attachmentsProvider(ownerLocalId)).value ?? const [];
    // An attachment is a Document in GLPI, filed against the object: it needs
    // the document right as well as the right to write the object.
    final rights = ref.watch(rightsProvider).value ?? Rights.empty;
    final canAdd =
        rights.canAddDocument &&
        (itilTypes.contains(itemtype)
            ? rights.canUpdateItil(itemtype)
            : rights.canUpdateItemtype(itemtype));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          'Attachments',
          count: items.isEmpty ? null : items.length,
          trailing: canAdd
              ? TextButton.icon(
                  onPressed: () => _add(context, ref),
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                  label: const Text('Add'),
                )
              : null,
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'No attachments',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          )
        else
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) =>
                  _AttachmentTile(attachment: items[i]),
            ),
          ),
      ],
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<ImageSource>(
      useSafeArea: true,
      // Root navigator: from the embedded two-pane detail the nearest
      // navigator is the shell branch, whose barrier misses the rail,
      // bottom bar, and shell FAB (they overlap the sheet on a foldable).
      useRootNavigator: true,
      context: context,
      constraints: sheetConstraints(context),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final XFile? picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 70, // keep uploads well under the server's post limit
      maxWidth: 2000,
    );
    if (picked == null) return;

    final repo = ref.read(attachmentRepositoryProvider);
    final actions = ref.read(ticketActionsProvider);
    if (repo == null || actions == null) return;
    final filename = p.basename(picked.path);
    final stored = await repo.importFile(picked.path, filename);
    await actions.addAttachment(
      ownerLocalId: ownerLocalId,
      ownerServerId: ownerServerId,
      itemtype: itemtype,
      localPath: stored.path,
      name: filename,
      mime: picked.mimeType,
      sizeBytes: stored.size,
    );
  }
}

class _AttachmentTile extends ConsumerWidget {
  const _AttachmentTile({required this.attachment});

  final Attachment attachment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fileAsync = ref.watch(attachmentFileProvider(attachment.localId));
    final path = fileAsync.value;

    final Widget content;
    if (attachment.isImage && path != null) {
      content = Image.file(
        File(path),
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fileIcon(theme),
      );
    } else if (attachment.isImage) {
      // Image still downloading / decoding.
      content = const SizedBox(
        width: 96,
        height: 96,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    } else {
      content = _fileIcon(theme);
    }

    final canOpen = path != null && attachment.isImage;
    return Semantics(
      // A thumbnail is a picture of a picture: without this it is an anonymous
      // 96px box. Name it, say whether it is still uploading, and say what a
      // tap does — only images have a preview.
      label: semanticSentence([
        attachment.name,
        attachment.isImage ? 'image' : 'file',
        if (attachment.pending) 'uploading',
      ]),
      button: canOpen,
      hint: canOpen ? 'Open preview' : null,
      onTap: canOpen ? () => _open(context, path) : null,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: path == null ? null : () => _open(context, path),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                color: theme.colorScheme.surfaceContainerHighest,
                child: content,
              ),
              if (attachment.pending)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fileIcon(ThemeData theme) => SizedBox(
    width: 96,
    height: 96,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.insert_drive_file_outlined,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 4),
        // Flexible, not Padding: the tile is a fixed 96 square and a long name
        // at a large font scale would otherwise overflow the column.
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              attachment.name,
              style: theme.textTheme.labelSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ),
  );

  void _open(BuildContext context, String path) {
    if (!attachment.isImage) return; // preview images only for now
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ImageViewer(path: path, title: attachment.name),
      ),
    );
  }
}

/// Full-screen, pinch-to-zoom image preview.
class _ImageViewer extends StatelessWidget {
  const _ImageViewer({required this.path, required this.title});

  final String path;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 5,
          child: Image.file(File(path), semanticLabel: title),
        ),
      ),
    );
  }
}
