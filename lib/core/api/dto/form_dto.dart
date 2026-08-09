/// GLPI 11 Service Catalog forms, as served by the `glpimobile` plugin.
///
/// GLPI has no REST API for forms, so the plugin serializes them: sections →
/// questions, with dropdown options already resolved server-side. Answers are
/// submitted back by question id and GLPI's own destination config maps them
/// onto the created ticket.
library;

/// A form as listed in the catalog.
class FormSummaryDto {
  const FormSummaryDto({
    required this.id,
    required this.name,
    required this.description,
    required this.illustration,
  });

  final int id;
  final String name;
  final String description;
  final String illustration;

  factory FormSummaryDto.fromJson(Map<String, Object?> json) => FormSummaryDto(
    id: (json['id'] as num).toInt(),
    name: (json['name'] ?? '') as String,
    description: (json['description'] ?? '') as String,
    illustration: (json['illustration'] ?? '') as String,
  );
}

/// A selectable option for a choice/dropdown question.
class FormOption {
  const FormOption({required this.value, required this.label});

  final String value;
  final String label;

  factory FormOption.fromJson(Map<String, Object?> json) => FormOption(
    value: '${json['value'] ?? ''}',
    label: '${json['label'] ?? ''}',
  );
}

/// Question types the renderer understands. [unsupported] keeps unknown types
/// visible (as a disabled note) rather than silently dropping them.
enum QuestionKind {
  shortText,
  longText,
  email,
  number,
  checkbox,
  radio,
  dropdown,
  itemDropdown,
  urgency,
  requestType,
  dateTime,
  file,
  actors,
  userDevice,
  item,
  unsupported;

  static QuestionKind fromSlug(String slug) => switch (slug) {
    'short_text' => QuestionKind.shortText,
    'long_text' => QuestionKind.longText,
    'email' => QuestionKind.email,
    'number' => QuestionKind.number,
    'checkbox' => QuestionKind.checkbox,
    'radio' => QuestionKind.radio,
    'dropdown' => QuestionKind.dropdown,
    'item_dropdown' => QuestionKind.itemDropdown,
    'urgency' => QuestionKind.urgency,
    'request_type' => QuestionKind.requestType,
    'date_time' => QuestionKind.dateTime,
    'file' => QuestionKind.file,
    'requester' || 'observer' || 'assignee' => QuestionKind.actors,
    'user_device' => QuestionKind.userDevice,
    'item' => QuestionKind.item,
    _ => QuestionKind.unsupported,
  };
}

/// A condition row: `item_uuid value_operator value`, joined by
/// [logicOperator] with the previous one.
class FormCondition {
  const FormCondition({
    required this.itemUuid,
    required this.valueOperator,
    required this.value,
    required this.logicOperator,
  });

  final String itemUuid;
  final String valueOperator;
  final Object? value;
  final String logicOperator; // 'and' | 'or'

  factory FormCondition.fromJson(Map<String, Object?> json) => FormCondition(
    itemUuid: '${json['item_uuid'] ?? ''}',
    valueOperator: '${json['value_operator'] ?? ''}',
    value: json['value'],
    logicOperator: '${json['logic_operator'] ?? 'and'}',
  );
}

class FormQuestionDto {
  const FormQuestionDto({
    required this.id,
    required this.uuid,
    required this.name,
    required this.kind,
    required this.typeSlug,
    required this.mandatory,
    required this.description,
    required this.defaultValue,
    required this.options,
    required this.extraData,
    required this.visibilityStrategy,
    required this.conditions,
  });

  final int id;
  final String uuid;
  final String name;
  final QuestionKind kind;
  final String typeSlug;
  final bool mandatory;
  final String description;
  final String? defaultValue;
  final List<FormOption> options;
  final Map<String, Object?>? extraData;
  final String visibilityStrategy;
  final List<FormCondition> conditions;

  /// Actor questions accept multiple people when configured to.
  bool get multipleActors => _flag(extraData?['is_multiple_actors']);

  /// Device questions can accept several assets.
  bool get multipleDevices => _flag(extraData?['is_multiple_devices']);

  /// GLPI is not consistent about these flags: the same setting arrives as a
  /// real boolean on one form and as the string `"0"` on another, depending on
  /// which editor wrote it. A plain `as bool?` throws on the string — and a
  /// throw here takes out the whole field with it.
  static bool _flag(Object? raw) {
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    if (raw is String) return raw == '1' || raw.toLowerCase() == 'true';
    return false;
  }

  factory FormQuestionDto.fromJson(Map<String, Object?> json) {
    final slug = '${json['type'] ?? ''}';
    return FormQuestionDto(
      id: (json['id'] as num).toInt(),
      uuid: '${json['uuid'] ?? ''}',
      name: (json['name'] ?? '') as String,
      kind: QuestionKind.fromSlug(slug),
      typeSlug: slug,
      mandatory: json['mandatory'] == true,
      description: (json['description'] ?? '') as String,
      defaultValue: json['default_value']?.toString(),
      options: (json['options'] as List<Object?>? ?? const [])
          .whereType<Map<String, Object?>>()
          .map(FormOption.fromJson)
          .toList(),
      extraData: json['extra_data'] as Map<String, Object?>?,
      visibilityStrategy: '${json['visibility_strategy'] ?? ''}',
      conditions: (json['conditions'] as List<Object?>? ?? const [])
          .whereType<Map<String, Object?>>()
          .map(FormCondition.fromJson)
          .toList(),
    );
  }
}

class FormSectionDto {
  const FormSectionDto({
    required this.id,
    required this.uuid,
    required this.name,
    required this.description,
    required this.questions,
    required this.visibilityStrategy,
    required this.conditions,
  });

  final int id;
  final String uuid;
  final String name;
  final String description;
  final List<FormQuestionDto> questions;
  final String visibilityStrategy;
  final List<FormCondition> conditions;

  factory FormSectionDto.fromJson(Map<String, Object?> json) => FormSectionDto(
    id: (json['id'] as num).toInt(),
    uuid: '${json['uuid'] ?? ''}',
    name: (json['name'] ?? '') as String,
    description: (json['description'] ?? '') as String,
    questions: (json['questions'] as List<Object?>? ?? const [])
        .whereType<Map<String, Object?>>()
        .map(FormQuestionDto.fromJson)
        .toList(),
    visibilityStrategy: '${json['visibility_strategy'] ?? ''}',
    conditions: (json['conditions'] as List<Object?>? ?? const [])
        .whereType<Map<String, Object?>>()
        .map(FormCondition.fromJson)
        .toList(),
  );
}

/// A full form definition, ready to render.
class FormDefinitionDto {
  const FormDefinitionDto({
    required this.id,
    required this.name,
    required this.description,
    required this.sections,
  });

  final int id;
  final String name;
  final String description;
  final List<FormSectionDto> sections;

  List<FormQuestionDto> get allQuestions => [
    for (final s in sections) ...s.questions,
  ];

  factory FormDefinitionDto.fromJson(Map<String, Object?> json) =>
      FormDefinitionDto(
        id: (json['id'] as num).toInt(),
        name: (json['name'] ?? '') as String,
        description: (json['description'] ?? '') as String,
        sections: (json['sections'] as List<Object?>? ?? const [])
            .whereType<Map<String, Object?>>()
            .map(FormSectionDto.fromJson)
            .toList(),
      );
}

/// What a submission created (typically one ticket).
class FormSubmitResult {
  const FormSubmitResult({required this.answersSetId, required this.ticketId});

  final int answersSetId;
  final int? ticketId;

  factory FormSubmitResult.fromJson(Map<String, Object?> json) {
    int? ticketId;
    for (final item in (json['created'] as List<Object?>? ?? const [])) {
      if (item is Map && item['itemtype'] == 'Ticket') {
        ticketId = (item['id'] as num?)?.toInt();
        break;
      }
    }
    return FormSubmitResult(
      answersSetId: (json['answers_set_id'] as num?)?.toInt() ?? 0,
      ticketId: ticketId,
    );
  }
}
