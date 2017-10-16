//
//  AddressContact.swift
//  CoreDataTest
//
//  Created by Evolution Group Ltd on 02/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

struct AddressContact {
    
    let address: String
    
    // MARK: - ContactProtocol
    var displayName: String
    var avatarData: Data?
    var isArchived: Bool
    var txHashes: Set<String>
}

// MARK: - ContactProtocol

extension AddressContact: ContactProtocol {
    
    var isNotificationTxNeededToSend: Bool {
        return false
    }
    
    var uniqueValue: String {
        return address
    }
    
    var description: (smart: String, full: String) {
        return ("Address", "Address contact")
    }
    
    static var uniqueAttribute: String {
        return "address"
    }
    
    static func create(unique address: String) -> AddressContact {
        return AddressContact(address: address,
                              displayName: defaultDisplayName,
                              avatarData: nil,
                              isArchived: false,
                              txHashes: [])
    }
    
    func save() {
        CoreDataObject.context().perform {
            let object = CoreDataObject.initManagedObject(true)!
            object.address = self.address
            object.displayName = self.displayName
            object.avatarData = self.avatarData
            object.isArchived = self.isArchived
            object.txHashes = Set(self.txHashes)
            try? CoreDataObject.save()
        }
    }
    
    func isContact(for transaction: BRTransaction) -> Bool {
        let outputsAddresses = transaction.outputAddresses.flatMap { $0 as? String }
        return outputsAddresses.contains(where: { $0 == address })
    }
    
    mutating func addressToSend() -> String? {
        return address
    }
    
}

// MARK: - PlainMappable

extension AddressContact: PlainMappable {
    
    typealias CoreDataObject = ForeignAddressEntity
    
    static func map(from object: CoreDataObject) -> AddressContact {
        return AddressContact(address: object.address,
                              displayName: object.displayName,
                              avatarData: object.avatarData,
                              isArchived: object.isArchived,
                              txHashes: object.txHashes)
    }
    
}
