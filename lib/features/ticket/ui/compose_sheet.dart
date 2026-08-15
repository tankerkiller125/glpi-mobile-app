import 'package:flutter/material.dart';

import '../../../core/utils/layout.dart';
import '../../../core/widgets/rich_editor.dart';

/// A simple multiline text-entry bottom sheet used for solutions, approval
/// requests, and refusal reasons. Returns the entered text, or null if
/// dismissed.
class ComposeSheet extends StatefulWidget {
  const ComposeSheet({
    super.key,
    required this.title,
    required this.hint,
    required this.submitLabel,
    this.initialText = '',
    this.rich = false,
  });

  final String title;
  final String hint;
  final String submitLabel;

  /// Pre-fills the field when editing existing text (e.g. analysis notes).
  final String initialText;

  /// Edit as formatted text and return HTML. GLPI stores ticket content,
  /// followups, solutions and analysis fields as HTML; plain fields like an
  /// asset's comment stay plain.
  final bool rich;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String hint,
    required String submitLabel,
    String initialText = '',
    bool rich = false,
  }) => showModalBottomSheet<String>(
    context: context,
    constraints: sheetConstraints(context),
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => ComposeSheet(
      title: title,
      hint: hint,
      submitLabel: submitLabel,
      initialText: initialText,
      rich: rich,
    ),
  );

  @override
  State<ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends State<ComposeSheet> {
  late final _controller = TextEditingController(text: widget.initialText);
  late final _rich = widget.rich
      ? RichEditorController(html: widget.initialText)
      : null;

  @override
  void dispose() {
    _controller.dispose();
    _rich?.dispose();
    super.dispose();
  }

  String get _result => _rich != null ? _rich.toHtml() : _controller.text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The sheet's own heading: a modal that opens over a screen has to
          // announce what it is, and the reader lands on the first node.
          Semantics(
            header: true,
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 12),
          if (_rich != null)
            RichEditor(controller: _rich, hint: widget.hint, autofocus: true)
          else
            Semantics(
              // The hint vanishes as soon as there is text; the field still
              // needs a name after that.
              label: widget.title,
              textField: true,
              child: TextField(
                controller: _controller,
                autofocus: true,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => Navigator.pop(context, _result),
                child: Text(widget.submitLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
