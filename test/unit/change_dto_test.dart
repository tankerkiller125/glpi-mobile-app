import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/dto/change_dto.dart';

void main() {
  group('ChangeCalendarEventDto', () {
    test('a change row carries a numeric GLPI status', () {
      final e = ChangeCalendarEventDto.fromJson(const {
        'type': 'change',
        'id': 276,
        'title': 'Upgrade core switch',
        'start': '2026-09-01 22:00:00',
        'end': '2026-09-02 02:00:00',
        'entities_id': 570,
        'state': 1,
      });
      expect(e.type, ChangeCalendarEventDto.kindChange);
      expect(e.changeStatus, 1);
      expect(e.releaseState, isNull);
      expect(e.severity, isNull);
      expect(e.start, DateTime(2026, 9, 1, 22));
    });

    test('a release row carries a state string', () {
      final e = ChangeCalendarEventDto.fromJson(const {
        'type': 'release',
        'id': 25,
        'title': 'ERP 14.2',
        'start': '2026-09-05 08:00:00',
        'end': '2026-09-05 12:00:00',
        'state': 'scheduled',
      });
      expect(e.releaseState, 'scheduled');
      expect(e.changeStatus, isNull);
    });

    test('a freeze row carries a severity', () {
      final e = ChangeCalendarEventDto.fromJson(const {
        'type': 'freeze',
        'id': 25,
        'title': 'Quarter close',
        'start': '2026-09-28 00:00:00',
        'end': '2026-10-02 00:00:00',
        'severity': 'policy',
      });
      expect(e.type, ChangeCalendarEventDto.kindFreeze);
      expect(e.severity, 'policy');
    });

    test('a sparse row degrades, never throws', () {
      final e = ChangeCalendarEventDto.fromJson(const {'type': 'change'});
      expect(e.id, 0);
      expect(e.start, isNull);
      expect(e.changeStatus, isNull);
    });
  });

  group('FreezeDto', () {
    final freeze = FreezeDto.fromJson(const {
      'id': 25,
      'title': 'Quarter close',
      'begin': '2026-09-28 00:00:00',
      'end': '2026-10-02 00:00:00',
      'severity': 'policy',
      'reason': 'Finance close',
    });

    test('contains is inclusive of its bounds', () {
      expect(freeze.contains(DateTime(2026, 9, 28)), isTrue);
      expect(freeze.contains(DateTime(2026, 9, 30, 12)), isTrue);
      expect(freeze.contains(DateTime(2026, 10, 2)), isTrue);
      expect(freeze.contains(DateTime(2026, 10, 2, 0, 1)), isFalse);
      expect(freeze.contains(DateTime(2026, 9, 27, 23, 59)), isFalse);
    });

    test('overlaps catches a range that merely touches the freeze', () {
      expect(
        freeze.overlaps(DateTime(2026, 9, 20), DateTime(2026, 9, 28)),
        isTrue,
      );
      expect(
        freeze.overlaps(DateTime(2026, 9, 29), DateTime(2026, 9, 29, 2)),
        isTrue,
      );
      expect(
        freeze.overlaps(DateTime(2026, 9, 20), DateTime(2026, 9, 27)),
        isFalse,
      );
    });

    test('a freeze without dates never matches', () {
      final f = FreezeDto.fromJson(const {'id': 1, 'title': 'X'});
      expect(f.contains(DateTime(2026)), isFalse);
      expect(f.overlaps(DateTime(2020), DateTime(2030)), isFalse);
    });
  });

  group('ChangeScheduleDto', () {
    test('parses the live schedule shape', () {
      final s = ChangeScheduleDto.fromJson(const {
        'window': {
          'begin': '2026-09-01 22:00:00',
          'end': '2026-09-02 02:00:00',
          'source': 'explicit',
          'source_label': 'Planned dates',
        },
        'collisions': [
          {
            'id': 7,
            'kind': 'shared_ci',
            'other_itemtype': 'Change',
            'other_items_id': 275,
            'detail': {'ci': 'sw-core-01'},
            'first_seen': '2026-08-20 10:00:00',
            'is_dismissed': 1,
            'dismiss_reason': 'Coordinated with team B',
          },
        ],
        'freezes': [
          {
            'id': 25,
            'title': 'Quarter close',
            'begin': '2026-09-28 00:00:00',
            'end': '2026-10-02 00:00:00',
            'severity': 'policy',
          },
        ],
      });
      expect(s.hasWindow, isTrue);
      expect(s.windowSourceLabel, 'Planned dates');
      expect(s.collisions.single.kind, 'shared_ci');
      expect(s.collisions.single.isDismissed, isTrue);
      expect(s.collisions.single.dismissReason, 'Coordinated with team B');
      expect(s.freezes.single.severity, 'policy');
    });

    test('a null window (no dates on the change) reads as windowless', () {
      final s = ChangeScheduleDto.fromJson(const {
        'window': {'begin': null, 'end': null, 'source': 'none'},
        'collisions': [],
        'freezes': [],
      });
      expect(s.hasWindow, isFalse);
      expect(s.collisions, isEmpty);
    });

    test('garbage degrades to an empty schedule', () {
      final s = ChangeScheduleDto.fromJson(const {});
      expect(s.hasWindow, isFalse);
      expect(s.freezes, isEmpty);
    });
  });
}
