import 'dart:math' as math;
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

  /// Small tablets, large phones in landscape, half-screen multitasking,
  /// unfolded foldables held in portrait.
  medium,

  /// Tablets in landscape, and unfolded foldables in landscape.
  expanded,

  /// Large tablet and desktop displays.
  large;

  bool get isCompact => this == WindowSize.compact;

  /// Room to show a list and a detail at once.
  bool get hasTwoPanes =>
      this == WindowSize.expanded || this == WindowSize.large;
}

/// Material's width breakpoints: compact below 600, medium to 839, expanded to
/// 1199, large above that. Extra-large (1600+) is not split out because this
/// app treats it the same as large.
WindowSize windowSizeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 600) return WindowSize.compact;
  if (width < 840) return WindowSize.medium;
  if (width < 1200) return WindowSize.expanded;
  return WindowSize.large;
}

/// Material's compact *height* breakpoint. A phone in landscape is wide and
/// short, and the short axis is the one that has run out.
const double _compactHeight = 480;

/// How the shell should offer its top-level destinations.
enum NavStyle {
  /// A bar under the content.
  bottomBar,

  /// A collapsed, icon-only rail beside it.
  rail,

  /// A wide, labelled rail beside it.
  extendedRail;

  bool get isRail => this != NavStyle.bottomBar;
}

/// The navigation affordance for this window, per Material's adaptive rule:
/// a navigation bar when the width *or the height* is compact, or when the
/// device is in tabletop posture; a rail for everything else.
///
/// Two consequences worth knowing, because both used to be got wrong here.
///
/// A phone in landscape is around 850x390: expanded by width, compact by
/// height. Deciding on width alone gave it the full labelled rail a desktop
/// gets, which is a quarter of a phone screen spent on three destinations.
///
/// And the rail is only *expanded* at large widths (1200dp and up). An
/// unfolded foldable is 840–1199 — expanded, not large — so it gets the
/// collapsed rail, and the two panes either side of the fold keep the width
/// the labelled rail used to take out of the list.
NavStyle navStyleOf(BuildContext context) {
  if (MediaQuery.sizeOf(context).height < _compactHeight) {
    return NavStyle.bottomBar;
  }
  // Half-open on a horizontal fold: the lower half is lying on the table and
  // is where the hands are, so navigation belongs at the bottom.
  if (isTabletopPosture(context)) return NavStyle.bottomBar;

  final size = windowSizeOf(context);
  if (size.isCompact) return NavStyle.bottomBar;
  return size == WindowSize.large ? NavStyle.extendedRail : NavStyle.rail;
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

/// True in tabletop posture: half-opened on a hinge that runs left to right,
/// so the screen is split into an upright top half and a flat bottom half.
///
/// Half-opened only. Laid flat the device is one surface again and behaves
/// like any tablet of its size, which is why a flat fold counts for
/// [verticalHingeOf] — a pane split still wants to avoid the seam — but not
/// here, where the question is which way the device is being held.
bool isTabletopPosture(BuildContext context) {
  for (final feature in MediaQuery.of(context).displayFeatures) {
    if (feature.state != DisplayFeatureState.postureHalfOpened) continue;
    if (feature.bounds.width > feature.bounds.height) return true;
  }
  return false;
}

/// True once the user's font size makes side-by-side label/value rows
/// unworkable, so a layout should stack instead.
///
/// Android and iOS both go past 200%, and the app's detail rows put a
/// fixed-width label beside its value — at that scale the label wins the space
/// and the value is left with three ellipsised characters. The threshold is
/// 1.4×, measured on real body text rather than assumed, because a text scaler
/// is not necessarily linear (iOS's accessibility sizes are a curve).
bool prefersStackedRows(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(14) > 14 * 1.4;

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

/// Kept between the top of a sheet and the status bar, so the drag handle is
/// somewhere a thumb can start a downward swipe without the gesture belonging
/// to the system instead.
const double _sheetTopGap = 24;

/// A bottom sheet stretched across a tablet is a wall of whitespace with the
/// controls at the far edges. Cap it, centre it — and cap how *tall* it can
/// get, which is the half that matters on a phone.
///
/// **Why the height cap exists.** A modal sheet grows with its content, and its
/// content grows by the height of the keyboard (sheets pad themselves by
/// `viewInsets.bottom` so the field being typed into stays visible). A list
/// sheet with the keyboard up could therefore end up taller than the screen,
/// which pushes its top — and the drag handle with it — behind the status bar.
/// The handle is then in the notification shade's gesture area: pulling down
/// opens Android's shade instead of dismissing the sheet, and there is no
/// other way out of a modal that owns the whole screen.
BoxConstraints sheetConstraints(BuildContext context) {
  final media = MediaQuery.of(context);
  final maxHeight = math.max(
    // A degenerate window (a tiny split-screen) still gets a usable sheet
    // rather than a negative constraint.
    240.0,
    media.size.height - media.padding.top - _sheetTopGap,
  );

  return windowSizeOf(context).isCompact
      ? BoxConstraints(maxHeight: maxHeight)
      : BoxConstraints(maxWidth: 640, maxHeight: maxHeight);
}

/// How tall a sheet's own content may be — a *fraction of the window*, but
/// never more than what is left once the status bar, the keyboard and the drag
/// handle have taken theirs.
///
/// The fraction is what a designer wants ("about two thirds of the screen");
/// the subtraction is what stops that being a promise the window cannot keep.
/// Use it wherever a sheet sizes itself rather than sizing to its content:
/// a `SizedBox(height: MediaQuery.sizeOf(context).height * 0.6)` inside a
/// keyboard-padded sheet is exactly how the handle ends up off-screen.
double sheetContentHeight(BuildContext context, {double fraction = 0.6}) {
  final media = MediaQuery.of(context);
  final available =
      media.size.height -
      media.padding.top -
      media.viewInsets.bottom -
      _sheetTopGap -
      // The drag handle Material draws above the content.
      _dragHandleHeight;

  return math.max(160.0, math.min(media.size.height * fraction, available));
}

/// Material's drag-handle row: a 4dp bar with 22dp of padding either side.
const double _dragHandleHeight = 48;
