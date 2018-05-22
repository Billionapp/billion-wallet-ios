//
//  KeychainMigratorv051.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 12/04/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class KeychainMigratorv051: VersionMigrator {
    
    let oldVersion: Version = "0.0.0"
    let newVersion: Version = "0.5.1"
    
    let accountManager: AccountManager
    
    init(accountManager: AccountManager) {
        self.accountManager = accountManager
    }
    
    func migrateData() {
        let selfPrivData = accountManager.getSelfCPPriv()
        let keychain = Keychain()
        keychain.selfPCPriv = selfPrivData
    }

}
