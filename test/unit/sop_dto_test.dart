import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/dto/sop_dto.dart';

Map<String, Object?> _step({
  required int id,
  String type = 'check',
  bool visible = true,
  int section = 1,
  Map<String, Object?> config = const {},
  Map<String, Object?>? answer,
}) => {
  'id': id,
  'sections_id': section,
  'number': '$id',
  'label': 'Step $id',
  'type': type,
  'type_label': type,
  'required': true,
  'visible': visible,
  'parent_id': 0,
  'config': config,
  'answer': answer ?? const {'state': 'pending'},
};

void main() {
  group('Runs', () {
    test('outstanding counts only required steps still being asked', () {
      final run = SopRunDto.fromJson(const {
        'id': 4,
        'name': 'New Employee',
        'status': 'in_progress',
        'status_label': 'in progress',
        'total': 14,
        'done': 3,
        'total_required': 12,
        'done_required': 4,
        'enforcing': true,
        'editable': true,
      });

      expect(run.outstanding, 8);
      expect(run.isComplete, isFalse);
      expect(run.enforcing, isTrue);
      expect(run.fraction, closeTo(3 / 14, 0.001));
    });

    test(
      'a run with no steps reads as complete rather than dividing by zero',
      () {
        final run = SopRunDto.fromJson(const {'id': 1, 'total': 0, 'done': 0});
        expect(run.fraction, 1);
        expect(run.outstanding, 0);
      },
    );
  });

  group('Steps', () {
    test('invisible steps are not part of the checklist', () {
      final detail = SopRunDetailDto.fromJson({
        'id': 4,
        'total': 2,
        'done': 0,
        'sections': const [
          {'id': 1, 'name': 'Verification'},
        ],
        'steps': [_step(id: 1), _step(id: 2, visible: false)],
      });

      expect(detail.steps, hasLength(2));
      expect(detail.visibleSteps, hasLength(1));
      expect(detail.sectionName(1), 'Verification');
      expect(detail.sectionName(99), isEmpty);
    });

    test('choice options come out of the step config', () {
      final detail = SopRunDetailDto.fromJson({
        'steps': [
          _step(
            id: 1,
            type: 'choice',
            config: const {
              'options': ['Yes', 'No', 'N/A'],
            },
          ),
        ],
      });

      expect(detail.steps.single.type, SopStepType.choice);
      expect(detail.steps.single.options, ['Yes', 'No', 'N/A']);
    });

    test('a step type the app has never heard of is read-only, not hidden', () {
      final detail = SopRunDetailDto.fromJson({
        'steps': [_step(id: 1, type: 'signature')],
      });

      final step = detail.steps.single;
      expect(step.type, SopStepType.unknown);
      expect(step.type.answerableHere, isFalse);
      expect(step.visible, isTrue);
    });

    test('approval and ticket steps are not answerable from the phone', () {
      expect(SopStepType.approval.answerableHere, isFalse);
      expect(SopStepType.ticket.answerableHere, isFalse);
      expect(SopStepType.asset.answerableHere, isFalse);
      expect(SopStepType.text.answerableHere, isTrue);
      expect(SopStepType.datetime.answerableHere, isTrue);
    });
  });

  group('Answers', () {
    test('a multi-choice answer decodes to its picked options', () {
      final answer = SopAnswerDto.fromJson(const {
        'state': 'done',
        'value': '["Laptop","Dock","Headset"]',
      });

      expect(answer.selected, ['Laptop', 'Dock', 'Headset']);
      expect(answer.isDone, isTrue);
      expect(answer.isAnswered, isTrue);
    });

    test('a plain value is not read as a list', () {
      final answer = SopAnswerDto.fromJson(const {
        'state': 'done',
        'value': 'SN-12345',
      });
      expect(answer.selected, isEmpty);
    });

    test('a skipped step is answered but not done', () {
      final answer = SopAnswerDto.fromJson(const {
        'state': 'skipped',
        'note': 'no dock in stock',
      });

      expect(answer.isSkipped, isTrue);
      expect(answer.isDone, isFalse);
      expect(answer.isAnswered, isTrue);
      expect(answer.note, 'no dock in stock');
    });

    test('an untouched step is neither', () {
      expect(SopAnswerDto.blank.isAnswered, isFalse);
      expect(SopAnswerDto.blank.value, isNull);
    });
  });

  group('Log', () {
    test('carries the who, the what and the when', () {
      final entry = SopLogEntryDto.fromJson(const {
        'at': '2026-09-06 00:16:00',
        'who': 'glpi',
        'action': 'answered',
        'label': 'answered',
        'step': 'Verify approval',
        'detail': 'yes',
      });

      expect(entry.who, 'glpi');
      expect(entry.label, 'answered');
      expect(entry.step, 'Verify approval');
    });
  });
}
