/// Small helpers that keep the accessibility rules in one place instead of
/// re-deriving them at every call site.
///
/// The rules themselves:
/// * anything you can tap gets a 48dp target ([TapTarget]) and a name
///   (a `tooltip`, a `Text` child, or a `Semantics(label:)`);
/// * state that changes without a visible dialog gets announced ([announce]);
/// * meaning is never carried by color alone — see `core/a11y/contrast.dart`
///   for the ink used by the semantic pills.
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Pads a small control out to the 48dp minimum touch target from the Material
/// guidelines (and WCAG 2.5.5 / 2.5.8).
///
/// Put it **inside** the [InkWell]/[GestureDetector], not around it, so the
/// gesture area — not just the paint — grows:
///
/// ```dart
/// InkWell(
///   onTap: _toggle,
///   child: const TapTarget(child: Icon(Icons.check_box_outlined, size: 18)),
/// )
/// ```
class TapTarget extends StatelessWidget {
  const TapTarget({
    super.key,
    required this.child,
    this.size = kMinInteractiveDimension,
  });

  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      child: Center(widthFactor: 1, heightFactor: 1, child: child),
    );
  }
}

/// Speaks [message] through the screen reader without showing anything.
///
/// For state the user did not ask for and cannot see — the outbox draining, the
/// connection dropping, a queue finishing its refresh. A [SnackBar] is already a
/// live region, so don't double-announce one.
void announce(
  BuildContext context,
  String message, {
  Assertiveness assertiveness = Assertiveness.polite,
}) {
  if (message.isEmpty) return;
  // View-scoped: SemanticsService.announce is deprecated because it guesses at
  // the implicit view, which doesn't exist in a multi-window embedding.
  SemanticsService.sendAnnouncement(
    View.of(context),
    message,
    Directionality.of(context),
    assertiveness: assertiveness,
  );
}

/// True when the platform is driving the UI through a screen reader (TalkBack,
/// VoiceOver) or another accessible-navigation service.
///
/// Use it to *add* information (spell out an abbreviated age, keep an action
/// reachable that is otherwise a swipe), never to take a feature away.
bool usingScreenReader(BuildContext context) =>
    MediaQuery.accessibleNavigationOf(context);

/// Joins the parts of a composite label, dropping the empty ones.
///
/// A card that reads "Ticket 42. Email outage. New. Assigned to Bo." is one
/// coherent sentence; the same words as eight separate nodes are a maze.
String semanticSentence(Iterable<String?> parts) => parts
    .where((p) => p != null && p.trim().isNotEmpty)
    .map((p) => p!.trim())
    .map(
      (p) => p.endsWith('.') || p.endsWith('?') || p.endsWith('!') ? p : '$p.',
    )
    .join(' ');
