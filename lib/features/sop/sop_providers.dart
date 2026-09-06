import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/dto/sop_dto.dart';
import '../../core/api/glpi_api.dart';
import '../../core/providers.dart';

/// Which item a procedure list is about.
typedef SopTarget = ({String itemtype, int itemsId});

/// The procedures attached to one ticket.
///
/// Read-through, and failures read as "none": a checklist that cannot be
/// fetched must not put an error on a ticket screen that is otherwise fine
/// offline. The section simply does not render.
final sopRunsProvider = FutureProvider.family<List<SopRunDto>, SopTarget>((
  ref,
  target,
) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return const [];
  try {
    return await api.listSopRuns(target.itemtype, target.itemsId);
  } on Exception {
    return const [];
  }
});

/// One run, and the writes against it.
///
/// Every write answers with the whole run recomputed, which is the point:
/// answering one step can open a branch, close another, complete the run and
/// unblock the ticket — none of it derivable on the client. So the controller
/// never patches its own state, it replaces it with what the server said.
///
/// Deliberately *not* offline-first, unlike ticket writes. A step marked done
/// is a compliance claim about a specific moment, the server decides whether
/// the answer is even valid, and a queued answer that fails validation an hour
/// later — when the technician has left the site — is worse than one that
/// could not be given.
class SopRunController extends AsyncNotifier<SopRunDetailDto?> {
  SopRunController(this.runId);

  final int runId;

  @override
  Future<SopRunDetailDto?> build() async {
    final api = ref.watch(glpiApiProvider);
    if (api == null) return null;
    return api.getSopRun(runId);
  }

  Future<void> answer(
    int stepId, {
    Object? value,
    String? valueItemtype,
    int? valueItemsId,
    int? documentsId,
  }) => _write(
    (api) => api.answerSopStep(
      runId,
      stepId,
      value: value,
      valueItemtype: valueItemtype,
      valueItemsId: valueItemsId,
      documentsId: documentsId,
    ),
  );

  Future<void> clear(int stepId) =>
      _write((api) => api.clearSopStep(runId, stepId));

  Future<void> skip(int stepId, String reason) =>
      _write((api) => api.skipSopStep(runId, stepId, reason));

  Future<void> note(int stepId, String note) =>
      _write((api) => api.noteSopStep(runId, stepId, note));

  /// Raise the ticket a ticket-step asks for.
  Future<void> spawn(int stepId) =>
      _write((api) => api.spawnSopStep(runId, stepId));

  /// The run's own history, fetched on demand — it is a second request, and
  /// most people never open it.
  Future<List<SopLogEntryDto>> log() async {
    final api = ref.read(glpiApiProvider);
    if (api == null) return const [];
    return api.getSopRunLog(runId);
  }

  /// Runs one write and adopts the server's answer.
  ///
  /// A refusal — a value the server would not accept, a run that turned out to
  /// be read-only — is rethrown for the screen to show, and the run on screen
  /// is left exactly as it was. Emptying a checklist somebody is working
  /// through because one answer was rejected would be the worse failure.
  Future<void> _write(
    Future<SopRunDetailDto> Function(GlpiApi api) call,
  ) async {
    final api = ref.read(glpiApiProvider);
    if (api == null) return;
    state = AsyncValue.data(await call(api));
    // The ticket's own section shows the counters, and they have just moved.
    ref.invalidate(sopRunsProvider);
  }
}

final sopRunControllerProvider =
    AsyncNotifierProvider.family<SopRunController, SopRunDetailDto?, int>(
      SopRunController.new,
    );
