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
      != null && >= 500 => GlpiServerError(detail),
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

String? _detail(Object? body) {
  if (body is Map) {
    final d = body['detail'] ?? body['title'] ?? body['message'];
    if (d is String && d.isNotEmpty) return d;
  }
  return null;
}
