//
//  NotificationService.swift
//  Message Decryptor Extension
//
//  Created by macbook on 21.06.17.
//  Copyright © 2017 Nikita. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    var attachmentStorage: AttachmentStorage = AttachmentStorage()
    
    func handleMessage() {
        guard let content = bestAttemptContent,
            let contentHandler = self.contentHandler
            else { return }
        
        // Modify the notification content here...
        content.title = "\(content.title)"
        content.body = String(data: Data(base64Encoded: content.body)!, encoding: .utf8)!
        
        contentHandler(content)
    }
    
    func handleGif() {
        guard let content = bestAttemptContent,
            let contentHandler = self.contentHandler
            else { return }
        
        if let gifPath = content.userInfo["gif"] as? String {
            let url = URL(string: gifPath)!
            attachmentStorage.store(url: url, extension: "gif") { (path, error) in
                if let path = path {
                    let attachment = try! UNNotificationAttachment(identifier: "image", url: path, options: nil)
                    
                    content.attachments = [attachment]
                }
                contentHandler(content)
            }
        }
    }
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let content = bestAttemptContent else { return }
        
        switch content.categoryIdentifier {
        case "message":
            handleMessage()
        case "gif":
            handleGif()
        default:
            contentHandler(content)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
