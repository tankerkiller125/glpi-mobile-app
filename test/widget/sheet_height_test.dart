import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/utils/layout.dart';

/// A phone-shaped window with a status bar, and optionally a keyboard up.
MediaQueryData _window({double keyboard = 0}) => MediaQueryData(
  size: const Size(400, 800),
  padding: const EdgeInsets.only(top: 40, bottom: 20),
  viewInsets: EdgeInsets.only(bottom: keyboard),
);

/// Reads a value out of a build under [data].
Future<T> _resolve<T>(
  WidgetTester tester,
  MediaQueryData data,
  T Function(BuildContext) read,
) async {
  late T seen;
  await tester.pumpWidget(
    MediaQuery(
      data: data,
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            seen = read(context);
            return const SizedBox();
          },
        ),
      ),
    ),
  );
  return seen;
}

void main() {
  group('Sheet sizing', () {
    testWidgets('content never claims more than the window has left', (
      tester,
    ) async {
      // The reported failure: a sheet asking for 60% of an 800dp window while
      // a 500dp keyboard is up, on top of which the sheet pads itself by the
      // keyboard's height — 480 + 500 is taller than the window, so the top of
      // the sheet (and its drag handle) ends up behind the status bar.
      final withKeyboard = await _resolve(
        tester,
        _window(keyboard: 500),
        (context) => sheetContentHeight(context),
      );

      expect(withKeyboard + 500, lessThanOrEqualTo(800 - 40));
    });

    testWidgets('and still asks for the fraction when there is room', (
      tester,
    ) async {
      final relaxed = await _resolve(
        tester,
        _window(),
        (context) => sheetContentHeight(context),
      );

      expect(relaxed, 800 * 0.6);
    });

    testWidgets('a degenerate window still gets a usable sheet', (
      tester,
    ) async {
      // Split-screen with the keyboard up: the arithmetic goes negative, and a
      // negative constraint is a crash rather than a small sheet.
      final tiny = await _resolve(
        tester,
        const MediaQueryData(
          size: Size(400, 320),
          padding: EdgeInsets.only(top: 40),
          viewInsets: EdgeInsets.only(bottom: 260),
        ),
        (context) => sheetContentHeight(context),
      );

      expect(tiny, greaterThan(0));
    });

    testWidgets('the shared constraints leave the status bar clear', (
      tester,
    ) async {
      final constraints = await _resolve(
        tester,
        _window(),
        (context) => sheetConstraints(context),
      );

      expect(constraints.maxHeight, lessThan(800 - 40));
    });
  });

  group('The drag handle stays reachable', () {
    testWidgets('with the keyboard up and a tall sheet', (tester) async {
      // The whole point of the fix, asserted where it is visible: open a real
      // modal sheet, sized the way the pickers size themselves, and check that
      // its top edge — the handle's row — is below the status bar rather than
      // behind it.
      await tester.pumpWidget(
        MediaQuery(
          data: _window(keyboard: 500),
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    useSafeArea: true,
                    showDragHandle: true,
                    isScrollControlled: true,
                    constraints: sheetConstraints(context),
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: SizedBox(
                        height: sheetContentHeight(context),
                        child: const Center(child: Text('list')),
                      ),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final sheet = tester.getRect(find.byType(BottomSheet));
      expect(sheet.top, greaterThanOrEqualTo(40));
      expect(find.text('list'), findsOneWidget);
    });
  });
}
