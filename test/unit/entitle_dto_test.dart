import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/dto/entitle_dto.dart';

void main() {
  group('EntitlementDto envelope', () {
    test('parses a fresh answer with the full v2 payload', () {
      final e = EntitlementDto.fromJson(const {
        'state': 'fresh',
        'age': 0,
        'error': null,
        'payload': {
          'version': 2,
          'contracts': [
            {
              'contract': 'MSP Gold',
              'billing_model': 'Block Hours',
              'is_labor_contract': true,
              'ending_soon': true,
              'start_date': '2026-01-01',
              'end_date': '2026-12-31',
              'block': {'consumed_hours': 12.5, 'pool_hours': 40},
            },
            {'contract': 'Licenses', 'billing_model': 'Licensing'},
          ],
          'has_labor_coverage': true,
          'labor': {
            'contract': 'MSP Gold',
            'model': 'Block Hours',
            'kind': 'block',
            'after_hours_billable': true,
            'block': {'consumed_hours': 12.5, 'pool_hours': 40},
          },
          'lapsed': [],
          'uncontracted': {
            'policy': 'Bill at Uncontracted Rate',
            'rate': 150,
            'currency': 'USD',
            'approver_glpi_user_id': 0,
            'source': 'customer',
          },
        },
      });
      expect(e.state, EntitlementDto.fresh);
      expect(e.isSilent, isFalse);
      expect(e.isStale, isFalse);
      final p = e.payload!;
      expect(p.contracts, hasLength(2));
      expect(p.contracts.first.name, 'MSP Gold');
      expect(p.contracts.first.isLaborContract, isTrue);
      expect(p.contracts.first.endingSoon, isTrue);
      expect(p.contracts.first.block!.consumedHours, 12.5);
      expect(p.contracts.first.block!.poolHours, 40);
      expect(p.contracts.last.block, isNull);
      expect(p.hasLaborCoverage, isTrue);
      expect(p.labor!.kind, 'block');
      expect(p.labor!.afterHoursBillable, isTrue);
      expect(p.uncontracted!.policy, EntitleUncontractedDto.bill);
      expect(p.uncontracted!.rate, 150);
    });

    test('stale keeps the payload and states the age', () {
      final e = EntitlementDto.fromJson(const {
        'state': 'stale',
        'age': 7200,
        'error': 'ERPNext unreachable: timeout',
        'payload': {'contracts': [], 'has_labor_coverage': false},
      });
      expect(e.isStale, isTrue);
      expect(e.ageSeconds, 7200);
      expect(e.error, contains('unreachable'));
      expect(e.payload, isNotNull);
    });

    test('silent carries nothing and renders nothing', () {
      final e = EntitlementDto.fromJson(const {
        'state': 'silent',
        'age': 0,
        'error': null,
        'payload': null,
      });
      expect(e.isSilent, isTrue);
      expect(e.payload, isNull);
    });

    test('a non-silent state without payload still reads silent', () {
      // Defensive: the app must never render a card off nothing.
      final e = EntitlementDto.fromJson(const {'state': 'fresh', 'age': 0});
      expect(e.isSilent, isTrue);
    });

    test('garbage reads as silent, never a throw', () {
      expect(EntitlementDto.fromJson('nope').isSilent, isTrue);
      expect(EntitlementDto.fromJson(null).isSilent, isTrue);
    });
  });

  group('payload tolerance (v1 endpoints)', () {
    test('missing v2 blocks read as unavailable, not guessed defaults', () {
      final p = EntitlementPayloadDto.fromJson(const {
        'contracts': [
          {'contract': 'Old Deal', 'billing_model': 'Fixed Fee'},
        ],
        'has_labor_coverage': true,
      });
      expect(p.labor, isNull);
      expect(p.lapsed, isEmpty);
      expect(p.uncontracted, isNull);
    });

    test('lapsed rows parse; malformed entries are dropped', () {
      final p = EntitlementPayloadDto.fromJson(const {
        'lapsed': [
          {
            'contract': 'MSP Gold',
            'model': 'Block Hours',
            'ended': '2026-06-30',
          },
          'garbage',
        ],
      });
      expect(p.lapsed, hasLength(1));
      expect(p.lapsed.first.ended, '2026-06-30');
    });

    test('an empty uncontracted policy string falls back to bill', () {
      final u = EntitleUncontractedDto.fromJson(const {'rate': '99.5'});
      expect(u.policy, EntitleUncontractedDto.bill);
      expect(u.rate, 99.5);
    });
  });

  group('EntitleBlockDto', () {
    test('gauge fraction clamps over-consumption to 1', () {
      const b = EntitleBlockDto(consumedHours: 50, poolHours: 40);
      expect(b.fraction, 1);
    });

    test(
      'a zero pool reads as fully consumed rather than dividing by zero',
      () {
        const b = EntitleBlockDto(consumedHours: 5, poolHours: 0);
        expect(b.fraction, 1);
      },
    );
  });
}
