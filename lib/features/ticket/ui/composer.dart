import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/a11y/a11y.dart';
import '../../../core/api/dto/ai_dto.dart';
import '../../../core/api/errors.dart';
import '../../../core/api/itil_type.dart';
import '../../../core/models/capabilities.dart';
import '../../../core/models/rights.dart';
import '../../../core/models/ticket_detail.dart';
import '../../../core/providers.dart';
import '../../../core/utils/html_text.dart';
import '../../../core/utils/layout.dart';
import '../../../l10n/generated/app_localizations.dart';
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
  bool _reviewing = false;

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
    // Same handshake for reply text staged by the KEDB "Use workaround"
    // action before this composer mounted.
    final pendingText = ref.read(pendingComposerTextProvider);
    if (pendingText != null && pendingText.trim().isNotEmpty) {
      _mode = _Mode.reply;
      _controller.text = pendingText;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(pendingComposerTextProvider.notifier).set(null);
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
    // "Use workaround" pressed while this composer is mounted pre-fills the
    // reply live, replacing whatever draft was there (the action announces
    // itself, and the technician asked for the snippet).
    ref.listen<String?>(pendingComposerTextProvider, (prev, next) {
      if (next != null && next.trim().isNotEmpty) {
        setState(() {
          _mode = _Mode.reply;
          _controller.text = next;
        });
        ref.read(pendingComposerTextProvider.notifier).set(null);
      }
    });

    // GLPI splits "add a followup" and "add a task" into separate rights, and
    // a read-only profile (an observer, say) holds neither — then there is
    // nothing to compose and the bar goes entirely, rather than offering a
    // send button that will 403.
    final rights = ref.watch(rightsProvider).value ?? Rights.empty;
    final canReply = rights.canAddFollowup;
    final canTask = rights.canAddTask;
    if (!canReply && !canTask) return const SizedBox.shrink();
    // With only one of the two, the mode switch is noise — and the mode has
    // to be the one that is allowed, whatever a stopped timer or a staged
    // reply put there.
    if (!canReply && _mode != _Mode.task) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _mode = _Mode.task);
      });
    } else if (!canTask && _mode != _Mode.reply) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _mode = _Mode.reply);
      });
    }
    return _build(context, canReply: canReply, canTask: canTask);
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

  /// Read the reply before it goes, when the server offers that.
  ///
  /// Nothing is written and nothing is sent: the reviewer answers with what it
  /// would stop a colleague about, and the technician decides. A clean verdict
  /// sends straight away — making somebody press send twice to be told there
  /// was nothing wrong is how a check stops being used.
  Future<void> _reviewThenSend() async {
    final text = _controller.text.trim();
    final api = ref.read(glpiApiProvider);
    final serverId = widget.ticket.serverId;
    if (text.isEmpty || api == null || serverId == null) return;

    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _reviewing = true);

    ReplyReviewDto review;
    try {
      review = await api.reviewReply(
        itemtype: widget.ticket.itemtype,
        itemsId: serverId,
        text: plainTextToHtml(text),
      );
    } on GlpiError catch (e) {
      // A refusal here is usually a rule — the feature is off for this entity,
      // or there is not enough written yet — so it is said and the reply is
      // left alone. It is never a reason not to be able to send.
      if (!mounted) return;
      setState(() => _reviewing = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }

    if (!mounted) return;
    setState(() => _reviewing = false);

    if (review.isClean) {
      messenger.showSnackBar(SnackBar(content: Text(l.aiReplyClean)));
      await _send();
      return;
    }

    final send = await showModalBottomSheet<bool>(
      useSafeArea: true,
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      constraints: sheetConstraints(context),
      builder: (context) => _ReviewSheet(review: review),
    );
    if (send == true) await _send();
  }

  /// Reply review is offered only where it can work: a reply (not a task), on
  /// a synced ITIL object, against a server whose glpi-ai has it switched on.
  bool _canReview(WidgetRef ref) {
    if (_mode != _Mode.reply) return false;
    if (widget.ticket.serverId == null) return false;
    if (!itilTypes.contains(widget.ticket.itemtype)) return false;
    final caps = ref.watch(capabilitiesProvider).value ?? Capabilities.empty;
    return caps.has(Cap.ai, Cap.aiReplyReview);
  }

  Widget _build(
    BuildContext context, {
    required bool canReply,
    required bool canTask,
  }) {
    final l = AppLocalizations.of(context);
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
                  // Scale down rather than overflow: mid fold/unfold the
                  // detail pane can be laid out a frame at a degenerate width,
                  // and a hard overflow paints stripes over the composer.
                  if (canReply && canTask)
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: SegmentedButton<_Mode>(
                          style: const ButtonStyle(
                            visualDensity: VisualDensity.compact,
                          ),
                          segments: const [
                            ButtonSegment(
                              value: _Mode.reply,
                              label: Text('Reply'),
                            ),
                            ButtonSegment(
                              value: _Mode.task,
                              label: Text('Task'),
                            ),
                          ],
                          selected: {_mode},
                          onSelectionChanged: (s) =>
                              setState(() => _mode = s.first),
                        ),
                      ),
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
                  if (_canReview(ref))
                    IconButton(
                      tooltip: l.aiReplyReview,
                      onPressed: _sending || _reviewing
                          ? null
                          : _reviewThenSend,
                      icon: _reviewing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.spellcheck),
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

/// What the reviewer would stop you about, and the two ways out of it.
class _ReviewSheet extends StatelessWidget {
  const _ReviewSheet({required this.review});

  final ReplyReviewDto review;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Semantics(
            header: true,
            child: Text(l.aiReplyTitle, style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          for (final flag in review.flags)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flag.label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  // The technician's own words, quoted back, so the flag can be
                  // found in the reply rather than hunted for.
                  if (flag.quote.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '“${flag.quote}”',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(flag.why, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.aiReplyKeepEditing),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.aiReplySendAnyway),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
