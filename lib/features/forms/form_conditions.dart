import '../../core/api/dto/form_dto.dart';

/// Evaluates GLPI form visibility conditions.
///
/// A section/question declares a strategy (`always_visible`, `visible_if`,
/// `hidden_if`) plus condition rows referencing other questions by uuid. Rows
/// are combined left-to-right with each row's own logic operator (GLPI has no
/// precedence/grouping here — it folds in order).
bool isVisible({
  required String strategy,
  required List<FormCondition> conditions,
  required Map<String, Object?> answersByUuid,
}) {
  switch (strategy) {
    case 'visible_if':
      if (conditions.isEmpty) return true;
      return _evaluate(conditions, answersByUuid);
    case 'hidden_if':
      if (conditions.isEmpty) return true;
      return !_evaluate(conditions, answersByUuid);
    default: // always_visible / unset
      return true;
  }
}

bool _evaluate(
  List<FormCondition> conditions,
  Map<String, Object?> answersByUuid,
) {
  var result = _matches(
    conditions.first,
    answersByUuid[conditions.first.itemUuid],
  );
  for (final c in conditions.skip(1)) {
    final value = _matches(c, answersByUuid[c.itemUuid]);
    result = c.logicOperator == 'or' ? (result || value) : (result && value);
  }
  return result;
}

bool _matches(FormCondition condition, Object? answer) {
  final expected = condition.value;
  switch (condition.valueOperator) {
    case 'equals':
      return _eq(answer, expected);
    case 'not_equals':
      return !_eq(answer, expected);
    case 'contains':
      return _contains(answer, expected);
    case 'not_contains':
      return !_contains(answer, expected);
    case 'greater_than':
      return _compare(answer, expected, (a, b) => a > b);
    case 'greater_than_or_equals':
      return _compare(answer, expected, (a, b) => a >= b);
    case 'less_than':
      return _compare(answer, expected, (a, b) => a < b);
    case 'less_than_or_equals':
      return _compare(answer, expected, (a, b) => a <= b);
    case 'length_greater_than':
      return _length(answer) > (_num(expected) ?? 0);
    case 'length_greater_than_or_equals':
      return _length(answer) >= (_num(expected) ?? 0);
    case 'length_less_than':
      return _length(answer) < (_num(expected) ?? 0);
    case 'length_less_than_or_equals':
      return _length(answer) <= (_num(expected) ?? 0);
    case 'match_regex':
      return _regex(answer, expected);
    case 'not_match_regex':
      return !_regex(answer, expected);
    case 'visible':
      return _isAnswered(answer);
    case 'not_visible':
      return !_isAnswered(answer);
    default:
      // Unknown operator: don't hide content we can't reason about.
      return true;
  }
}

bool _isAnswered(Object? answer) {
  if (answer == null) return false;
  if (answer is String) return answer.trim().isNotEmpty;
  if (answer is Iterable) return answer.isNotEmpty;
  return true;
}

bool _eq(Object? answer, Object? expected) {
  if (answer is Iterable) {
    return answer.any((a) => '$a' == '$expected');
  }
  return '${answer ?? ''}' == '${expected ?? ''}';
}

bool _contains(Object? answer, Object? expected) {
  final needle = '${expected ?? ''}'.toLowerCase();
  if (answer is Iterable) {
    return answer.any((a) => '$a'.toLowerCase().contains(needle));
  }
  return '${answer ?? ''}'.toLowerCase().contains(needle);
}

num? _num(Object? v) => v is num ? v : num.tryParse('${v ?? ''}');

bool _compare(Object? answer, Object? expected, bool Function(num, num) op) {
  final a = _num(answer);
  final b = _num(expected);
  if (a == null || b == null) return false;
  return op(a, b);
}

int _length(Object? answer) {
  if (answer is Iterable) return answer.length;
  return '${answer ?? ''}'.length;
}

bool _regex(Object? answer, Object? expected) {
  final pattern = '${expected ?? ''}';
  if (pattern.isEmpty) return false;
  try {
    // GLPI stores PCRE literals like /foo/i — strip delimiters + flags.
    var body = pattern;
    var caseInsensitive = false;
    if (body.length > 1 && body.startsWith('/')) {
      final end = body.lastIndexOf('/');
      if (end > 0) {
        final flags = body.substring(end + 1);
        caseInsensitive = flags.contains('i');
        body = body.substring(1, end);
      }
    }
    return RegExp(
      body,
      caseSensitive: !caseInsensitive,
    ).hasMatch('${answer ?? ''}');
  } on FormatException {
    return false;
  }
}
