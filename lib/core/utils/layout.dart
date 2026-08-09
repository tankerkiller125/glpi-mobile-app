import 'dart:ui' show DisplayFeatureState;

import 'package:flutter/material.dart';

/// Material 3 window size classes.
///
/// The app is built for a technician's phone first; these describe when there
/// is genuinely more room to work with — a tablet, an unfolded foldable, or a
/// phone in landscape — rather than trying to detect device types, which lie.
enum WindowSize {
  /// Phones, and folded foldables.
  compact,

  /// Small tablets, large phones in landscape, half-screen multitasking.
  medium,

  /// Tablets and unfolded foldables.
  expanded;

  bool get isCompact => this == WindowSize.compact;

  /// Room for a side rail instead of a bottom bar.
  bool get hasRail => this != WindowSize.compact;

  /// Room to show a list and a detail at once.
  bool get hasTwoPanes => this == WindowSize.expanded;
}

WindowSize windowSizeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 600) return WindowSize.compact;
  if (width < 840) return WindowSize.medium;
  return WindowSize.expanded;
}

/// Where a foldable's hinge crosses this box, in local coordinates.
///
/// Returning the hinge lets a two-pane layout put its split *on* the fold
/// rather than laying content across it, which is unreadable on a book-style
/// device and physically awkward on a table-top one.
Rect? verticalHingeOf(BuildContext context) {
  final media = MediaQuery.of(context);
  for (final feature in media.displayFeatures) {
    final isSeparating =
        feature.state == DisplayFeatureState.postureFlat ||
        feature.state == DisplayFeatureState.postureHalfOpened;
    // A vertical hinge splits the screen left/right, which is the only case a
    // horizontal two-pane split cares about.
    final isVertical = feature.bounds.height >= feature.bounds.width;
    if (isSeparating && isVertical) return feature.bounds;
  }
  return null;
}

/// Long-form text is unreadable at tablet width; cap the measure and centre it.
class ReadableWidth extends StatelessWidget {
  const ReadableWidth({super.key, required this.child, this.maxWidth = 720});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

/// A bottom sheet stretched across a tablet is a wall of whitespace with the
/// controls at the far edges. Cap it and centre it.
BoxConstraints? sheetConstraints(BuildContext context) =>
    windowSizeOf(context).isCompact
    ? null
    : const BoxConstraints(maxWidth: 640);
