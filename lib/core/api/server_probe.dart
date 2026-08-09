import 'package:dio/dio.dart';

sealed class ServerProbeResult {
  const ServerProbeResult();
}

class ServerOk extends ServerProbeResult {
  const ServerOk(this.normalizedUrl);
  final String normalizedUrl;
}

class ServerHlApiDisabled extends ServerProbeResult {
  const ServerHlApiDisabled();
}

class ServerUnreachable extends ServerProbeResult {
  const ServerUnreachable();
}

/// Validates a user-entered server URL by fetching `/api.php/doc.json`, which
/// is public when the high-level API is enabled (200) and returns 403 with a
/// "disabled" error when it is not.
Future<ServerProbeResult> probeServer(String input, {Dio? dio}) async {
  var url = input.trim();
  if (url.isEmpty) return const ServerUnreachable();
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = 'https://$url';
  }
  while (url.endsWith('/')) {
    url = url.substring(0, url.length - 1);
  }

  final client = dio ?? Dio();
  try {
    final response = await client.get<Object?>(
      '$url/api.php/doc.json',
      options: Options(
        followRedirects: true,
        receiveTimeout: const Duration(seconds: 10),
        validateStatus: (_) => true,
      ),
    );
    return switch (response.statusCode) {
      200 => ServerOk(url),
      403 => const ServerHlApiDisabled(),
      _ => const ServerUnreachable(),
    };
  } on DioException {
    return const ServerUnreachable();
  } finally {
    if (dio == null) client.close();
  }
}
