//
//  PaymentCodeContact.swift
//  CoreDataTest
//
//  Created by Evolution Group Ltd on 02/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import CoreData

struct PaymentCodeContact: PaymentCodeContactProtocol {
    
    static let pregenCount = 100
    
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
    
    // Outgoing notification tx hash
    var notificationTxHash: String?
    // Incoming notification transaction hash
    var incomingNotificationTxhash: String?
    var notificationAddress: String?
}

// MARK: - ContactProtocol

extension PaymentCodeContact: ContactProtocol {
    
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
    
    static func create(unique paymentCode: String) -> PaymentCodeContact {
        
        let friendPC = try? PaymentCode(with: paymentCode)
        let notifAddress = friendPC?.notificationAddress
        
        let contactName = defaultDisplayName + String(paymentCode.suffix(4))
        let contactAvatarImage = contactName.createAvatarImage()
        let avatarData = UIImagePNGRepresentation(contactAvatarImage)
        
        var pcContact = PaymentCodeContact(displayName: contactName,
                                  avatarData: avatarData,
                                  isArchived: true,
                                  txHashes: [],
                                  lastUsed: NSNumber(value: Double(Date().timeIntervalSince1970)),
                                  paymentCode: paymentCode,
                                  firstUnusedIndex: 0,
                                  receiveAddresses: [],
                                  sendAddresses: [],
                                  notificationTxHash: nil,
                                  incomingNotificationTxhash: nil,
                                  notificationAddress: notifAddress)
        pcContact.generateSendAddresses()
        pcContact.generateReceiveAddresses()
        return pcContact
    }
    
    func backup(using icloud: ICloud) throws {
        try icloud.backup(object: self)
    }
    
    func save() {
        CoreDataObject.context().perform {
            let object = CoreDataObject.initManagedObject(true)!
            object.displayName = self.displayName
            object.avatarData = self.avatarData
            object.isArchived = self.isArchived
            object.txHashes = Set(self.txHashes)
            object.lastUsed = self.lastUsed
            object.paymentCode = self.paymentCode
            object.firstUnusedIndex = NSNumber(value: self.firstUnusedIndex)
            object.receiveAddresses = self.receiveAddresses
            object.notificationTxHash = self.notificationTxHash
            object.incomingNotificationTxHash = self.incomingNotificationTxhash
            object.sendAddresses = self.sendAddresses
            do {
                try ForeignPaymentCodeEntity.save()
            } catch let error {
                Logger.error("\(error.localizedDescription)")
            }
            NotificationCenter.default.post(name: contactsChangedAfterSaveNotification, object: nil)
        }
    }
    
}

// MARK: - ContactDisplayable

extension PaymentCodeContact: ContactDisplayable {
    
    var description: (value: String, type: String) {
        return ("Payment code", "Payment code")
    }
    
    var givenName: String {
        get {
            return displayName
        }
        
        set {
            displayName = newValue
        }
    }
    
}

// MARK: - PlainMappable

extension PaymentCodeContact: PlainMappable {
    
    typealias CoreDataObject = ForeignPaymentCodeEntity
    
    static func map(from object: CoreDataObject) -> PaymentCodeContact {
        return PaymentCodeContact(displayName: object.displayName,
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
