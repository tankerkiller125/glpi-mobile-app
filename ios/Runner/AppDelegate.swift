import Flutter
import UIKit
import UserNotifications

// iOS push (APNs). Requires, in Xcode: the "Push Notifications" capability
// (adds aps-environment) and "Background Modes → Remote notifications".
// APNs credentials (.p8 / key id / team id / bundle id) are configured in the
// GLPI plugin, which sends the notifications. This class obtains the device
// token and hands it — plus notification taps — to Dart over a method channel.
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private static let channelName = "tech.norsewave.glpi/push"
  private var pushChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(
      options: [.alert, .badge, .sound]
    ) { granted, _ in
      if granted {
        DispatchQueue.main.async { application.registerForRemoteNotifications() }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "GlpiMobilePush") {
      pushChannel = FlutterMethodChannel(
        name: AppDelegate.channelName,
        binaryMessenger: registrar.messenger()
      )
    }
  }

  // APNs device token → Dart (hex), which registers it with the plugin.
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let token = deviceToken.map { String(format: "%02x", $0) }.joined()
    pushChannel?.invokeMethod("apnsToken", arguments: token)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    NSLog("glpimobile: APNs registration failed: \(error.localizedDescription)")
  }

  // Show notifications while the app is in the foreground.
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // .banner is iOS 14+; .alert is its deprecated equivalent and the only
    // option on iOS 13, which this app still supports.
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .list, .sound])
    } else {
      completionHandler([.alert, .sound])
    }
  }

  // Tap → deep-link to the ticket (the payload carries ticket_id).
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    if let ticketId = response.notification.request.content.userInfo["ticket_id"] {
      pushChannel?.invokeMethod("openTicket", arguments: ticketId)
    }
    completionHandler()
  }
}
