import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/dto/form_dto.dart';
import 'package:glpi_mobile/features/forms/form_conditions.dart';

FormCondition cond(
  String uuid,
  String op,
  Object? value, {
  String logic = 'and',
}) => FormCondition(
  itemUuid: uuid,
  valueOperator: op,
  value: value,
  logicOperator: logic,
);

void main() {
  group('visibility strategies', () {
    test('always_visible (or unset) ignores conditions', () {
      expect(
        isVisible(strategy: '', conditions: const [], answersByUuid: const {}),
        isTrue,
      );
      expect(
        isVisible(
          strategy: 'always_visible',
          conditions: [cond('a', 'equals', 'x')],
          answersByUuid: const {'a': 'nope'},
        ),
        isTrue,
      );
    });

    test('visible_if shows only when the condition holds', () {
      final conditions = [cond('a', 'equals', 'yes')];
      expect(
        isVisible(
          strategy: 'visible_if',
          conditions: conditions,
          answersByUuid: const {'a': 'yes'},
        ),
        isTrue,
      );
      expect(
        isVisible(
          strategy: 'visible_if',
          conditions: conditions,
          answersByUuid: const {'a': 'no'},
        ),
        isFalse,
      );
    });

    test('hidden_if hides when the condition holds', () {
      final conditions = [cond('a', 'equals', 'yes')];
      expect(
        isVisible(
          strategy: 'hidden_if',
          conditions: conditions,
          answersByUuid: const {'a': 'yes'},
        ),
        isFalse,
      );
      expect(
        isVisible(
          strategy: 'hidden_if',
          conditions: conditions,
          answersByUuid: const {'a': 'no'},
        ),
        isTrue,
      );
    });
  });

  group('operators', () {
    bool check(String op, Object? answer, Object? expected) => isVisible(
      strategy: 'visible_if',
      conditions: [cond('q', op, expected)],
      answersByUuid: {'q': answer},
    );

    test('equals / not_equals compare loosely across types', () {
      expect(check('equals', 5, '5'), isTrue);
      expect(check('equals', '5', 5), isTrue);
      expect(check('not_equals', 5, 4), isTrue);
    });

    test('equals matches any element of a multi-answer', () {
      expect(check('equals', ['a', 'b'], 'b'), isTrue);
      expect(check('equals', ['a', 'b'], 'c'), isFalse);
    });

    test('contains is case-insensitive', () {
      expect(check('contains', 'Printer is broken', 'BROKEN'), isTrue);
      expect(check('not_contains', 'Printer is broken', 'laptop'), isTrue);
    });

    test('numeric comparisons', () {
      expect(check('greater_than', 5, 3), isTrue);
      expect(check('greater_than_or_equals', 3, 3), isTrue);
      expect(check('less_than', 2, 3), isTrue);
      expect(check('less_than_or_equals', 3, 3), isTrue);
      expect(check('greater_than', 'abc', 3), isFalse); // non-numeric
    });

    test('length comparisons work on text and lists', () {
      expect(check('length_greater_than', 'abcd', 3), isTrue);
      expect(check('length_less_than_or_equals', ['a', 'b'], 2), isTrue);
    });

    test('visible / not_visible test answeredness', () {
      expect(check('visible', 'x', null), isTrue);
      expect(check('visible', '   ', null), isFalse);
      expect(check('visible', const <String>[], null), isFalse);
      expect(check('not_visible', null, null), isTrue);
    });

    test('regex honours PCRE delimiters and the i flag', () {
      expect(check('match_regex', 'Server DOWN', '/down/i'), isTrue);
      expect(check('match_regex', 'Server DOWN', '/down/'), isFalse);
      expect(check('not_match_regex', 'all good', '/down/i'), isTrue);
    });

    test('an unknown operator does not hide the field', () {
      expect(check('some_future_operator', 'x', 'y'), isTrue);
    });
  });

  test('multiple conditions fold with each row\'s logic operator', () {
    // a == 1 AND b == 2
    expect(
      isVisible(
        strategy: 'visible_if',
        conditions: [
          cond('a', 'equals', 1),
          cond('b', 'equals', 2, logic: 'and'),
        ],
        answersByUuid: const {'a': 1, 'b': 2},
      ),
      isTrue,
    );
    expect(
      isVisible(
        strategy: 'visible_if',
        conditions: [
          cond('a', 'equals', 1),
          cond('b', 'equals', 2, logic: 'and'),
        ],
        answersByUuid: const {'a': 1, 'b': 99},
      ),
      isFalse,
    );
    // a == 1 OR b == 2
    expect(
      isVisible(
        strategy: 'visible_if',
        conditions: [
          cond('a', 'equals', 1),
          cond('b', 'equals', 2, logic: 'or'),
        ],
        answersByUuid: const {'a': 0, 'b': 2},
      ),
      isTrue,
    );
  });
}
