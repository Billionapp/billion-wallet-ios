//
//  TxPostConnectToContact.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 24/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class TxPostConnectToContact: TxPostPublish {
    private var contact: PaymentCodeContactProtocol
    private let contactsProvider: ContactsProvider
    
    init(contact: PaymentCodeContactProtocol, contactsProvider: ContactsProvider) {
        self.contact = contact
        self.contactsProvider = contactsProvider
    }
    
    func performPostPublishTasks(_ transactions: [Transaction]) {
        for transaction in transactions {
            // Check v1 notification transactions
            if transaction.outputAddresses.contains(contact.paymentCodeObject.notificationAddress!) {
                contact.notificationTxHash = transaction.txHashString
            }
            contact.incrementFirstUnusedIndex()
            contact.txHashes.insert(transaction.txHash.data.hex)
            contactsProvider.save(contact)
        }
    }
}
