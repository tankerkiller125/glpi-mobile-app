import 'dart:io';

import 'package:dio/dio.dart';

import 'hl_client.dart' show isTokenChallenge;

/// Error taxonomy shared by the sync engine and repositories. Classification
/// drives outbox retry policy: network/server errors are retryable, validation
/// and rights errors go straight to needs-attention.
sealed class GlpiError implements Exception {
  const GlpiError(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Socket/timeout — retryable, does not count toward permanent failure.
class GlpiNetworkError extends GlpiError {
  const GlpiNetworkError(super.message);
}

/// 401 — token refresh path, never an op failure.
class GlpiAuthError extends GlpiError {
  const GlpiAuthError(super.message);
}

/// 403 — rights changed server-side.
class GlpiForbiddenError extends GlpiError {
  const GlpiForbiddenError(super.message);
}

/// 404 — target gone (deleted ticket, removed sub-item).
class GlpiNotFoundError extends GlpiError {
  const GlpiNotFoundError(super.message);
}

/// 400/422 — the server rejected the payload.
class GlpiValidationError extends GlpiError {
  const GlpiValidationError(super.message, [this.fieldErrors = const {}]);
  final Map<String, List<String>> fieldErrors;
}

/// 5xx — retryable with attempt penalty.
class GlpiServerError extends GlpiError {
  const GlpiServerError(super.message);
}

/// The server understood the request and deliberately refused it: an item
/// hook (e.g. glpi-entitle's uncontracted-work policy) vetoed the write.
/// GLPI reports this as a 500 "Failed to create item(s)" that carries the
/// refusing plugin's explanation in `additional_messages` — but unlike a
/// real 5xx it is not transient, and retrying cannot succeed until the
/// underlying state changes (a contract renewed, an approval granted). Goes
/// straight to needs-attention, with the server's own words as the message.
class GlpiRejectedError extends GlpiError {
  const GlpiRejectedError(super.message);
}

/// Anything unexpected (parse failures, contract drift) — do not retry-loop.
class GlpiUnexpectedError extends GlpiError {
  const GlpiUnexpectedError(super.message);
}

GlpiError mapDioError(Object error) {
  if (error is GlpiError) return error;
  if (error is DioException) {
    // The auth interceptor rejects with a GlpiError when refresh is impossible.
    if (error.error is GlpiError) return error.error! as GlpiError;
    final status = error.response?.statusCode;
    final detail =
        _detail(error.response?.data) ?? error.message ?? 'request failed';
    // A dead bearer token arrives as 400 'Invalid OAuth token', so classify by
    // meaning rather than by code alone.
    if (isTokenChallenge(error.response)) return GlpiAuthError(detail);
    return switch (status) {
      401 => GlpiAuthError(detail),
      403 => GlpiForbiddenError(detail),
      404 => GlpiNotFoundError(detail),
      400 || 422 => GlpiValidationError(detail),
      != null && >= 500 => switch (_refusalOf(error.response?.data)) {
        final refusal? => GlpiRejectedError(refusal),
        null => GlpiServerError(detail),
      },
      _ => switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.connectionError => GlpiNetworkError(detail),
        // Offline sockets often surface as `unknown` wrapping a
        // SocketException — retryable network errors, not permanent failures.
        DioExceptionType.unknown when error.error is SocketException =>
          GlpiNetworkError(detail),
        _ => GlpiUnexpectedError(detail),
      },
    };
  }
  return GlpiUnexpectedError(error.toString());
}

/// A hook-refused write, if that's what this 500 body is.
///
/// `AbstractController::getCRUDErrorResponse` answers a `false` from
/// `CommonDBTM::add/update/delete` with 500 `"Failed to <action> item(s)"`
/// plus whatever the refusing code said via `Session::addMessageAfterRedirect`
/// as `additional_messages`. When those messages exist, they — not the
/// generic title — are the story; returns them joined, or null when this is
/// an ordinary server error.
String? _refusalOf(Object? body) {
  if (body is! Map) return null;
  final title = body['title'];
  if (title is! String || !title.startsWith('Failed to ')) return null;
  final raw = body['additional_messages'];
  if (raw is! List) return null;
  final texts = [
    for (final m in raw)
      if (m is Map && m['message'] is String) (m['message'] as String).trim(),
  ]..removeWhere((t) => t.isEmpty);
  return texts.isEmpty ? null : texts.join('\n');
}

String? _detail(Object? body) {
  if (body is Map) {
    // `error` last: the plugin controllers answer terse machine codes there
    // (e.g. `state_refused`) — better than Dio's page-long default message.
    final d =
        body['detail'] ?? body['title'] ?? body['message'] ?? body['error'];
    if (d is String && d.isNotEmpty) return d;
  }
  return null;
}
