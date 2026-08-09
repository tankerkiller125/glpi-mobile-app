import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/errors.dart';
import 'package:glpi_mobile/core/auth/broker_client.dart';

/// A Dio whose responses are canned by an interceptor, so BrokerClient's
/// parsing and error mapping can be tested without a server.
Dio _dioOk(Map<String, Object?> body) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) => handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: body),
      ),
    ),
  );
  return dio;
}

Dio _dioError(int status, Map<String, Object?> body) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) => handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: status,
            data: body,
          ),
        ),
      ),
    ),
  );
  return dio;
}

void main() {
  test('pair() parses tokens and sets an expiry', () async {
    final broker = BrokerClient(
      'http://x',
      dio: _dioOk({
        'access_token': 'aaa',
        'refresh_token': 'rrr',
        'expires_in': 3600,
      }),
    );
    final result = await broker.pair('code123');
    expect(result.credentials.accessToken, 'aaa');
    expect(result.credentials.expiration, isNotNull);
    expect(result.credentials.expiration!.isAfter(DateTime.now()), isTrue);
  });

  test('pair() picks up the device credential', () async {
    final broker = BrokerClient(
      'http://x',
      dio: _dioOk({
        'access_token': 'aaa',
        'expires_in': 3600,
        'device_id': 'dev-1',
        'device_secret': 'sec-1',
      }),
    );
    final result = await broker.pair('code123');
    expect(result.device?.id, 'dev-1');
    expect(result.device?.secret, 'sec-1');
    // Device sessions keep the rotating token server-side.
    expect(result.credentials.refreshToken, isNull);
  });

  test('refreshDevice() parses a fresh access token', () async {
    final broker = BrokerClient(
      'http://x',
      dio: _dioOk({'access_token': 'new', 'expires_in': 3600}),
    );
    final result = await broker.refreshDevice((id: 'd', secret: 's'));
    expect(result.credentials.accessToken, 'new');
    // The device credential is unchanged, so the server need not resend it.
    expect(result.device, isNull);
  });

  test('a legacy refresh upgrades the app to a device session', () async {
    final broker = BrokerClient(
      'http://x',
      dio: _dioOk({
        'access_token': 'new',
        'expires_in': 3600,
        'device_id': 'dev-9',
        'device_secret': 'sec-9',
      }),
    );
    final result = await broker.refreshLegacy('old-refresh');
    expect(result.credentials.accessToken, 'new');
    expect(result.device?.id, 'dev-9');
  });

  test('missing access_token is an auth error', () async {
    final broker = BrokerClient('http://x', dio: _dioOk({'nope': true}));
    await expectLater(broker.pair('c'), throwsA(isA<GlpiAuthError>()));
  });

  test('a used/expired code (410) surfaces as a GlpiError', () async {
    final broker = BrokerClient(
      'http://x',
      dio: _dioError(410, {'error': 'code_used'}),
    );
    await expectLater(broker.pair('c'), throwsA(isA<GlpiError>()));
  });

  test('a rejected session (401) is a GlpiAuthError', () async {
    final broker = BrokerClient(
      'http://x',
      dio: _dioError(401, {'error': 'session_rejected'}),
    );
    await expectLater(
      broker.refreshDevice((id: 'd', secret: 's')),
      throwsA(isA<GlpiAuthError>()),
    );
  });

  test('the broker being unreachable (503) is NOT an auth error', () async {
    // The distinction matters: an auth error wipes the pairing, a server error
    // is retried. A busy GLPI must not sign a technician out.
    final broker = BrokerClient(
      'http://x',
      dio: _dioError(503, {'error': 'refresh_unavailable'}),
    );
    await expectLater(
      broker.refreshDevice((id: 'd', secret: 's')),
      throwsA(isA<GlpiServerError>()),
    );
  });
}
