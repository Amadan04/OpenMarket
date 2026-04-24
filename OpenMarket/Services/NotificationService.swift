import UserNotifications
import UIKit

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    // Called when user explicitly enables a notification toggle.
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    // Called on every app launch — re-registers silently if already authorized
    // so AppDelegate receives a fresh token to upload.
    func registerIfAuthorized() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    // Called on logout to remove the token from the backend.
    func unregisterDevice() {
        guard let token = UserDefaults.standard.string(forKey: "apns_device_token") else { return }
        Task { await DeviceService.unregister(token: token) }
        UserDefaults.standard.removeObject(forKey: "apns_device_token")
    }

    func scheduleLocalNotification(title: String, body: String, identifier: String = UUID().uuidString) {
        guard UserDefaults.standard.bool(forKey: "notif_messages") else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
