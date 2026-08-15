import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// [RefreshIndicator] with a refresh that doesn't require the gesture.
///
/// Pull-to-refresh is a swipe, and a swipe is exactly what a screen reader
/// takes over: with TalkBack or VoiceOver running, the pull never reaches the
/// scroll view, so the only way to reload a list is to leave the app and come
/// back. This adds "Refresh" as a custom semantics action, which surfaces in
/// TalkBack's actions menu and VoiceOver's rotor, and leaves the visual
/// behaviour exactly as it was.
///
/// Every list that can be pulled uses this instead of [RefreshIndicator].
class AccessibleRefresh extends StatelessWidget {
  const AccessibleRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final RefreshCallback onRefresh;
  final Widget child;

  static const _refresh = CustomSemanticsAction(label: 'Refresh');

  @override
  Widget build(BuildContext context) {
    return Semantics(
      customSemanticsActions: {_refresh: () => onRefresh()},
      child: RefreshIndicator(onRefresh: onRefresh, child: child),
    );
  }
}
