import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

import '../api/errors.dart';
import '../api/hl_client.dart' show glpiApiVersion;
import 'secure_store.dart' show DeviceCredentials;

/// What the broker hands back: an access token, plus the device credential
/// when the server issued or rotated one.
typedef BrokerTokens = ({
  oauth2.Credentials credentials,
  DeviceCredentials? device,
});

/// Talks to the `glpimobile` GLPI plugin's device-pairing broker.
///
/// The app holds no OAuth client secret — the plugin keeps it server-side — so
/// both initial pairing (redeeming a QR code) and token refresh go through
/// these endpoints.
///
/// Refresh is **device-bound**, not refresh-token-bound. GLPI revokes a refresh
/// token the moment it is exchanged, so an app that held the token itself would
/// be permanently locked out whenever a refresh response was lost in transit —
/// a dropped signal at the wrong moment would cost the technician a re-scan.
/// Instead the server keeps the rotating token and the app presents a device
/// secret that never changes, which makes a lost response a non-event: it just
/// asks again.
class BrokerClient {
  BrokerClient(String serverUrl, {Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: '$serverUrl/api.php/v$glpiApiVersion',
              headers: {
                'GLPI-API-Version': glpiApiVersion,
                'Accept': 'application/json',
              },
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  final Dio _dio;

  /// Redeem a one-time pairing code (scanned from the user's GLPI profile QR).
  Future<BrokerTokens> pair(String code) =>
      _exchange('/GlpiMobile/pair', {'code': code, 'platform': _platform});

  /// Refresh using this device's stable credential.
  Future<BrokerTokens> refreshDevice(DeviceCredentials device) =>
      _exchange('/GlpiMobile/refresh', {
        'device_id': device.id,
        'device_secret': device.secret,
        'platform': _platform,
      });

  /// Refresh for an install paired before device sessions existed. The server
  /// answers with a device credential, upgrading the app in place — nobody has
  /// to re-scan a QR because of this change.
  Future<BrokerTokens> refreshLegacy(String refreshToken) => _exchange(
    '/GlpiMobile/refresh',
    {'refresh_token': refreshToken, 'platform': _platform},
  );

  /// Reported verbatim ('android', 'ios', …) so the admin device list shows
  /// what the OS actually says rather than a guess.
  static String get _platform => Platform.operatingSystem;

  Future<BrokerTokens> _exchange(String path, Map<String, Object?> body) async {
    try {
      final res = await _dio.post<Map<String, Object?>>(path, data: body);
      final data = res.data ?? const {};
      final access = data['access_token'] as String?;
      if (access == null || access.isEmpty) {
        throw const GlpiAuthError('broker returned no access token');
      }
      final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 3600;
      final deviceId = data['device_id'] as String?;
      final deviceSecret = data['device_secret'] as String?;
      return (
        credentials: oauth2.Credentials(
          access,
          // Only the legacy path still returns one; device sessions keep the
          // refresh token on the server.
          refreshToken: data['refresh_token'] as String?,
          expiration: DateTime.now().add(Duration(seconds: expiresIn)),
        ),
        device: (deviceId != null && deviceSecret != null)
            ? (id: deviceId, secret: deviceSecret)
            : null,
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
