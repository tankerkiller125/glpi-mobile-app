/// DTOs for the glpi-ai plugin (`/GlpiAi/*`): the assistant's conversations and
/// the three things it does on a ticket — draft a solution, propose a triage,
/// read a reply before it is sent.
///
/// Parsed tolerantly, like every other plugin DTO here: a field an older server
/// does not send degrades to empty rather than throwing, because the app has to
/// keep working against whatever mix of plugin versions a fleet is running.
library;

int _intOf(Object? v) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

String _stringOf(Object? v) => v == null ? '' : '$v';

/// What the server will actually answer right now (`GET /GlpiAi/status`).
///
/// Distinct from the capability map, and deliberately: capabilities are
/// computed once per session, and the entity gate — which decides whether this
/// entity's data may reach a provider at all — moves when the technician
/// switches entity. This is the answer for the entity the request was made in.
class AiStatusDto {
  const AiStatusDto({
    required this.enabled,
    required this.entityAllowed,
    required this.assistant,
    required this.draft,
    required this.replyReview,
    required this.triage,
  });

  static const off = AiStatusDto(
    enabled: false,
    entityAllowed: false,
    assistant: false,
    draft: false,
    replyReview: false,
    triage: false,
  );

  final bool enabled;
  final bool entityAllowed;
  final bool assistant;
  final bool draft;
  final bool replyReview;
  final bool triage;

  factory AiStatusDto.fromJson(Map<String, Object?> json) => AiStatusDto(
    enabled: json['enabled'] == true,
    entityAllowed: json['entity_allowed'] == true,
    assistant: json['assistant'] == true,
    draft: json['draft'] == true,
    replyReview: json['reply_review'] == true,
    triage: json['triage'] == true,
  );
}

/// One conversation in the history list.
class AiThreadDto {
  const AiThreadDto({
    required this.id,
    required this.title,
    required this.itemtype,
    required this.itemsId,
    required this.dateMod,
  });

  final int id;

  /// Taken from the first question asked, and never changed afterwards — so a
  /// thread stays recognisable between visits. Empty until something is asked.
  final String title;

  /// The record the conversation was opened on, or empty for a general thread.
  final String itemtype;
  final int itemsId;
  final String dateMod;

  bool get hasContext => itemtype.isNotEmpty && itemsId > 0;

  factory AiThreadDto.fromJson(Map<String, Object?> json) => AiThreadDto(
    id: _intOf(json['id']),
    title: _stringOf(json['title']),
    itemtype: _stringOf(json['itemtype']),
    itemsId: _intOf(json['items_id']),
    dateMod: _stringOf(json['date_mod']),
  );
}

/// One turn of a transcript.
class AiMessageDto {
  const AiMessageDto({
    required this.role,
    required this.content,
    required this.contentHtml,
    required this.trail,
  });

  /// `user` or `assistant`.
  final String role;

  /// The markdown the model wrote. Rendered by the app rather than the server's
  /// HTML: a phone styles its own bubbles, and the source is what survives a
  /// copy to the clipboard.
  final String content;

  /// The same answer rendered server-side. Used rather than a second markdown
  /// implementation on the phone: one renderer, one place for the escaping to
  /// be right. Empty for the technician's own questions, and for an answer
  /// still streaming in.
  final String contentHtml;

  /// One line naming what the model reached for on this turn ("no tools used",
  /// "read_ticket, osquery_live"). Shown under the answer, because an answer
  /// that came from looking at the machine and one that came from the model's
  /// general knowledge read identically.
  final String trail;

  bool get isAssistant => role == 'assistant';

  factory AiMessageDto.fromJson(Map<String, Object?> json) => AiMessageDto(
    role: _stringOf(json['role']),
    content: _stringOf(json['content']),
    contentHtml: _stringOf(json['content_html']),
    trail: _stringOf(json['trail']),
  );
}

/// A conversation with its transcript (`POST /GlpiAi/threads`, `GET .../{id}`).
class AiThreadDetailDto {
  const AiThreadDetailDto({
    required this.thread,
    required this.context,
    required this.messages,
  });

  final AiThreadDto thread;

  /// What the server says the thread is about ("Ticket #7 — Email outage"),
  /// already resolved and rights-checked. Empty for a general conversation.
  final String context;
  final List<AiMessageDto> messages;

  factory AiThreadDetailDto.fromJson(Map<String, Object?> json) =>
      AiThreadDetailDto(
        thread: AiThreadDto.fromJson(json),
        context: _stringOf(json['context']),
        messages: json['messages'] is List
            ? [
                for (final m in json['messages'] as List)
                  if (m is Map)
                    AiMessageDto.fromJson(m.cast<String, Object?>()),
              ]
            : const [],
      );
}

/// One tool the model reached for during a run.
class AiToolCallDto {
  const AiToolCallDto({
    required this.name,
    required this.error,
    required this.arguments,
  });

  final String name;
  final bool error;

  /// The arguments it chose, as the JSON the server capped and stringified.
  final String arguments;

  factory AiToolCallDto.fromJson(Map<String, Object?> json) => AiToolCallDto(
    name: _stringOf(json['name']),
    error: json['error'] == true,
    arguments: _stringOf(json['args'] ?? json['arguments']),
  );
}

/// A finished answer — the body of `POST /threads/{id}/ask`, and of the
/// stream's `done` event.
class AiAnswerDto {
  const AiAnswerDto({
    required this.answer,
    required this.answerHtml,
    required this.trail,
    required this.tools,
    required this.exhausted,
    required this.truncated,
    required this.continued,
  });

  final String answer;

  /// The markdown rendered server-side; see [AiMessageDto.contentHtml].
  final String answerHtml;
  final String trail;
  final List<AiToolCallDto> tools;

  /// The run used every tool turn it was allowed. The answer may therefore be
  /// the model's best guess rather than its conclusion.
  final bool exhausted;

  /// The answer hit the output ceiling. Said out loud rather than left to be
  /// noticed: a truncated answer is fluent and stops somewhere plausible.
  final bool truncated;
  final int continued;

  factory AiAnswerDto.fromJson(Map<String, Object?> json) => AiAnswerDto(
    answer: _stringOf(json['answer']),
    answerHtml: _stringOf(json['answer_html']),
    trail: _stringOf(json['trail']),
    tools: json['tools'] is List
        ? [
            for (final t in json['tools'] as List)
              if (t is Map) AiToolCallDto.fromJson(t.cast<String, Object?>()),
          ]
        : const [],
    exhausted: json['exhausted'] == true,
    truncated: json['truncated'] == true,
    continued: _intOf(json['continued']),
  );
}

/// What the run is doing, as it does it.
///
/// The event names are the server's own `Progress` constants, so a server that
/// grows a new one arrives here as [AiEventKind.unknown] and is ignored rather
/// than breaking the stream.
enum AiEventKind {
  open,
  turn,
  tool,
  toolResult,
  thinking,
  text,
  continued,
  done,
  failed,
  unknown;

  static AiEventKind parse(String name) => switch (name) {
    'open' => AiEventKind.open,
    'turn' => AiEventKind.turn,
    'tool' => AiEventKind.tool,
    'tool_result' => AiEventKind.toolResult,
    'thinking' => AiEventKind.thinking,
    'text' => AiEventKind.text,
    'continued' => AiEventKind.continued,
    'done' => AiEventKind.done,
    'failed' => AiEventKind.failed,
    _ => AiEventKind.unknown,
  };
}

/// One server-sent event from `POST /GlpiAi/threads/{id}/stream`.
class AiStreamEvent {
  const AiStreamEvent({required this.kind, required this.data});

  final AiEventKind kind;
  final Map<String, Object?> data;

  /// Answer text for `text`, reasoning for `thinking`.
  String get text => _stringOf(data['text']);

  /// The tool being called, or that just finished.
  String get toolName => _stringOf(data['name']);

  /// Which turn of the agent loop is running, and how many it may use.
  int get turn => _intOf(data['turn']);
  int get budget => _intOf(data['budget']);

  /// Why the run stopped, for `failed`.
  String get message => _stringOf(data['message']);

  /// The finished answer, for `done`.
  AiAnswerDto get answer => AiAnswerDto.fromJson(data);
}

/// A drafted solution or knowledge-base article for a ticket.
class AiDraftDto {
  const AiDraftDto({
    required this.id,
    required this.kind,
    required this.state,
    required this.outcome,
    required this.title,
    required this.confidence,
    required this.knowbaseitemsId,
    required this.content,
    required this.contentHtml,
    required this.message,
  });

  final int id;

  /// `solution` or `article`.
  final String kind;

  /// `pending`, `ready` or `failed`.
  final String state;

  /// What became of it: empty (undecided), `used` or `discarded`.
  final String outcome;
  final String title;

  /// `high`, `medium`, `low` — the model's own confidence, as it reported it.
  final String confidence;

  /// Set once an article draft has been filed, so the app offers to open the
  /// article rather than to create it a second time.
  final int knowbaseitemsId;

  /// Markdown, which is what goes into the reply box — the composer wraps and
  /// sends what the technician can see and edit.
  final String content;

  /// The same text rendered server-side, for reading.
  final String contentHtml;

  /// Why it failed, when it did.
  final String message;

  bool get isReady => state == 'ready' && content.trim().isNotEmpty;

  /// What to render: the server's HTML where it sent some, else the markdown
  /// source, which reads acceptably as plain text.
  String get contentHtmlOrText =>
      contentHtml.isNotEmpty ? contentHtml : content;
  bool get isDecided => outcome.isNotEmpty;

  factory AiDraftDto.fromJson(Map<String, Object?> json) => AiDraftDto(
    id: _intOf(json['id']),
    kind: _stringOf(json['kind']),
    state: _stringOf(json['state']),
    outcome: _stringOf(json['outcome']),
    title: _stringOf(json['title']),
    confidence: _stringOf(json['confidence']),
    knowbaseitemsId: _intOf(json['knowbaseitems_id']),
    content: _stringOf(json['content']),
    contentHtml: _stringOf(json['content_html']),
    message: _stringOf(json['message']),
  );
}

/// The draft endpoint's answer: the draft, plus whether one may be asked for.
class AiDraftStateDto {
  const AiDraftStateDto({
    required this.available,
    required this.refusal,
    required this.draft,
  });

  static const unavailable = AiDraftStateDto(
    available: false,
    refusal: null,
    draft: null,
  );

  final bool available;

  /// Why not, in words the technician can act on ("Drafting is switched off",
  /// "This entity is not permitted to use AI features").
  final String? refusal;
  final AiDraftDto? draft;

  factory AiDraftStateDto.fromJson(Map<String, Object?> json) {
    final refusal = _stringOf(json['refusal']);
    final draft = json['draft'];
    return AiDraftStateDto(
      available: json['available'] == true,
      refusal: refusal.isEmpty ? null : refusal,
      draft: draft is Map
          ? AiDraftDto.fromJson(draft.cast<String, Object?>())
          : null,
    );
  }
}

/// One field a triage suggestion proposes, with both sides of the proposal.
class AiTriageFieldDto {
  const AiTriageFieldDto({
    required this.field,
    required this.value,
    required this.label,
    required this.current,
    required this.currentLabel,
    required this.matches,
    required this.outcome,
  });

  /// `itilcategories_id`, `urgency`, `impact`, or `plugin_glpisop_sops_id`.
  final String field;
  final int value;
  final String label;
  final int current;
  final String currentLabel;

  /// The ticket already says this. Not a decision, and not worth a button.
  final bool matches;

  /// Empty (open), `accepted`, `dismissed`, or `matched`.
  final String outcome;

  bool get isOpen => outcome.isEmpty && !matches;

  factory AiTriageFieldDto.fromJson(Map<String, Object?> json) =>
      AiTriageFieldDto(
        field: _stringOf(json['field']),
        value: _intOf(json['value']),
        label: _stringOf(json['label']),
        current: _intOf(json['current']),
        currentLabel: _stringOf(json['current_label']),
        matches: json['matches'] == true,
        outcome: _stringOf(json['outcome']),
      );
}

/// The triage suggestion for a ticket.
class AiTriageDto {
  const AiTriageDto({
    required this.id,
    required this.state,
    required this.confidence,
    required this.reasoning,
    required this.message,
    required this.fields,
  });

  final int id;

  /// `pending` (queued, nothing asked yet), `ready`, or `failed`.
  final String state;
  final String confidence;

  /// One line on why, from the model.
  final String reasoning;
  final String message;
  final List<AiTriageFieldDto> fields;

  bool get isReady => state == 'ready';

  /// The proposals still worth showing a button for.
  List<AiTriageFieldDto> get open => [
    for (final f in fields)
      if (f.isOpen) f,
  ];

  factory AiTriageDto.fromJson(Map<String, Object?> json) => AiTriageDto(
    id: _intOf(json['id']),
    state: _stringOf(json['state']),
    confidence: _stringOf(json['confidence']),
    reasoning: _stringOf(json['reasoning']),
    message: _stringOf(json['message']),
    fields: json['fields'] is List
        ? [
            for (final f in json['fields'] as List)
              if (f is Map)
                AiTriageFieldDto.fromJson(f.cast<String, Object?>()),
          ]
        : const [],
  );
}

/// The triage endpoint's answer: the suggestion, plus whether it may be applied.
class AiTriageStateDto {
  const AiTriageStateDto({required this.canApply, required this.suggestion});

  static const none = AiTriageStateDto(canApply: false, suggestion: null);

  final bool canApply;
  final AiTriageDto? suggestion;

  factory AiTriageStateDto.fromJson(Map<String, Object?> json) {
    final suggestion = json['suggestion'];
    return AiTriageStateDto(
      canApply: json['can_apply'] == true,
      suggestion: suggestion is Map
          ? AiTriageDto.fromJson(suggestion.cast<String, Object?>())
          : null,
    );
  }
}

/// One thing the reviewer would stop a colleague about.
class ReplyFlagDto {
  const ReplyFlagDto({
    required this.kind,
    required this.label,
    required this.quote,
    required this.why,
  });

  /// `internal`, `jargon`, `next_step` or `tone`.
  final String kind;

  /// What that kind is called, already translated by the server.
  final String label;

  /// The words it is about. Empty for `next_step`, which is about what is
  /// *not* there.
  final String quote;
  final String why;

  factory ReplyFlagDto.fromJson(Map<String, Object?> json) => ReplyFlagDto(
    kind: _stringOf(json['kind']),
    label: _stringOf(json['label']),
    quote: _stringOf(json['quote']),
    why: _stringOf(json['why']),
  );
}

/// The verdict on a drafted reply.
class ReplyReviewDto {
  const ReplyReviewDto({required this.verdict, required this.flags});

  /// `ok` — nothing to raise — or `check`.
  final String verdict;
  final List<ReplyFlagDto> flags;

  bool get isClean => flags.isEmpty;

  factory ReplyReviewDto.fromJson(Map<String, Object?> json) => ReplyReviewDto(
    verdict: _stringOf(json['verdict']),
    flags: json['flags'] is List
        ? [
            for (final f in json['flags'] as List)
              if (f is Map) ReplyFlagDto.fromJson(f.cast<String, Object?>()),
          ]
        : const [],
  );
}
