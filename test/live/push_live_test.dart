@Tags(['live'])
library;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/glpi_api.dart';
import 'live_config.dart';

/// Exercises the app's push API layer against the real `glpimobile` plugin:
/// the VAPID/transport config endpoint and device register/unregister.
const _server = liveServer;

Future<HlGlpiApi> _api() async {
  final dio = Dio();
  final r = await dio.post<Map<String, Object?>>(
    '$_server/api.php/token',
    data: {
      'grant_type': 'password',
      'client_id': liveClientId,
      'client_secret': liveClientSecret,
      'username': liveUsername,
      'password': livePassword,
      'scope': 'api user email',
    },
  );
  final token = r.data!['access_token']! as String;
  return HlGlpiApi(
    Dio(
      BaseOptions(
        baseUrl: '$_server/api.php/v2.3',
        headers: {'Authorization': 'Bearer $token', 'GLPI-API-Version': '2.3'},
      ),
    ),
  );
}

void main() {
  test('push config exposes the VAPID key + transports', () async {
    final config = await (await _api()).fetchPushConfig();
    expect(config.vapidPublicKey, isNotEmpty);
    expect(config.transports['unifiedpush'], isTrue);
  });

  test('device register + unregister round-trips', () async {
    final api = await _api();
    final endpoint =
        'http://ntfy/live-test-${DateTime.now().microsecondsSinceEpoch}?up=1';

    // Should not throw (200 from the plugin).
    await api.registerDevice(
      transport: 'unifiedpush',
      endpoint: endpoint,
      p256dh:
          'BPtestp256dhkeyxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
      auth: 'YXV0aHNlY3JldDEyMw',
      platform: 'android',
    );

    // Cleanup — also verifies the unregister endpoint.
    await api.unregisterDevice(endpoint);
  });
}
