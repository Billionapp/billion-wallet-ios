//
//  TransactionRelationMigratorv040.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 02.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class TransactionRelationMigratorv040: VersionMigrator {
    
    private let walletProvider: WalletProvider
    private let transactionLinker: TransactionLinkerProtocol
    private let transactionRelator: TransactionRelatorProtocol
    private let contactsProvider: ContactsProvider
    
    let oldVersion: Version = "0.0.0"
    let newVersion: Version = "0.4.0"
    
    init (wallet: WalletProvider, transactionLinker: TransactionLinkerProtocol,
          transactionRelator: TransactionRelatorProtocol,
          contactsProvider: ContactsProvider) {
        self.walletProvider = wallet
        self.transactionLinker = transactionLinker
        self.transactionRelator = transactionRelator
        self.contactsProvider = contactsProvider
    }
    
    private func checkAllTransactions(with contact: ContactProtocol) -> [TxRelation]  {
        guard let wallet = try? walletProvider.getWallet() else { return [] }
        
        let empty = [TxRelation]()
        let transactions = wallet.allTransactions.map({ Transaction(brTransaction: $0, walletProvider: walletProvider) })
        guard transactions.count > 0 else { return empty }
        return transactionRelator.detectRelated(transactions, for: contact)
    }
    
    func migrateData() {
        let allContacts = contactsProvider.allContacts()
        for var contact in allContacts {
            if contact.getSendAddresses().isEmpty {
                contact.generateSendAddresses()
                contactsProvider.save(contact)
            }
            
            let relations = checkAllTransactions(with: contact)
            transactionLinker.link(relations: relations, completion: { (contact) in
                contactsProvider.save(contact)
            })
        }
        
        NotificationCenter.default.post(name: .transactionsLinkedToContact, object: nil)
        Logger.debug("Transaction relation migration successful")
    }
}
