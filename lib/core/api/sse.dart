import 'dart:convert';

/// One decoded server-sent event: its name, and its `data:` payload parsed as
/// JSON.
typedef SseEvent = ({String event, Map<String, Object?> data});

/// Decode a `text/event-stream` body into events.
///
/// Split out of the API client so it can be tested without a socket, and
/// because the framing has three details that are easy to get wrong and
/// impossible to notice from a passing happy path:
///
///  - a frame ends at a **blank line**, not at a `data:` line — one frame may
///    be split across several reads on a slow connection;
///  - `data:` lines accumulate, so a payload broken over two lines is one
///    value, not two events;
///  - a payload that will not parse is dropped rather than thrown, because
///    losing one progress line is nothing and losing the answer is everything.
///
/// Comments (`:` lines, which some proxies inject as keep-alives) and unknown
/// fields are ignored, per the spec.
Stream<SseEvent> decodeSse(Stream<String> lines) async* {
  String? event;
  final data = StringBuffer();

  SseEvent? flush() {
    final name = event;
    final raw = data.toString();
    event = null;
    data.clear();
    if (name == null) return null;
    Object? decoded;
    try {
      decoded = raw.isEmpty ? null : jsonDecode(raw);
    } on FormatException {
      return null;
    }
    return (
      event: name,
      data: decoded is Map ? decoded.cast<String, Object?>() : const {},
    );
  }

  await for (final line in lines) {
    if (line.isEmpty) {
      final frame = flush();
      if (frame != null) yield frame;
      continue;
    }
    if (line.startsWith('event:')) {
      event = line.substring(6).trim();
    } else if (line.startsWith('data:')) {
      data.write(line.substring(5).trimLeft());
    }
  }

  // A stream that ends without its final blank line still had a frame in it.
  final last = flush();
  if (last != null) yield last;
}
