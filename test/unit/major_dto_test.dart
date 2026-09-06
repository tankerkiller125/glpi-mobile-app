import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/dto/major_dto.dart';

void main() {
  group('MajorIncidentDto', () {
    test('parses a full row with nested records', () {
      final i = MajorIncidentDto.fromJson(const {
        'id': 5,
        'title': 'Mail platform outage',
        'state': 'open',
        'tickets_id': 99,
        'entity': {'id': 1, 'name': 'Acme'},
        'commander': {'id': 2, 'name': 'alex'},
        'declared_at': '2026-08-21 09:00:00',
        'next_update_at': '2026-08-21 11:00:00',
      });
      expect(i.id, 5);
      expect(i.isOpen, isTrue);
      expect(i.ticketsId, 99);
      expect(i.entityName, 'Acme');
      expect(i.commanderId, 2);
      expect(i.commanderName, 'alex');
      expect(i.nextUpdateAt, '2026-08-21 11:00:00');
    });

    test('a sparse row defaults to open with nothing bound', () {
      final i = MajorIncidentDto.fromJson(const {'id': 1, 'title': 'x'});
      expect(i.isOpen, isTrue);
      expect(i.ticketsId, isNull);
      expect(i.commanderName, isNull);
    });
  });

  group('MajorIncidentDetailDto', () {
    test('reads the record plus its comms log', () {
      final d = MajorIncidentDetailDto.fromJson(const {
        'id': 5,
        'title': 'Mail platform outage',
        'state': 'open',
        'updates': [
          {
            'id': 1,
            'audience': 'customer',
            'content': '<p>We are investigating.</p>',
            'author': {'id': 2, 'name': 'alex'},
            'created_at': '2026-08-21 09:10:00',
          },
          {
            'id': 2,
            'audience': 'internal',
            'content': 'DB failover in progress',
            'author': 'sam',
          },
        ],
      });
      expect(d.incident.id, 5);
      expect(d.updates, hasLength(2));
      expect(d.updates.first.isCustomer, isTrue);
      expect(d.updates.first.author, 'alex');
      expect(d.updates.last.isCustomer, isFalse);
      expect(d.updates.last.author, 'sam');
    });
  });

  group('MajorTicketInfoDto', () {
    test('state one: this ticket drives the incident', () {
      final info = MajorTicketInfoDto.fromJson(const {
        'incident': {'id': 5, 'title': 'Outage', 'state': 'open'},
        'attached_to': null,
        'offer_attach': [],
      });
      expect(info.incident?.id, 5);
      expect(info.attachedTo, isNull);
      expect(info.bound?.id, 5);
    });

    test('state two: the ticket is attached to another incident', () {
      final info = MajorTicketInfoDto.fromJson(const {
        'incident': null,
        'attached_to': {'id': 8, 'title': 'Network storm', 'state': 'open'},
        'offer_attach': [],
      });
      expect(info.incident, isNull);
      expect(info.attachedTo?.id, 8);
      expect(info.bound?.id, 8);
    });

    test('state three: unbound, with open incidents offered', () {
      final info = MajorTicketInfoDto.fromJson(const {
        'incident': null,
        'attached_to': null,
        'offer_attach': [
          {'id': 8, 'title': 'Network storm'},
        ],
      });
      expect(info.bound, isNull);
      expect(info.offerAttach.single.id, 8);
      expect(info.offerAttach.single.title, 'Network storm');
    });

    test('a malformed payload reads as unbound', () {
      final info = MajorTicketInfoDto.fromJson(const {
        'incident': 'nope',
        'offer_attach': 'also nope',
      });
      expect(info.bound, isNull);
      expect(info.offerAttach, isEmpty);
    });
  });
}
