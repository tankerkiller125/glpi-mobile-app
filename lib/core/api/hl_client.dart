import 'dart:async';

import 'package:dio/dio.dart';

import '../auth/token_manager.dart';
import '../models/account.dart';
import 'errors.dart';

/// Runs work against a specific GLPI entity, overriding the account's active
/// context for every request made inside it.
///
/// GLPI takes the entity from a request header — including for writes, where it
/// decides the entity a new ticket is filed into. The outbox therefore cannot
/// simply use whatever context happens to be active when it drains: an op
/// composed in one entity and sent after the technician switched would land in
/// the wrong place. The drainer wraps each op in its own scope.
///
/// Zone-scoped rather than threaded through every API signature, so the
/// override survives `await`s without touching 60-odd call sites.
class EntityScope {
  const EntityScope._();

  static const _key = #glpiEntityScope;

  /// The override in force for the current async context, if any.
  static ({int id, bool recursive})? get current =>
      Zone.current[_key] as ({int id, bool recursive})?;

  static Future<T> run<T>(
    int? entityId,
    bool? recursive,
    Future<T> Function() body,
  ) {
    if (entityId == null) return body();
    return runZoned(
      body,
      zoneValues: {_key: (id: entityId, recursive: recursive ?? false)},
    );
  }
}

/// Does this response mean "your access token is no good"?
///
/// GLPI does not answer 401 for a dead bearer token: `Router::handleRequest`
/// catches the OAuth exception and returns **400** with
/// `{status: ERROR_INVALID_PARAMETER, title: 'Invalid OAuth token'}`. Matching
/// only on 401 meant a revoked token never triggered a refresh — the app just
/// showed stale data until the token's local expiry passed.
bool isTokenChallenge(Response<Object?>? response) {
  final status = response?.statusCode;
  if (status == 401) return true;
  if (status != 400) return false;
  final data = response?.data;
  if (data is! Map) return false;
  final title = '${data['title'] ?? ''}'.toLowerCase();
  final detail = '${data['detail'] ?? ''}'.toLowerCase();
  return title.contains('oauth token') ||
      detail.contains('access token') ||
      detail.contains('token could not be verified');
}

/// GLPI 11 high-level API version this app is built against. Pinned via both
/// the URL prefix and the header; bump deliberately, with a fixture re-capture.
const glpiApiVersion = '2.3';

/// Builds the dio instance for the high-level API.
///
/// - Bearer auth with proactive + reactive (401, single-flight) refresh.
/// - Per-request GLPI context headers (profile / entity / recursive) — the HL
///   API is stateless, there is no "change active entity" call.
Dio buildHlDio({
  required String serverUrl,
  required TokenManager tokens,
  required Account? Function() account,
}) {
  final dio = Dio(
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

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final acc = account();
        if (acc != null && acc.hasContext) {
          options.headers['GLPI-Profile'] = '${acc.profileId}';
          // An outbox op pinned to an entity wins over the active context.
          final scope = EntityScope.current;
          options.headers['GLPI-Entity'] = '${scope?.id ?? acc.entityId}';
          options.headers['GLPI-Entity-Recursive'] =
              (scope?.recursive ?? acc.entityRecursive) ? 'true' : 'false';
        }
        handler.next(options);
      },
    ),
  );

  // QueuedInterceptor serializes error handling so concurrent 401s wait for
  // the one in-flight refresh instead of stampeding the token endpoint.
  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await tokens.accessToken();
          options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        } on ReauthRequired {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
              error: const GlpiAuthError('re-authentication required'),
            ),
          );
        } on GlpiError catch (e) {
          // Offline / server busy while refreshing: reject with the original
          // (retryable) error so the outbox queues instead of giving up.
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
              error: e,
            ),
          );
        }
      },
      onError: (error, handler) async {
        final response = error.response;
        final alreadyRetried =
            error.requestOptions.extra['auth_retried'] == true;
        if (!isTokenChallenge(response) || alreadyRetried) {
          handler.next(error);
          return;
        }
        try {
          final refreshed = await tokens.refresh();
          final options = error.requestOptions
            ..headers['Authorization'] = 'Bearer ${refreshed.accessToken}'
            ..extra['auth_retried'] = true;
          handler.resolve(await dio.fetch<Object?>(options));
        } on ReauthRequired {
          handler.next(error);
        } catch (_) {
          handler.next(error);
        }
      },
    ),
  );

  return dio;
}
