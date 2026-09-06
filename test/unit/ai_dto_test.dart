import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/dto/ai_dto.dart';
import 'package:glpi_mobile/core/api/sse.dart';

void main() {
  group('AI status', () {
    test('reads the per-entity answer', () {
      final status = AiStatusDto.fromJson(const {
        'enabled': true,
        'entity_allowed': true,
        'assistant': true,
        'draft': false,
        'reply_review': true,
        'triage': false,
      });
      expect(status.assistant, isTrue);
      expect(status.draft, isFalse);
      expect(status.triage, isFalse);
    });

    test('an empty body reads as everything off', () {
      final status = AiStatusDto.fromJson(const {});
      expect(status.enabled, isFalse);
      expect(status.assistant, isFalse);
    });
  });

  group('Threads', () {
    test('carries the context and the transcript', () {
      final detail = AiThreadDetailDto.fromJson(const {
        'id': 7,
        'title': 'Why is that laptop slow',
        'itemtype': 'Ticket',
        'items_id': 42,
        'date_mod': '2026-09-05 20:00:00',
        'context': 'Ticket #42 — Slow laptop',
        'messages': [
          {'role': 'user', 'content': 'why is it slow', 'trail': ''},
          {
            'role': 'assistant',
            'content': 'The disk is at 96%.',
            'content_html': '<p>The disk is at 96%.</p>',
            'trail': 'osquery_live',
          },
        ],
      });

      expect(detail.thread.id, 7);
      expect(detail.thread.hasContext, isTrue);
      expect(detail.context, 'Ticket #42 — Slow laptop');
      expect(detail.messages, hasLength(2));
      expect(detail.messages.last.isAssistant, isTrue);
      expect(detail.messages.last.contentHtml, contains('96%'));
      expect(detail.messages.last.trail, 'osquery_live');
    });

    test('a thread with no context is the general one', () {
      final thread = AiThreadDto.fromJson(const {
        'id': 3,
        'itemtype': '',
        'items_id': 0,
      });
      expect(thread.hasContext, isFalse);
      expect(thread.title, isEmpty);
    });
  });

  group('Stream events', () {
    test('names map to kinds, unknown ones survive', () {
      expect(AiEventKind.parse('tool_result'), AiEventKind.toolResult);
      expect(AiEventKind.parse('done'), AiEventKind.done);
      expect(AiEventKind.parse('something_new'), AiEventKind.unknown);
    });

    test('a done frame carries the whole answer', () {
      const event = AiStreamEvent(
        kind: AiEventKind.done,
        data: {
          'answer': 'The disk is full.',
          'answer_html': '<p>The disk is full.</p>',
          'trail': 'osquery_live',
          'tools': [
            {'name': 'osquery_live', 'error': false, 'args': '{"host":"a"}'},
          ],
          'exhausted': false,
          'truncated': true,
          'continued': 1,
        },
      );

      final answer = event.answer;
      expect(answer.answer, 'The disk is full.');
      expect(answer.answerHtml, contains('<p>'));
      expect(answer.truncated, isTrue);
      expect(answer.continued, 1);
      expect(answer.tools.single.name, 'osquery_live');
      expect(answer.tools.single.error, isFalse);
    });
  });

  group('SSE decoding', () {
    Stream<String> lines(List<String> l) => Stream.fromIterable(l);

    test('a frame ends at the blank line', () async {
      final events = await decodeSse(
        lines([
          'event: turn',
          'data: {"turn":1,"budget":12}',
          '',
          'event: text',
          'data: {"text":"OK"}',
          '',
        ]),
      ).toList();

      expect(events, hasLength(2));
      expect(events.first.event, 'turn');
      expect(events.first.data['turn'], 1);
      expect(events.last.data['text'], 'OK');
    });

    test('data lines accumulate across a split payload', () async {
      final events = await decodeSse(
        lines(['event: done', 'data: {"answer":', 'data: "yes"}', '']),
      ).toList();

      expect(events.single.data['answer'], 'yes');
    });

    test('a truncated payload is dropped, not thrown', () async {
      final events = await decodeSse(
        lines([
          'event: text',
          'data: {"text":',
          '',
          'event: done',
          'data: {}',
          '',
        ]),
      ).toList();

      expect(events, hasLength(1));
      expect(events.single.event, 'done');
    });

    test('a final frame with no trailing blank line still arrives', () async {
      final events = await decodeSse(
        lines(['event: failed', 'data: {"message":"rate limit"}']),
      ).toList();

      expect(events.single.data['message'], 'rate limit');
    });

    test('comments and unknown fields are ignored', () async {
      final events = await decodeSse(
        lines([
          ': keep-alive',
          'id: 4',
          'event: open',
          'data: {"thread":9}',
          '',
        ]),
      ).toList();

      expect(events.single.event, 'open');
      expect(events.single.data['thread'], 9);
    });
  });

  group('Drafts', () {
    test('a ready, undecided draft is offerable', () {
      final state = AiDraftStateDto.fromJson(const {
        'available': true,
        'refusal': null,
        'draft': {
          'id': 5,
          'kind': 'solution',
          'state': 'ready',
          'outcome': '',
          'confidence': 'high',
          'content': 'Replace the disk.',
          'content_html': '<p>Replace the disk.</p>',
        },
      });

      expect(state.available, isTrue);
      expect(state.refusal, isNull);
      expect(state.draft!.isReady, isTrue);
      expect(state.draft!.isDecided, isFalse);
      expect(state.draft!.contentHtmlOrText, contains('<p>'));
    });

    test('a refusal is carried in the words the server used', () {
      final state = AiDraftStateDto.fromJson(const {
        'available': false,
        'refusal': 'Drafting is switched off.',
        'draft': null,
      });

      expect(state.available, isFalse);
      expect(state.refusal, 'Drafting is switched off.');
      expect(state.draft, isNull);
    });

    test('a draft with no HTML falls back to its markdown', () {
      final draft = AiDraftDto.fromJson(const {
        'id': 1,
        'state': 'ready',
        'content': 'Replace the disk.',
      });
      expect(draft.contentHtmlOrText, 'Replace the disk.');
    });
  });

  group('Triage', () {
    test('only undecided, non-matching proposals are open', () {
      final state = AiTriageStateDto.fromJson(const {
        'can_apply': true,
        'suggestion': {
          'id': 2,
          'state': 'ready',
          'confidence': 'medium',
          'reasoning': 'Mentions Outlook.',
          'fields': [
            {
              'field': 'itilcategories_id',
              'value': 3,
              'label': 'Email',
              'current': 1,
              'current_label': 'General',
              'matches': false,
              'outcome': '',
            },
            {
              'field': 'urgency',
              'value': 3,
              'label': 'Medium',
              'current': 3,
              'current_label': 'Medium',
              'matches': true,
              'outcome': 'matched',
            },
            {
              'field': 'impact',
              'value': 4,
              'label': 'High',
              'current': 3,
              'current_label': 'Medium',
              'matches': false,
              'outcome': 'dismissed',
            },
          ],
        },
      });

      final open = state.suggestion!.open;
      expect(open, hasLength(1));
      expect(open.single.field, 'itilcategories_id');
      expect(state.suggestion!.isReady, isTrue);
      expect(state.canApply, isTrue);
    });

    test('no suggestion is not an error', () {
      final state = AiTriageStateDto.fromJson(const {
        'can_apply': false,
        'suggestion': null,
      });
      expect(state.suggestion, isNull);
      expect(state.canApply, isFalse);
    });
  });

  group('Reply review', () {
    test('a clean verdict has no flags', () {
      final review = ReplyReviewDto.fromJson(const {
        'verdict': 'ok',
        'flags': [],
      });
      expect(review.isClean, isTrue);
    });

    test('flags keep the quote and the reason', () {
      final review = ReplyReviewDto.fromJson(const {
        'verdict': 'check',
        'flags': [
          {
            'kind': 'internal',
            'label': 'Internal content',
            'quote': 'the DC is on the same VLAN',
            'why': 'That is internal detail.',
          },
          {
            'kind': 'next_step',
            'label': 'No next step',
            'quote': '',
            'why': 'It does not say what happens next.',
          },
        ],
      });

      expect(review.isClean, isFalse);
      expect(review.flags, hasLength(2));
      expect(review.flags.first.quote, contains('VLAN'));
      // next_step is the one kind allowed an empty quote — it is about what is
      // not there.
      expect(review.flags.last.quote, isEmpty);
    });
  });
}
