import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/widgets/two_pane.dart';

/// Wraps [child] in a window of [size], optionally with a foldable hinge.
Widget _window({
  required Widget child,
  Size size = const Size(1000, 800),
  List<DisplayFeature> features = const [],
  double railWidth = 0,
}) => MediaQuery(
  data: MediaQueryData(size: size, displayFeatures: features),
  child: MaterialApp(
    home: Scaffold(
      body: Row(
        children: [
          // Stands in for the navigation rail, so TwoPane is offset from the
          // left edge exactly as it is in the real shell.
          SizedBox(width: railWidth),
          Expanded(child: child),
        ],
      ),
    ),
  ),
);

void main() {
  testWidgets('splits at a fixed width when there is no hinge', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _window(
        child: const TwoPane(
          start: Text('list'),
          end: Text('detail'),
          startWidth: 300,
        ),
      ),
    );

    expect(tester.getSize(find.text('list')).width, lessThanOrEqualTo(300));
    expect(find.text('detail'), findsOneWidget);
  });

  testWidgets('puts the split on a vertical hinge', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const rail = 80.0;
    await tester.pumpWidget(
      _window(
        railWidth: rail,
        features: const [
          DisplayFeature(
            bounds: Rect.fromLTRB(490, 0, 510, 800),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.postureHalfOpened,
          ),
        ],
        child: const TwoPane(start: Text('list'), end: Text('detail')),
      ),
    );

    // The start pane must end where the hinge begins — 490 in screen
    // coordinates, i.e. 410 inside a box that starts after an 80px rail.
    final listRight = tester.getTopRight(find.text('list')).dx;
    expect(listRight, lessThanOrEqualTo(490));
    // And the detail must start after the hinge, never under it.
    expect(
      tester.getTopLeft(find.text('detail')).dx,
      greaterThanOrEqualTo(510),
    );
  });

  testWidgets('with no rail the panes are the two halves', (tester) async {
    // A phone in landscape: expanded by width so it has two panes, compact by
    // height so navigation is a bar rather than a rail. TwoPane therefore
    // starts at the window's left edge with nothing offsetting it, and the
    // split still has to land on the fold rather than at startWidth.
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _window(
        railWidth: 0,
        features: const [
          DisplayFeature(
            bounds: Rect.fromLTRB(490, 0, 510, 800),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.postureHalfOpened,
          ),
        ],
        child: const TwoPane(start: Text('list'), end: Text('detail')),
      ),
    );

    expect(tester.getTopLeft(find.text('list')).dx, 0);
    expect(tester.getTopRight(find.text('list')).dx, lessThanOrEqualTo(490));
    expect(
      tester.getTopLeft(find.text('detail')).dx,
      greaterThanOrEqualTo(510),
    );
  });

  testWidgets('renders with an empty pane and a hinge', (tester) async {
    // Regression: computing the hinge offset via findRenderObject() inside
    // LayoutBuilder threw before layout, which release builds paint as a bare
    // grey box — the whole screen, both panes.
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _window(
        railWidth: 80,
        features: const [
          DisplayFeature(
            bounds: Rect.fromLTRB(490, 0, 510, 800),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.postureHalfOpened,
          ),
        ],
        child: const TwoPane(
          start: Center(child: Text('nothing here')),
          end: Center(child: Text('pick one')),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('nothing here'), findsOneWidget);
    expect(find.text('pick one'), findsOneWidget);
  });

  testWidgets('ignores a hinge that falls outside the pane', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _window(
        // The whole widget sits to the right of the hinge (half-screen
        // multitasking): splitting on it would put a pane at zero width.
        railWidth: 600,
        features: const [
          DisplayFeature(
            bounds: Rect.fromLTRB(490, 0, 510, 800),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.postureHalfOpened,
          ),
        ],
        child: const TwoPane(
          start: Text('list'),
          end: Text('detail'),
          startWidth: 200,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('list'), findsOneWidget);
    expect(find.text('detail'), findsOneWidget);
  });
}
