import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unifiedpush/unifiedpush.dart';

import '../api/glpi_api.dart';
import '../providers.dart';
import '../router/app_router.dart';

const _androidNotifDetails = AndroidNotificationDetails(
  'ticket_updates',
  'Ticket updates',
  channelDescription: 'Assignments, approvals and replies on your tickets',
  importance: Importance.high,
  priority: Priority.high,
);

/// The channel FCM's background/killed-app notifications land on (referenced by
/// the `default_notification_channel_id` manifest meta-data). Created explicitly
/// at startup so it exists — and keeps high importance (heads-up) — even before
/// the app has shown its first local notification.
const _androidChannel = AndroidNotificationChannel(
  'ticket_updates',
  'Ticket updates',
  description: 'Assignments, approvals and replies on your tickets',
  importance: Importance.high,
);

/// Decode a UnifiedPush payload (`{ticket_id,title,body}`), or null if it can't
/// be decrypted/parsed.
Map<String, Object?>? _decodePush(PushMessage message) {
  if (!message.decrypted) return null;
  try {
    return jsonDecode(utf8.decode(message.content)) as Map<String, Object?>;
  } on Exception {
    return null;
  }
}

/// Show a ticket notification. Shared by the foreground service and the
/// killed-app background isolate. The payload carries the server ticket id so a
/// tap can deep-link.
Future<void> _showTicketNotification(
  FlutterLocalNotificationsPlugin local,
  Map<String, Object?> data,
) async {
  final ticketId = (data['ticket_id'] as num?)?.toInt();
  await local.show(
    ticketId ?? 0,
    (data['title'] as String?) ?? 'GLPI',
    (data['body'] as String?) ?? '',
    const NotificationDetails(android: _androidNotifDetails),
    payload: ticketId?.toString(),
  );
}

/// Entrypoint the native `UnifiedPushService` runs (`main` with the
/// `--unifiedpush-bg` arg) when a message arrives and the app is killed. It
/// registers a message handler that shows a local notification — no app UI,
/// providers, or server calls (the message is already delivered + decrypted).
@pragma('vm:entry-point')
Future<void> unifiedPushBackgroundMain() async {
  final local = FlutterLocalNotificationsPlugin();
  await local.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  await UnifiedPush.initialize(
    onMessage: (message, instance) async {
      final data = _decodePush(message);
      if (data != null) await _showTicketNotification(local, data);
    },
  );
}

/// Push notifications over UnifiedPush (self-hosted, Firebase-free) on Android
/// and APNs on iOS. The companion plugin encrypts + delivers; this service
/// registers the device, shows notifications while the app is alive, refreshes
/// the affected ticket, and deep-links on tap. Killed-app delivery is handled
/// by [unifiedPushBackgroundMain].
class PushService {
  PushService(this._ref);

  final Ref _ref;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _started = false;
  String? _endpoint;

  /// Native bridge for iOS APNs (the token + notification taps come from Swift).
  static const _iosChannel = MethodChannel('tech.norsewave.glpi/push');

  /// Register for push once the account is authenticated. Idempotent.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    try {
      await _run();
    } on Exception catch (e) {
      debugPrint('[push] start failed: $e');
    }
  }

  Future<void> _run() async {
    // iOS uses APNs (no UnifiedPush): the native side registers for remote
    // notifications and hands us the device token + taps over a method channel.
    if (Platform.isIOS) {
      await _startApns();
      return;
    }

    await _initLocalNotifications();
    await _handleLaunchFromNotification();

    await UnifiedPush.initialize(
      onNewEndpoint: _onNewEndpoint,
      onMessage: _onMessage,
      onUnregistered: (_) => _endpoint = null,
      onRegistrationFailed: (reason, _) =>
          debugPrint('[push] registration failed: $reason'),
    );

    final config = await _pushConfig();
    if (config == null) return; // plugin/push not available on this server

    // Prefer UnifiedPush when a distributor is available and VAPID is set;
    // otherwise, if one distributor is installed, select it silently. With no
    // UnifiedPush distributor at all, fall back to FCM (if the server set it up).
    if (config.vapidPublicKey.isNotEmpty) {
      if (await UnifiedPush.tryUseCurrentOrDefaultDistributor()) {
        await UnifiedPush.register(vapid: config.vapidPublicKey);
        return;
      }
      final distributors = await UnifiedPush.getDistributors();
      if (distributors.isNotEmpty) {
        await UnifiedPush.saveDistributor(distributors.first);
        await UnifiedPush.register(vapid: config.vapidPublicKey);
        return;
      }
    }
    await _startFcm(config.fcm);
  }

  Future<PushConfig?> _pushConfig() async {
    final api = _ref.read(glpiApiProvider);
    if (api == null) return null;
    try {
      return await api.fetchPushConfig();
    } on Exception {
      return null;
    }
  }

  // --- FCM fallback (Android with no UnifiedPush distributor) ---

  Future<void> _startFcm(FcmOptions? fcm) async {
    if (fcm == null) return; // FCM not configured on this server.
    try {
      // Initialise Firebase with runtime options from the server (no baked-in
      // google-services.json), so each self-hosted instance uses its own project.
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: fcm.apiKey,
            appId: fcm.appId,
            messagingSenderId: fcm.senderId,
            projectId: fcm.projectId,
          ),
        );
      }
    } on Object {
      return;
    }
    final messaging = FirebaseMessaging.instance;
    try {
      await messaging.requestPermission();
      final token = await messaging.getToken();
      if (token == null || token.isEmpty) return;
      await _registerFcm(token);
    } on Object {
      return; // e.g. a placeholder project — no token, no push.
    }

    messaging.onTokenRefresh.listen((t) => unawaited(_registerFcm(t)));

    // Foreground: FCM does not display automatically, so we show it + refresh.
    FirebaseMessaging.onMessage.listen((message) {
      final data = _fcmPayload(message);
      unawaited(_showTicketNotification(_local, data));
      final id = data['ticket_id'] as int?;
      if (id != null) unawaited(_refreshTicket(id));
    });

    // Background/killed: FCM shows the notification; a tap routes here.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final id = int.tryParse('${message.data['ticket_id'] ?? ''}');
      if (id != null) unawaited(_openTicket(id));
    });
    final initial = await messaging.getInitialMessage();
    final launchId = int.tryParse('${initial?.data['ticket_id'] ?? ''}');
    if (launchId != null) {
      unawaited(
        Future<void>.delayed(
          const Duration(milliseconds: 600),
          () => _openTicket(launchId),
        ),
      );
    }
  }

  Future<void> _registerFcm(String token) async {
    _endpoint = token;
    final api = _ref.read(glpiApiProvider);
    if (api == null) return;
    try {
      await api.registerDevice(
        transport: 'fcm',
        endpoint: token,
        platform: 'android',
      );
    } on Exception {
      // A failed registration just means no pushes until the next attempt.
    }
  }

  Map<String, Object?> _fcmPayload(RemoteMessage message) => {
    'ticket_id': int.tryParse('${message.data['ticket_id'] ?? ''}'),
    'title': message.notification?.title ?? 'GLPI',
    'body': message.notification?.body ?? '',
  };

  /// Called on sign-out. Best-effort: local unregister always; server-side only
  /// if the API is still available (tokens may already be gone on logout).
  Future<void> stop() async {
    if (!_started) return;
    _started = false;
    final endpoint = _endpoint;
    _endpoint = null;
    if (endpoint != null) {
      try {
        await _ref.read(glpiApiProvider)?.unregisterDevice(endpoint);
      } on Exception {
        // ignore — the row gets overwritten on next login or pruned on send.
      }
    }
    if (Platform.isAndroid) {
      try {
        await UnifiedPush.unregister();
      } on Exception {
        // ignore
      }
    }
  }

  Future<void> _onNewEndpoint(PushEndpoint endpoint, String instance) async {
    _endpoint = endpoint.url;
    final api = _ref.read(glpiApiProvider);
    if (api == null) return;
    try {
      await api.registerDevice(
        transport: 'unifiedpush',
        endpoint: endpoint.url,
        p256dh: endpoint.pubKeySet?.pubKey,
        auth: endpoint.pubKeySet?.auth,
        platform: 'android',
      );
    } on Exception {
      // A failed registration just means no pushes until the next attempt.
    }
  }

  // --- iOS APNs (native bridge) ---

  Future<void> _startApns() async {
    _iosChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'apnsToken':
          final token = call.arguments as String?;
          if (token != null && token.isNotEmpty) await _registerApns(token);
        case 'openTicket':
          final arg = call.arguments;
          final serverId = arg is int ? arg : int.tryParse('$arg');
          if (serverId != null) await _openTicket(serverId);
      }
    });
  }

  Future<void> _registerApns(String token) async {
    _endpoint = token;
    final api = _ref.read(glpiApiProvider);
    if (api == null) return;
    try {
      await api.registerDevice(
        transport: 'apns',
        endpoint: token,
        platform: 'ios',
      );
    } on Exception {
      // A failed registration just means no pushes until the next attempt.
    }
  }

  Future<void> _onMessage(PushMessage message, String instance) async {
    final data = _decodePush(message);
    if (data == null) return;
    await _showTicketNotification(_local, data);
    final ticketId = (data['ticket_id'] as num?)?.toInt();
    if (ticketId != null) await _refreshTicket(ticketId);
  }

  /// Pull the changed ticket so any open screen updates immediately.
  Future<void> _refreshTicket(int serverId) async {
    final tickets = _ref.read(ticketRepositoryProvider);
    if (tickets == null) return;
    final localId = await tickets.localIdForServerId(serverId);
    if (localId == null) return;
    try {
      await tickets.refreshTicket(localId, serverId);
      await _ref
          .read(timelineRepositoryProvider)
          ?.refreshTimeline(localId, serverId);
    } on Exception {
      // best-effort
    }
  }

  // --- Local notification display + tap handling ---

  Future<void> _initLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final id = int.tryParse(response.payload ?? '');
        if (id != null) unawaited(_openTicket(id));
      },
    );
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    // Ensure the high-priority channel exists up front so FCM's background
    // notifications (which reference it by id) show as heads-up alerts.
    await android?.createNotificationChannel(_androidChannel);
    // Request the runtime permission without blocking push registration on the
    // user's dialog response.
    unawaited(android?.requestNotificationsPermission() ?? Future.value());
  }

  /// If the app was launched by tapping a (killed-app) notification, deep-link
  /// to its ticket once the shell is ready.
  Future<void> _handleLaunchFromNotification() async {
    final launch = await _local.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      final id = int.tryParse(launch!.notificationResponse?.payload ?? '');
      // Defer so the app's initial route settles before we stack the ticket.
      if (id != null) {
        unawaited(
          Future<void>.delayed(
            const Duration(milliseconds: 600),
            () => _openTicket(id),
          ),
        );
      }
    }
  }

  Future<void> _openTicket(int serverId) async {
    final tickets = _ref.read(ticketRepositoryProvider);
    if (tickets == null) return;
    final localId = await tickets.openByServerId(serverId);
    if (localId == null) return;
    // Fresh read of the global navigator context (no State.mounted applies).
    final context = rootNavigatorKey.currentContext;
    // ignore: use_build_context_synchronously
    if (context != null) unawaited(context.push(Routes.ticket(localId)));
  }
}

final pushServiceProvider = Provider<PushService>((ref) => PushService(ref));
