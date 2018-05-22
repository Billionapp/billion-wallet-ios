//
//  MigrationAssistant.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol VersionMigrator: class {
    var oldVersion: Version { get }
    var newVersion: Version { get }
    
    func migrateData()
}

class MigrationAssistant: MigrationAssistantProtocol {
    private var versionMigrators: [VersionMigrator]
    
    init(migrators: [VersionMigrator]) {
        self.versionMigrators = migrators
    }
    
    func migrateComponent(fromVersion version: Version) {
        let sortedMigartors = versionMigrators.sorted(by: { $0.oldVersion < $1.oldVersion })
        var ver = version
        for migrator in sortedMigartors {
            if migrator.newVersion <= ver {
                continue
            } else if migrator.oldVersion < ver {
                migrator.migrateData()
                ver = migrator.newVersion
            } else {
                fatalError("Could not find appropriate migration for component \(type(of: migrator))")
            }
        }
    }
}
