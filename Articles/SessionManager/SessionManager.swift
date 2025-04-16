//
//  SessionManager.swift
//  Articles
//
//  Created by Dwistari on 14/04/25.
//

import UserNotifications
import Auth0
import UIKit

class SessionManager {
    
    static let shared = SessionManager()
    var onLogout: (() -> Void)?
    
    private init() {}

    
    func isSessionStillValid() -> Bool {
        guard let loginDate = UserDefaults.standard.object(forKey: "loginDate") as? Date else {
            return false
        }
        let elapsed = Date().timeIntervalSince(loginDate)
        return elapsed < 10 * 60
    }
    
    func logoutUser() {
        UserDefaults.standard.removeObject(forKey: "loginDate")
        self.sendLogoutNotification()
        DispatchQueue.main.async {
            self.onLogout?()
        }
    }
    
    // MARK: - Function add permission notification

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission granted for notifications")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            } else {
                print("Permission denied")
            }
        }
    }
    
    // MARK: - Function to show push notification

    func sendLogoutNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Session Expired"
        content.body = "Your session has expired and you’ve been logged out."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error showing notification: \(error.localizedDescription)")
            } else {
                print("Logout notification scheduled.")
            }
        }
    }
    
}
