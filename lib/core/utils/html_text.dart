// One place for the HTML⇄text conversions the app needs, replacing the five
// slightly-different tag strippers that used to live in the screens.

/// The idempotency marker the outbox embeds in created content. GLPI keeps HTML
/// comments verbatim, which is what makes it a reliable dedup key — but it must
/// never reach the screen.
final _opMarker = RegExp(r'<!--\s*op:[^>]*-->', dotAll: true);

/// Does this look like markup, or like something a person typed?
///
/// GLPI content is HTML when it came from its editor and plain text when it
/// came from a script, an email drop, or this app's quick composer. Feeding
/// plain text to an HTML renderer silently eats its line breaks, so the two
/// cases are told apart rather than assumed.
bool looksLikeHtml(String value) => RegExp(
  r'<(/?)(p|br|div|ul|ol|li|b|strong|i|em|u|a|h[1-6]|table|tr|td|'
  r'blockquote|pre|code|span|img)\b[^>]*>',
  caseSensitive: false,
).hasMatch(value);

/// Markup the mobile editor cannot represent, and would therefore destroy on
/// save.
///
/// Quill has no table model: a GLPI table imported into it comes back as a
/// single paragraph with the cell text run together, so editing a field that
/// contains one would silently flatten the author's work. Embedded images are
/// dropped the same way. Content like this is shown read-only instead.
bool htmlHasUnsupportedMarkup(String html) =>
    RegExp(r'<(table|img)\b', caseSensitive: false).hasMatch(html);

/// Strips the outbox marker (and nothing else) — safe to render afterwards.
String sanitizeGlpiHtml(String html) => html.replaceAll(_opMarker, '').trim();

/// Flattens HTML for places that must be one line: queue cards, list
/// subtitles, notification bodies, the ticket title fallback.
String htmlToPlainText(String html) {
  var text = sanitizeGlpiHtml(html);
  if (looksLikeHtml(text)) {
    text = text
        // Block boundaries become line breaks so a list doesn't run together.
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        // A paragraph break is a blank line; a list item is just a new line.
        .replaceAll(
          RegExp(r'</(p|div|h[1-6])\s*>', caseSensitive: false),
          '\n\n',
        )
        .replaceAll(RegExp(r'</(li|tr)\s*>', caseSensitive: false), '\n')
        // Table cells are separate values, not one word.
        .replaceAll(RegExp(r'</(td|th)\s*>', caseSensitive: false), ' | ')
        .replaceAll(RegExp(r'<li\b[^>]*>', caseSensitive: false), '• ')
        .replaceAll(RegExp(r'<[^>]+>'), '');
  }
  return _decodeEntities(text)
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .split('\n')
      // A row ends with a separator it doesn't need.
      .map((line) => line.trim().replaceFirst(RegExp(r'\s*\|$'), '').trim())
      .join('\n')
      .trim();
}

/// Wraps user-typed plain text as HTML, so line breaks survive the round trip
/// to GLPI (which renders content as markup).
String plainTextToHtml(String text) {
  final escaped = text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
  final paragraphs = escaped
      .split(RegExp(r'\n{2,}'))
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .map((p) => '<p>${p.replaceAll('\n', '<br>')}</p>');
  return paragraphs.isEmpty ? '' : paragraphs.join();
}

String _decodeEntities(String value) => value
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&rsquo;', '’');
