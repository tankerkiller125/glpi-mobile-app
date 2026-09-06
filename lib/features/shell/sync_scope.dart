import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/providers.dart';
import '../../core/push/push_service.dart';

/// Drives sync + push from app lifecycle while the authenticated shell is
/// mounted: drains the outbox on start, on resume, and when connectivity is
/// regained, and registers for push once the account is [Ready].
///
/// The shell can mount before session restore finishes wiring the API client,
/// so activation is gated on the `Ready` state (via [ref.listen]) rather than
/// on `initState` alone.
class SyncScope extends ConsumerStatefulWidget {
  const SyncScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SyncScope> createState() => _SyncScopeState();
}

class _SyncScopeState extends ConsumerState<SyncScope>
    with WidgetsBindingObserver {
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Handle the case where the account is already Ready when the shell mounts.
    WidgetsBinding.instance.addPostFrameCallback((_) => _activateIfReady());
    _connSub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) _kick();
    });
  }

  @override
  void dispose() {
    _connSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _kick();
    // The server may have gained/lost plugin features while we were away;
    // refetch (falls back to the cached map when offline).
    ref.invalidate(capabilitiesProvider);
    // Renew the session while the app is in the foreground and likely to have
    // signal. Each refresh also renews the server-side lease, so a technician
    // who uses the app at all stays paired without re-scanning.
    unawaited(
      ref.read(authControllerProvider.notifier).tokens?.refreshIfStale() ??
          Future.value(),
    );
  }

  void _activateIfReady() {
    if (ref.read(authControllerProvider) is! Ready) return;
    _kick();
    unawaited(
      ref.read(authControllerProvider.notifier).tokens?.refreshIfStale() ??
          Future.value(),
    );
    unawaited(ref.read(pushServiceProvider).start());
  }

  void _kick() {
    final sync = ref.read(syncServiceProvider);
    unawaited(sync?.kick() ?? Future.value());
  }

  @override
  Widget build(BuildContext context) {
    // Activate once the account becomes Ready (session restore completes), and
    // tear push down on sign-out.
    ref.listen(authControllerProvider, (previous, next) {
      if (next is Ready) {
        _activateIfReady();
      } else if (next is SignedOut) {
        unawaited(ref.read(pushServiceProvider).stop());
      }
    });
    return widget.child;
  }
}
