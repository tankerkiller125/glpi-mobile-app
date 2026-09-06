import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/dto/signal_dto.dart';

void main() {
  group('alertRowsFromJson', () {
    test('digs the rows out of the pagination wrapper', () {
      final rows = alertRowsFromJson(const {
        'alerts': [
          {'id': 1, 'name': 'disk full'},
          {'id': 2, 'name': 'cpu high'},
        ],
        'start': 0,
        'limit': 50,
        'total': 2,
      });
      expect(rows, hasLength(2));
      expect(rows.first['id'], 1);
    });

    test('accepts a bare array and rejects garbage', () {
      expect(
        alertRowsFromJson(const [
          {'id': 1},
        ]),
        hasLength(1),
      );
      expect(alertRowsFromJson('nope'), isEmpty);
      expect(alertRowsFromJson(null), isEmpty);
      expect(alertRowsFromJson(const {'total': 0}), isEmpty);
    });
  });

  group('AlertDto', () {
    test('parses a full row with nested records', () {
      final a = AlertDto.fromJson(const {
        'id': 42,
        'name': 'RAID degraded',
        'severity': 'critical',
        'state': 'acked',
        'host': 'nas01',
        'itemtype': 'Computer',
        'items_id': 7,
        'tickets_id': 314,
        'event_count': 12,
        'first_seen': '2026-08-20 09:00:00',
        'last_seen': '2026-08-21 10:30:00',
        'users_id_ack': 3,
        'ack_user': {'id': 3, 'name': 'sam'},
        'entity': {'id': 1, 'name': 'Acme'},
      });
      expect(a.id, 42);
      expect(a.severity, AlertSeverity.critical);
      expect(a.state, 'acked');
      expect(a.isOpen, isFalse);
      expect(a.host, 'nas01');
      expect(a.itemsId, 7);
      expect(a.ticketsId, 314);
      expect(a.eventCount, 12);
      expect(a.ackUserId, 3);
      expect(a.ackUserName, 'sam');
      expect(a.entityId, 1);
      expect(a.entityName, 'Acme');
    });

    test('a sparse open row keeps sensible defaults', () {
      final a = AlertDto.fromJson(const {'id': 1, 'name': 'ping lost'});
      expect(a.state, 'open');
      expect(a.isOpen, isTrue);
      expect(a.severity, AlertSeverity.info);
      expect(a.eventCount, 1);
      expect(a.ticketsId, isNull);
      expect(a.ackUserId, isNull);
    });

    test('a zero tickets_id means no bound ticket', () {
      final a = AlertDto.fromJson(const {'id': 1, 'tickets_id': 0});
      expect(a.ticketsId, isNull);
    });
  });

  group('AlertSeverity.parse', () {
    test('handles names, synonyms, numbers and junk', () {
      expect(AlertSeverity.parse('critical'), AlertSeverity.critical);
      expect(AlertSeverity.parse('MAJOR'), AlertSeverity.high);
      expect(AlertSeverity.parse('warning'), AlertSeverity.medium);
      expect(AlertSeverity.parse('minor'), AlertSeverity.low);
      expect(AlertSeverity.parse(5), AlertSeverity.critical);
      expect(AlertSeverity.parse(3), AlertSeverity.medium);
      expect(AlertSeverity.parse('mysterious'), AlertSeverity.info);
      expect(AlertSeverity.parse(null), AlertSeverity.info);
    });
  });

  group('AlertDetailDto', () {
    test('reads the row plus its page log', () {
      final d = AlertDetailDto.fromJson(const {
        'id': 9,
        'name': 'db down',
        'severity': 4,
        'state': 'open',
        'log': [
          {
            'date': '2026-08-21 10:00:00',
            'target': 'sam',
            'status': 'delivered',
            'message': 'pushed to phone',
          },
        ],
      });
      expect(d.alert.id, 9);
      expect(d.alert.severity, AlertSeverity.high);
      expect(d.log, hasLength(1));
      expect(d.log.single.target, 'sam');
      expect(d.log.single.status, 'delivered');
    });

    test('tolerates a wrapped row and a missing log', () {
      final d = AlertDetailDto.fromJson(const {
        'alert': {'id': 9, 'name': 'db down'},
      });
      expect(d.alert.id, 9);
      expect(d.log, isEmpty);
    });
  });

  group('OncallRotaDto', () {
    test('parses nested current and next users', () {
      final r = OncallRotaDto.fromJson(const {
        'id': 1,
        'name': 'Infra',
        'oncall_user': {'id': 2, 'name': 'alex'},
        'am_i_on_call': false,
        'next_handoff': '2026-08-22 08:00:00',
        'next_user': {'id': 3, 'name': 'sam'},
      });
      expect(r.oncallUserId, 2);
      expect(r.oncallUserName, 'alex');
      expect(r.amIOnCall, isFalse);
      expect(r.nextHandoff, '2026-08-22 08:00:00');
      expect(r.nextUserName, 'sam');
    });

    test('a layered rota lists every current on-call name', () {
      final r = OncallRotaDto.fromJson(const {
        'id': 1,
        'name': 'Infra',
        'oncall_users': [
          {'id': 2, 'name': 'alex'},
          {'id': 3, 'name': 'sam'},
        ],
        'am_i_on_call': true,
      });
      expect(r.oncallUserId, 2);
      expect(r.oncallUserName, 'alex, sam');
      expect(r.amIOnCall, isTrue);
    });

    test('an empty rota has nobody on call', () {
      final r = OncallRotaDto.fromJson(const {'id': 1, 'name': 'Infra'});
      expect(r.oncallUserId, isNull);
      expect(r.oncallUserName, isNull);
      expect(r.amIOnCall, isFalse);
    });

    test(
      'parses the live wire shape: layers, epoch handoff, next_incoming',
      () {
        final r = OncallRotaDto.fromJson(const {
          'id': 1,
          'name': 'Fjordline out-of-hours',
          'entity': {'id': 567, 'name': 'Fjordline'},
          'layers': [
            {
              'name': 'Primary on-call',
              'on_call': [
                {'id': 155, 'name': 'Solberg Ingrid'},
              ],
              'next_handoff': 1787558400,
              'incoming': [
                {'id': 156, 'name': 'Lindqvist Tomas'},
              ],
            },
            {
              'name': 'Second line',
              'on_call': [
                {'id': 156, 'name': 'Lindqvist Tomas'},
                {'id': 157, 'name': 'Havnen Erik'},
              ],
              'next_handoff': 0,
              'incoming': <Object?>[],
            },
          ],
          'am_i_on_call': false,
          'next_handoff': 1787558400,
          'next_incoming': [
            {'id': 156, 'name': 'Lindqvist Tomas'},
          ],
        });
        expect(r.oncallUserId, 155);
        expect(
          r.oncallUserName,
          'Solberg Ingrid, Lindqvist Tomas, Havnen Erik',
        );
        expect(r.amIOnCall, isFalse);
        // Epoch seconds become a local SQL wall-clock string the rest of the
        // app can parse; the exact digits depend on the host timezone.
        expect(
          r.nextHandoff,
          matches(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'),
        );
        expect(r.nextUserName, 'Lindqvist Tomas');
      },
    );

    test('a zero epoch handoff means none', () {
      final r = OncallRotaDto.fromJson(const {
        'id': 1,
        'name': 'Infra',
        'layers': [
          {
            'on_call': [
              {'id': 2, 'name': 'alex'},
            ],
          },
        ],
        'next_handoff': 0,
      });
      expect(r.nextHandoff, isNull);
      expect(r.oncallUserName, 'alex');
    });
  });

  group('oncallRowsFromJson', () {
    test('unwraps {"rotas": [...]} and accepts a bare array', () {
      const row = {'id': 1, 'name': 'Infra'};
      expect(
        oncallRowsFromJson(const {
          'rotas': [row],
        }),
        [row],
      );
      expect(oncallRowsFromJson(const [row]), [row]);
      expect(oncallRowsFromJson('garbage'), isEmpty);
      expect(oncallRowsFromJson(const {'total': 0}), isEmpty);
    });
  });

  group('AlertDto ack affordance', () {
    test('open, ticketed and suppressed alerts still need an ack', () {
      AlertDto row(String state) =>
          AlertDto.fromJson({'id': 1, 'name': 'a', 'state': state});
      expect(row('open').needsAck, isTrue);
      expect(row('ticketed').needsAck, isTrue);
      expect(row('suppressed').needsAck, isTrue);
      expect(row('acked').needsAck, isFalse);
      expect(row('closed').needsAck, isFalse);
      expect(row('ticketed').isLive, isTrue);
      expect(row('closed').isLive, isFalse);
    });
  });
}
