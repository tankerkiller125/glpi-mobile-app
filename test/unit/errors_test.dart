import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glpi_mobile/core/api/errors.dart';
import 'package:glpi_mobile/core/api/hl_client.dart';

DioException _http(int status, [Object? body]) => DioException(
  requestOptions: RequestOptions(path: '/x'),
  response: Response<Object?>(
    requestOptions: RequestOptions(path: '/x'),
    statusCode: status,
    data: body,
  ),
  type: DioExceptionType.badResponse,
);

void main() {
  _tokenChallengeTests();
  group('mapDioError', () {
    test('classifies HTTP statuses per outbox retry policy', () {
      expect(mapDioError(_http(401)), isA<GlpiAuthError>());
      expect(mapDioError(_http(403)), isA<GlpiForbiddenError>());
      expect(mapDioError(_http(404)), isA<GlpiNotFoundError>());
      expect(mapDioError(_http(400)), isA<GlpiValidationError>());
      expect(mapDioError(_http(422)), isA<GlpiValidationError>());
      expect(mapDioError(_http(500)), isA<GlpiServerError>());
      expect(mapDioError(_http(503)), isA<GlpiServerError>());
    });

    test('classifies transport failures as network errors', () {
      final timeout = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(mapDioError(timeout), isA<GlpiNetworkError>());
    });

    test(
      'offline SocketException (unknown type) is a retryable network error',
      () {
        // What dio actually throws when the device is offline.
        final offline = DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.unknown,
          error: const SocketException('Network is unreachable'),
        );
        expect(mapDioError(offline), isA<GlpiNetworkError>());
      },
    );

    test('extracts the GLPI error detail field', () {
      final error = mapDioError(
        _http(400, {'status': 'ERROR', 'detail': 'Invalid status value'}),
      );
      expect(error.message, 'Invalid status value');
    });

    test('passes through existing GlpiError instances', () {
      const original = GlpiNetworkError('offline');
      expect(mapDioError(original), same(original));
    });
  });

  group('hook-refused writes (server policy rejections)', () {
    // Verbatim shape from AbstractController::getCRUDErrorResponse: a hook
    // that vetoes an add (glpi-entitle's uncontracted-work gate) surfaces as
    // a 500 "Failed to create item(s)" carrying the refusal in
    // additional_messages.
    test('carry the server\'s refusal text and skip the retry ladder', () {
      final err = mapDioError(
        _http(500, {
          'status': 'ERROR',
          'title': 'Failed to create item(s)',
          'detail': null,
          'additional_messages': [
            {
              'priority': 'error',
              'message':
                  'This client has no active support contract — responses '
                  'are blocked by their uncontracted-work policy. Renew the '
                  'contract in ERPNext to continue.',
            },
          ],
        }),
      );
      expect(err, isA<GlpiRejectedError>());
      expect(err.message, contains('no active support contract'));
      expect(err.message, isNot(contains('Failed to create')));
    });

    test('multiple messages are all surfaced', () {
      final err = mapDioError(
        _http(500, {
          'title': 'Failed to update item(s)',
          'additional_messages': [
            {'priority': 'warning', 'message': 'first'},
            {'priority': 'error', 'message': 'second'},
          ],
        }),
      );
      expect(err, isA<GlpiRejectedError>());
      expect(err.message, 'first\nsecond');
    });

    test('a bare 500 create failure stays a retryable server error', () {
      expect(
        mapDioError(
          _http(500, {
            'title': 'Failed to create item(s)',
            'additional_messages': <Object?>[],
          }),
        ),
        isA<GlpiServerError>(),
      );
      expect(
        mapDioError(_http(500, {'title': 'Internal Server Error'})),
        isA<GlpiServerError>(),
      );
      expect(mapDioError(_http(500)), isA<GlpiServerError>());
    });
  });
}

void _tokenChallengeTests() {
  group('GLPI answers a dead token with 400, not 401', () {
    Response<Object?> res(int status, Object? data) => Response(
      requestOptions: RequestOptions(path: '/x'),
      statusCode: status,
      data: data,
    );

    test('the 400 "Invalid OAuth token" body is an auth challenge', () {
      // Verbatim shape from Glpi\Api\HL\Router::handleRequest.
      expect(
        isTokenChallenge(
          res(400, {
            'status': 'ERROR_INVALID_PARAMETER',
            'title': 'Invalid OAuth token',
            'detail': 'Access token could not be verified',
          }),
        ),
        isTrue,
      );
    });

    test('a plain 401 still counts', () {
      expect(isTokenChallenge(res(401, {'title': 'Unauthorized'})), isTrue);
    });

    test('an ordinary 400 does not', () {
      expect(
        isTokenChallenge(
          res(400, {
            'status': 'ERROR_INVALID_PARAMETER',
            'title': 'Bad filter',
          }),
        ),
        isFalse,
      );
    });

    test('mapDioError reports it as an auth error, not a validation error', () {
      final err = mapDioError(
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.badResponse,
          response: res(400, {
            'title': 'Invalid OAuth token',
            'detail': 'Access token could not be verified',
          }),
        ),
      );
      expect(err, isA<GlpiAuthError>());
    });
  });
}
