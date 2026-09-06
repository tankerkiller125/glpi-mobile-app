/// What the connected server's companion plugins can do, from
/// `GET /GlpiMobile/capabilities`:
///
/// ```json
/// {"glpisignal": {"version": "0.1.0",
///                 "features": {"alerts": true, "ack": true, "oncall": true}}}
/// ```
///
/// The parser is deliberately tolerant — unknown plugins and features are
/// carried along, malformed entries are dropped, and anything missing reads as
/// `false` — because the app must keep working against every mix of plugin
/// versions a server may run.
class Capabilities {
  const Capabilities(this._plugins);

  /// No optional features: an older server plugin, or nothing cached yet.
  static const empty = Capabilities({});

  final Map<String, PluginCapabilities> _plugins;

  /// True when [plugin] (keyed by its GLPI directory name, e.g. `glpisignal`)
  /// advertises [feature]. Missing plugin or feature ⇒ false, never a throw.
  bool has(String plugin, String feature) =>
      _plugins[plugin]?.features[feature] ?? false;

  /// The plugin's advertised version, or null when it isn't installed.
  String? versionOf(String plugin) => _plugins[plugin]?.version;

  bool get isEmpty => _plugins.isEmpty;

  /// Parse the capabilities payload. Anything that isn't the expected shape —
  /// a non-map body, a plugin entry that isn't an object, a feature value that
  /// isn't `true` — degrades to "feature absent" rather than an error.
  factory Capabilities.fromJson(Object? json) {
    if (json is! Map) return empty;
    final plugins = <String, PluginCapabilities>{};
    json.forEach((key, value) {
      if (value is! Map) return;
      final features = <String, bool>{};
      final raw = value['features'];
      if (raw is Map) {
        raw.forEach((name, enabled) {
          if (enabled == true) features['$name'] = true;
        });
      }
      final version = value['version'];
      plugins['$key'] = PluginCapabilities(
        version: version is String ? version : '',
        features: features,
      );
    });
    return Capabilities(plugins);
  }

  /// Round-trips through [Capabilities.fromJson] — used to cache the last-known
  /// map so gating still works offline.
  Map<String, Object?> toJson() => {
    for (final e in _plugins.entries)
      e.key: {'version': e.value.version, 'features': e.value.features},
  };
}

/// One plugin's advertised version and feature switches.
class PluginCapabilities {
  const PluginCapabilities({required this.version, required this.features});

  final String version;
  final Map<String, bool> features;
}

/// The plugin/feature names the app gates on, so a typo'd string can't
/// silently hide a module.
abstract final class Cap {
  static const signal = 'glpisignal';
  static const signalAlerts = 'alerts';
  static const signalAck = 'ack';
  static const signalOncall = 'oncall';

  static const major = 'glpimajor';
  static const majorView = 'view';
  static const majorDeclare = 'declare';
  static const majorPublish = 'publish';

  static const kedb = 'glpikedb';
  static const kedbMatch = 'match';
  static const kedbSearch = 'search';
  static const kedbHits = 'hits';

  static const entitle = 'glpientitle';
  static const entitleEntitlement = 'entitlement';

  static const ai = 'glpiai';
  static const aiAssistant = 'assistant';
  static const aiDraft = 'draft';
  static const aiReplyReview = 'reply_review';
  static const aiTriage = 'triage';

  static const sop = 'glpisop';
  static const sopRuns = 'runs';
  static const sopAnswer = 'answer';

  static const presence = 'glpipresence';
  static const presenceView = 'presence';
  static const presenceClaim = 'claim';

  static const change = 'glpichange';
  static const changeCalendar = 'calendar';
  static const changeSchedule = 'schedule';
  static const changeFreezes = 'freezes';
}
