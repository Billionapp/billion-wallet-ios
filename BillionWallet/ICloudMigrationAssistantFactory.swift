//
//  ICloudMigrationAssistantFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class ICloudMigrationAssistantFactory: MigrationAssistantFactory {
    private let fileManager: FileManager
    private let accountManager: AccountManager
    
    init(fileManager: FileManager, accountManager: AccountManager) {
        self.fileManager = fileManager
        self.accountManager = accountManager
    }
    
    func createAssistant() -> MigrationAssistantProtocol {
        let versionMigrators: [VersionMigrator] = [
            ICloudMigratorv040(fileManager: fileManager, accountManager: accountManager)
        ]
        
        let assistant = MigrationAssistant(migrators: versionMigrators)
        return assistant
    }
}

