import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/dto/change_dto.dart';
import '../../core/models/capabilities.dart';
import '../../core/providers.dart';

/// The agenda's rolling window: a week back for context, eight weeks forward
/// — comfortably inside the server's 92-day cap.
const changeCalendarBackDays = 7;
const changeCalendarForwardDays = 56;

String _isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// The combined change/release/freeze feed over the rolling window.
/// Read-through only — schedule truth lives server-side.
final changeCalendarProvider = FutureProvider<List<ChangeCalendarEventDto>>((
  ref,
) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return const [];
  final now = DateTime.now();
  return api.fetchChangeCalendar(
    from: _isoDate(now.subtract(const Duration(days: changeCalendarBackDays))),
    to: _isoDate(now.add(const Duration(days: changeCalendarForwardDays))),
  );
});

/// One change's scheduling picture, keyed by the change's server id.
final changeScheduleProvider = FutureProvider.family<ChangeScheduleDto?, int>((
  ref,
  changeId,
) async {
  final api = ref.watch(glpiApiProvider);
  if (api == null) return null;
  try {
    return await api.getChangeSchedule(changeId);
  } on Exception {
    return null; // the section shows nothing rather than an error row
  }
});

/// The freezes in force (now → +14 d), for the freeze-warning chip in the
/// date composers. Fetched lazily the first time a composer needs it and
/// kept for a few minutes — a freeze list changes on the scale of days, and
/// every date tap must not be a network call. Missing capability, signed-out
/// or failure all read as "no freezes": the chip is a courtesy, never a gate.
final activeFreezesProvider = FutureProvider.autoDispose<List<FreezeDto>>((
  ref,
) async {
  final api = ref.watch(glpiApiProvider);
  final caps = ref.watch(capabilitiesProvider).value ?? Capabilities.empty;
  if (api == null || !caps.has(Cap.change, Cap.changeFreezes)) return const [];
  // Brief cache: keep the resolved list alive for five minutes, then let the
  // provider dispose so the next composer refetches.
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), link.close);
  ref.onDispose(timer.cancel);
  try {
    return await api.listActiveFreezes();
  } on Exception {
    link.close(); // don't cache a failure for five minutes
    return const [];
  }
});
