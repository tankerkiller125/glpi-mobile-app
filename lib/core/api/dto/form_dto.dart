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

/// What a catalog entry *is*, which is also what tapping it does: file a form,
/// open a category, read an article. Anything a newer server adds arrives as
/// [unknown] and is skipped rather than shown as a row that does nothing.
enum ServiceCatalogItemKind {
  form,
  category,
  kb,
  unknown;

  static ServiceCatalogItemKind parse(String raw) => switch (raw) {
    'form' => ServiceCatalogItemKind.form,
    'category' => ServiceCatalogItemKind.category,
    'kb' => ServiceCatalogItemKind.kb,
    _ => ServiceCatalogItemKind.unknown,
  };
}

/// One entry in the service catalog: a form, a category, or a knowledge-base
/// article — the three things GLPI 11 lists side by side in its own catalog.
class ServiceCatalogItemDto {
  const ServiceCatalogItemDto({
    required this.kind,
    required this.id,
    required this.name,
    required this.description,
    required this.illustration,
    required this.pinned,
    required this.children,
  });

  final ServiceCatalogItemKind kind;
  final int id;
  final String name;
  final String description;

  /// GLPI's illustration slug (`report-issue`, `request-service`, …). The app
  /// maps it to an icon; an unknown slug degrades to a generic one.
  final String illustration;

  /// Pinned items are sorted first by the server. Kept so the app can mark
  /// them, never to re-sort: order is the server's business.
  final bool pinned;

  /// A category's children — one level, already loaded, which is exactly what
  /// the "expand categories" setting renders in place. Empty for leaves, and
  /// for a nested category, which is a tile you open.
  final List<ServiceCatalogItemDto> children;

  bool get isCategory => kind == ServiceCatalogItemKind.category;

  factory ServiceCatalogItemDto.fromJson(Map<String, Object?> json) =>
      ServiceCatalogItemDto(
        kind: ServiceCatalogItemKind.parse('${json['kind'] ?? ''}'),
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: '${json['name'] ?? ''}',
        description: '${json['description'] ?? ''}',
        illustration: '${json['illustration'] ?? ''}',
        pinned: json['pinned'] == true,
        children: json['children'] is List
            ? [
                for (final c in json['children'] as List)
                  if (c is Map)
                    ServiceCatalogItemDto.fromJson(c.cast<String, Object?>()),
              ]
            : const [],
      );
}

/// One step of the category breadcrumb, root first, ending with the category
/// being looked at.
class ServiceCatalogCrumb {
  const ServiceCatalogCrumb({required this.id, required this.name});

  final int id;
  final String name;

  factory ServiceCatalogCrumb.fromJson(Map<String, Object?> json) =>
      ServiceCatalogCrumb(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: '${json['name'] ?? ''}',
      );
}

/// One level of the service catalog, with the entity's display settings.
///
/// The settings travel with the level rather than being asked for separately
/// because they are per-entity and inherited: switching entity in the app can
/// change how the catalog is meant to look, and a cached answer from the last
/// entity would be wrong in a way nobody would think to check.
class ServiceCatalogPageDto {
  const ServiceCatalogPageDto({
    required this.expandCategories,
    required this.sortStrategy,
    required this.categoryId,
    required this.ancestors,
    required this.items,
    required this.total,
  });

  static const empty = ServiceCatalogPageDto(
    expandCategories: false,
    sortStrategy: 'popularity',
    categoryId: 0,
    ancestors: [],
    items: [],
    total: 0,
  );

  /// GLPI's *Expand categories in the service catalog* entity setting: a
  /// category is drawn as a section with its forms under it rather than as a
  /// tile you tap into.
  final bool expandCategories;

  /// `popularity`, `alphabetical` or `reverse_alphabetical` — the entity's
  /// default. Reported for transparency; the ordering itself is the server's,
  /// and the app never re-sorts (pinned first, then categories, then the
  /// strategy).
  final String sortStrategy;

  /// 0 at the root of the tree.
  final int categoryId;
  final List<ServiceCatalogCrumb> ancestors;
  final List<ServiceCatalogItemDto> items;

  /// How many entries this level has, which may exceed what was fetched.
  final int total;

  /// The name of the category being looked at, or empty at the root.
  String get title => ancestors.isEmpty ? '' : ancestors.last.name;

  /// Every illustration this level draws, children included — a category
  /// rendered as a section shows its forms' artwork too, and asking for it in
  /// the same request is the difference between a list that paints and one
  /// that fills in.
  List<String> get illustrationIds {
    final ids = <String>{};
    void walk(ServiceCatalogItemDto item) {
      if (item.illustration.isNotEmpty) ids.add(item.illustration);
      item.children.forEach(walk);
    }

    items.forEach(walk);
    return ids.toList();
  }

  bool get isEmpty => items.isEmpty;

  /// Built from the flat `/forms` list, for a server whose plugin predates the
  /// catalog route: every form, no categories, nothing expanded.
  factory ServiceCatalogPageDto.flat(List<FormSummaryDto> forms) =>
      ServiceCatalogPageDto(
        expandCategories: false,
        sortStrategy: 'alphabetical',
        categoryId: 0,
        ancestors: const [],
        items: [
          for (final form in forms)
            ServiceCatalogItemDto(
              kind: ServiceCatalogItemKind.form,
              id: form.id,
              name: form.name,
              description: form.description,
              illustration: form.illustration,
              pinned: false,
              children: const [],
            ),
        ],
        total: forms.length,
      );

  factory ServiceCatalogPageDto.fromJson(Map<String, Object?> json) =>
      ServiceCatalogPageDto(
        expandCategories: json['expand_categories'] == true,
        sortStrategy: '${json['sort_strategy'] ?? 'popularity'}',
        categoryId: (json['category_id'] as num?)?.toInt() ?? 0,
        ancestors: json['ancestors'] is List
            ? [
                for (final a in json['ancestors'] as List)
                  if (a is Map)
                    ServiceCatalogCrumb.fromJson(a.cast<String, Object?>()),
              ]
            : const [],
        items: json['items'] is List
            ? [
                for (final i in json['items'] as List)
                  if (i is Map)
                    ServiceCatalogItemDto.fromJson(i.cast<String, Object?>()),
              ]
            : const [],
        total: (json['total'] as num?)?.toInt() ?? 0,
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
