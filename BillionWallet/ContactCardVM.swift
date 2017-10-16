//
//  ContactCardVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.08.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
protocol ContactCardVMDelegate: class {
    
}

class ContactCardVM {
   
    weak var delegate: ContactCardVMDelegate?
    weak var contactsProvider: ContactsProvider?
    
    var newName: String?
    var photo: Data? {
        didSet {
            updateContact()
        }
    }
    
    var qrImage: UIImage {
        return qrFromString()!
    }
    
    var contact: ContactProtocol
    
    init(contact: ContactProtocol, contactsProvider: ContactsProvider?) {
        self.contact = contact
        self.contactsProvider = contactsProvider
    }
    
    func qrFromString() -> UIImage? {
        return createQRFromString(contact.uniqueValue, size: CGSize(width: 280, height: 280), inverseColor: true)
    }
    
    func updateContact() {
        guard newName != nil || photo != nil else {
            return
        }
        
        if let name = newName {
            contact.displayName = name
        }
        if let photo = photo {
            contact.avatarData = photo
        }
        
        do {
            try contactsProvider?.save(contact)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func archiveContact() throws {
        contact.isArchived = true
        do {
            try contactsProvider?.save(contact)
        } catch {
            print(error.localizedDescription)
        }
    }
}
