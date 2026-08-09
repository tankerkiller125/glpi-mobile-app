import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/errors.dart';
import 'package:glpi_mobile/core/auth/broker_client.dart';
import 'package:glpi_mobile/core/auth/secure_store.dart';
import 'package:glpi_mobile/core/auth/token_manager.dart';
import 'package:glpi_mobile/core/models/account.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

/// In-memory SecureStore for tests (no platform channels).
class _MemStore implements SecureStore {
  String? _creds;
  DeviceCredentials? _device;

  @override
  Future<String?> readCredentials() async => _creds;
  @override
  Future<void> writeCredentials(String json) async => _creds = json;
  @override
  Future<DeviceCredentials?> readDevice() async => _device;
  @override
  Future<void> writeDevice(DeviceCredentials device) async => _device = device;
  @override
  Future<void> deleteTokens() async {
    _creds = null;
    _device = null;
  }

  @override
  Future<Account?> readAccount() async => null;
  @override
  Future<void> writeAccount(Account account) async {}
  @override
  Future<void> deleteAll() async => _creds = null;
}

/// A broker whose refresh is scripted; counts calls to prove single-flight.
class _FakeBroker extends BrokerClient {
  _FakeBroker(this._result) : super('http://x');
  final oauth2.Credentials Function() _result;
  int refreshCalls = 0;
  int legacyCalls = 0;
  DeviceCredentials? handOut;

  @override
  Future<BrokerTokens> refreshDevice(DeviceCredentials device) async {
    refreshCalls++;
    return (credentials: _result(), device: null);
  }

  @override
  Future<BrokerTokens> refreshLegacy(String refreshToken) async {
    refreshCalls++;
    legacyCalls++;
    return (credentials: _result(), device: handOut);
  }
}

class _AuthFailBroker extends BrokerClient {
  _AuthFailBroker() : super('http://x');
  @override
  Future<BrokerTokens> refreshDevice(DeviceCredentials device) async =>
      throw const GlpiAuthError('rejected');
  @override
  Future<BrokerTokens> refreshLegacy(String refreshToken) async =>
      throw const GlpiAuthError('rejected');
}

/// The server is up but unable to reach GLPI (503), or the phone is offline.
class _UnavailableBroker extends BrokerClient {
  _UnavailableBroker() : super('http://x');
  int calls = 0;

  @override
  Future<BrokerTokens> refreshDevice(DeviceCredentials device) async {
    calls++;
    throw const GlpiServerError('broker unavailable');
  }
}

oauth2.Credentials _creds(String access, {String? refresh, DateTime? expiry}) =>
    oauth2.Credentials(access, refreshToken: refresh, expiration: expiry);

void main() {
  test('returns the stored token when not near expiry', () async {
    final store = _MemStore();
    await store.writeCredentials(
      _creds(
        'fresh',
        refresh: 'r',
        expiry: DateTime.now().add(const Duration(hours: 1)),
      ).toJson(),
    );
    final tm = TokenManager(
      store: store,
      serverUrl: 'http://x',
      broker: _FakeBroker(() => _creds('unused')),
    );
    expect(await tm.accessToken(), 'fresh');
  });

  test('proactively refreshes when close to expiry', () async {
    final store = _MemStore();
    await store.writeCredentials(
      _creds(
        'old',
        refresh: 'r',
        expiry: DateTime.now().add(const Duration(seconds: 5)),
      ).toJson(),
    );
    final broker = _FakeBroker(
      () => _creds(
        'refreshed',
        refresh: 'r2',
        expiry: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
    final tm = TokenManager(
      store: store,
      serverUrl: 'http://x',
      broker: broker,
    );
    expect(await tm.accessToken(), 'refreshed');
    expect(broker.refreshCalls, 1);
  });

  test('concurrent refreshes are single-flight', () async {
    final store = _MemStore();
    await store.writeCredentials(_creds('old', refresh: 'r').toJson());
    final broker = _FakeBroker(
      () => _creds(
        'refreshed',
        refresh: 'r2',
        expiry: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
    final tm = TokenManager(
      store: store,
      serverUrl: 'http://x',
      broker: broker,
    );
    final results = await Future.wait([
      tm.refresh(),
      tm.refresh(),
      tm.refresh(),
    ]);
    expect(results.map((c) => c.accessToken), everyElement('refreshed'));
    expect(broker.refreshCalls, 1);
  });

  test('a rejected refresh clears tokens and demands re-auth', () async {
    final store = _MemStore();
    await store.writeDevice((id: 'd', secret: 's'));
    await store.writeCredentials(_creds('old', refresh: 'r').toJson());
    var signedOut = 0;
    final tm = TokenManager(
      store: store,
      serverUrl: 'http://x',
      broker: _AuthFailBroker(),
      onReauthRequired: () => signedOut++,
    );
    await expectLater(tm.refresh(), throwsA(isA<ReauthRequired>()));
    expect(await store.readCredentials(), isNull);
    expect(await store.readDevice(), isNull);
    // The UI must be told, or the app sits on stale data failing every call.
    expect(signedOut, 1);
  });

  test('a transient failure never signs the technician out', () async {
    final store = _MemStore();
    await store.writeDevice((id: 'd', secret: 's'));
    await store.writeCredentials(_creds('old').toJson());
    var signedOut = 0;
    final tm = TokenManager(
      store: store,
      serverUrl: 'http://x',
      broker: _UnavailableBroker(),
      onReauthRequired: () => signedOut++,
    );
    await expectLater(tm.refresh(), throwsA(isA<GlpiServerError>()));
    expect(signedOut, 0);
  });

  test('a device session survives a lost/failed refresh response', () async {
    // GLPI revokes a refresh token the moment it is exchanged. When the app
    // held that token, a reply lost in transit stranded the device forever.
    // The device secret never rotates, so the retry simply works.
    final store = _MemStore();
    await store.writeDevice((id: 'd', secret: 's'));
    await store.writeCredentials(_creds('old', refresh: 'r').toJson());
    final broker = _FakeBroker(
      () => _creds(
        'refreshed',
        expiry: DateTime.now().add(const Duration(hours: 1)),
      ),
    );
    final tm = TokenManager(
      store: store,
      serverUrl: 'http://x',
      broker: broker,
    );
    expect((await tm.refresh()).accessToken, 'refreshed');
    // Same secret, second attempt — as if the first reply never arrived.
    expect((await tm.refresh()).accessToken, 'refreshed');
    expect(await store.readDevice(), isNotNull);
  });

  test('an unreachable broker keeps the pairing intact', () async {
    // A busy server must never sign a technician out.
    final store = _MemStore();
    await store.writeDevice((id: 'd', secret: 's'));
    await store.writeCredentials(_creds('old').toJson());
    final broker = _UnavailableBroker();
    final tm = TokenManager(
      store: store,
      serverUrl: 'http://x',
      broker: broker,
    );
    await expectLater(tm.refresh(), throwsA(isA<GlpiServerError>()));
    expect(await store.readCredentials(), isNotNull);
    expect(await store.readDevice(), isNotNull);
  });

  test('a legacy install upgrades to a device session in place', () async {
    // Apps paired before device sessions hold an OAuth refresh token; the
    // server hands back device credentials so nobody re-scans a QR.
    final store = _MemStore();
    await store.writeCredentials(_creds('old', refresh: 'r').toJson());
    final broker = _FakeBroker(
      () => _creds(
        'refreshed',
        expiry: DateTime.now().add(const Duration(hours: 1)),
      ),
    )..handOut = (id: 'dev-9', secret: 'sec-9');
    final tm = TokenManager(
      store: store,
      serverUrl: 'http://x',
      broker: broker,
    );
    await tm.refresh();
    expect(broker.legacyCalls, 1);
    expect((await store.readDevice())?.id, 'dev-9');

    // The next refresh uses the device path, not the dead refresh token.
    await tm.refresh();
    expect(broker.legacyCalls, 1);
    expect(broker.refreshCalls, 2);
  });

  test(
    'refreshIfStale renews a half-spent token and swallows failures',
    () async {
      final store = _MemStore();
      await store.writeDevice((id: 'd', secret: 's'));
      await store.writeCredentials(
        _creds(
          'old',
          expiry: DateTime.now().add(const Duration(minutes: 5)),
        ).toJson(),
      );
      final broker = _FakeBroker(
        () => _creds(
          'renewed',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        ),
      );
      final tm = TokenManager(
        store: store,
        serverUrl: 'http://x',
        broker: broker,
      );
      await tm.refreshIfStale();
      expect(broker.refreshCalls, 1);
      // Now fresh: a second call is a no-op.
      await tm.refreshIfStale();
      expect(broker.refreshCalls, 1);

      // And it never throws, even when the server is down.
      final offline = TokenManager(
        store: store,
        serverUrl: 'http://x',
        broker: _UnavailableBroker(),
      );
      await offline.refreshIfStale(staleAfter: const Duration(days: 365));
    },
  );

  test('no credentials at all means re-auth', () async {
    final store = _MemStore();
    await store.writeCredentials(_creds('old').toJson());
    final tm = TokenManager(
      store: store,
      serverUrl: 'http://x',
      broker: _FakeBroker(() => _creds('x')),
    );
    await expectLater(tm.refresh(), throwsA(isA<ReauthRequired>()));
  });
}
