import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/html_text.dart';

/// Renders the HTML GLPI stores for descriptions, followups, tasks, solutions
/// and analysis fields.
///
/// Everything a technician writes in GLPI's web editor is HTML — paragraphs,
/// lists, bold, links, tables. The app used to strip the tags and show one flat
/// run of text, which turned a numbered procedure into an unreadable sentence.
class RichContent extends StatelessWidget {
  const RichContent(
    this.html, {
    super.key,
    this.style,
    this.maxLines,
    this.selectable = true,
  });

  final String html;

  /// Base text style; defaults to the surrounding body text.
  final TextStyle? style;

  /// Collapse to a preview of at most this many lines (queue cards, list
  /// subtitles). Rendering is plain text in that case — a clamped rich tree
  /// can't be truncated reliably.
  final int? maxLines;

  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = style ?? theme.textTheme.bodyMedium!;
    final cleaned = sanitizeGlpiHtml(html);

    if (maxLines != null) {
      return Text(
        htmlToPlainText(cleaned),
        style: base,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Plain text (an offline-composed reply, or a GLPI field never touched by
    // the editor) renders as-is: running it through the HTML parser would eat
    // its line breaks.
    if (!looksLikeHtml(cleaned)) {
      return selectable
          ? SelectableText(cleaned, style: base)
          : Text(cleaned, style: base);
    }

    return Html(
      data: cleaned,
      style: {
        // Kill the default 1em margins so a single paragraph doesn't float in
        // the middle of a card.
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(base.fontSize ?? 14),
          color: base.color,
          fontFamily: base.fontFamily,
          lineHeight: LineHeight.number(1.35),
        ),
        'p': Style(margin: Margins.only(bottom: 8)),
        'ul': Style(margin: Margins.only(left: 16, bottom: 8)),
        'ol': Style(margin: Margins.only(left: 16, bottom: 8)),
        'li': Style(margin: Margins.only(bottom: 2)),
        'a': Style(color: theme.colorScheme.primary),
        'blockquote': Style(
          margin: Margins.only(left: 8, bottom: 8),
          padding: HtmlPaddings.only(left: 10),
          border: Border(
            left: BorderSide(color: theme.colorScheme.outlineVariant, width: 3),
          ),
        ),
        'pre': Style(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          padding: HtmlPaddings.all(8),
          fontFamily: 'monospace',
        ),
        'code': Style(fontFamily: 'monospace'),
        'table': Style(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          margin: Margins.only(bottom: 8),
        ),
        'th': Style(
          padding: HtmlPaddings.all(6),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          fontWeight: FontWeight.w600,
        ),
        'td': Style(
          padding: HtmlPaddings.all(6),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
      },
      onLinkTap: (url, _, _) async {
        if (url == null) return;
        final uri = Uri.tryParse(url);
        if (uri == null) return;
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      extensions: [
        // flutter_html 3.x ships table rendering as a separate package; without
        // this extension a <table> isn't handled at all and its cells collapse
        // into a run of text. GLPI's editor produces real tables, so it matters.
        const TableHtmlExtension(),
        // GLPI embeds images as document URLs that need the session/OAuth
        // token, so they'd render as a broken box. Say what it is instead —
        // the file itself is reachable from Attachments.
        TagExtension(
          tagsToExtend: {'img'},
          builder: (context) =>
              _ImagePlaceholder(alt: context.attributes['alt'] ?? 'Image'),
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.alt});

  final String alt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_outlined,
            size: 16,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              alt.isEmpty ? 'Image — see Attachments' : alt,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
