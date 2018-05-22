//
//  KeychainMigrationAssistantFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 12/04/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class KeychainMigrationAssistantFactory: MigrationAssistantFactory {
    
    let accountManager: AccountManager
    
    init(accountManager: AccountManager) {
        self.accountManager = accountManager
    }

    func createAssistant() -> MigrationAssistantProtocol {
        let versionMigrators: [VersionMigrator] = [
            KeychainMigratorv051(accountManager: accountManager)
        ]
        
        let assistant = MigrationAssistant(migrators: versionMigrators)
        return assistant
    }
    
}
