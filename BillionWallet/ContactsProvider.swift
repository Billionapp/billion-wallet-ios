//
//  ContactsProvider.swift
//  CoreDataTest
//
//  Created by Evolution Group Ltd on 02/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

@objc class ContactsProvider: NSObject {
    
    enum ContactMessage {
        case contactAdded(ContactProtocol)
        case contactUpdated(ContactProtocol)
        case contactRemoved(ContactProtocol)
    }
  
    private let queueIdProvider: QueueIdProviderProtocol
    private let groupProvider: GroupFolderProviderProtocol
    private var channel: Channel<ContactMessage>?
    private weak var iCloudProvider: ICloud!
    private let lock: NSLock
    
    init(iCloudProvider: ICloud, groupProvider: GroupFolderProviderProtocol, queueIdProvider: QueueIdProviderProtocol) {
        self.iCloudProvider = iCloudProvider
        self.groupProvider = groupProvider
        self.queueIdProvider = queueIdProvider
        self.channel = nil
        self.lock = NSLock()
    }
    
    func setChannel(_ channel: Channel<ContactMessage>) {
        self.channel = channel
    }
    
    /// Returns all address contacts
    var addressContacts: [AddressContact] {
        return ForeignAddressEntity.all()
    }
    
    /// Returns all payment code contacts
    var paymentCodeContacts: [PaymentCodeContact] {
        return ForeignPaymentCodeEntity.all()
    }
    
    /// Returns all friends contacts
    var friends: [FriendContact] {
        return ForeignFriendEntity.all()
    }
    
    var paymentCodeProtocolContacts: [PaymentCodeContactProtocol] {
        return Array([paymentCodeContacts as [PaymentCodeContactProtocol], friends as [PaymentCodeContactProtocol]].joined())
    }
    
    /// Returns all contacts
    ///
    /// - Parameter isArchived: define to return archived or unarchived contacts only
    func allContacts(isArchived: Bool? = nil) -> [ContactProtocol] {
        let contacts = Array([addressContacts as [ContactProtocol], paymentCodeContacts as [ContactProtocol], friends as [ContactProtocol]].joined())
        guard let isArchived = isArchived else {
            return contacts.sorted(by: { $0.lastUsed > $1.lastUsed })
        }
        return contacts.filter { $0.isArchived == isArchived }.sorted(by: { $0.lastUsed > $1.lastUsed })
    }
    
    /// Returns contact depending on unique object id
    ///
    /// - Parameter uniqueValue: unique object id, implemented in PlainMappable and entity constraints
    func getContact<Contact: ContactProtocol>(uniqueValue: String) -> Contact? where Contact: PlainMappable {
        return Contact.CoreDataObject.find(attribute: Contact.uniqueAttribute, value: uniqueValue)
    }
    
    /// Find existed contact or create new depending on unique object id
    ///
    /// - Parameters:
    ///  - uniqueValue: unique object id, implemented in PlainMappable and entity constraints
    ///  - isNew: inout flag. Says whether there is a contact
    func getContactOrCreate<Contact: ContactProtocol>(uniqueValue: String, isNew: inout Bool?) -> Contact where Contact: PlainMappable {
        guard let finded: Contact = Contact.CoreDataObject.find(attribute: Contact.uniqueAttribute, value: uniqueValue) else {
            isNew = true
            let newContact = Contact.create(unique: uniqueValue)
            channel?.send(.contactAdded(newContact))
            return newContact
        }
        isNew = false
        return finded
    }
    
    func getFriendContact(paymentCode: String) -> FriendContact? {
        return getContact(uniqueValue: paymentCode)
    }
    
    /// Get or create PaymentCodeContact
    ///
    /// - Parameters:
    ///  - paymentCode: payment code serialized string
    func getOrCreatePaymentCodeContact(paymentCode: String) -> PaymentCodeContact {
        var isNew: Bool?
        return getContactOrCreate(uniqueValue: paymentCode, isNew: &isNew)
    }
    
    /// Get or create AddressContact
    ///
    /// - Parameters:
    ///   - address: bitcoin address
    func getOrCreateAddressContact(address: String) -> AddressContact {
        var isNew: Bool?
        return getContactOrCreate(uniqueValue: address, isNew: &isNew)
    }

    @objc func getNewPregeneratedReceiveAddresses(for transaction: Transaction) -> [String] {
        guard var contact = paymentCodeProtocolContacts.first(where: { $0.isContact(for: transaction)}) else {
            return []
        }
        
        var newReceivingAddresses = [String]()
        if let address = contact.getConnectedReceiveAddress(for: transaction.brTransaction) {
            newReceivingAddresses = contact.getNewPregeneratedReceiveAddresses(forReceivingAddress: address)
        }
        
        guard newReceivingAddresses.count > 0 else {
            return []
        }
        
        contact.receiveAddresses += newReceivingAddresses
        
        save(contact)
        return newReceivingAddresses
    }
    
    @objc func getNewPregeneratedSendAddresses(for transaction: Transaction) -> [String] {
        guard var contact = paymentCodeProtocolContacts.first(where: { $0.isContact(for: transaction)}) else {
            return []
        }
        
        var newSendAddresses = [String]()
        if let address = contact.getConnectedSendAddress(for: transaction.brTransaction) {
            newSendAddresses = contact.getNewPregeneratedSendAddresses(forSendAddress: address)
        }
        
        guard newSendAddresses.count > 0 else {
            return []
        }
        
        contact.sendAddresses += newSendAddresses
        
        save(contact)
        return newSendAddresses
    }
    
    
    /// Connect transacrion to contact
    ///
    /// - Parameter transaction: Transaction
    @objc func connectTransactionToContact(_ transaction: Transaction) {
        guard var contact = allContacts().first(where: { $0.isContact(for: transaction) }) else {
            return
        }
        contact.txHashes.insert(transaction.txHash.data.hex)
        save(contact)
    }
    
    func connectSentTransactionToContact(_ transaction: Transaction, contact: PaymentCodeContactProtocol) {
        var contact = contact
        contact.txHashes.insert(transaction.txHash.data.hex)
        save(contact)
    }
    
    func getContactForNotification(txHash: UInt256S) -> ContactProtocol? {
        return paymentCodeProtocolContacts.first { (paymentCodeContact: PaymentCodeContactProtocol) in
            return paymentCodeContact.isContactForNotificationTransaction(txHash: txHash)
        }
    }
    
    /// Delete contact from Core Data
    ///
    /// - Parameter contact: contact to delete, wich responds ContactProtocol & PlainMappable
    func delete<Contact: ContactProtocol>(contact: Contact) where Contact: PlainMappable  {
        lock.lock()
        defer { lock.unlock() }
        
        guard let entity = Contact.CoreDataObject.findObject(attribute: Contact.uniqueAttribute, value: contact.uniqueValue) else {
            return
        }
        entity.delete()
        channel?.send(.contactRemoved(contact))
    }
    
    /// Delete all contacts from Core Data
    func deleteAllContacts() {
        for contact in addressContacts {
            delete(contact: contact)
        }
        
        for contact in paymentCodeContacts {
            delete(contact: contact)
        }
        
        for contact in friends {
            delete(contact: contact)
        }
    }
    
    func updateLastUsed(contact: inout ContactProtocol) {
        contact.lastUsed = NSNumber(value: Double(Date().timeIntervalSince1970))
        save(contact)
    }
    
    func setInitialLastUsed(contact: inout ContactProtocol) {
        contact.lastUsed = NSNumber(value: Double(0))
        save(contact)
    }
    
    /// Save or update contact depending on existense unique object id
    ///
    /// - Parameter contact: contact to save
    func save(_ contact: ContactProtocol) {
        lock.lock()
        defer { lock.unlock() }
        
        contact.save()
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else { return }
            
            // Backup to iCloud
            try? contact.backup(using: strongSelf.iCloudProvider)
            
            // Store contact in group derictory
            if let queueId = try? strongSelf.queueIdProvider.getQueueId(for: contact.uniqueValue) {
                let contactIndex = ContactIndex(pc: contact.uniqueValue,
                                                avatarData: contact.avatarData,
                                                queueId: queueId,
                                                name: contact.displayName,
                                                fileNames: [])
                try? strongSelf.groupProvider.saveContact(contactIndex, queueId: queueId)
            }
            
        }
        channel?.send(.contactUpdated(contact))
    }
}
