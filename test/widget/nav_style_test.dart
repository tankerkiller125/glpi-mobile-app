import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/utils/layout.dart';

/// A hinge running top-to-bottom down the middle: book posture.
List<DisplayFeature> _bookFold(
  double width,
  double height, {
  DisplayFeatureState state = DisplayFeatureState.postureHalfOpened,
}) => [
  DisplayFeature(
    bounds: Rect.fromLTRB(width / 2 - 10, 0, width / 2 + 10, height),
    type: DisplayFeatureType.hinge,
    state: state,
  ),
];

/// A hinge running left-to-right across the middle: tabletop posture.
List<DisplayFeature> _tabletopFold(double width, double height) => [
  DisplayFeature(
    bounds: Rect.fromLTRB(0, height / 2 - 10, width, height / 2 + 10),
    type: DisplayFeatureType.hinge,
    state: DisplayFeatureState.postureHalfOpened,
  ),
];

/// Resolves [navStyleOf] for a window of [size] with [features].
Future<NavStyle> _styleFor(
  WidgetTester tester,
  Size size, {
  List<DisplayFeature> features = const [],
}) async {
  late NavStyle seen;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size, displayFeatures: features),
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            seen = navStyleOf(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  return seen;
}

void main() {
  group('windowSizeOf', () {
    testWidgets('splits at Material\'s width breakpoints', (tester) async {
      Future<WindowSize> sizeFor(double width) async {
        late WindowSize seen;
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(size: Size(width, 1000)),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  seen = windowSizeOf(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
        return seen;
      }

      expect(await sizeFor(599), WindowSize.compact);
      expect(await sizeFor(600), WindowSize.medium);
      expect(await sizeFor(839), WindowSize.medium);
      expect(await sizeFor(840), WindowSize.expanded);
      expect(await sizeFor(1199), WindowSize.expanded);
      expect(await sizeFor(1200), WindowSize.large);
    });

    test('large keeps two panes', () {
      // Adding the large class must not cost the desktop its detail pane.
      expect(WindowSize.large.hasTwoPanes, isTrue);
      expect(WindowSize.expanded.hasTwoPanes, isTrue);
      expect(WindowSize.medium.hasTwoPanes, isFalse);
      expect(WindowSize.compact.hasTwoPanes, isFalse);
    });
  });

  group('navStyleOf', () {
    testWidgets('a phone in portrait gets the bar', (tester) async {
      expect(await _styleFor(tester, const Size(400, 900)), NavStyle.bottomBar);
    });

    testWidgets('a phone in landscape gets the bar, not a rail', (
      tester,
    ) async {
      // 851x393 is expanded by width and compact by height. Deciding on width
      // alone handed a phone the labelled rail a desktop gets.
      expect(await _styleFor(tester, const Size(851, 393)), NavStyle.bottomBar);
    });

    testWidgets('a tablet in portrait gets the collapsed rail', (tester) async {
      expect(await _styleFor(tester, const Size(700, 1000)), NavStyle.rail);
    });

    testWidgets('an unfolded foldable gets the collapsed rail', (tester) async {
      // 840-1199 is expanded, not large: the rail stays collapsed, so the two
      // panes either side of the fold keep the width a labelled rail would
      // have taken out of the list.
      expect(
        await _styleFor(
          tester,
          const Size(1000, 800),
          features: _bookFold(1000, 800),
        ),
        NavStyle.rail,
      );
    });

    testWidgets('a tablet in landscape gets the collapsed rail', (
      tester,
    ) async {
      expect(await _styleFor(tester, const Size(1100, 800)), NavStyle.rail);
    });

    testWidgets('a large display gets the labelled rail', (tester) async {
      expect(
        await _styleFor(tester, const Size(1400, 1000)),
        NavStyle.extendedRail,
      );
    });

    testWidgets('tabletop posture sends navigation to the bar', (tester) async {
      // Half-open on a horizontal fold: the bottom half is on the table and is
      // where the hands are.
      expect(
        await _styleFor(
          tester,
          const Size(1000, 800),
          features: _tabletopFold(1000, 800),
        ),
        NavStyle.bottomBar,
      );
    });

    testWidgets('a flat device is not in tabletop posture', (tester) async {
      // Opened flat it is one surface again, whichever way the fold runs.
      expect(
        await _styleFor(
          tester,
          const Size(1400, 1000),
          features: const [
            DisplayFeature(
              bounds: Rect.fromLTRB(0, 490, 1400, 510),
              type: DisplayFeatureType.hinge,
              state: DisplayFeatureState.postureFlat,
            ),
          ],
        ),
        NavStyle.extendedRail,
      );
    });

    testWidgets('a book fold never counts as tabletop', (tester) async {
      expect(
        await _styleFor(
          tester,
          const Size(1400, 1000),
          features: _bookFold(1400, 1000),
        ),
        NavStyle.extendedRail,
      );
    });
  });
}
