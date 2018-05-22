//
//  Strings+Contacts.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum Contacts {
        static let title = NSLocalizedString("Contacts.title", tableName: "Contacts", value: "Contacts", comment: "Contacts title")
        static let cancelButton = NSLocalizedString("Contacts.cancelButton", tableName: "Contacts", value: "Cancel", comment: "Cancel")
        
        static let noContacts = NSLocalizedString("Contacts.noContacts", tableName: "Contacts", value: "You have no contacts", comment: "Message that user have no contacts")
        static let addContact = NSLocalizedString("Contacts.addContact", tableName: "Contacts", value: "Add Contact", comment: "Add contact button title")
    }
}
