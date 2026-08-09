import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/dto/catalog_dto.dart';

void main() {
  group('CatalogItemDto', () {
    test('promotes the fields every list row needs', () {
      final dto = CatalogItemDto.fromJson('Computer', const {
        'id': 1,
        'name': 'DELTA-WS01',
        'serial': 'SN-DELTA-0001',
        'otherserial': 'INV-1001',
        'status': {'id': 1, 'name': 'In use'},
        'location': {'id': 2, 'completename': 'HQ > Floor 2'},
        'user': {'id': 3, 'name': 'sam'},
        'manufacturer': {'id': 4, 'name': 'Acme'},
        'group': [
          {'id': 5, 'name': 'Field techs'},
        ],
      });

      expect(dto.id, 1);
      expect(dto.serial, 'SN-DELTA-0001');
      expect(dto.otherserial, 'INV-1001');
      expect(dto.statusName, 'In use');
      // Locations use completename so the row reads unambiguously.
      expect(dto.locationName, 'HQ > Floor 2');
      expect(dto.userName, 'sam');
      expect(dto.manufacturerName, 'Acme');
      // Groups arrive as a list; the first is the one worth showing.
      expect(dto.groupName, 'Field techs');
      expect(dto.modelName, isNull);
    });

    test('takes an explicit expiry date when the schema has one', () {
      final cert = CatalogItemDto.fromJson('Certificate', const {
        'id': 1,
        'name': 'wildcard.delta.example',
        'date_expiration': '2026-09-15',
      });
      expect(cert.expiryDate, '2026-09-15');
    });

    test('computes a contract end from its start plus duration months', () {
      // GLPI stores no end date for contracts — only a begin and a duration in
      // months — so the badge has to derive it.
      final contract = CatalogItemDto.fromJson('Contract', const {
        'id': 1,
        'name': 'Delta support 2026',
        'date_begin': '2026-01-01',
        'duration': 12,
      });
      expect(contract.expiryDate, '2027-01-01');
    });

    test('a contract with no duration has no expiry', () {
      final contract = CatalogItemDto.fromJson('Contract', const {
        'id': 2,
        'name': 'Open-ended',
        'date_begin': '2026-01-01',
        'duration': 0,
      });
      expect(contract.expiryDate, isNull);
    });
  });

  group('SoftwareListDto', () {
    test('keeps the true total when the page is capped', () {
      final dto = SoftwareListDto.fromJson(const {
        'total': 120,
        'items': [
          {'name': 'LibreOffice', 'version': '24.2'},
        ],
      });
      expect(dto.total, 120);
      expect(dto.items.single.name, 'LibreOffice');
      expect(dto.items.single.version, '24.2');
    });
  });

  group('NetworkPortDto', () {
    test('reads MAC and IPs', () {
      final dto = NetworkPortDto.fromJson(const {
        'id': 1,
        'name': 'eth0',
        'mac': 'aa:bb:cc:11:22:33',
        'type': 'Ethernet',
        'ips': ['10.20.0.11'],
      });
      expect(dto.name, 'eth0');
      expect(dto.mac, 'aa:bb:cc:11:22:33');
      expect(dto.ips, ['10.20.0.11']);
    });
  });
}
