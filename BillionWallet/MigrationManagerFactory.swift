//
//  MigrationManagerFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol MigrationManagerFactory {
    func createMananger() -> MigrationManagerProtocol
}

class MainMigrationManagerFactory {
    private let defaults: UserDefaults
    private let fileManager: FileManager
    private let accountManager: AccountManager
    private let walletProvider: WalletProvider
    private let txLinker: TransactionLinkerProtocol
    private let txRelator: TransactionRelatorProtocol
    private let contactsProvider: ContactsProvider
    private let app: Application
    private let keychain: Keychain
    private let queueIdProvider: QueueIdProviderProtocol
    private let groupProvider: GroupFolderProviderProtocol
    
    init(defaults: UserDefaults,
        fileManager: FileManager,
        accountManager: AccountManager,
        walletProvider: WalletProvider,
        txLinker: TransactionLinkerProtocol,
        txRelator: TransactionRelatorProtocol,
        contactsProvider: ContactsProvider,
        app: Application,
        keychain: Keychain,
        queueIdProvider: QueueIdProviderProtocol,
        groupProvider: GroupFolderProviderProtocol) {
        
        self.defaults = defaults
        self.fileManager = fileManager
        self.accountManager = accountManager
        self.walletProvider = walletProvider
        self.txLinker = txLinker
        self.txRelator = txRelator
        self.contactsProvider = contactsProvider
        self.app = app
        self.keychain = keychain
        self.queueIdProvider = queueIdProvider
        self.groupProvider = groupProvider
    }
    
    func createManager() -> MigrationManagerProtocol {
        let defaultsFactory = DefaultsMigrationAssistantFactory(defaults: defaults)
        let icloudFactory = ICloudMigrationAssistantFactory(fileManager: fileManager, accountManager: accountManager)
       
        let storageUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last!
        let selfPRstorage = SelfPaymentRequestStorage(fileManager: fileManager, storageUrl: storageUrl)
        let userPRstorage = UserPaymentRequestStorage(fileManager: fileManager, storageUrl: storageUrl)
        let paymentRequestFactory = PaymentRequestMigrationAssistantFactory(selfPRstorage: selfPRstorage, userPRstorage: userPRstorage)
        
        let txRelationFactory = TransasactionRelatorMigrationAssistantFactory(walletProvider: walletProvider,
                                                                              transactionLinker: txLinker,
                                                                              transactionRelator: txRelator,
                                                                              contactsProvider: contactsProvider)
        
        let keychainFactory = KeychainMigrationAssistantFactory(accountManager: accountManager)
        
        let passcodeFactory = PinCodeMigrationAssistantFactory(app: app, keychain: keychain)

        let groupFolderFactory = GroupFolderMigrationAssistantFactory(queueIdProvider: queueIdProvider, contactsProvider: contactsProvider, groupProvider: groupProvider)
        
        let assistants: [MigrationAssistantProtocol] = [
            defaultsFactory.createAssistant(),
            icloudFactory.createAssistant(),
            txRelationFactory.createAssistant(),
            paymentRequestFactory.createAssistant(),
            passcodeFactory.createAssistant(),
            keychainFactory.createAssistant(),
            groupFolderFactory.createAssistant()
        ]

        let manager = MigrationManager(defaults: defaults, migrationAssistants: assistants)
        return manager
    }
}
