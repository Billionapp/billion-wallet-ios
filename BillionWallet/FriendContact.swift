//
//  FriendContact.swift
//  CoreDataTest
//
//  Created by Evolution Group Ltd on 03/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct FriendContact {
    
    var nickname: String?
    
    // MARK: - ContactProtocol
    var displayName: String
    var avatarData: Data?
    var isArchived: Bool
    var txHashes: Set<String>
    
    // MARK: - PaymentCodeContactProtocol
    let paymentCode: String
    var firstUnusedIndex: Int
    var receiveAddresses: [String]
    var notificationTxHash: String?
}

// MARK: - ContactProtocol

extension FriendContact: ContactProtocol {
    
    var uniqueValue: String {
        return paymentCode
    }
    
    static var uniqueAttribute: String {
        return "paymentCode"
    }
    
    var description: (smart: String, full: String) {
        return ("PC", "Friend")
    }
    
    static func create(unique paymentCode: String) -> FriendContact {
        return FriendContact(nickname: nil,
                             displayName: defaultDisplayName,
                             avatarData: nil,
                             isArchived: false,
                             txHashes: [],
                             paymentCode: paymentCode,
                             firstUnusedIndex: 0,
                             receiveAddresses: generateReceiveAddresses(pc: paymentCode, range: 0..<100),
                             notificationTxHash: nil)
    }
    
    func save() {
        CoreDataObject.context().perform {
            let object = CoreDataObject.initManagedObject(true)!
            object.nickname = self.nickname
            object.displayName = self.displayName
            object.avatarData = self.avatarData
            object.isArchived = self.isArchived
            object.txHashes = self.txHashes
            object.paymentCode = self.paymentCode
            object.firstUnusedIndex = NSNumber(value: self.firstUnusedIndex)
            object.receiveAddresses = self.receiveAddresses
            object.notificationTxHash = self.notificationTxHash
            try? CoreDataObject.save()
        }
    }
    
}

// MARK: - PaymentCodeContactProtocol

extension FriendContact: PaymentCodeContactProtocol {
    
    
    
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
                             paymentCode: object.paymentCode,
                             firstUnusedIndex: object.firstUnusedIndex.intValue,
                             receiveAddresses: object.receiveAddresses,
                             notificationTxHash: object.notificationTxHash)
    }
    
}
