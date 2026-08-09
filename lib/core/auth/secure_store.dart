import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/account.dart';

/// Identifies this installation to the pairing broker. Stable for the life of
/// the pairing — the server rotates the OAuth tokens behind it.
typedef DeviceCredentials = ({String id, String secret});

/// All persisted secrets and the account record live here (Keychain/Keystore).
/// The account JSON itself is not secret, but in M1 (pre-drift) this is the
/// single persistence layer; non-secret fields migrate to the database in M2.
class SecureStore {
  SecureStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kAccount = 'account';
  static const _kCredentials = 'oauth_credentials';
  static const _kDevice = 'device_credentials';

  Future<Account?> readAccount() async {
    final raw = await _storage.read(key: _kAccount);
    if (raw == null) return null;
    return Account.fromJson(jsonDecode(raw) as Map<String, Object?>);
  }

  Future<void> writeAccount(Account account) =>
      _storage.write(key: _kAccount, value: jsonEncode(account.toJson()));

  /// oauth2 `Credentials.toJson()` string (access + refresh token + expiry).
  Future<String?> readCredentials() => _storage.read(key: _kCredentials);

  Future<void> writeCredentials(String credentialsJson) =>
      _storage.write(key: _kCredentials, value: credentialsJson);

  /// The paired-device credential: `{id, secret}`. Unlike the OAuth refresh
  /// token it never rotates, so losing a refresh response can't strand the
  /// device.
  Future<DeviceCredentials?> readDevice() async {
    final raw = await _storage.read(key: _kDevice);
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, Object?>;
    final id = json['id'] as String?;
    final secret = json['secret'] as String?;
    if (id == null || secret == null) return null;
    return (id: id, secret: secret);
  }

  Future<void> writeDevice(DeviceCredentials device) => _storage.write(
    key: _kDevice,
    value: jsonEncode({'id': device.id, 'secret': device.secret}),
  );

  /// Sign-out: drop tokens but keep the account record so cached data and the
  /// outbox can resume after re-login.
  Future<void> deleteTokens() async {
    await _storage.delete(key: _kCredentials);
    await _storage.delete(key: _kDevice);
  }

  /// Full wipe (remove account).
  Future<void> deleteAll() => _storage.deleteAll();
}
