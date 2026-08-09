import 'package:flutter/material.dart';

/// Replaces Flutter's default error placeholder with something a technician —
/// or whoever they send the screenshot to — can act on.
///
/// In release builds the default is a **bare grey rectangle**: no text, no
/// stack, nothing in the logs. A single field that throws silently swallows the
/// rest of the screen, which has now hidden two real bugs (a two-pane layout
/// that failed on an empty queue, and a form field that choked on a value GLPI
/// typed inconsistently). Showing the error inline costs nothing and turns a
/// mystery into a bug report.
void installInlineErrorWidget() {
  ErrorWidget.builder = (details) => _InlineError(details: details);
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    // No Theme is guaranteed here — this can be built above MaterialApp.
    final message = details.exceptionAsString();
    return Semantics(
      container: true,
      label: 'Display error',
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          border: Border.all(color: const Color(0xFFE65100)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This part didn't load",
              textDirection: TextDirection.ltr,
              style: TextStyle(
                color: Color(0xFFE65100),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              // The exception text is the actionable part; the stack is in the
              // logs. Cap it so one long message can't take over the screen.
              message.length > 300 ? '${message.substring(0, 300)}…' : message,
              textDirection: TextDirection.ltr,
              style: const TextStyle(color: Color(0xFF5D4037), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
