import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/a11y/a11y.dart';
import '../../../core/models/ticket_detail.dart';
import '../../../core/providers.dart';
import '../../../core/utils/html_text.dart';
import 'compose_sheet.dart';
import 'duration_field.dart';

enum _Mode { reply, task }

/// Docked composer: Reply | Task toggle, public/private, optional task duration,
/// and a Send that enqueues offline and never blocks on the network.
class Composer extends ConsumerStatefulWidget {
  const Composer({super.key, required this.ticket});

  final TicketDetail ticket;

  @override
  ConsumerState<Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<Composer> {
  final _controller = TextEditingController();
  _Mode _mode = _Mode.reply;
  bool _private = false;
  int _durationMinutes = 0;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // A timer stopped BEFORE this screen mounted leaves a pending duration —
    // ref.listen only catches later changes, so consume the initial value here.
    final pending = ref.read(pendingTaskMinutesProvider);
    if (pending != null && pending > 0) {
      _mode = _Mode.task;
      _durationMinutes = pending.clamp(0, 480);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(pendingTaskMinutesProvider.notifier).set(null);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A timer stopped while this screen is already open pre-fills live.
    ref.listen<int?>(pendingTaskMinutesProvider, (prev, next) {
      if (next != null && next > 0) {
        setState(() {
          _mode = _Mode.task;
          _durationMinutes = next.clamp(0, 480);
        });
        ref.read(pendingTaskMinutesProvider.notifier).set(null);
      }
    });
    return _build(context);
  }

  /// Open the full editor for anything longer than a one-liner, seeded with
  /// whatever has been typed so far.
  Future<void> _composeRich() async {
    final html = await ComposeSheet.show(
      context,
      title: _mode == _Mode.reply ? 'Write a reply' : 'Describe the task',
      hint: 'Add detail, steps, emphasis…',
      submitLabel: 'Done',
      initialText: _controller.text,
      rich: true,
    );
    if (html == null || !mounted) return;
    await _sendHtml(html);
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    // Wrap as HTML so the line breaks a technician typed survive: GLPI renders
    // this content as markup, and a bare string collapses into one paragraph.
    await _sendHtml(plainTextToHtml(text));
  }

  Future<void> _sendHtml(String html) async {
    if (html.trim().isEmpty) return;
    final actions = ref.read(ticketActionsProvider);
    if (actions == null) return;
    setState(() => _sending = true);
    final text = html;
    if (_mode == _Mode.reply) {
      await actions.addFollowup(
        widget.ticket,
        content: text,
        isPrivate: _private,
      );
    } else {
      await actions.addTask(
        widget.ticket,
        content: text,
        isPrivate: _private,
        durationSeconds: _durationMinutes > 0 ? _durationMinutes * 60 : null,
      );
    }
    if (!mounted) return;
    _controller.clear();
    // The only visible confirmation is a new row further up a list the user
    // isn't looking at, so say it happened.
    announce(context, _mode == _Mode.reply ? 'Reply added' : 'Task added');
    setState(() {
      _sending = false;
      _durationMinutes = 0;
    });
  }

  Widget _build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  SegmentedButton<_Mode>(
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                    segments: const [
                      ButtonSegment(value: _Mode.reply, label: Text('Reply')),
                      ButtonSegment(value: _Mode.task, label: Text('Task')),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (s) => setState(() => _mode = s.first),
                  ),
                  const Spacer(),
                  // A toggle, so the reader says "Private note, on/off" rather
                  // than leaving the current state to the icon shape.
                  Semantics(
                    toggled: _private,
                    child: IconButton(
                      tooltip: _private
                          ? 'Private note — the requester will not see it'
                          : 'Public note — the requester will see it',
                      onPressed: () => setState(() => _private = !_private),
                      icon: Icon(
                        _private
                            ? Icons.lock_outline
                            : Icons.lock_open_outlined,
                        color: _private ? theme.colorScheme.primary : null,
                      ),
                    ),
                  ),
                ],
              ),
              if (_mode == _Mode.task)
                DurationField(
                  minutes: _durationMinutes,
                  onChanged: (m) => setState(() => _durationMinutes = m),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Semantics(
                      // A hint disappears the moment you type, taking the
                      // field's name with it.
                      label: _mode == _Mode.reply
                          ? 'Reply'
                          : 'Task description',
                      textField: true,
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: _mode == _Mode.reply
                              ? 'Write a reply…'
                              : 'Describe the task…',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Formatting',
                    onPressed: _sending ? null : _composeRich,
                    icon: const Icon(Icons.text_format),
                  ),
                  Tooltip(
                    // An icon-only FilledButton has nothing to announce.
                    message: _mode == _Mode.reply ? 'Send reply' : 'Add task',
                    child: FilledButton(
                      onPressed: _sending ? null : _send,
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Icon(Icons.send, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
