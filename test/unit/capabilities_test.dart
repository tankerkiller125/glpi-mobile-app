import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/errors.dart';
import 'package:glpi_mobile/core/auth/auth_controller.dart';
import 'package:glpi_mobile/core/db/app_database.dart';
import 'package:glpi_mobile/core/models/capabilities.dart';
import 'package:glpi_mobile/core/providers.dart';

import '../support/fake_glpi_api.dart';

/// Keeps the provider graph off SecureStore (a platform channel) in tests.
class _StubAuth extends AuthController {
  @override
  AuthState build() => const SignedOut();
}

class _CapsApi with FakeGlpiApiDefaults {
  _CapsApi(this._onFetch);
  final Future<Capabilities> Function() _onFetch;

  @override
  Future<Capabilities> fetchCapabilities() => _onFetch();
}

void main() {
  group('Capabilities model', () {
    test('looks features up per plugin', () {
      final caps = Capabilities.fromJson(const {
        'glpisignal': {
          'version': '0.1.0',
          'features': {'alerts': true, 'ack': true, 'oncall': false},
        },
        'glpimajor': {
          'version': '0.1.0',
          'features': {'view': true, 'declare': true, 'publish': false},
        },
      });
      expect(caps.has(Cap.signal, Cap.signalAlerts), isTrue);
      expect(caps.has(Cap.signal, Cap.signalOncall), isFalse);
      expect(caps.has(Cap.major, Cap.majorView), isTrue);
      expect(caps.has(Cap.major, Cap.majorPublish), isFalse);
      expect(caps.versionOf(Cap.signal), '0.1.0');
    });

    test('anything missing reads as false, never a throw', () {
      final caps = Capabilities.fromJson(const {
        'glpisignal': {
          'version': '0.1.0',
          'features': {'alerts': true},
        },
      });
      expect(caps.has(Cap.signal, 'no_such_feature'), isFalse);
      expect(caps.has('no_such_plugin', 'anything'), isFalse);
      expect(caps.versionOf('no_such_plugin'), isNull);
    });

    test('malformed payloads degrade to empty, not errors', () {
      expect(Capabilities.fromJson(null).isEmpty, isTrue);
      expect(Capabilities.fromJson('not a map').isEmpty, isTrue);
      expect(Capabilities.fromJson(const [1, 2, 3]).isEmpty, isTrue);
      // A plugin entry that isn't an object is dropped; feature values that
      // aren't `true` read as absent.
      final caps = Capabilities.fromJson(const {
        'broken': 'nope',
        'glpisignal': {
          'version': 7,
          'features': {'alerts': 'yes', 'ack': 1, 'oncall': true},
        },
      });
      expect(caps.has('broken', 'anything'), isFalse);
      expect(caps.has(Cap.signal, Cap.signalAlerts), isFalse);
      expect(caps.has(Cap.signal, Cap.signalAck), isFalse);
      expect(caps.has(Cap.signal, Cap.signalOncall), isTrue);
    });

    test('unknown plugins and features are carried, not rejected', () {
      final caps = Capabilities.fromJson(const {
        'glpifuture': {
          'version': '9.9.9',
          'features': {'teleport': true},
        },
      });
      expect(caps.has('glpifuture', 'teleport'), isTrue);
    });

    test('round-trips through toJson for the offline cache', () {
      final caps = Capabilities.fromJson(const {
        'glpisignal': {
          'version': '0.1.0',
          'features': {'alerts': true},
        },
      });
      final revived = Capabilities.fromJson(caps.toJson());
      expect(revived.has(Cap.signal, Cap.signalAlerts), isTrue);
      expect(revived.versionOf(Cap.signal), '0.1.0');
    });
  });

  group('capabilitiesProvider', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    ProviderContainer container(Future<Capabilities> Function() onFetch) {
      final c = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith(_StubAuth.new),
          databaseProvider.overrideWithValue(db),
          glpiApiProvider.overrideWithValue(_CapsApi(onFetch)),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    const wire = {
      'glpisignal': {
        'version': '0.1.0',
        'features': {'alerts': true, 'ack': true},
      },
    };

    test('serves the fetched map and caches it', () async {
      final c = container(() async => Capabilities.fromJson(wire));
      final caps = await c.read(capabilitiesProvider.future);
      expect(caps.has(Cap.signal, Cap.signalAlerts), isTrue);
    });

    test('404 (older server plugin) means empty, not an error', () async {
      final c = container(() => throw const GlpiNotFoundError('no route'));
      final caps = await c.read(capabilitiesProvider.future);
      expect(caps.isEmpty, isTrue);
    });

    test('a network error falls back to the last cached map', () async {
      // First run online: fetch succeeds and lands in the cache.
      final online = container(() async => Capabilities.fromJson(wire));
      await online.read(capabilitiesProvider.future);

      // Next run offline (same database): gating still works.
      final offline = container(() => throw const GlpiNetworkError('offline'));
      final caps = await offline.read(capabilitiesProvider.future);
      expect(caps.has(Cap.signal, Cap.signalAck), isTrue);
    });

    test('a network error with nothing cached means empty', () async {
      final c = container(() => throw const GlpiNetworkError('offline'));
      final caps = await c.read(capabilitiesProvider.future);
      expect(caps.isEmpty, isTrue);
    });
  });
}
