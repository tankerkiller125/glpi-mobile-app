import 'package:flutter/material.dart';

import '../utils/layout.dart';

/// A list beside a detail, split on the fold when there is one.
///
/// On a foldable, laying a pane across the hinge puts a seam (and on some
/// devices a physical gap) through the middle of the content. When a vertical
/// separating hinge is present the split lands exactly on it, so each pane
/// occupies one physical half; otherwise the start pane takes a fixed,
/// comfortable width and the detail gets the rest.
class TwoPane extends StatelessWidget {
  const TwoPane({
    super.key,
    required this.start,
    required this.end,
    this.startWidth = 380,
  });

  final Widget start;
  final Widget end;

  /// Used only when there is no hinge to split on.
  final double startWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hinge = verticalHingeOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        double leftWidth = startWidth;
        double gap = 0;
        if (hinge != null) {
          // The hinge is reported in screen coordinates. This widget is the
          // last child of the shell's row, so whatever width it was *not*
          // given sits to its left (the navigation rail).
          //
          // Deliberately not `findRenderObject()`: inside a LayoutBuilder the
          // render object has not been laid out yet, so asking for its offset
          // throws — and a throw here paints the whole pane as a grey box in
          // release builds.
          final inset = MediaQuery.sizeOf(context).width - constraints.maxWidth;
          final local = hinge.left - inset;
          // A hinge outside our box (half-screen multitasking, say) is not
          // ours to split on.
          if (local > 0 && local < constraints.maxWidth) {
            leftWidth = local;
            gap = hinge.width;
          }
        }

        return Row(
          children: [
            SizedBox(width: leftWidth, child: start),
            if (gap > 0)
              SizedBox(width: gap)
            else
              VerticalDivider(
                width: 1,
                color: theme.colorScheme.outlineVariant,
              ),
            Expanded(child: end),
          ],
        );
      },
    );
  }
}
