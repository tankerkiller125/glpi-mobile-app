import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/dto/kedb_dto.dart';

void main() {
  group('KedbMatchDto', () {
    test('parses the live match-row shape', () {
      final m = KedbMatchDto.fromJson(const {
        'id': 18,
        'title': 'Zebra label printer drops jobs',
        'status': 'active',
        'workaround': 'Restart the spooler service.',
        'has_workaround': true,
        'reasons': ['category', 'keyword'],
        'weight': 100,
      });
      expect(m.id, 18);
      expect(m.title, 'Zebra label printer drops jobs');
      expect(m.hasWorkaround, isTrue);
      expect(m.reasons, ['category', 'keyword']);
      expect(m.weight, 100);
      expect(m.snippet, 'Restart the spooler service.');
    });

    test('a sparse row degrades, never throws', () {
      final m = KedbMatchDto.fromJson(const {'id': '3'});
      expect(m.id, 3);
      expect(m.title, '');
      expect(m.hasWorkaround, isFalse);
      expect(m.reasons, isEmpty);
      expect(m.snippet, '');
    });

    test('a server-sent symptom wins the snippet slot', () {
      final m = KedbMatchDto.fromJson(const {
        'id': 1,
        'symptom': 'Print queue stalls',
        'workaround': 'Restart it',
      });
      expect(m.snippet, 'Print queue stalls');
    });

    test('workaround text alone implies has_workaround', () {
      final m = KedbMatchDto.fromJson(const {'id': 1, 'workaround': 'Fix it'});
      expect(m.hasWorkaround, isTrue);
    });
  });

  group('KedbHitResultDto', () {
    test('used returns the snippet', () {
      final r = KedbHitResultDto.fromJson(const {
        'ok': true,
        'snippet': 'Known error: X\n\nWorkaround applied: Y',
      });
      expect(r.ok, isTrue);
      expect(r.snippet, startsWith('Known error'));
    });

    test('dismissed has no snippet; garbage is a quiet false', () {
      expect(KedbHitResultDto.fromJson(const {'ok': true}).snippet, isNull);
      expect(KedbHitResultDto.fromJson('nope').ok, isFalse);
      expect(KedbHitResultDto.fromJson(null).ok, isFalse);
    });
  });

  group('kedbRowsFromJson', () {
    test('unwraps the confirmed {total, start, limit, rows} wrapper', () {
      final rows = kedbRowsFromJson(const {
        'total': 1,
        'start': 0,
        'limit': 50,
        'rows': [
          {
            'id': 18,
            'title': 'Zebra',
            'status': 'active',
            'has_workaround': true,
          },
        ],
      });
      expect(rows, hasLength(1));
      final row = KedbRowDto.fromJson(rows.first);
      expect(row.id, 18);
      expect(row.hasWorkaround, isTrue);
    });

    test('accepts a bare array', () {
      expect(
        kedbRowsFromJson(const [
          {'id': 1},
        ]),
        hasLength(1),
      );
    });

    test('falls back to the first list-valued key', () {
      expect(
        kedbRowsFromJson(const {
          'knownerrors': [
            {'id': 2},
          ],
        }),
        hasLength(1),
      );
    });

    test('garbage reads as empty', () {
      expect(kedbRowsFromJson('x'), isEmpty);
      expect(kedbRowsFromJson(null), isEmpty);
      expect(kedbRowsFromJson(const {'total': 0}), isEmpty);
    });
  });

  group('KedbDetailDto', () {
    test('parses the full record', () {
      final d = KedbDetailDto.fromJson(const {
        'id': 18,
        'title': 'Zebra label printer drops jobs',
        'status': 'active',
        'status_label': 'Active',
        'symptom': '<p>Queue stalls</p>',
        'workaround': '<p>Restart the spooler</p>',
        'root_cause': '<p>Firmware bug</p>',
        'lifecycle': {
          'date_identified': '2026-08-01 09:00:00',
          'date_retired': null,
          'use_count': 4,
        },
        'software': ['ZDesigner'],
        'problem': {'id': 12, 'name': 'Printing outage'},
      });
      expect(d.statusLabel, 'Active');
      expect(d.hasWorkaround, isTrue);
      expect(d.useCount, 4);
      expect(d.dateIdentified, '2026-08-01 09:00:00');
      expect(d.dateRetired, isNull);
      expect(d.software, ['ZDesigner']);
      expect(d.problemId, 12);
      expect(d.problemName, 'Printing outage');
    });

    test('missing lifecycle/problem degrade to defaults', () {
      final d = KedbDetailDto.fromJson(const {'id': 1, 'title': 'X'});
      expect(d.useCount, 0);
      expect(d.problemId, isNull);
      expect(d.software, isEmpty);
      expect(d.hasWorkaround, isFalse);
    });
  });
}
