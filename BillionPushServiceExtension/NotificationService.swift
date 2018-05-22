//
//  NotificationService.swift
//  BillionPushServiceExtension
//
//  Created by Evolution Group Ltd on 29/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UserNotifications
import UIKit

class NotificationService: UNNotificationServiceExtension {
    
    lazy var wrapper: MessageWrapperProtocol = MessageWrapper()
    lazy var userPRProvider: UserPaymentRequestProtocol = DefaultUserPaymentRequestProviderFactory().createUserPaymentRequestProvider()
    lazy var groupProvider: GroupFolderProviderProtocol = GroupFolderProviderFactory().create()
    lazy var groupRequestStorage = GroupRequestStorageFactory(requestProvider: self.userPRProvider).create()
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        
        // If these method take out from here there is no possibility of debugging
        func getAttachment(_ identifier: String, data: Data, options: [AnyHashable: Any]?) throws -> UNNotificationAttachment {
            let fileManager = FileManager.default
            guard let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.evogroup.billionwallet")?.appendingPathComponent("ContactIndex") else {
                throw Errors.noAccessToGroupFolder
            }
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            let fileURL = directory.appendingPathComponent(identifier)
            try data.write(to: fileURL, options: [])
            return try UNNotificationAttachment(identifier: identifier, url: fileURL, options: options)
        }
        
        // If these method take out from here there is no possibility of debugging
        func getImageData(_ contactIndex: ContactIndex) throws -> Data {
            guard let data = contactIndex.avatarData else {
                throw Errors.noImageData
            }
            return data
        }
        
        let msgTitle = "New encrypted message received"
        let msgBody = "Open the app to read"
        
        let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            if
                let content = bestAttemptContent.userInfo["message-contents"] as? String {
                do {
                    
                    guard let queue = bestAttemptContent.userInfo["message-queue"] as? String else {
                        bestAttemptContent.title = msgTitle
                        bestAttemptContent.body = msgBody
                        contentHandler(bestAttemptContent)
                        return
                    }
                    
                    guard let fileName = bestAttemptContent.userInfo["message-filename"] as? String else {
                        bestAttemptContent.title = msgTitle
                        bestAttemptContent.body = msgBody
                        contentHandler(bestAttemptContent)
                        return
                    }
                    
                    var contact: ContactIndex! = nil
                    do {
                        contact = try groupProvider.getContactIndex(with: queue)
                    } catch {
                        bestAttemptContent.title = msgTitle
                        bestAttemptContent.body = msgBody
                        contentHandler(bestAttemptContent)
                        return
                    }
                    
                    guard let data = Data(base64Encoded: content) else {
                        bestAttemptContent.title = msgTitle
                        bestAttemptContent.body = msgBody
                        contentHandler(bestAttemptContent)
                        return
                    }
                    
                    guard let selfPcPriv = Keychain().selfPCPriv else {
                        bestAttemptContent.title = msgTitle
                        bestAttemptContent.body = msgBody
                        contentHandler(bestAttemptContent)
                        return
                    }
                    
                    let bobPC = try PaymentCode(with: contact.pc)
                    let alicePC = try PrivatePaymentCode(priv: selfPcPriv)
                    let decryptor = MessageEncryptorFactory().create(alicePC: alicePC, bobPC: bobPC)
                    
                    let encrypted = try decryptor.decrypt(data: data)
                    let unwrapped = try wrapper.unwrap(encrypted)
                    
                    // Skip if message already processed
                    guard !contact.fileNames.contains(fileName) else {
                        bestAttemptContent.title = msgTitle
                        bestAttemptContent.body = msgBody + "."
                        contentHandler(bestAttemptContent)
                        return
                    }
                    
                    switch unwrapped.type {
                    case .request:
                        let jsonString = unwrapped.json.description
                        let request = try userPRProvider.restore(from: jsonString)
                        bestAttemptContent.title = "-\(request.amount)" + Strings.satoshiSymbol
                        bestAttemptContent.body = "Confirm a payment request from \(contact.name)"
                    case .cancelRequest:
                        bestAttemptContent.title = ""
                        bestAttemptContent.body = "\(contact.name) has canceled a payment request"
                    case .declineRequest:
                        bestAttemptContent.title = ""
                        bestAttemptContent.body = "\(contact.name) has declined a payment request"
                    case .confirmRequest:
                        bestAttemptContent.title = ""
                        bestAttemptContent.body = "\(contact.name) has confirmed a payment request"
                    }
                    
                    // Store message to temp message storage (to update after app launch)
                    try groupRequestStorage.store(encrypted, fileName: fileName)
                    
                    // Appending user avatar
                    let imageData = try getImageData(contact)
                    let attachment = try getAttachment("image.jpg", data: imageData, options: nil)
                    bestAttemptContent.attachments = [attachment]
                    
                    // Update message list for contact
                    contact.fileNames.append(fileName)
                    try groupProvider.saveContact(contact, queueId: queue)
                    
                    contentHandler(bestAttemptContent)
                    
                } catch {
                    bestAttemptContent.title = msgTitle
                    bestAttemptContent.body = msgBody
                    contentHandler(bestAttemptContent)
                }
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Don't show push notification
    }
    
    enum Errors: Error {
        case noImageData
        case invalidImageData
        case noAccessToGroupFolder
    }
    
}
