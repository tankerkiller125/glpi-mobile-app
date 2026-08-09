import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/utils/priority_matrix.dart';

void main() {
  // Values verified against the live GLPI priority_matrix config.
  test('matches GLPI corners and samples', () {
    expect(computePriority(1, 1), 1);
    expect(computePriority(5, 5), 5);
    expect(computePriority(5, 1), 2); // high urgency, low impact
    expect(computePriority(1, 5), 2); // low urgency, high impact
    expect(computePriority(3, 4), 4);
    expect(computePriority(5, 3), 4);
    expect(computePriority(3, 3), 3);
  });

  test('clamps out-of-range inputs', () {
    expect(computePriority(0, 0), computePriority(1, 1));
    expect(computePriority(9, 9), computePriority(5, 5));
  });

  test('parses GLPI config JSON ({urgency:{impact:priority}})', () {
    const raw =
        '{"1":{"1":1,"2":1,"3":2,"4":2,"5":2},'
        '"2":{"1":1,"2":2,"3":2,"4":3,"5":3},'
        '"3":{"1":2,"2":2,"3":3,"4":4,"5":4},'
        '"4":{"1":2,"2":3,"3":4,"4":4,"5":5},'
        '"5":{"1":2,"2":3,"3":4,"4":5,"5":5}}';
    final grid = PriorityMatrix.parseGlpiJson(raw);
    expect(grid, isNotNull);
    expect(computePriority(3, 4, matrix: grid), 4);
    expect(computePriority(5, 1, matrix: grid), 2);
  });

  test('malformed config JSON returns null (falls back to default)', () {
    expect(PriorityMatrix.parseGlpiJson('not json'), isNull);
    expect(PriorityMatrix.parseGlpiJson('{"1":{"1":1}}'), isNull);
  });

  test('a custom admin grid changes the computed priority', () {
    // An admin grid where everything is Major (5).
    final custom = List.generate(5, (_) => List.filled(5, 5));
    expect(computePriority(1, 1, matrix: custom), 5);
    expect(computePriority(3, 3, matrix: custom), 5);
  });
}
