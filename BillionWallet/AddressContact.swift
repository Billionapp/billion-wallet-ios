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
    var lastUsed: NSNumber
}

// MARK: - ContactProtocol

extension AddressContact: ContactProtocol {

    var notificationTxHash: String? {
        get {
            return nil
        }
        set {
            notificationTxHash = nil
        }
    }
    
    func getReceiveAddresses() -> [String] {
        return [String]()
    }
    
    func getNotificationAddress() -> String? {
        return nil
    }
    
    func getSendAddresses() -> [String] {
        return [String]()
    }
    
    var isNotificationTxNeededToSend: Bool {
        return false
    }
    
    var uniqueValue: String {
        return address
    }
    
    static var uniqueAttribute: String {
        return "address"
    }
    
    static func create(unique address: String) -> AddressContact {
        return AddressContact(address: address,
                              displayName: defaultDisplayName,
                              avatarData: nil,
                              isArchived: false,
                              txHashes: [],
                              lastUsed: NSNumber(value: Double(Date().timeIntervalSince1970)))
    }
    
    func backup(using icloud: ICloud) throws {
        try icloud.backup(object: self)
    }
    
    func save() {
        CoreDataObject.context().perform {
            let object = CoreDataObject.initManagedObject(true)!
            object.address = self.address
            object.displayName = self.displayName
            object.avatarData = self.avatarData
            object.isArchived = self.isArchived
            object.txHashes = Set(self.txHashes)
            object.lastUsed = self.lastUsed

            try? CoreDataObject.save()
            NotificationCenter.default.post(name: contactsChangedAfterSaveNotification, object: nil)
        }
    }
    
    func getConnectedAddress(for transaction: Transaction) -> String? {
        let outputsAddresses = transaction.outputAddresses
        guard outputsAddresses.contains(where: { $0 == address }) else {
            return nil
        }
        return address
    }
    
    func addressToSend() -> String? {
        return address
    }
    
    mutating func incrementFirstUnusedIndex() {
        // Implemented in PaymentCodeContactProtocol, for AddressContact we do nothing
    }
    
    mutating func generateSendAddresses() {
        // Implemented in PaymentCodeContactProtocol, for AddressContact we do nothing
    }
    
}

// MARK: - ContactDisplayable

extension AddressContact: ContactDisplayable {
    
    var description: (value: String, type: String) {
        return ("Address", "Address contact")
    }
    
    var givenName: String {
        get {
            return displayName
        }
        
        set {
            displayName = newValue
        }
    }
    
    var sharingString: String {
        return "bitcoin://\(uniqueValue)"
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
                              txHashes: object.txHashes,
                              lastUsed: object.lastUsed)
    }
    
}
