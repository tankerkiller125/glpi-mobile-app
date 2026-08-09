@Tags(['live'])
library;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/server_probe.dart';
import 'package:glpi_mobile/core/auth/broker_client.dart';
import 'live_config.dart';

/// Exercises the real QR-pairing broker (the `glpimobile` GLPI plugin) against
/// the dev-env GLPI. Obtains a one-time pairing code the way the plugin's
/// "Mobile app" settings tab does (web login -> render tab), then verifies the
/// app's [BrokerClient] redeems it and refreshes — with no client secret.
const _server = liveServer;

void main() {
  test('server probe accepts the dev server', () async {
    final result = await probeServer('$_server/');
    expect(result, isA<ServerOk>());
    expect((result as ServerOk).normalizedUrl, _server);
  });

  test('QR pairing yields HL-API tokens and refreshes', () async {
    final code = await _obtainPairingCode();

    final broker = BrokerClient(_server);
    final paired = await broker.pair(code);
    expect(paired.credentials.accessToken, isNotEmpty);
    // Pairing yields a device credential; the rotating OAuth refresh token
    // stays on the server.
    expect(paired.device, isNotNull);

    // The brokered access token works against the HL API.
    final dio = Dio(BaseOptions(baseUrl: '$_server/api.php/v2.3'));
    final session = await dio.get<Map<String, Object?>>(
      '/session',
      options: Options(
        headers: {'Authorization': 'Bearer ${paired.credentials.accessToken}'},
      ),
    );
    expect(session.data?['user_id'], isNotNull);

    // Same code can't be redeemed twice (single-use).
    await expectLater(broker.pair(code), throwsA(isA<Object>()));

    // The device credential refreshes repeatedly WITHOUT itself rotating —
    // this is what stops a lost response from stranding a technician.
    final device = paired.device!;
    for (var i = 0; i < 3; i++) {
      final refreshed = await broker.refreshDevice(device);
      expect(refreshed.credentials.accessToken, isNotEmpty);
    }
  });
}

/// Logs into GLPI's web UI, renders the plugin's "Mobile app" settings tab, and
/// scrapes the freshly minted pairing code from it.
Future<String> _obtainPairingCode() async {
  final dio = Dio(
    BaseOptions(
      followRedirects: false,
      validateStatus: (s) => s != null && s < 400,
    ),
  );
  final cookies = <String, String>{};
  void absorb(Response<Object?> r) {
    for (final raw in r.headers['set-cookie'] ?? const <String>[]) {
      final pair = raw.split(';').first.split('=');
      if (pair.length == 2) cookies[pair[0].trim()] = pair[1].trim();
    }
  }

  String cookieHeader() =>
      cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

  // 1. Landing page -> session cookie + CSRF token.
  final landing = await dio.get<String>(
    '$_server/',
    options: Options(responseType: ResponseType.plain),
  );
  absorb(landing);
  final csrf = RegExp(
    r'name="_glpi_csrf_token"[^>]*value="([^"]+)"',
  ).firstMatch(landing.data ?? '')?.group(1);
  expect(csrf, isNotNull, reason: 'CSRF token on the login page');

  // 2. Submit credentials.
  final login = await dio.post<String>(
    '$_server/front/login.php',
    data: {
      'login_name': liveUsername,
      'login_password': livePassword,
      '_glpi_csrf_token': csrf,
      'submit': 'Post',
    },
    options: Options(
      contentType: Headers.formUrlEncodedContentType,
      responseType: ResponseType.plain,
      headers: {'Cookie': cookieHeader()},
    ),
  );
  absorb(login);

  // 3. Render the "Mobile app" tab (mints tokens + stores a pairing code).
  final tab = await dio.get<String>(
    '$_server/ajax/common.tabs.php',
    queryParameters: {
      '_glpi_tab': r'GlpiPlugin\Glpimobile\QrTab$1',
      '_itemtype': 'Preference',
      '_target': '/front/preference.php',
      'id': '2',
      'withtemplate': '0',
    },
    options: Options(
      responseType: ResponseType.plain,
      headers: {'Cookie': cookieHeader()},
    ),
  );
  final code = RegExp(r'[0-9a-f]{48}').firstMatch(tab.data ?? '')?.group(0);
  expect(code, isNotNull, reason: 'pairing code rendered in the tab');
  return code!;
}
