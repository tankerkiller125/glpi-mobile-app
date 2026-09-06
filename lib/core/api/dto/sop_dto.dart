/// DTOs for the glpi-sop plugin (`/GlpiSop/*`): the procedures attached to a
/// ticket, and the run a technician answers step by step.
///
/// The server owns every rule about what an answer means — which steps are
/// being asked, whether a value is valid, what the counters are. These types
/// carry that answer; they never recompute it.
library;

int _intOf(Object? v) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

String _stringOf(Object? v) => v == null ? '' : '$v';

/// The step types the plugin defines. Anything a newer server adds arrives as
/// [SopStepType.unknown], which the app renders read-only rather than hiding —
/// a step nobody can see is a step nobody does.
enum SopStepType {
  check,
  yesno,
  text,
  textarea,
  number,
  choice,
  multichoice,
  date,
  datetime,
  user,
  asset,
  document,
  ticket,
  approval,
  unknown;

  static SopStepType parse(String raw) => switch (raw) {
    'check' => SopStepType.check,
    'yesno' => SopStepType.yesno,
    'text' => SopStepType.text,
    'textarea' => SopStepType.textarea,
    'number' => SopStepType.number,
    'choice' => SopStepType.choice,
    'multichoice' => SopStepType.multichoice,
    'date' => SopStepType.date,
    'datetime' => SopStepType.datetime,
    'user' => SopStepType.user,
    'asset' => SopStepType.asset,
    'document' => SopStepType.document,
    'ticket' => SopStepType.ticket,
    'approval' => SopStepType.approval,
    _ => SopStepType.unknown,
  };

  /// Types the phone can answer on its own. The rest are either answered
  /// elsewhere (approval, ticket) or need a picker the app does not have on
  /// this screen (asset, document) — both render read-only with an
  /// explanation rather than a control that cannot work.
  bool get answerableHere => switch (this) {
    SopStepType.check ||
    SopStepType.yesno ||
    SopStepType.text ||
    SopStepType.textarea ||
    SopStepType.number ||
    SopStepType.choice ||
    SopStepType.multichoice ||
    SopStepType.date ||
    SopStepType.datetime => true,
    _ => false,
  };
}

/// A procedure attached to a ticket, as the ticket screen lists it.
class SopRunDto {
  const SopRunDto({
    required this.id,
    required this.name,
    required this.status,
    required this.statusLabel,
    required this.origin,
    required this.total,
    required this.done,
    required this.totalRequired,
    required this.doneRequired,
    required this.enforcing,
    required this.editable,
  });

  final int id;
  final String name;

  /// `in_progress`, `completed` or `abandoned`.
  final String status;

  /// Already translated by the server.
  final String statusLabel;

  /// How it got here: `trigger`, `template`, `rule`, `manual`, `ai`.
  final String origin;

  /// Counts over the steps actually being asked — a step whose condition is
  /// not met is not outstanding, and is not counted.
  final int total;
  final int done;
  final int totalRequired;
  final int doneRequired;

  /// This procedure blocks solving the ticket until its required steps are done.
  final bool enforcing;

  /// False when the run is locked, frozen by age, or the caller cannot update
  /// the item. The app shows it read-only rather than hiding it.
  final bool editable;

  int get outstanding => (totalRequired - doneRequired).clamp(0, totalRequired);
  bool get isComplete => status == 'completed';
  bool get isAbandoned => status == 'abandoned';

  /// 0–1 for a progress bar. Zero-step runs read as complete rather than as
  /// a division by zero.
  double get fraction => total <= 0 ? 1 : (done / total).clamp(0, 1).toDouble();

  factory SopRunDto.fromJson(Map<String, Object?> json) => SopRunDto(
    id: _intOf(json['id']),
    name: _stringOf(json['name']),
    status: _stringOf(json['status']),
    statusLabel: _stringOf(json['status_label']),
    origin: _stringOf(json['origin']),
    total: _intOf(json['total']),
    done: _intOf(json['done']),
    totalRequired: _intOf(json['total_required']),
    doneRequired: _intOf(json['done_required']),
    enforcing: json['enforcing'] == true,
    editable: json['editable'] == true,
  );
}

/// A heading inside a procedure.
class SopSectionDto {
  const SopSectionDto({required this.id, required this.name});

  final int id;
  final String name;

  factory SopSectionDto.fromJson(Map<String, Object?> json) =>
      SopSectionDto(id: _intOf(json['id']), name: _stringOf(json['name']));
}

/// What has been recorded against one step.
class SopAnswerDto {
  const SopAnswerDto({
    required this.state,
    required this.value,
    required this.valueItemtype,
    required this.valueItemsId,
    required this.documentsId,
    required this.note,
    required this.text,
    required this.meta,
  });

  static const blank = SopAnswerDto(
    state: 'pending',
    value: null,
    valueItemtype: '',
    valueItemsId: 0,
    documentsId: 0,
    note: '',
    text: '',
    meta: '',
  );

  /// `pending`, `done` or `skipped`.
  final String state;

  /// The raw stored value: the text typed, the option picked, the date, or a
  /// JSON array for a multi-choice step.
  final String? value;
  final String valueItemtype;
  final int valueItemsId;
  final int documentsId;
  final String note;

  /// The answer as words, composed server-side ("yes", "3.50", a user's name).
  final String text;

  /// Who answered it and when, already formatted and translated.
  final String meta;

  bool get isDone => state == 'done';
  bool get isSkipped => state == 'skipped';
  bool get isAnswered => isDone || isSkipped;

  /// The picked options of a multi-choice answer, which the server stores as a
  /// JSON array in [value].
  List<String> get selected {
    final raw = value;
    if (raw == null || !raw.startsWith('[')) return const [];
    // Deliberately not a JSON decode of arbitrary shape: the only thing this
    // is ever asked for is a flat list of option strings.
    final inner = raw.substring(1, raw.length - 1).trim();
    if (inner.isEmpty) return const [];
    return [
      for (final part in inner.split(','))
        part.trim().replaceAll(RegExp(r'^"|"$'), '').replaceAll(r'\"', '"'),
    ];
  }

  factory SopAnswerDto.fromJson(Map<String, Object?> json) => SopAnswerDto(
    state: _stringOf(json['state']),
    value: json['value'] == null ? null : _stringOf(json['value']),
    valueItemtype: _stringOf(json['value_itemtype']),
    valueItemsId: _intOf(json['value_items_id']),
    documentsId: _intOf(json['documents_id']),
    note: _stringOf(json['note']),
    text: _stringOf(json['text']),
    meta: _stringOf(json['meta']),
  );
}

/// One step of a procedure, with everything needed to draw its control.
class SopStepDto {
  const SopStepDto({
    required this.id,
    required this.sectionsId,
    required this.number,
    required this.label,
    required this.help,
    required this.type,
    required this.typeLabel,
    required this.required,
    required this.visible,
    required this.parentId,
    required this.options,
    required this.itemtypes,
    required this.min,
    required this.max,
    required this.answer,
  });

  final int id;
  final int sectionsId;

  /// "3", "3a" — the server's numbering, which encodes the branch structure.
  final String number;
  final String label;
  final String help;
  final SopStepType type;
  final String typeLabel;
  final bool required;

  /// Whether this step is being asked at all. A step whose condition is not
  /// met is not outstanding and must not be shown as unanswered work.
  final bool visible;

  /// The step this one branches from, or 0.
  final int parentId;

  /// Choices, for choice/multichoice.
  final List<String> options;

  /// Allowed asset types, for an asset step.
  final List<String> itemtypes;
  final String? min;
  final String? max;
  final SopAnswerDto answer;

  bool get isChild => parentId > 0;

  factory SopStepDto.fromJson(Map<String, Object?> json) {
    final config = json['config'] is Map
        ? (json['config'] as Map).cast<String, Object?>()
        : const <String, Object?>{};
    final answer = json['answer'] is Map
        ? SopAnswerDto.fromJson((json['answer'] as Map).cast<String, Object?>())
        : SopAnswerDto.blank;

    return SopStepDto(
      id: _intOf(json['id']),
      sectionsId: _intOf(json['sections_id']),
      number: _stringOf(json['number']),
      label: _stringOf(json['label']),
      help: _stringOf(json['help']),
      type: SopStepType.parse(_stringOf(json['type'])),
      typeLabel: _stringOf(json['type_label']),
      required: json['required'] == true,
      visible: json['visible'] == true,
      parentId: _intOf(json['parent_id']),
      options: config['options'] is List
          ? [for (final o in config['options'] as List) '$o']
          : const [],
      itemtypes: config['itemtypes'] is List
          ? [for (final t in config['itemtypes'] as List) '$t']
          : const [],
      min: config['min'] == null ? null : '${config['min']}',
      max: config['max'] == null ? null : '${config['max']}',
      answer: answer,
    );
  }
}

/// A run, whole: its steps, its headings and its counters.
class SopRunDetailDto {
  const SopRunDetailDto({
    required this.run,
    required this.description,
    required this.allowSkip,
    required this.skipReasonRequired,
    required this.locked,
    required this.frozen,
    required this.percent,
    required this.sections,
    required this.steps,
  });

  final SopRunDto run;
  final String description;

  /// The instance allows skipping a step, and whether a reason is compulsory.
  final bool allowSkip;
  final bool skipReasonRequired;

  /// A finished run locks itself; a long-finished one freezes for good.
  final bool locked;
  final bool frozen;
  final int percent;
  final List<SopSectionDto> sections;
  final List<SopStepDto> steps;

  /// The steps actually being asked, in order.
  List<SopStepDto> get visibleSteps => [
    for (final s in steps)
      if (s.visible) s,
  ];

  String sectionName(int id) {
    for (final s in sections) {
      if (s.id == id) return s.name;
    }
    return '';
  }

  factory SopRunDetailDto.fromJson(Map<String, Object?> json) =>
      SopRunDetailDto(
        run: SopRunDto.fromJson(json),
        description: _stringOf(json['description']),
        allowSkip: json['allow_skip'] == true,
        skipReasonRequired: json['skip_reason_required'] == true,
        locked: json['locked'] == true,
        frozen: json['frozen'] == true,
        percent: json['progress'] is Map
            ? _intOf((json['progress'] as Map)['percent'])
            : 0,
        sections: json['sections'] is List
            ? [
                for (final s in json['sections'] as List)
                  if (s is Map)
                    SopSectionDto.fromJson(s.cast<String, Object?>()),
              ]
            : const [],
        steps: json['steps'] is List
            ? [
                for (final s in json['steps'] as List)
                  if (s is Map) SopStepDto.fromJson(s.cast<String, Object?>()),
              ]
            : const [],
      );
}

/// One line of a run's history.
class SopLogEntryDto {
  const SopLogEntryDto({
    required this.at,
    required this.who,
    required this.label,
    required this.step,
    required this.detail,
  });

  final String at;
  final String who;

  /// The action, already translated ("answered", "skipped", …).
  final String label;
  final String step;
  final String detail;

  factory SopLogEntryDto.fromJson(Map<String, Object?> json) => SopLogEntryDto(
    at: _stringOf(json['at']),
    who: _stringOf(json['who']),
    label: _stringOf(json['label']),
    step: _stringOf(json['step']),
    detail: _stringOf(json['detail']),
  );
}
