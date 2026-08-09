import 'dart:async';

import 'package:oauth2/oauth2.dart' as oauth2;

import '../api/errors.dart';
import 'broker_client.dart';
import 'secure_store.dart';

/// Thrown when the refresh token is dead — the account must re-authenticate
/// (re-scan the pairing QR). Local data and the outbox are untouched.
class ReauthRequired implements Exception {
  const ReauthRequired();
}

/// Owns the OAuth credential pair: persistence, proactive refresh, and
/// single-flight refresh so concurrent 401s trigger exactly one token call.
///
/// The app has no client secret, so refresh goes through the plugin broker
/// (`/GlpiMobile/refresh`) rather than the GLPI token endpoint directly.
class TokenManager {
  TokenManager({
    required SecureStore store,
    required String serverUrl,
    BrokerClient? broker,
    void Function()? onReauthRequired,
  }) // Private fields can't be named initializing formals.
    // ignore: prefer_initializing_formals
    : _store = store,
       // ignore: prefer_initializing_formals
       _onReauthRequired = onReauthRequired,
       _broker = broker ?? BrokerClient(serverUrl);

  final SecureStore _store;
  final BrokerClient _broker;

  /// Fired once when the pairing is definitively dead (revoked by an admin,
  /// or its grant expired). Without it the app keeps showing cached data while
  /// every request fails — it must visibly return to the sign-in screen.
  final void Function()? _onReauthRequired;

  oauth2.Credentials? _credentials;
  DeviceCredentials? _device;
  bool _deviceLoaded = false;
  Future<oauth2.Credentials>? _refreshing;

  Future<oauth2.Credentials?> _load() async {
    if (_credentials != null) return _credentials;
    final raw = await _store.readCredentials();
    if (raw == null) return null;
    _credentials = oauth2.Credentials.fromJson(raw);
    return _credentials;
  }

  Future<void> adopt(
    oauth2.Credentials credentials, {
    DeviceCredentials? device,
  }) async {
    _credentials = credentials;
    await _store.writeCredentials(credentials.toJson());
    if (device != null) {
      _device = device;
      _deviceLoaded = true;
      await _store.writeDevice(device);
    }
  }

  Future<void> clear() async {
    _credentials = null;
    _device = null;
    _deviceLoaded = true;
    await _store.deleteTokens();
  }

  Future<DeviceCredentials?> _loadDevice() async {
    if (_deviceLoaded) return _device;
    _device = await _store.readDevice();
    _deviceLoaded = true;
    return _device;
  }

  bool get hasCredentials => _credentials != null;

  /// A valid access token, refreshing proactively when <60 s from expiry.
  Future<String> accessToken() async {
    final creds = await _load();
    if (creds == null) throw const ReauthRequired();
    final expiration = creds.expiration;
    final closeToExpiry =
        expiration != null &&
        expiration.difference(DateTime.now()) < const Duration(seconds: 60);
    if (!closeToExpiry) return creds.accessToken;
    return (await refresh()).accessToken;
  }

  /// Refresh early, while the app is in the foreground and likely to have
  /// signal, rather than waiting for a token to be seconds from death mid-tap.
  /// Every successful refresh also renews the server-side session's lease, so
  /// simply using the app keeps a technician paired.
  ///
  /// No-ops when nothing is stored, when the token is still fresh, or when a
  /// refresh is already in flight. Never throws — this is opportunistic.
  Future<void> refreshIfStale({
    Duration staleAfter = const Duration(minutes: 30),
  }) async {
    if (_refreshing != null) return;
    final creds = await _load();
    final expiration = creds?.expiration;
    if (creds == null || expiration == null) return;
    if (expiration.difference(DateTime.now()) > staleAfter) return;
    try {
      await refresh();
    } on Object {
      // Offline or the server is busy — the reactive path will try again.
    }
  }

  /// Force a refresh (reactive 401 path). Single-flight.
  Future<oauth2.Credentials> refresh() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<oauth2.Credentials> _doRefresh() async {
    final device = await _loadDevice();
    final creds = await _load();
    final refreshToken = creds?.refreshToken;
    if (device == null && refreshToken == null) throw const ReauthRequired();

    try {
      final result = device != null
          ? await _broker.refreshDevice(device)
          // Paired before device sessions existed: the server answers with a
          // device credential and the app upgrades itself in place.
          : await _broker.refreshLegacy(refreshToken!);
      await adopt(result.credentials, device: result.device);
      return result.credentials;
    } on GlpiAuthError {
      // A 401 here is the server's definite verdict: this device is unknown,
      // revoked, or its grant is dead. Only THEN do we wipe.
      await clear();
      _onReauthRequired?.call();
      throw const ReauthRequired();
    }
    // Everything else — offline, timeout, 5xx, the broker's 503 when it can't
    // reach GLPI — propagates as a retryable error with credentials INTACT.
    // Conflating those with rejection is how a busy server signs everyone out.
  }
}
