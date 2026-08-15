import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/a11y/a11y.dart';
import 'package:glpi_mobile/core/models/ticket_list_item.dart';
import 'package:glpi_mobile/core/models/timeline_entry.dart';
import 'package:glpi_mobile/core/providers.dart';
import 'package:glpi_mobile/core/theme/app_theme.dart';
import 'package:glpi_mobile/core/widgets/accessible_refresh.dart';
import 'package:glpi_mobile/core/widgets/info_tile.dart';
import 'package:glpi_mobile/core/widgets/section_heading.dart';
import 'package:glpi_mobile/core/widgets/status_chip.dart';
import 'package:glpi_mobile/features/queue/ui/ticket_card.dart';
import 'package:glpi_mobile/features/ticket/ui/timeline_entry_tile.dart';

/// The accessibility contract for the surfaces a technician lives in.
///
/// Flutter ships the WCAG-derived guidelines used here (`androidTapTargetGuideline`,
/// `labeledTapTargetGuideline`, `textContrastGuideline`); the rest of the
/// assertions pin the *content* of the semantics tree, because a labelled node
/// with the wrong words is as useless as an unlabelled one.
void main() {
  Widget host(Widget child, {double textScale = 1.0, Brightness? brightness}) {
    return ProviderScope(
      // The card watches the outbox for its "waiting to sync" badge; a stub
      // keeps the widget test off the database (whose live query would outlive
      // the test as a pending timer).
      overrides: [
        ticketPendingCountProvider.overrideWith((ref, arg) => Stream.value(0)),
      ],
      child: MaterialApp(
        theme: brightness == Brightness.dark
            ? buildDarkTheme()
            : buildLightTheme(),
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    );
  }

  TicketListItem ticket({
    int? serverId = 42,
    int status = 1,
    int priority = 4,
    DateTime? due,
  }) => TicketListItem(
    localId: 'local-1',
    serverId: serverId,
    itemtype: 'Ticket',
    name: 'Email outage',
    status: status,
    priority: priority,
    categoryName: 'Hardware',
    entityName: 'Acme',
    dateMod: DateTime.now().subtract(const Duration(hours: 4)),
    dateCreation: DateTime.now().subtract(const Duration(days: 1)),
    timeToResolve: due,
    assignedUserIds: const {},
    assignedGroupIds: const {},
    requesterName: 'Alice',
  );

  group('queue card', () {
    testWidgets('reads as one sentence, not eight fragments', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(TicketCard(ticket: ticket(), onTap: () {})));
      await tester.pump();

      final node = tester.getSemantics(find.byType(TicketCard));
      expect(node.label, contains('Ticket 42'));
      expect(node.label, contains('Email outage'));
      expect(node.label, contains('Priority High'));
      expect(node.label, contains('Status New'));
      expect(node.label, contains('Alice'));
      // The compact "4h" must never reach a screen reader as-is.
      expect(node.label, contains('4 hours ago'));
      expect(node.label, isNot(contains('4h')));
      handle.dispose();
    });

    testWidgets('is a button that can actually be activated', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        host(TicketCard(ticket: ticket(), onTap: () => taps++)),
      );
      await tester.pump();

      final node = tester.getSemantics(find.byType(TicketCard));
      // Regression: hiding the children's semantics also hides the InkWell's
      // tap action, so the node has to carry the action itself or a screen
      // reader's double-tap does nothing at all.
      expect(node, isSemantics(isButton: true, hasTapAction: true));
      node.owner!.performAction(node.id, SemanticsAction.tap);
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('says a queued ticket has not been sent', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(TicketCard(ticket: ticket(serverId: null), onTap: () {})),
      );
      await tester.pump();

      expect(
        tester.getSemantics(find.byType(TicketCard)).label,
        contains('not yet sent'),
      );
      handle.dispose();
    });

    testWidgets('meets the tap-target and contrast guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          TicketCard(
            ticket: ticket(due: DateTime.now().add(const Duration(hours: 2))),
            onTap: () {},
          ),
        ),
      );
      await tester.pump();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('semantic pills', () {
    for (final brightness in Brightness.values) {
      testWidgets('status chips pass contrast in ${brightness.name}', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            const Wrap(
              children: [
                StatusChip(status: 1),
                StatusChip(status: 2),
                StatusChip(status: 3),
                StatusChip(status: 4),
                StatusChip(status: 5),
                StatusChip(status: 6),
              ],
            ),
            brightness: brightness,
          ),
        );
        await tester.pump();

        // The whole reason AccentPill derives its ink: the raw GLPI greens and
        // ambers sit near 2:1 as text on their own wash.
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }

    testWidgets('a status chip names the dimension it belongs to', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const StatusChip(status: 1)));
      await tester.pump();

      expect(tester.getSemantics(find.byType(StatusChip)).label, 'Status: New');
      handle.dispose();
    });

    testWidgets('a priority dot is never colour-only', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const PriorityDot(priority: 5)));
      await tester.pump();

      expect(
        tester.getSemantics(find.byType(PriorityDot)).label,
        'Priority Very high',
      );
      handle.dispose();
    });
  });

  group('detail rows', () {
    testWidgets('read as "label, value" and expose the edit', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          InfoTile(
            icon: Icons.folder_outlined,
            label: 'Category',
            value: 'Hardware',
            onTap: () {},
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.getSemantics(find.byType(InfoTile)),
        isSemantics(
          label: 'Category',
          value: 'Hardware',
          hint: 'Edit',
          isButton: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('a tappable row reaches the 48dp target', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 400,
            child: InfoTile(
              icon: Icons.folder_outlined,
              label: 'Category',
              value: 'Hardware',
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('stacks instead of truncating at 200% text', (tester) async {
      await tester.pumpWidget(
        host(
          const SizedBox(
            width: 360,
            child: InfoTile(
              icon: Icons.person_outline,
              label: 'Requester',
              value: 'Alexandra Featherstonehaugh',
            ),
          ),
          textScale: 2.0,
        ),
      );
      await tester.pump();

      // No RenderFlex overflow, and the value is still laid out in full.
      expect(tester.takeException(), isNull);
      final label = tester.getTopLeft(find.text('Requester'));
      final value = tester.getTopLeft(find.text('Alexandra Featherstonehaugh'));
      expect(
        value.dy,
        greaterThan(label.dy),
        reason: 'the value should drop below the label, not share the row',
      );
    });
  });

  group('timeline', () {
    TimelineEntry task({bool done = false}) => TimelineEntry(
      localId: 't1',
      serverId: 7,
      type: 'task',
      content: 'Replaced the switch',
      isPrivate: false,
      dateCreation: DateTime.now().subtract(const Duration(minutes: 30)),
      authorId: 2,
      authorName: 'Bo',
      taskDuration: 5400,
      taskState: done ? 2 : 1,
    );

    testWidgets('the task toggle is a checkbox with a 48dp target', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var toggles = 0;
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 400,
            child: TimelineEntryTile(
              entry: task(),
              onToggleTask: () => toggles++,
            ),
          ),
        ),
      );
      await tester.pump();

      final node = tester.getSemantics(find.bySemanticsLabel('Task done'));
      expect(node, isSemantics(hasCheckedState: true, isChecked: false));
      node.owner!.performAction(node.id, SemanticsAction.tap);
      expect(toggles, 1);

      // The glyph is 20px; the target around it is what has to be 48. (The
      // tree-wide androidTapTargetGuideline can't be used here: the timeline's
      // selectable body text carries a long-press action, which the guideline
      // counts as an undersized tap target.)
      final target = tester.getSize(find.byType(TapTarget));
      expect(target.width, greaterThanOrEqualTo(kMinInteractiveDimension));
      expect(target.height, greaterThanOrEqualTo(kMinInteractiveDimension));
      handle.dispose();
    });

    testWidgets('a done task announces its state', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 400,
            child: TimelineEntryTile(
              entry: task(done: true),
              onToggleTask: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        tester.getSemantics(find.bySemanticsLabel('Task done')),
        isSemantics(isChecked: true),
      );
      // The duration pill spells the value out rather than reading "1h 30m".
      expect(
        find.bySemanticsLabel('Duration 1 hour 30 minutes'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('a private note says so in words', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 400,
            child: TimelineEntryTile(
              entry: TimelineEntry(
                localId: 'f1',
                serverId: 8,
                type: 'followup',
                content: 'Internal only',
                isPrivate: true,
                dateCreation: DateTime.now(),
                authorId: 2,
                authorName: 'Bo',
                taskDuration: null,
                taskState: null,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.bySemanticsLabel(RegExp('Private, not visible to the requester')),
        findsWidgets,
      );
      handle.dispose();
    });
  });

  testWidgets('pull-to-refresh has a non-gesture equivalent', (tester) async {
    final handle = tester.ensureSemantics();
    var refreshes = 0;
    await tester.pumpWidget(
      host(
        SizedBox(
          height: 300,
          width: 300,
          child: AccessibleRefresh(
            onRefresh: () async => refreshes++,
            child: ListView(children: const [Text('a row')]),
          ),
        ),
      ),
    );
    await tester.pump();

    // A swipe is the one gesture a screen reader takes over, so the action has
    // to exist in the semantics tree as well.
    final node = tester.getSemantics(find.byType(AccessibleRefresh));
    final actions =
        node.getSemanticsData().customSemanticsActionIds ?? const [];
    expect(actions, isNotEmpty);
    final action = CustomSemanticsAction.getAction(actions.first)!;
    expect(action.label, 'Refresh');
    node.owner!.performAction(
      node.id,
      SemanticsAction.customAction,
      actions.first,
    );
    await tester.pump();
    expect(refreshes, 1);
    handle.dispose();
  });

  testWidgets('section titles are headings', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(const SectionHeading('Timeline', count: 3)));
    await tester.pump();

    expect(
      tester.getSemantics(find.byType(SectionHeading)),
      isSemantics(isHeader: true, label: 'Timeline, 3'),
    );
    handle.dispose();
  });
}
