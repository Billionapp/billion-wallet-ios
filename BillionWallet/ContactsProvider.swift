//
//  ContactsProvider.swift
//  CoreDataTest
//
//  Created by Evolution Group Ltd on 02/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ContactsProvider {
        
    /// Returns all address contacts
    var addessContacts: [AddressContact] {
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
    
    var paymenctCodeProtocolContacts: [PaymentCodeContactProtocol] {
        return Array([paymentCodeContacts as [PaymentCodeContactProtocol], friends as [PaymentCodeContactProtocol]].joined())
    }
    
    /// Returns all contacts
    ///
    /// - Parameter isArchived: define to return archived or unarchived contacts only
    func allContacts(isArchived: Bool? = nil) -> [ContactProtocol] {
        let contacts = Array([addessContacts as [ContactProtocol], paymentCodeContacts as [ContactProtocol], friends as [ContactProtocol]].joined())
        guard let isArchived = isArchived else {
            return contacts
        }
        return contacts.filter { $0.isArchived == isArchived}
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
            return Contact.create(unique: uniqueValue)
        }
        isNew = false
        return finded
    }
    
    /// Get or create PaymentCodeContact
    ///
    /// - Parameters:
    ///  - paymentCode: payment code sereilized string
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
    
    func getContact(txHash: UInt256S) -> ContactProtocol? {
        return allContacts().filter({ $0.txHashes.contains(txHash.data.toHexString()) }).first
    }
    
    func getContactForNotification(txHash: UInt256S) -> ContactProtocol? {
        return paymenctCodeProtocolContacts.filter() { $0.isContactForNotificationTransaction(txHash: txHash) }.first as? ContactProtocol
    }
    
    /// Delete contact from Core Data
    ///
    /// - Parameter contact: contact to delete, wich responds ContactProtocol & PlainMappable
    func delete<Contact: ContactProtocol>(contact: Contact) where Contact: PlainMappable  {
        guard let entity = Contact.CoreDataObject.findObject(attribute: Contact.uniqueAttribute, value: contact.uniqueValue) else {
            return
        }
        entity.delete()
    }
    
    /// Delete all contacts from Core Data
    func deleteAllContacts() {
        for contact in addessContacts {
            delete(contact: contact)
        }
        
        for contact in paymentCodeContacts {
            delete(contact: contact)
        }
        
        for contact in friends {
            delete(contact: contact)
        }
    }
    
    /// Save or update contact depending on existanse unique object id
    ///
    /// - Parameter contact: contact to save
    func save(_ contact: ContactProtocol) throws {
        contact.save()
    }

}
