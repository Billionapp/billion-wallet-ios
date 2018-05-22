//
//  TransasactionRelatorMigrationAssistantFactory.swift
//  BillionWallet
//
//  Created by  Evolution Group Ltd on 03.02.18.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class NoMigration: MigrationAssistantProtocol {
    func migrateComponent(fromVersion version: Version) {
        return
    }
}

class TransasactionRelatorMigrationAssistantFactory: MigrationAssistantFactory {
    
    private let walletProvider: WalletProvider
    private let transactionLinker: TransactionLinkerProtocol
    private let transactionRelator: TransactionRelatorProtocol
    private let contactsProvider: ContactsProvider
    
    init (walletProvider: WalletProvider,
          transactionLinker: TransactionLinkerProtocol,
          transactionRelator: TransactionRelatorProtocol,
          contactsProvider: ContactsProvider) {
        
        self.walletProvider = walletProvider
        self.transactionLinker = transactionLinker
        self.transactionRelator = transactionRelator
        self.contactsProvider = contactsProvider
    }
    
    func createAssistant() -> MigrationAssistantProtocol {
        let versionMigrators: [VersionMigrator] = [
            TransactionRelationMigratorv040(wallet: walletProvider, transactionLinker: transactionLinker, transactionRelator: transactionRelator, contactsProvider: contactsProvider)
        ]
    
        let assistant = MigrationAssistant(migrators: versionMigrators)
        return assistant
    }
}
