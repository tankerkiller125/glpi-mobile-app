import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../core/api/dto/form_dto.dart';
import '../../../core/api/dto/user_ref.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatting.dart';
import '../../ticket/ui/user_picker.dart';
import '../form_conditions.dart';

/// Renders a GLPI Service Catalog form and submits it offline-first.
///
/// Every question type GLPI ships is rendered natively; unknown ones are shown
/// as a disabled note rather than silently dropped. Section/question visibility
/// conditions are evaluated live as answers change.
class DynamicFormScreen extends ConsumerStatefulWidget {
  const DynamicFormScreen({super.key, required this.formId});

  final int formId;

  @override
  ConsumerState<DynamicFormScreen> createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends ConsumerState<DynamicFormScreen> {
  /// Answers keyed by question id; values are already in GLPI's wire shape.
  final Map<int, Object?> _answers = {};

  /// Files picked for `file` questions, keyed by question id.
  final Map<int, List<({String path, String name, String? mime, int size})>>
  _files = {};
  final Set<int> _touched = {};
  bool _submitting = false;
  bool _seeded = false;

  /// Answers re-keyed by question uuid — the shape conditions reference.
  Map<String, Object?> _answersByUuid(FormDefinitionDto form) => {
    for (final q in form.allQuestions) q.uuid: _answers[q.id],
  };

  void _seedDefaults(FormDefinitionDto form) {
    if (_seeded) return;
    _seeded = true;
    for (final q in form.allQuestions) {
      final seeded = _defaultFor(q);
      if (seeded != null) _answers[q.id] = seeded;
    }
  }

  /// GLPI's `default_value` is always a string, but the field that renders it
  /// may want a list. Actor questions in particular default to a JSON blob
  /// (`{"users_ids":[],...}`), which the actors field would try to read as a
  /// list — a cast error that used to take the whole form down.
  Object? _defaultFor(FormQuestionDto q) {
    final raw = q.defaultValue;
    if (raw == null || raw.isEmpty || raw == '0') return null;

    switch (q.kind) {
      case QuestionKind.actors:
        return _actorsFromDefault(raw);
      case QuestionKind.checkbox:
        return _listFromDefault(raw);
      case QuestionKind.userDevice:
        return q.multipleDevices ? _listFromDefault(raw) : raw;
      default:
        return raw;
    }
  }

  /// `{"users_ids":[2],"groups_ids":[3],...}` → `['users_id-2', 'groups_id-3']`,
  /// the wire form the picker and the submit path both use.
  List<String>? _actorsFromDefault(String raw) {
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return null;
    }
    if (decoded is! Map) return null;
    const wire = {
      'users_ids': 'users_id',
      'groups_ids': 'groups_id',
      'suppliers_ids': 'suppliers_id',
    };
    final out = <String>[];
    for (final entry in wire.entries) {
      final ids = decoded[entry.key];
      if (ids is! List) continue;
      out.addAll(ids.map((id) => '${entry.value}-$id'));
    }
    return out.isEmpty ? null : out;
  }

  List<String>? _listFromDefault(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => '$e').toList();
      }
    } on FormatException {
      // Not JSON — fall through to the single-value case.
    }
    return [raw];
  }

  bool _questionVisible(FormDefinitionDto form, FormQuestionDto q) => isVisible(
    strategy: q.visibilityStrategy,
    conditions: q.conditions,
    answersByUuid: _answersByUuid(form),
  );

  bool _sectionVisible(FormDefinitionDto form, FormSectionDto s) => isVisible(
    strategy: s.visibilityStrategy,
    conditions: s.conditions,
    answersByUuid: _answersByUuid(form),
  );

  bool _isAnswered(FormQuestionDto q) {
    if (q.kind == QuestionKind.file) {
      return (_files[q.id] ?? const []).isNotEmpty;
    }
    final v = _answers[q.id];
    if (v == null) return false;
    if (v is String) return v.trim().isNotEmpty;
    if (v is Iterable) return v.isNotEmpty;
    return true;
  }

  /// Mandatory, visible questions that are still empty.
  List<FormQuestionDto> _missing(FormDefinitionDto form) => [
    for (final s in form.sections)
      if (_sectionVisible(form, s))
        for (final q in s.questions)
          if (q.mandatory && _questionVisible(form, q) && !_isAnswered(q)) q,
  ];

  Future<void> _submit(FormDefinitionDto form) async {
    final missing = _missing(form);
    if (missing.isNotEmpty) {
      setState(() => _touched.addAll(missing.map((q) => q.id)));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please answer: ${missing.map((q) => q.name).join(', ')}',
          ),
        ),
      );
      return;
    }
    final actions = ref.read(ticketActionsProvider);
    if (actions == null) return;
    setState(() => _submitting = true);

    // Only send answers for questions that are actually visible — a hidden
    // question's answer must not leak into the ticket.
    final payload = <int, Object?>{};
    for (final s in form.sections) {
      if (!_sectionVisible(form, s)) continue;
      for (final q in s.questions) {
        if (!_questionVisible(form, q)) continue;
        if (q.kind == QuestionKind.file) continue; // uploaded as attachments
        final v = _answers[q.id];
        if (v == null) continue;
        if (v is String && v.trim().isEmpty) continue;
        if (v is Iterable && v.isEmpty) continue;
        payload[q.id] = v;
      }
    }

    final files = <({String path, String name, String? mime, int size})>[
      for (final s in form.sections)
        if (_sectionVisible(form, s))
          for (final q in s.questions)
            if (q.kind == QuestionKind.file && _questionVisible(form, q))
              ...?_files[q.id],
    ];

    final localId = await actions.submitForm(
      formId: form.id,
      answers: payload,
      placeholderTitle: _placeholderTitle(form, payload),
      placeholderContent: _placeholderContent(form, payload),
      files: files,
    );
    if (!mounted) return;
    context.pushReplacement(Routes.ticket(localId));
  }

  /// The queue needs *something* to show until the server replies; GLPI's
  /// destination config decides the real title. Prefer the first short-text
  /// answer, else the form's own name.
  String _placeholderTitle(FormDefinitionDto form, Map<int, Object?> answers) {
    for (final q in form.allQuestions) {
      if (q.kind == QuestionKind.shortText) {
        final v = answers[q.id];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    }
    return form.name;
  }

  String _placeholderContent(
    FormDefinitionDto form,
    Map<int, Object?> answers,
  ) {
    for (final q in form.allQuestions) {
      if (q.kind == QuestionKind.longText) {
        final v = answers[q.id];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(formDefinitionProvider(widget.formId));

    return Scaffold(
      appBar: AppBar(title: Text(async.value?.name ?? 'New request')),
      body: switch (async) {
        AsyncData(:final value) => _buildForm(value),
        AsyncError() => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Could not load this form. It may need a connection the '
                  'first time.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.invalidate(formDefinitionProvider(widget.formId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _buildForm(FormDefinitionDto form) {
    _seedDefaults(form);
    final theme = Theme.of(context);
    final visibleSections = form.sections
        .where((s) => _sectionVisible(form, s))
        .toList();

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              if (form.description.isNotEmpty) ...[
                Text(
                  form.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              for (final section in visibleSections) ...[
                // A single unnamed section is just the form body — no header.
                if (visibleSections.length > 1 || section.name.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    section.name.isEmpty ? 'Details' : section.name,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (section.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        section.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
                for (final q in section.questions)
                  if (_questionVisible(form, q))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _QuestionField(
                        question: q,
                        value: _answers[q.id],
                        files: _files[q.id] ?? const [],
                        showError:
                            q.mandatory &&
                            _touched.contains(q.id) &&
                            !_isAnswered(q),
                        onChanged: (v) => setState(() => _answers[q.id] = v),
                        onFilesChanged: (f) => setState(() => _files[q.id] = f),
                      ),
                    ),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submitting ? null : () => _submit(form),
                icon: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_submitting ? 'Submitting…' : 'Submit'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Renders one question according to its type.
class _QuestionField extends ConsumerWidget {
  const _QuestionField({
    required this.question,
    required this.value,
    required this.files,
    required this.showError,
    required this.onChanged,
    required this.onFilesChanged,
  });

  final FormQuestionDto question;
  final Object? value;
  final List<({String path, String name, String? mime, int size})> files;
  final bool showError;
  final ValueChanged<Object?> onChanged;
  final ValueChanged<List<({String path, String name, String? mime, int size})>>
  onFilesChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final label = question.mandatory ? '${question.name} *' : question.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        if (question.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              question.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        const SizedBox(height: 6),
        _control(context, ref),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Required',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _control(BuildContext context, WidgetRef ref) {
    switch (question.kind) {
      case QuestionKind.shortText:
      case QuestionKind.email:
      case QuestionKind.number:
        return TextFormField(
          initialValue: value?.toString(),
          keyboardType: switch (question.kind) {
            QuestionKind.email => TextInputType.emailAddress,
            QuestionKind.number => TextInputType.number,
            _ => TextInputType.text,
          },
          textCapitalization: question.kind == QuestionKind.shortText
              ? TextCapitalization.sentences
              : TextCapitalization.none,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onChanged: onChanged,
        );

      case QuestionKind.longText:
        return TextFormField(
          initialValue: value?.toString(),
          minLines: 3,
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onChanged: onChanged,
        );

      case QuestionKind.urgency:
      case QuestionKind.requestType:
      case QuestionKind.dropdown:
      case QuestionKind.itemDropdown:
      case QuestionKind.item:
        return _dropdown(context);

      case QuestionKind.userDevice:
        // Multi-device questions submit a list; single ones a bare value.
        if (!question.multipleDevices) return _dropdown(context);
        final raw = value;
        final chosen = raw is List ? raw.map((e) => '$e').toSet() : <String>{};
        if (question.options.isEmpty) {
          return Text(
            'No devices are registered to your account.',
            style: Theme.of(context).textTheme.bodySmall,
          );
        }
        return Column(
          children: [
            for (final o in question.options)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: chosen.contains(o.value),
                title: Text(o.label),
                onChanged: (checked) {
                  final next = {...chosen};
                  if (checked == true) {
                    next.add(o.value);
                  } else {
                    next.remove(o.value);
                  }
                  onChanged(next.toList());
                },
              ),
          ],
        );

      case QuestionKind.radio:
        return RadioGroup<String>(
          groupValue: value?.toString(),
          onChanged: onChanged,
          child: Column(
            children: [
              for (final o in question.options)
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  value: o.value,
                  title: Text(o.label),
                ),
            ],
          ),
        );

      case QuestionKind.checkbox:
        final raw = value;
        final selected = raw is List
            ? raw.map((e) => '$e').toSet()
            : <String>{};
        return Column(
          children: [
            for (final o in question.options)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: selected.contains(o.value),
                title: Text(o.label),
                onChanged: (checked) {
                  final next = {...selected};
                  if (checked == true) {
                    next.add(o.value);
                  } else {
                    next.remove(o.value);
                  }
                  onChanged(next.toList());
                },
              ),
          ],
        );

      case QuestionKind.dateTime:
        return _DateTimeField(value: value?.toString(), onChanged: onChanged);

      case QuestionKind.actors:
        final raw = value;
        return _ActorsField(
          // `is List`, not `as List?`: GLPI hands out defaults as strings, and
          // a bad cast here blanks the whole form.
          value: raw is List ? raw.map((e) => '$e').toList() : const [],
          multiple: question.multipleActors,
          onChanged: onChanged,
        );

      case QuestionKind.file:
        return _FilesField(files: files, onChanged: onFilesChanged);

      case QuestionKind.unsupported:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'This question type (${question.typeSlug}) isn\'t supported in the '
            'mobile app yet — please use the web interface for it.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
    }
  }

  Widget _dropdown(BuildContext context) {
    final current = value?.toString();
    final hasCurrent = question.options.any((o) => o.value == current);
    return DropdownButtonFormField<String>(
      initialValue: hasCurrent ? current : null,
      isExpanded: true,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      hint: Text(question.options.isEmpty ? 'No options available' : 'Select…'),
      items: [
        for (final o in question.options)
          DropdownMenuItem(value: o.value, child: Text(o.label)),
      ],
      onChanged: question.options.isEmpty ? null : onChanged,
    );
  }
}

/// Date (and time) picker storing GLPI's `YYYY-MM-DD HH:MM:SS` shape.
class _DateTimeField extends StatelessWidget {
  const _DateTimeField({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    final parsed = value == null ? null : DateTime.tryParse(value!);
    return OutlinedButton.icon(
      onPressed: () async {
        final now = DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: parsed ?? now,
          firstDate: DateTime(now.year - 2),
          lastDate: DateTime(now.year + 5),
        );
        if (date == null || !context.mounted) return;
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(parsed ?? now),
        );
        final dt = DateTime(
          date.year,
          date.month,
          date.day,
          time?.hour ?? 0,
          time?.minute ?? 0,
        );
        String two(int n) => n.toString().padLeft(2, '0');
        onChanged(
          '${dt.year}-${two(dt.month)}-${two(dt.day)} '
          '${two(dt.hour)}:${two(dt.minute)}:00',
        );
      },
      icon: const Icon(Icons.event),
      label: Text(parsed == null ? 'Pick a date' : formatDateTime(parsed)),
    );
  }
}

/// Actor picker: emits GLPI's `users_id-<id>` wire values.
class _ActorsField extends ConsumerWidget {
  const _ActorsField({
    required this.value,
    required this.multiple,
    required this.onChanged,
  });

  final List<String> value;
  final bool multiple;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final v in value)
          InputChip(
            visualDensity: VisualDensity.compact,
            avatar: const Icon(Icons.person_outline, size: 16),
            label: Text(_labelFor(ref, v)),
            onDeleted: () => onChanged([...value]..remove(v)),
          ),
        if (multiple || value.isEmpty)
          ActionChip(
            visualDensity: VisualDensity.compact,
            avatar: const Icon(Icons.add, size: 16),
            label: const Text('Add'),
            onPressed: () async {
              final user = await UserPicker.show(context, title: 'Select user');
              if (user == null) return;
              final wire = 'users_id-${user.id}';
              _cacheName(ref, wire, user);
              onChanged(multiple ? [...value, wire] : [wire]);
            },
          ),
      ],
    );
  }

  // Display names for already-picked actors, remembered for this screen.
  static final Map<String, String> _names = {};
  void _cacheName(WidgetRef ref, String wire, UserRef user) =>
      _names[wire] = user.displayName;
  String _labelFor(WidgetRef ref, String wire) => _names[wire] ?? wire;
}

/// File answers: picked via camera/gallery and uploaded as ticket attachments
/// once the form's ticket exists.
class _FilesField extends ConsumerWidget {
  const _FilesField({required this.files, required this.onChanged});

  final List<({String path, String name, String? mime, int size})> files;
  final ValueChanged<List<({String path, String name, String? mime, int size})>>
  onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final f in files)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(Icons.attachment),
            title: Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => onChanged([...files]..remove(f)),
            ),
          ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => _pick(context, ref, ImageSource.camera),
              icon: const Icon(Icons.photo_camera_outlined, size: 18),
              label: const Text('Camera'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => _pick(context, ref, ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text('Gallery'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 2000,
    );
    if (picked == null) return;
    final repo = ref.read(attachmentRepositoryProvider);
    if (repo == null) return;
    final name = p.basename(picked.path);
    final stored = await repo.importFile(picked.path, name);
    onChanged([
      ...files,
      (path: stored.path, name: name, mime: picked.mimeType, size: stored.size),
    ]);
  }
}
