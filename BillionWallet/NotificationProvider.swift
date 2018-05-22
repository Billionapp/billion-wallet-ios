//
//  NotificationProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit
import UserNotifications

protocol UNProvider {
    /// Configure the initial state of provider. i.e. set itself as delegate
    ///
    /// - Parameter application: Shared application instance (for example)
    func configure(application: UIApplication)
    /// Register application for remote notifications
    func registerForPushes()
}

class NotificationProvider: NSObject {
    private weak var application: UIApplication?
    
    override init() { }
}

extension NotificationProvider: UNProvider {
    func configure(application: UIApplication) {
        self.application = application
        
        let center = UNUserNotificationCenter.current()
        let action = UNNotificationAction(identifier: "readIdentifier", title: "Read", options: [])
        let category = UNNotificationCategory(identifier: "message", actions: [action], intentIdentifiers: [], options: [])
        center.setNotificationCategories([category])
        center.requestAuthorization(options: [.badge, .alert, .sound]) { [unowned self] success, error in
            if let error = error {
                Logger.error(error.localizedDescription)
                return
            }
            self.registerForPushes()
        }
        center.delegate = self
    }
    
    func registerForPushes() {
        guard let application = self.application else {
            Logger.warn(".configure(application:) should be called prior to registration")
            return
        }
        // UI code should be run at the main thread and this method could be used in any
        DispatchQueue.main.async {
            application.registerForRemoteNotifications()
        }
    }
}

extension NotificationProvider: UNUserNotificationCenterDelegate {
    /// Called to let your app know which action was selected by the user for a given notification.
    ///
    /// - Parameters:
    ///   - center: The notification center that received the notification.
    ///   - response:
    ///     The user’s response to the notification.
    ///     This object contains the original notification and the identifier
    ///     string for the selected action. If the action allowed the user to
    ///     provide a textual response, this object is an instance of the
    ///     UNTextInputNotificationResponse class.
    ///   - completionHandler:
    ///     The block to execute when you have finished processing the user’s
    ///     response. You must execute this block from your method and should
    ///     call it as quickly as possible. The block has no return value or parameters.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "readIdentifier" {
            // TODO: Save user payment request
            // TODO: Route to user payment request afterwards
            let content = response.notification.request.content
            if content.categoryIdentifier == "message" {
                let queue = content.userInfo["message-queue"] as? String
                let filename = content.userInfo["message-filename"] as? String
                let message = content.userInfo["message-contents"] as? String
                Logger.debug("\(queue ?? "nil"), \(filename ?? "nil"), \(message ?? "nil")")
            }
        }
        completionHandler()
    }
    
    /// Called when a notification is delivered to a foreground app.
    ///
    /// - Parameters:
    ///   - center: The notification center that received the notification.
    ///   - notification: The notification that is about to be delivered. Use
    ///     the information in this object to determine an appropriate course
    ///     of action. For example, you might use the arrival of the notification
    ///     to fetch new content or update your app’s interface.
    ///   - completionHandler: The block to execute with the presentation option
    ///     for the notification. Always execute this block at some point during
    ///     your implementation of this method. Specify an option indicating how
    ///     you want the system to alert the user, if at all.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let content = notification.request.content
        // TODO: Save user payment request
        if content.categoryIdentifier == "message" {
            let queue = content.userInfo["message-queue"] as? String
            let filename = content.userInfo["message-filename"] as? String
            let message = content.userInfo["message-contents"] as? String
            Logger.debug("\(queue ?? "nil"), \(filename ?? "nil"), \(message ?? "nil")")
        }
        completionHandler([])
    }
}
