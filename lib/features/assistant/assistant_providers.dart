import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/dto/ai_dto.dart';
import '../../core/api/errors.dart';
import '../../core/providers.dart';

/// What glpi-ai will answer in the entity the technician is working in.
///
/// Separate from the capability map on purpose: capabilities are computed once
/// per session, and the entity gate — which decides whether an entity's data
/// may reach a provider at all — moves when they switch entity. Failures read
/// as "off" rather than as an error: an unreachable server and a switched-off
/// feature look the same from a phone, and both mean "do not offer this".
final aiStatusProvider = FutureProvider<AiStatusDto>((ref) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return AiStatusDto.off;
  try {
    return await api.getAiStatus();
  } on Exception {
    return AiStatusDto.off;
  }
});

/// This technician's recent conversations, for the history sheet.
final aiThreadsProvider = FutureProvider<List<AiThreadDto>>((ref) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return const [];
  return api.listAiThreads();
});

/// Which context a conversation is about: a ticket, or nothing.
///
/// A record rather than two arguments because it is the family key, and a
/// family keyed on a mutable object would rebuild the screen on every tick.
typedef AssistantContext = ({String? itemtype, int? itemsId});

const AssistantContext generalAssistant = (itemtype: null, itemsId: null);

/// One message in the on-screen transcript.
///
/// Not the DTO: an answer being streamed is a message that does not exist on
/// the server yet, and the screen has to render it while it is still arriving.
class AssistantMessage {
  const AssistantMessage({
    required this.role,
    required this.text,
    this.html = '',
    this.trail = '',
    this.streaming = false,
    this.failed = false,
  });

  final String role;
  final String text;

  /// The answer as the server rendered it. Empty while it streams — markdown
  /// arrives a fragment at a time, and half a table is worse than plain text.
  final String html;
  final String trail;

  /// Still arriving. Rendered with a cursor and never with a "copy" action —
  /// half an answer is not worth pasting into a ticket.
  final bool streaming;
  final bool failed;

  bool get isUser => role == 'user';

  AssistantMessage copyWith({
    String? text,
    String? html,
    String? trail,
    bool? streaming,
    bool? failed,
  }) => AssistantMessage(
    role: role,
    text: text ?? this.text,
    html: html ?? this.html,
    trail: trail ?? this.trail,
    streaming: streaming ?? this.streaming,
    failed: failed ?? this.failed,
  );
}

/// What the run is doing right now, in one line.
///
/// The whole reason the streaming endpoint exists. An agent run is four to
/// eight vendor round trips with tool calls between them; on a phone, a still
/// spinner for that long reads as a crash, and the app gets backgrounded —
/// which kills the request.
class AssistantProgress {
  const AssistantProgress({
    required this.turn,
    required this.budget,
    required this.tool,
    required this.thinking,
  });

  static const idle = AssistantProgress(
    turn: 0,
    budget: 0,
    tool: '',
    thinking: false,
  );

  final int turn;
  final int budget;

  /// The tool being called right now, or empty between calls.
  final String tool;

  /// The model is reasoning — some providers send this, most do not.
  final bool thinking;

  bool get isEmpty => turn == 0 && tool.isEmpty && !thinking;
}

/// The state of one conversation on screen.
class AssistantState {
  const AssistantState({
    required this.threadId,
    required this.context,
    required this.messages,
    required this.busy,
    required this.progress,
    required this.error,
    required this.loading,
    this.offline = false,
  });

  static const initial = AssistantState(
    threadId: 0,
    context: '',
    messages: [],
    busy: false,
    progress: AssistantProgress.idle,
    error: null,
    loading: true,
  );

  final int threadId;

  /// What the server says this conversation is about ("Ticket #7 — Email
  /// outage"), already resolved and rights-checked.
  final String context;
  final List<AssistantMessage> messages;

  /// A question is in flight. The composer is disabled — a second question
  /// mid-run would race the first one's transcript write.
  final bool busy;
  final AssistantProgress progress;

  /// Something that stopped the conversation working at all (the thread would
  /// not open, the feature is off). A failed *answer* is a message, not this.
  ///
  /// Null when [offline]: a dropped connection is not a message worth quoting
  /// — dio's own wording ("This indicates an error which most likely cannot be
  /// solved by the library") is what a technician would otherwise read.
  final String? error;

  /// The server could not be reached. Said in the app's own words, and kept
  /// apart from a refusal, because the two need different things from the
  /// reader: one waits, the other asks an administrator.
  final bool offline;
  final bool loading;

  bool get isReady => !loading && error == null && !offline && threadId > 0;

  AssistantState copyWith({
    int? threadId,
    String? context,
    List<AssistantMessage>? messages,
    bool? busy,
    AssistantProgress? progress,
    String? error,
    bool? offline,
    bool clearError = false,
    bool? loading,
  }) => AssistantState(
    threadId: threadId ?? this.threadId,
    context: context ?? this.context,
    messages: messages ?? this.messages,
    busy: busy ?? this.busy,
    progress: progress ?? this.progress,
    error: clearError ? null : (error ?? this.error),
    offline: clearError ? false : (offline ?? this.offline),
    loading: loading ?? this.loading,
  );
}

/// Shown in place of an answer when the connection died mid-run. Not a
/// translated string only because it is written into the transcript on screen
/// rather than rendered from state; the screen's own offline copy is
/// localised.
const _offlineAnswer =
    'The connection dropped. The answer may still be on the '
    'server — reopen this conversation to see it.';

/// Drives one conversation: opens the thread, asks, and assembles the answer
/// as it streams in.
class AssistantController extends Notifier<AssistantState> {
  AssistantController(this.context);

  final AssistantContext context;

  StreamSubscription<AiStreamEvent>? _run;

  @override
  AssistantState build() {
    // The run belongs to the screen: leaving it subscribed after the screen is
    // gone would keep a provider connection open for an answer nobody reads.
    ref.onDispose(() => _run?.cancel());
    unawaited(_open());
    return AssistantState.initial;
  }

  Future<void> _open() async {
    final api = ref.read(glpiApiProvider);
    if (api == null) {
      state = state.copyWith(loading: false, offline: true);
      return;
    }
    try {
      final detail = await api.openAiThread(
        itemtype: context.itemtype,
        itemsId: context.itemsId,
      );
      state = state.copyWith(
        threadId: detail.thread.id,
        context: detail.context,
        messages: [
          for (final m in detail.messages)
            AssistantMessage(
              role: m.role,
              text: m.content,
              html: m.contentHtml,
              trail: m.trail,
            ),
        ],
        loading: false,
        clearError: true,
      );
    } on GlpiNetworkError {
      state = state.copyWith(loading: false, offline: true);
    } on GlpiError catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    }
  }

  /// Try again after a failure to open — a dropped connection, or a server
  /// that was not answering. The provider is kept alive so the transcript
  /// survives navigation, which means nothing re-opens the thread on its own:
  /// without this, a screen first opened offline would stay offline for the
  /// rest of the session.
  Future<void> retry() async {
    if (state.busy) return;
    state = state.copyWith(loading: true, clearError: true);
    await _open();
  }

  /// Resume a conversation from the history list, in place.
  Future<void> switchTo(int threadId) async {
    final api = ref.read(glpiApiProvider);
    if (api == null || state.busy) return;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final detail = await api.getAiThread(threadId);
      state = AssistantState.initial.copyWith(
        threadId: detail.thread.id,
        context: detail.context,
        messages: [
          for (final m in detail.messages)
            AssistantMessage(
              role: m.role,
              text: m.content,
              html: m.contentHtml,
              trail: m.trail,
            ),
        ],
        loading: false,
      );
    } on GlpiNetworkError {
      state = state.copyWith(loading: false, offline: true);
    } on GlpiError catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    }
  }

  /// Ask, and stream the answer.
  ///
  /// The question is appended optimistically and the answer grows in place, so
  /// the transcript reads the way a conversation does rather than appearing
  /// whole a minute later. The server owns the durable transcript; nothing
  /// here is queued offline, because a question nobody is waiting for is not
  /// worth asking a provider an hour later.
  Future<void> ask(String question) async {
    final text = question.trim();
    final api = ref.read(glpiApiProvider);
    if (text.isEmpty || api == null || state.busy || state.threadId <= 0) {
      return;
    }

    state = state.copyWith(
      messages: [
        ...state.messages,
        AssistantMessage(role: 'user', text: text),
        const AssistantMessage(role: 'assistant', text: '', streaming: true),
      ],
      busy: true,
      progress: AssistantProgress.idle,
      clearError: true,
    );

    final completer = Completer<void>();

    _run = api
        .streamAiAnswer(state.threadId, text)
        .listen(
          _onEvent,
          onError: (Object e) {
            // A dropped connection mid-run is the common one on a phone, and it is
            // not the provider's fault; the run itself carried on server-side and
            // reopening the thread recovers the answer.
            _finish(
              failure: switch (e) {
                GlpiNetworkError() => _offlineAnswer,
                GlpiError() => e.message,
                _ => 'Something went wrong',
              },
            );
            if (!completer.isCompleted) completer.complete();
          },
          onDone: () {
            // A stream that ends without `done` — the connection dropped mid-run.
            // Whatever text arrived stays on screen; the server finished the run
            // and kept it, so reopening the thread recovers the whole answer.
            if (state.busy) _finish();
            if (!completer.isCompleted) completer.complete();
          },
          cancelOnError: true,
        );

    return completer.future;
  }

  void _onEvent(AiStreamEvent event) {
    switch (event.kind) {
      case AiEventKind.turn:
        state = state.copyWith(
          progress: AssistantProgress(
            turn: event.turn,
            budget: event.budget,
            tool: '',
            thinking: false,
          ),
        );
      case AiEventKind.tool:
        state = state.copyWith(
          progress: AssistantProgress(
            turn: state.progress.turn,
            budget: state.progress.budget,
            tool: event.toolName,
            thinking: false,
          ),
        );
      case AiEventKind.toolResult:
        state = state.copyWith(
          progress: AssistantProgress(
            turn: state.progress.turn,
            budget: state.progress.budget,
            tool: '',
            thinking: false,
          ),
        );
      case AiEventKind.thinking:
        state = state.copyWith(
          progress: AssistantProgress(
            turn: state.progress.turn,
            budget: state.progress.budget,
            tool: '',
            thinking: true,
          ),
        );
      case AiEventKind.text:
        _appendAnswer(event.text);
      case AiEventKind.done:
        final answer = event.answer;
        // The whole answer replaces the assembled fragments rather than being
        // appended to them: a provider that does not stream sends nothing at
        // all until this event, and one that does sends exactly the same text.
        _finish(
          answer: answer.answer,
          html: answer.answerHtml,
          trail: answer.trail,
        );
      case AiEventKind.failed:
        _finish(failure: event.message);
      case AiEventKind.open:
      case AiEventKind.continued:
      case AiEventKind.unknown:
        break;
    }
  }

  void _appendAnswer(String chunk) {
    if (chunk.isEmpty || state.messages.isEmpty) return;
    final messages = [...state.messages];
    final last = messages.last;
    if (!last.streaming) return;
    messages[messages.length - 1] = last.copyWith(text: last.text + chunk);
    state = state.copyWith(messages: messages);
  }

  void _finish({String? answer, String? html, String? trail, String? failure}) {
    final messages = [...state.messages];
    if (messages.isNotEmpty && messages.last.streaming) {
      final last = messages.last;
      messages[messages.length - 1] = last.copyWith(
        text: failure ?? (answer ?? last.text),
        html: failure != null ? '' : (html ?? last.html),
        trail: trail ?? last.trail,
        streaming: false,
        failed: failure != null,
      );
    }
    state = state.copyWith(
      messages: messages,
      busy: false,
      progress: AssistantProgress.idle,
    );
    // The history list has just gained a title (a thread is named from its
    // first question) or moved to the top.
    ref.invalidate(aiThreadsProvider);
  }

  /// Abandon the run in flight. The server notices the dropped connection and
  /// stops; what it has already written to the transcript stays written.
  void stop() {
    _run?.cancel();
    _run = null;
    if (state.busy) _finish();
  }

  /// Empty the transcript, keeping the thread.
  Future<void> clear() async {
    final api = ref.read(glpiApiProvider);
    if (api == null || state.threadId <= 0 || state.busy) return;
    try {
      await api.clearAiThread(state.threadId);
    } on GlpiError {
      // Clearing is housekeeping. A failure here is not worth a dialog; the
      // messages simply stay.
      return;
    }
    state = state.copyWith(messages: const []);
    ref.invalidate(aiThreadsProvider);
  }
}

final assistantControllerProvider =
    NotifierProvider.family<
      AssistantController,
      AssistantState,
      AssistantContext
    >(AssistantController.new);

/// The drafted solution a ticket has, keyed by the ticket's server id.
///
/// A read: it never asks for a draft to be made, because that spends money at
/// a provider and must be something the technician pressed.
final aiDraftProvider = FutureProvider.family<AiDraftStateDto, int>((
  ref,
  ticketsId,
) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return AiDraftStateDto.unavailable;
  try {
    return await api.getAiDraft(ticketsId);
  } on Exception {
    return AiDraftStateDto.unavailable;
  }
});

/// The triage suggestion for a ticket, keyed by the ticket's server id.
final aiTriageProvider = FutureProvider.family<AiTriageStateDto, int>((
  ref,
  ticketsId,
) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return AiTriageStateDto.none;
  try {
    return await api.getAiTriage(ticketsId);
  } on Exception {
    return AiTriageStateDto.none;
  }
});
