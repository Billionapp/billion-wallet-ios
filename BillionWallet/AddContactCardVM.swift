//
//  AddContactCardVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol AddContactCardVMDelegate: class {
    func didReceiveContact(_ contact: ContactProtocol)
}

class AddContactCardVM {

    private let contactsProvider: ContactsProvider
    private var contact: ContactProtocol
    private var transactionLinker: TransactionLinkerProtocol
    private var transactionRelator: TransactionRelatorProtocol
    private let paymentCodesProvider: PaymentCodesProvider

    weak var delegate: AddContactCardVMDelegate?
    
    init(contact: ContactProtocol,
         contactsProvider: ContactsProvider,
         transactionLinker: TransactionLinkerProtocol,
         transactionRelator: TransactionRelatorProtocol,
         paymentCodesProvider: PaymentCodesProvider) {
        
        self.contact = contact
        self.contactsProvider = contactsProvider
        self.transactionLinker = transactionLinker
        self.transactionRelator = transactionRelator
        self.paymentCodesProvider = paymentCodesProvider
    }
    
    func getContact() {
        delegate?.didReceiveContact(contact)
    }
    
    func didChangeName(name: String) {
        contact.givenName = name
    }
    
    func save() {
        contactsProvider.updateLastUsed(contact: &contact)
        let relations = paymentCodesProvider.checkAllTransactions(with: contact)
        self.transactionLinker.link(relations: relations) { (linkedContact) in
            contactsProvider.save(linkedContact)
            NotificationCenter.default.post(name: .transactionsLinkedToContact, object: nil)
        }
    }
}
