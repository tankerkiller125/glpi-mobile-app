import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/a11y/a11y.dart';
import '../../../core/api/dto/sop_dto.dart';
import '../../../core/api/errors.dart';
import '../../../core/models/capabilities.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/accessible_refresh.dart';
import '../../../core/widgets/capability_gate.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../sop_providers.dart';

/// One procedure, answered step by step.
///
/// The checklist a technician works through while doing the work — which is
/// the whole argument for it being on a phone, since a good share of that work
/// happens in front of a rack rather than at a desk.
///
/// Every answer is a round trip, and the server's reply replaces the run
/// wholesale. That is not laziness: answering a step can open a branch, close
/// another, complete the run and unblock the ticket, and none of it is
/// derivable here. Nothing is queued offline either — a step marked done is a
/// compliance claim about a moment, and the server is the only thing that can
/// say whether the answer was valid.
class SopRunScreen extends ConsumerWidget {
  const SopRunScreen({super.key, required this.runId});

  final int runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(sopRunControllerProvider(runId));

    return CapabilityGate(
      plugin: Cap.sop,
      feature: Cap.sopRuns,
      title: l.sopTitle,
      child: Scaffold(
        appBar: AppBar(
          title: Text(async.value?.run.name ?? l.sopTitle),
          actions: [
            IconButton(
              tooltip: l.sopLog,
              icon: const Icon(Icons.history),
              onPressed: async.value == null
                  ? null
                  : () => _showLog(context, ref),
            ),
          ],
        ),
        body: AccessibleRefresh(
          onRefresh: () async =>
              ref.invalidate(sopRunControllerProvider(runId)),
          child: ReadableWidth(
            child: switch (async) {
              AsyncData(value: final run?) => _RunBody(run: run, runId: runId),
              AsyncError() => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text(l.genericError)),
                  ),
                ],
              ),
              _ => const Center(
                child: CircularProgressIndicator(semanticsLabel: 'Loading'),
              ),
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showLog(BuildContext context, WidgetRef ref) async {
    final entries = await ref
        .read(sopRunControllerProvider(runId).notifier)
        .log();
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      useSafeArea: true,
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      constraints: sheetConstraints(context),
      builder: (context) => _LogSheet(entries: entries),
    );
  }
}

class _RunBody extends ConsumerWidget {
  const _RunBody({required this.run, required this.runId});

  final SopRunDetailDto run;
  final int runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final steps = run.visibleSteps;

    // Section headings are interleaved rather than nested, so the list stays
    // one flat scrollable — a nested-list checklist on a phone scrolls two
    // things at once.
    final rows = <Widget>[];
    var lastSection = -1;
    for (final step in steps) {
      if (step.sectionsId != lastSection) {
        lastSection = step.sectionsId;
        final name = run.sectionName(step.sectionsId);
        if (name.isNotEmpty) {
          rows.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Semantics(
                header: true,
                child: Text(name, style: theme.textTheme.titleSmall),
              ),
            ),
          );
        }
      }
      rows.add(_StepTile(step: step, run: run, runId: runId));
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: run.run.fraction,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${l.sopProgress(run.run.done, run.run.total)} · '
                '${l.sopOutstanding(run.run.outstanding)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              if (!run.run.editable) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.sopReadOnly,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (run.description.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(run.description, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
        ...rows,
        const SizedBox(height: 32),
      ],
    );
  }
}

/// One step: its control, its answer, and the two things that can be done to
/// it besides answering — skipping it, and writing a note on it.
class _StepTile extends ConsumerStatefulWidget {
  const _StepTile({required this.step, required this.run, required this.runId});

  final SopStepDto step;
  final SopRunDetailDto run;
  final int runId;

  @override
  ConsumerState<_StepTile> createState() => _StepTileState();
}

class _StepTileState extends ConsumerState<_StepTile> {
  bool _busy = false;

  SopRunController get _controller =>
      ref.read(sopRunControllerProvider(widget.runId).notifier);

  bool get _editable => widget.run.run.editable;

  /// Runs one write, showing the server's refusal rather than swallowing it —
  /// "must be at least 4" is the whole reason the rule is server-side.
  Future<void> _write(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
    } on GlpiError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final step = widget.step;
    final answer = step.answer;

    final subtitleLines = <String>[
      if (step.help.isNotEmpty) step.help,
      if (answer.isSkipped)
        [l.sopSkipped, if (answer.note.isNotEmpty) answer.note].join(' — ')
      else if (answer.text.isNotEmpty)
        answer.text,
      if (!answer.isSkipped && answer.note.isNotEmpty)
        '${l.sopNote}: ${answer.note}',
      if (answer.meta.isNotEmpty) answer.meta,
    ];

    return Padding(
      // Children of a branch sit in from their parent, which is how a printed
      // procedure shows the same thing.
      padding: EdgeInsets.fromLTRB(step.isChild ? 32 : 16, 4, 16, 4),
      child: Opacity(
        opacity: _busy ? 0.55 : 1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              child: Text(
                step.number,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          step.required ? '${step.label} *' : step.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            decoration: answer.isSkipped
                                ? TextDecoration.lineThrough
                                : null,
                            color: answer.isSkipped
                                ? theme.colorScheme.outline
                                : null,
                          ),
                        ),
                      ),
                      _control(context, l),
                    ],
                  ),
                  for (final line in subtitleLines)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        line,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  if (_editable) _actions(context, l),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The control for this step's type, or a word saying why there isn't one.
  Widget _control(BuildContext context, AppLocalizations l) {
    final step = widget.step;
    final answer = step.answer;

    if (!_editable) {
      return Icon(
        answer.isDone
            ? Icons.check_circle
            : (answer.isSkipped
                  ? Icons.remove_circle_outline
                  : Icons.circle_outlined),
        size: 20,
        color: Theme.of(context).colorScheme.outline,
      );
    }

    switch (step.type) {
      case SopStepType.check:
        return Checkbox(
          value: answer.isDone,
          onChanged: _busy
              ? null
              : (value) => _write(
                  () => _controller.answer(step.id, value: value ?? false),
                ),
        );
      case SopStepType.yesno:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in const ['yes', 'no'])
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: ChoiceChip(
                  label: Text(option == 'yes' ? 'Yes' : 'No'),
                  selected: answer.value == option,
                  onSelected: _busy
                      ? null
                      : (_) => _write(
                          () => _controller.answer(step.id, value: option),
                        ),
                ),
              ),
          ],
        );
      case SopStepType.ticket:
        final raised = answer.valueItemsId > 0;
        return TextButton(
          onPressed: _busy || raised
              ? null
              : () => _write(() => _controller.spawn(step.id)),
          child: Text(
            raised ? l.sopRaisedTicket(answer.valueItemsId) : l.sopRaiseTicket,
          ),
        );
      case SopStepType.approval:
      case SopStepType.user:
      case SopStepType.asset:
      case SopStepType.document:
      case SopStepType.unknown:
        // Answered from somewhere the app cannot reach — an approval record, a
        // picker this screen does not have. Shown, and shown as read-only,
        // rather than hidden: a step nobody can see is a step nobody does.
        return Tooltip(
          message: l.sopAnswerElsewhere,
          child: Icon(
            answer.isDone ? Icons.check_circle : Icons.lock_outline,
            size: 20,
            color: Theme.of(context).colorScheme.outline,
          ),
        );
      default:
        return IconButton(
          tooltip: step.typeLabel,
          icon: Icon(
            answer.isDone ? Icons.edit_outlined : Icons.add_circle_outline,
          ),
          onPressed: _busy ? null : () => _answerByInput(context, l),
        );
    }
  }

  Widget _actions(BuildContext context, AppLocalizations l) {
    final step = widget.step;
    final answer = step.answer;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Wrap(
        spacing: 4,
        children: [
          if (answer.isAnswered && step.type != SopStepType.ticket)
            TextButton(
              onPressed: _busy
                  ? null
                  : () => _write(() => _controller.clear(step.id)),
              child: Text(l.sopClear),
            ),
          if (widget.run.allowSkip)
            TextButton(
              onPressed: _busy ? null : () => _skip(context, l),
              child: Text(answer.isSkipped ? l.sopUnskip : l.sopSkip),
            ),
          TextButton(
            onPressed: _busy ? null : () => _note(context, l),
            child: Text(l.sopNote),
          ),
        ],
      ),
    );
  }

  /// Text, number, dates and choices all end in the same place: one value, sent
  /// to the server, which decides whether it was acceptable.
  Future<void> _answerByInput(BuildContext context, AppLocalizations l) async {
    final step = widget.step;

    switch (step.type) {
      case SopStepType.choice:
        final picked = await _pickOne(context, step.label, step.options);
        if (picked == null) return;
        await _write(() => _controller.answer(step.id, value: picked));
      case SopStepType.multichoice:
        final picked = await _pickMany(
          context,
          step.label,
          step.options,
          step.answer.selected,
        );
        if (picked == null || picked.isEmpty) return;
        await _write(() => _controller.answer(step.id, value: picked));
      case SopStepType.date:
      case SopStepType.datetime:
        final now = DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 5),
        );
        if (date == null) return;
        var when = date;
        if (step.type == SopStepType.datetime && context.mounted) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(now),
          );
          if (time == null) return;
          when = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        }
        // The server accepts the browser's `YYYY-MM-DD HH:MM` shape and
        // normalises it, so this sends exactly that.
        final text = step.type == SopStepType.date
            ? _ymd(when)
            : '${_ymd(when)} ${_two(when.hour)}:${_two(when.minute)}';
        await _write(() => _controller.answer(step.id, value: text));
      default:
        final text = await _askText(
          context,
          l,
          title: step.label,
          initial: step.answer.value ?? '',
          multiline: step.type == SopStepType.textarea,
          number: step.type == SopStepType.number,
        );
        if (text == null || text.trim().isEmpty) return;
        await _write(() => _controller.answer(step.id, value: text.trim()));
    }
  }

  Future<void> _skip(BuildContext context, AppLocalizations l) async {
    // Un-skipping is the same call with no reason; the server clears it.
    if (widget.step.answer.isSkipped) {
      await _write(() => _controller.skip(widget.step.id, ''));
      return;
    }
    final reason = await _askText(
      context,
      l,
      title: l.sopSkipReason,
      initial: '',
      multiline: true,
    );
    if (reason == null) return;
    if (widget.run.skipReasonRequired && reason.trim().isEmpty) {
      if (!context.mounted) return;
      announce(context, l.sopSkipReasonRequired);
      return;
    }
    await _write(() => _controller.skip(widget.step.id, reason.trim()));
  }

  Future<void> _note(BuildContext context, AppLocalizations l) async {
    final note = await _askText(
      context,
      l,
      title: l.sopNote,
      initial: widget.step.answer.note,
      multiline: true,
      hint: l.sopNoteHint,
    );
    if (note == null) return;
    await _write(() => _controller.note(widget.step.id, note.trim()));
  }

  String _ymd(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';
  String _two(int n) => n.toString().padLeft(2, '0');
}

Future<String?> _askText(
  BuildContext context,
  AppLocalizations l, {
  required String title,
  required String initial,
  bool multiline = false,
  bool number = false,
  String? hint,
}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    useRootNavigator: true,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        minLines: multiline ? 3 : 1,
        maxLines: multiline ? 6 : 1,
        keyboardType: number
            ? const TextInputType.numberWithOptions(decimal: true, signed: true)
            : TextInputType.multiline,
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(l.sopSave),
        ),
      ],
    ),
  );
}

Future<String?> _pickOne(
  BuildContext context,
  String title,
  List<String> options,
) => showModalBottomSheet<String>(
  useSafeArea: true,
  context: context,
  useRootNavigator: true,
  showDragHandle: true,
  constraints: sheetConstraints(context),
  builder: (context) => SafeArea(
    child: ListView(
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        for (final option in options)
          ListTile(
            title: Text(option),
            onTap: () => Navigator.pop(context, option),
          ),
      ],
    ),
  ),
);

Future<List<String>?> _pickMany(
  BuildContext context,
  String title,
  List<String> options,
  List<String> selected,
) {
  final picked = {...selected};
  return showModalBottomSheet<List<String>>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    constraints: sheetConstraints(context),
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(title, style: Theme.of(context).textTheme.titleSmall),
            ),
            for (final option in options)
              CheckboxListTile(
                value: picked.contains(option),
                title: Text(option),
                onChanged: (on) => setState(() {
                  if (on == true) {
                    picked.add(option);
                  } else {
                    picked.remove(option);
                  }
                }),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () => Navigator.pop(context, picked.toList()),
                child: Text(AppLocalizations.of(context).sopSave),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _LogSheet extends StatelessWidget {
  const _LogSheet({required this.entries});

  final List<SopLogEntryDto> entries;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (entries.isEmpty) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l.sopLogEmpty,
            style: TextStyle(color: theme.colorScheme.outline),
          ),
        ),
      );
    }

    return SafeArea(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: entries.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final e = entries[i];
          return ListTile(
            dense: true,
            title: Text('${e.label} — ${e.step}'),
            subtitle: Text(
              [e.who, e.at, if (e.detail.isNotEmpty) e.detail].join(' · '),
            ),
          );
        },
      ),
    );
  }
}
