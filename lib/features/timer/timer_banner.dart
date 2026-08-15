import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/a11y/a11y.dart';
import '../../core/db/app_database.dart';
import '../../core/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/sync/timer_service.dart';
import '../../core/utils/formatting.dart';

/// App-wide banner shown above the bottom nav while a task timer runs. Ticks
/// every second and lets the tech jump to the ticket or stop the timer.
class TimerBanner extends ConsumerStatefulWidget {
  const TimerBanner({super.key});

  @override
  ConsumerState<TimerBanner> createState() => _TimerBannerState();
}

class _TimerBannerState extends ConsumerState<TimerBanner> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String _fmt(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final ActiveTimer? timer = ref.watch(activeTimerProvider).value;
    if (timer == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final elapsed = elapsedSeconds(timer);

    return Material(
      color: theme.colorScheme.primaryContainer,
      child: InkWell(
        onTap: () => _openTicket(timer),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // One node for the whole readout, and deliberately NOT a live
              // region: it changes every second, and a reader would talk over
              // everything else in the app.
              Expanded(
                child: Semantics(
                  container: true,
                  label:
                      'Timer running, ${spokenDuration(elapsed)}, on '
                      '${timer.ticketName}',
                  excludeSemantics: true,
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 18,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _fmt(elapsed),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontFeatures: const [],
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '#${timer.ticketServerId}  ${timer.ticketName}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _stop(timer),
                icon: const Icon(Icons.stop, size: 18),
                label: const Text('Stop'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to the timed ticket, unless we're already on it (avoids stacking
  /// duplicate detail screens when the banner is shown on the ticket itself).
  void _openTicket(ActiveTimer timer) {
    final target = Routes.ticket(timer.ticketLocalId);
    if (GoRouterState.of(context).uri.path != target) {
      unawaited(context.push(target));
    }
  }

  Future<void> _stop(ActiveTimer timer) async {
    final minutes = await ref.read(timerServiceProvider).stop();
    if (!mounted) return;
    // The banner disappears and a duration quietly lands in a composer that may
    // be a screen away — say what happened.
    announce(
      context,
      'Timer stopped, ${spokenDuration(minutes * 60)} ready to log',
    );
    // Pre-fill the composer's task duration. If we're already on the ticket,
    // the mounted composer picks it up via its listener; otherwise navigate.
    ref.read(pendingTaskMinutesProvider.notifier).set(minutes);
    _openTicket(timer);
  }
}
