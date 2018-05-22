//
//  FriendContact.swift
//  CoreDataTest
//
//  Created by Evolution Group Ltd on 03/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct FriendContact: PaymentCodeContactProtocol {

    static let pregenCount = 100
    
    // The name we invented
    var nickname: String?
    
    // MARK: - ContactProtocol
    var displayName: String
    var avatarData: Data?
    var isArchived: Bool
    var txHashes: Set<String>
    var lastUsed: NSNumber
    
    // MARK: - PaymentCodeContactProtocol
    let paymentCode: String
    var firstUnusedIndex: Int
    var receiveAddresses: [String]
    var sendAddresses: [String]
    // Outgoing notification transaction hash
    var notificationTxHash: String?
    // Incoming notification transaction hash
    var incomingNotificationTxhash: String?
    var notificationAddress: String?
}

// MARK: - ContactProtocol

extension FriendContact: ContactProtocol {
    
    mutating func generateSendAddresses() {
        sendAddresses = generateSendAddresses(range: 0..<PaymentCodeContact.pregenCount)
    }
    
    mutating func generateReceiveAddresses() {
        receiveAddresses = generateReceiveAddresses(range: 0..<PaymentCodeContact.pregenCount)
    }
    
    func getReceiveAddresses() -> [String] {
        return receiveAddresses
    }
    
    func getNotificationAddress() -> String? {
        return notificationAddress
    }
    
    func getSendAddresses() -> [String] {
        return sendAddresses
    }
        
    var uniqueValue: String {
        return paymentCode
    }
    
    static var uniqueAttribute: String {
        return "paymentCode"
    }
    
    static func create(unique paymentCode: String) -> FriendContact {
        
        let friendPC = try? PaymentCode(with: paymentCode)
        let notifAddress = friendPC?.notificationAddress
        
        let contactName = defaultDisplayName + String(paymentCode.suffix(4))
        let contactAvatarImage = contactName.createAvatarImage()
        let avatarData = UIImagePNGRepresentation(contactAvatarImage)
        
        var friendContact =  FriendContact(nickname: nil,
                             displayName: contactName,
                             avatarData: avatarData,
                             isArchived: false,
                             txHashes: [],
                             lastUsed: NSNumber(value: Double(Date().timeIntervalSince1970)),
                             paymentCode: paymentCode,
                             firstUnusedIndex: 0,
                             receiveAddresses: [],
                             sendAddresses: [],
                             notificationTxHash: nil,
                             incomingNotificationTxhash: nil,
                             notificationAddress: notifAddress)
        friendContact.generateSendAddresses()
        friendContact.generateReceiveAddresses()
        return friendContact
    }
    
    func backup(using icloud: ICloud) throws {
        try icloud.backup(object: self)
    }
    
    func save() {
        CoreDataObject.context().perform {
            let object = CoreDataObject.initManagedObject(true)!
            object.nickname = self.nickname
            object.displayName = self.displayName
            object.avatarData = self.avatarData
            object.isArchived = self.isArchived
            object.txHashes = self.txHashes
            object.lastUsed = self.lastUsed
            object.paymentCode = self.paymentCode
            object.firstUnusedIndex = NSNumber(value: self.firstUnusedIndex)
            object.receiveAddresses = self.receiveAddresses
            object.notificationTxHash = self.notificationTxHash
            object.incomingNotificationTxHash = self.incomingNotificationTxhash
            object.sendAddresses = self.sendAddresses
            try? CoreDataObject.save()
            NotificationCenter.default.post(name: contactsChangedAfterSaveNotification, object: nil)
        }
    }
    
}

// MARK: - ContactDisplayable

extension FriendContact: ContactDisplayable {
    
    var description: (value: String, type: String) {
        return ("Payment code", "Friend")
    }

    var givenName: String {
        get {
            return nickname ?? displayName
        }
        
        set {
            nickname = newValue
        }
    }
    
}

// MARK: - PlainMappable

extension FriendContact: PlainMappable {
    
    typealias CoreDataObject = ForeignFriendEntity
    
    static func map(from object: CoreDataObject) -> FriendContact {
        return FriendContact(nickname: object.nickname,
                             displayName: object.displayName,
                             avatarData: object.avatarData,
                             isArchived: object.isArchived,
                             txHashes: object.txHashes,
                             lastUsed: object.lastUsed,
                             paymentCode: object.paymentCode,
                             firstUnusedIndex: object.firstUnusedIndex.intValue,
                             receiveAddresses: object.receiveAddresses,
                             sendAddresses: object.sendAddresses,
                             notificationTxHash: object.notificationTxHash,
                             incomingNotificationTxhash: object.incomingNotificationTxHash,
                             notificationAddress: object.notificationAddress)
    }
    
}
