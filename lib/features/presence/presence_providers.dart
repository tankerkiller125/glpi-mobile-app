import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/api/dto/presence_dto.dart';
import '../../core/api/errors.dart';
import '../../core/providers.dart';

/// Which item a presence session is about.
typedef PresenceTarget = ({String itemtype, int itemsId});

/// Live presence for one open ticket: who else is here, and who has the claim.
///
/// Announces the technician while the screen is open and stops when it closes.
/// The cadence is deliberately far slower than the web bar's eight seconds: a
/// phone screen is off most of the time, radio wake-ups cost battery, and the
/// server expires a participant on its own TTL — so beating slowly just makes
/// arrival and departure coarser, which is the right trade on a battery.
///
/// Failures are swallowed into "nobody here". Presence is an advisory signal;
/// a technician mid-job must never get an error dialog because a heartbeat
/// missed the network.
class PresenceController extends Notifier<PresenceStateDto> {
  PresenceController(this.target);

  final PresenceTarget target;

  /// Comfortably inside the server's 90-second default TTL, and slow enough
  /// that an idle screen is not a radio wake-up every few seconds.
  static const _beat = Duration(seconds: 45);

  /// This device's participation. One key per screen: two devices sharing one
  /// would count as a single participant, and a new key per beat would make
  /// every beat a new one.
  late final String _sessionKey = const Uuid().v4().replaceAll('-', '');

  Timer? _timer;

  @override
  PresenceStateDto build() {
    ref.onDispose(() {
      _timer?.cancel();
      unawaited(_leave());
    });
    _timer = Timer.periodic(_beat, (_) => unawaited(_heartbeat()));
    unawaited(_heartbeat());
    return PresenceStateDto.empty;
  }

  Future<void> _heartbeat({bool typing = false, String? typingKind}) async {
    final api = ref.read(glpiApiProvider);
    if (api == null) return;
    try {
      state = await api.presenceHeartbeat(
        target.itemtype,
        target.itemsId,
        sessionKey: _sessionKey,
        typing: typing,
        typingKind: typingKind,
      );
    } on GlpiError {
      // Offline, or the plugin is gone. Keep the last-known state rather than
      // emptying the bar: "nobody is here" is a claim, and a dropped
      // connection is not evidence for it.
      return;
    }
  }

  Future<void> _leave() async {
    final api = ref.read(glpiApiProvider);
    if (api == null) return;
    try {
      await api.presenceLeave(
        target.itemtype,
        target.itemsId,
        sessionKey: _sessionKey,
      );
    } on GlpiError {
      // The TTL covers it.
      return;
    }
  }

  /// Tell the others somebody is writing. Sent on the beat rather than per
  /// keystroke — the server decays it after a few seconds, so this is
  /// refreshed by the composer while it holds focus.
  Future<void> typing({String kind = 'followup'}) =>
      _heartbeat(typing: true, typingKind: kind);

  /// Claim the work, take it over, or hand it back. Returns false when
  /// somebody else got there first, which the caller reports rather than
  /// retrying — taking over has to be a decision, not a retry.
  Future<bool> claim({bool takeover = false}) =>
      _act(takeover ? 'takeover' : 'claim');

  Future<bool> release() => _act('release');

  Future<bool> _act(String action) async {
    final api = ref.read(glpiApiProvider);
    if (api == null) return false;
    try {
      state = await api.presenceClaim(
        target.itemtype,
        target.itemsId,
        action: action,
      );
      return true;
    } on GlpiError {
      // A lost race comes back as a 409; refresh so the bar shows who actually
      // holds it rather than what the tap assumed.
      await _heartbeat();
      return false;
    }
  }
}

final presenceControllerProvider =
    NotifierProvider.family<
      PresenceController,
      PresenceStateDto,
      PresenceTarget
    >(PresenceController.new);
