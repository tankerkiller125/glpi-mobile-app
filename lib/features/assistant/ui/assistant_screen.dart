import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/a11y/a11y.dart';
import '../../../core/models/capabilities.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/utils/layout.dart';
import '../../../core/widgets/capability_gate.dart';
import '../../../core/widgets/rich_content.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../assistant_providers.dart';

/// The troubleshooting assistant, as a conversation.
///
/// Opened from the drawer with no context, or from a ticket with that ticket's
/// — which is the whole reason it is worth having on a phone. A technician
/// standing in front of the problem should not have to describe the ticket they
/// are looking at; the server resolves the context, rights-checks it, and tells
/// the model what is open.
///
/// The answer streams. An agent run is four to eight vendor round trips and
/// takes the better part of a minute, and a phone showing a still spinner for
/// that long reads as a crash — so the turns, the tools and the words arrive as
/// they happen.
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key, this.itemtype, this.itemsId});

  /// The record the conversation is about. Both null opens the general thread.
  final String? itemtype;
  final int? itemsId;

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  AssistantContext get _context =>
      (itemtype: widget.itemtype, itemsId: widget.itemsId);

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Follow the answer as it grows. Deferred a frame because the text that
  /// makes the list taller has not been laid out yet when the state changes.
  void _stickToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    _stickToBottom();
    await ref.read(assistantControllerProvider(_context).notifier).ask(text);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(assistantControllerProvider(_context));
    final controller = ref.read(assistantControllerProvider(_context).notifier);

    ref.listen(assistantControllerProvider(_context), (_, _) {
      _stickToBottom();
    });

    return CapabilityGate(
      plugin: Cap.ai,
      feature: Cap.aiAssistant,
      title: l.assistantTitle,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.assistantTitle),
              if (state.context.isNotEmpty)
                Text(
                  state.context,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: l.assistantHistory,
              icon: const Icon(Icons.history),
              onPressed: state.busy
                  ? null
                  : () => _showHistory(context, controller),
            ),
            IconButton(
              tooltip: l.assistantClear,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: state.busy || state.messages.isEmpty
                  ? null
                  : () async {
                      await controller.clear();
                      if (context.mounted) {
                        announce(context, l.assistantCleared);
                      }
                    },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ReadableWidth(
                child: switch (state) {
                  AssistantState(loading: true) => const Center(
                    child: CircularProgressIndicator(semanticsLabel: 'Loading'),
                  ),
                  AssistantState(offline: true) => _Unavailable(
                    message: l.assistantOffline,
                    icon: Icons.cloud_off_outlined,
                    onRetry: controller.retry,
                  ),
                  AssistantState(error: final String message) => _Unavailable(
                    message: message,
                    onRetry: controller.retry,
                  ),
                  AssistantState(messages: final m) when m.isEmpty =>
                    _EmptyState(context: state.context),
                  _ => ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    itemCount: state.messages.length,
                    itemBuilder: (context, i) =>
                        _Bubble(message: state.messages[i]),
                  ),
                },
              ),
            ),
            if (state.busy) _ProgressLine(progress: state.progress),
            _Composer(
              controller: _input,
              busy: state.busy,
              enabled: state.isReady,
              onSend: _send,
              onStop: controller.stop,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showHistory(
    BuildContext context,
    AssistantController controller,
  ) async {
    final threadId = await showModalBottomSheet<int>(
      constraints: sheetConstraints(context),
      useSafeArea: true,
      context: context,
      showDragHandle: true,
      builder: (_) => const _HistorySheet(),
    );
    if (threadId != null) await controller.switchTo(threadId);
  }
}

/// One turn. The technician's questions sit right, the model's answers left and
/// full width — an answer is usually a paragraph and a list, and a chat bubble
/// pinched to 70% of a phone makes that unreadable.
class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final AssistantMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);

    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 32),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.text,
            style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
          ),
        ),
      );
    }

    final failed = message.failed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.text.trim().isEmpty && message.streaming)
            Text(
              l.assistantThinking,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
                fontStyle: FontStyle.italic,
              ),
            )
          else if (failed)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 18,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message.text,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            )
          // Rendered from the server's HTML once the answer is whole; the
          // streaming text is markdown source, which is legible enough for the
          // few seconds it is on screen and avoids rendering half a table.
          else if (message.html.isNotEmpty && !message.streaming)
            RichContent(message.html)
          else
            SelectableText(message.text),
          if (message.trail.isNotEmpty && !message.streaming) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.build_outlined,
                  size: 14,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    message.trail,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// What the run is doing, while it does it.
class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.progress});

  final AssistantProgress progress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final label = switch (progress) {
      AssistantProgress(tool: final t) when t.isNotEmpty =>
        l.assistantRunningTool(t),
      AssistantProgress(thinking: true) => l.assistantThinking,
      AssistantProgress(turn: final n) when n > 0 => l.assistantTurn(n),
      _ => l.assistantWorking,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.busy,
    required this.enabled,
    required this.onSend,
    required this.onStop,
  });

  final TextEditingController controller;
  final bool busy;
  final bool enabled;
  final VoidCallback onSend;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Semantics(
                  label: l.assistantAsk,
                  textField: true,
                  child: TextField(
                    controller: controller,
                    enabled: enabled && !busy,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => onSend(),
                    decoration: InputDecoration(
                      hintText: l.assistantHint,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: busy ? l.assistantStop : l.assistantAsk,
                child: FilledButton(
                  onPressed: busy ? onStop : (enabled ? onSend : null),
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(14),
                  ),
                  child: Icon(busy ? Icons.stop : Icons.send, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.context});

  final String context;

  @override
  Widget build(BuildContext buildContext) {
    final l = AppLocalizations.of(buildContext);
    final theme = Theme.of(buildContext);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              context.isEmpty ? l.assistantEmpty : l.assistantEmptyOn(context),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.message, this.icon, this.onRetry});

  final String message;
  final IconData? icon;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 48, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () => onRetry!(),
                child: Text(AppLocalizations.of(context).retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Past conversations, newest first. A phone loses the panel every time it
/// closes, so unlike the web the app has to be able to go and find one.
class _HistorySheet extends ConsumerWidget {
  const _HistorySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final threads = ref.watch(aiThreadsProvider);

    return SafeArea(
      child: switch (threads) {
        AsyncData(:final value) when value.isEmpty => Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l.assistantNoHistory,
            style: TextStyle(color: theme.colorScheme.outline),
          ),
        ),
        AsyncData(:final value) => ListView.separated(
          shrinkWrap: true,
          itemCount: value.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final thread = value[i];
            final when = parseGlpiDateTime(thread.dateMod);
            return ListTile(
              leading: Icon(
                thread.hasContext
                    ? Icons.confirmation_number_outlined
                    : Icons.forum_outlined,
              ),
              title: Text(
                thread.title.isEmpty ? l.assistantUntitled : thread.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                [
                  if (thread.hasContext)
                    '${thread.itemtype} #${thread.itemsId}',
                  if (when != null) relativeAge(when),
                ].join(' · '),
              ),
              onTap: () => Navigator.pop(context, thread.id),
            );
          },
        ),
        AsyncError() => Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l.genericError),
        ),
        _ => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(semanticsLabel: 'Loading'),
          ),
        ),
      },
    );
  }
}
