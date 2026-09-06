import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/dto/presence_dto.dart';

void main() {
  group('Presence state', () {
    final state = PresenceStateDto.fromJson(const {
      'server_time': 1788653778,
      'you': 2,
      'can_claim': true,
      'presence_ttl': 90,
      'participants': [
        {
          'users_id': 2,
          'name': 'glpi',
          'initials': 'G',
          'typing': false,
          'since': 1788653700,
        },
        {
          'users_id': 5,
          'name': 'Sam Fox',
          'initials': 'SF',
          'typing': true,
          'typing_kind': 'followup',
          'since': 1788653740,
        },
      ],
      'claim': {
        'users_id': 5,
        'name': 'Sam Fox',
        'since': 1788653740,
        'idle': 12,
      },
    });

    test('others excludes the signed-in user', () {
      expect(state.participants, hasLength(2));
      expect(state.others, hasLength(1));
      expect(state.others.single.name, 'Sam Fox');
      expect(state.others.single.typing, isTrue);
      expect(state.others.single.typingKind, 'followup');
    });

    test('a claim held by somebody else is not held by you', () {
      expect(state.claimedByOther, isTrue);
      expect(state.claimedByYou, isFalse);
      expect(state.claim!.idle, 12);
    });

    test('a claim you hold is recognised as yours', () {
      final mine = PresenceStateDto.fromJson(const {
        'you': 2,
        'claim': {'users_id': 2, 'name': 'glpi', 'since': 1, 'idle': 0},
      });
      expect(mine.claimedByYou, isTrue);
      expect(mine.claimedByOther, isFalse);
    });

    test('an empty body is nobody here, not an error', () {
      final empty = PresenceStateDto.fromJson(const {});
      expect(empty.participants, isEmpty);
      expect(empty.claim, isNull);
      expect(empty.canClaim, isFalse);
      // The default TTL keeps a client from beating pointlessly fast when an
      // older server does not send one.
      expect(empty.presenceTtl, 90);
    });
  });
}
