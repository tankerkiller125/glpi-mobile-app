import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/dto/form_dto.dart';

FormQuestionDto _question(
  Map<String, Object?>? extraData, {
  String type = 'requester',
}) => FormQuestionDto.fromJson({
  'id': 1,
  'uuid': 'u',
  'name': 'Who approves?',
  'type': type,
  'mandatory': false,
  'description': '',
  'default_value': '',
  'extra_data': extraData,
  'visibility_strategy': '',
  'conditions': <Object?>[],
  'options': <Object?>[],
});

void main() {
  group('actor/device flags survive whatever GLPI sends', () {
    test('a real boolean', () {
      expect(_question({'is_multiple_actors': true}).multipleActors, isTrue);
      expect(_question({'is_multiple_actors': false}).multipleActors, isFalse);
    });

    test(
      'the string "0"/"1" — GLPI sends these from the newer form editor',
      () {
        // Regression: `as bool?` threw on the string, and the throw took the
        // whole field (and the rest of the form) down with it.
        expect(_question({'is_multiple_actors': '0'}).multipleActors, isFalse);
        expect(_question({'is_multiple_actors': '1'}).multipleActors, isTrue);
        expect(
          _question({'is_multiple_actors': 'true'}).multipleActors,
          isTrue,
        );
      },
    );

    test('numbers, nulls, and missing keys', () {
      expect(_question({'is_multiple_actors': 1}).multipleActors, isTrue);
      expect(_question({'is_multiple_actors': 0}).multipleActors, isFalse);
      expect(_question({'is_multiple_actors': null}).multipleActors, isFalse);
      expect(_question(const {}).multipleActors, isFalse);
      expect(_question(null).multipleActors, isFalse);
    });

    test('device questions use the same coercion', () {
      final q = _question({'is_multiple_devices': '1'}, type: 'user_device');
      expect(q.multipleDevices, isTrue);
    });

    test('the extra_data GLPI actually sent for the failing form parses', () {
      final q = _question(const {
        'enabled_types': ['User', 'Group'],
        'is_multiple_actors': '0',
      });
      expect(q.kind, QuestionKind.actors);
      expect(q.multipleActors, isFalse);
    });
  });
}
