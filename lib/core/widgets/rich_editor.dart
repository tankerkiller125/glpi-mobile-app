import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

import '../utils/html_text.dart';

/// A formatted-text editor that speaks GLPI's language: HTML in, HTML out.
///
/// GLPI stores everything a technician writes as HTML, so the app has to
/// produce it too — a plain string loses the numbered steps and emphasis that
/// make a work note readable. Quill edits a Delta document internally; this
/// wraps the conversion at both ends so callers only ever see HTML.
class RichEditor extends StatefulWidget {
  const RichEditor({
    super.key,
    required this.controller,
    this.hint,
    this.minLines = 4,
    this.autofocus = false,
  });

  final RichEditorController controller;
  final String? hint;
  final int minLines;
  final bool autofocus;

  @override
  State<RichEditor> createState() => _RichEditorState();
}

class _RichEditorState extends State<RichEditor> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          constraints: BoxConstraints(
            minHeight: widget.minLines * 22.0,
            maxHeight: 320,
          ),
          child: QuillEditor.basic(
            controller: widget.controller.quill,
            focusNode: _focus,
            config: QuillEditorConfig(
              placeholder: widget.hint,
              autoFocus: widget.autofocus,
              expands: false,
              scrollable: true,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Only the formatting a technician actually reaches for on a phone;
        // the full Quill toolbar is a desktop ribbon.
        QuillSimpleToolbar(
          controller: widget.controller.quill,
          config: const QuillSimpleToolbarConfig(
            multiRowsDisplay: false,
            showFontFamily: false,
            showFontSize: false,
            showBackgroundColorButton: false,
            showColorButton: false,
            showSubscript: false,
            showSuperscript: false,
            showSearchButton: false,
            showInlineCode: false,
            showClearFormat: false,
            showIndent: false,
            showAlignmentButtons: false,
            showHeaderStyle: true,
            showCodeBlock: false,
            showQuote: true,
            showListCheck: false,
            showStrikeThrough: false,
            showUndo: true,
            showRedo: true,
          ),
        ),
      ],
    );
  }
}

/// Owns the Quill document and the HTML conversion at both ends.
class RichEditorController {
  RichEditorController({String html = ''}) : quill = QuillController.basic() {
    setHtml(html);
  }

  final QuillController quill;

  /// Load existing content. Plain text is wrapped first so its line breaks
  /// survive — Quill's HTML importer would otherwise collapse them.
  void setHtml(String html) {
    final cleaned = sanitizeGlpiHtml(html);
    if (cleaned.isEmpty) return;
    final source = looksLikeHtml(cleaned) ? cleaned : plainTextToHtml(cleaned);
    try {
      final delta = HtmlToDelta().convert(source);
      quill.document = Document.fromDelta(delta);
    } on Exception {
      // Markup we can't import (an odd table, say) still has to be editable:
      // fall back to its text rather than showing an empty box.
      quill.document = Document()..insert(0, htmlToPlainText(cleaned));
    }
    quill.moveCursorToEnd();
  }

  /// The HTML to send GLPI. Empty when the user typed nothing, so callers can
  /// treat it like an empty text field.
  String toHtml() {
    if (isEmpty) return '';
    final converter = QuillDeltaToHtmlConverter(
      quill.document.toDelta().toJson(),
      ConverterOptions.forEmail(),
    );
    return converter.convert().trim();
  }

  bool get isEmpty => quill.document.toPlainText().trim().isEmpty;

  void clear() => quill.document = Document();

  void dispose() => quill.dispose();
}
