//
//  DefaultsMigratorv040.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class DefaultsMigratorv040: VersionMigrator {
    private let removedKeys: [String] = [
        "commission"
    ]
    private let movedKeys: [(from: String, to: String)] = [
        ("fitstEnterDate", "firstLaunchDate")
    ]
    
    private let defaults: UserDefaults
    
    let oldVersion: Version = "0.0.0"
    let newVersion: Version = "0.4.0"
    
    init(defaults: UserDefaults) {
        self.defaults = defaults
    }
    
    func migrateData() {
        for key in removedKeys {
            defaults.removeObject(forKey: key)
        }
        for key in movedKeys {
            let obj = defaults.object(forKey: key.from)
            defaults.set(obj, forKey: key.to)
            defaults.removeObject(forKey: key.from)
        }
    }
}
