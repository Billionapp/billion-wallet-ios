//
//  DefaultsMigrationAssistantFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class DefaultsMigrationAssistantFactory: MigrationAssistantFactory {
    private weak var defaults: UserDefaults!
    
    init(defaults: UserDefaults) {
        self.defaults = defaults
    }
    
    func createAssistant() -> MigrationAssistantProtocol {
        let migrators: [VersionMigrator] = [
            DefaultsMigratorv040(defaults: defaults)
        ]
        let assistant = MigrationAssistant(migrators: migrators)
        return assistant
    }
}
