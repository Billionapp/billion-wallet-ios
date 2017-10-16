//
//  PaymentCodeContact.swift
//  CoreDataTest
//
//  Created by Evolution Group Ltd on 02/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import CoreData

struct PaymentCodeContact {
    
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

extension PaymentCodeContact: ContactProtocol {
    
    var uniqueValue: String {
        return paymentCode
    }
    
    static var uniqueAttribute: String {
        return "paymentCode"
    }
    
    var description: (smart: String, full: String) {
        return ("PC", "Payment code")
    }
    
    static func create(unique paymentCode: String) -> PaymentCodeContact {
        return PaymentCodeContact(displayName: "unknown" + String(paymentCode.suffix(4)),
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
            object.displayName = self.displayName
            object.avatarData = self.avatarData
            object.isArchived = self.isArchived
            object.txHashes = Set(self.txHashes)
            object.paymentCode = self.paymentCode
            object.firstUnusedIndex = NSNumber(value: self.firstUnusedIndex)
            object.receiveAddresses = self.receiveAddresses
            object.notificationTxHash = self.notificationTxHash
            try? ForeignPaymentCodeEntity.save()
        }
    }
    
}

// MARK: - PaymentCodeContactProtocol

extension PaymentCodeContact: PaymentCodeContactProtocol {
    
}

// MARK: - PlainMappable

extension PaymentCodeContact: PlainMappable {
    
    typealias CoreDataObject = ForeignPaymentCodeEntity
    
    static func map(from object: CoreDataObject) -> PaymentCodeContact {
        return PaymentCodeContact(displayName: object.displayName,
                                  avatarData: object.avatarData,
                                  isArchived: object.isArchived,
                                  txHashes: object.txHashes,
                                  paymentCode: object.paymentCode,
                                  firstUnusedIndex: object.firstUnusedIndex.intValue,
                                  receiveAddresses: object.receiveAddresses,
                                  notificationTxHash: object.notificationTxHash)
    }
    
}
