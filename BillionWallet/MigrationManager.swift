//
//  MigrationManager.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol MigrationManagerProtocol: class {
    func migrateAppData(bundleVersionString: String, progressDelegate: MigrationProgressDelegate?)
}

protocol MigrationAssistantFactory {
    func createAssistant() -> MigrationAssistantProtocol
}

protocol MigrationProgressDelegate: class {
    func didChangeProgress(_ value: Int, total: Int)
    func didFinishMigration()
}

/// A class used to migrate a single or component
protocol MigrationAssistantProtocol: class {
    /// Perform component migration tasks
    ///
    /// - Parameter version: version from which to perform migration tasks
    func migrateComponent(fromVersion version: Version)
}

class MigrationManager: MigrationManagerProtocol {
    /// Please do not modify this key
    /// otherwise it can break compatibility
    static let versionKey = "MigrationManagerDataVersion"
    
    private var migrationAssistants: [MigrationAssistantProtocol]
    private let defaults: UserDefaults
    private weak var progressDelegate: MigrationProgressDelegate?
    
    init(defaults: UserDefaults, migrationAssistants: [MigrationAssistantProtocol]) {
        self.defaults = defaults
        self.migrationAssistants = migrationAssistants
    }
    
    private func getCurrentAppDataVersion() -> Version {
        let version = defaults.string(forKey: MigrationManager.versionKey) ?? "0"
        let ver = Version(rawValue: version)!
        return ver
    }
    
    private func migrateAppData(from oldVersion: Version, to newVersion: Version) {
        for (i, assistant) in migrationAssistants.enumerated() {
            assistant.migrateComponent(fromVersion: oldVersion)
            progressDelegate?.didChangeProgress(i+1, total: migrationAssistants.count)
            sleep(1)
        }
        defaults.set(newVersion.rawValue, forKey: MigrationManager.versionKey)
        progressDelegate?.didFinishMigration()
    }
    
    func migrateAppData(bundleVersionString: String, progressDelegate: MigrationProgressDelegate?) {
        let dataVersion = getCurrentAppDataVersion()
        let currentVersion = Version(rawValue: bundleVersionString)!
        self.progressDelegate = progressDelegate
        if currentVersion == dataVersion {
            progressDelegate?.didFinishMigration()
            return
        } else if currentVersion > dataVersion {
            let start = Date().timeIntervalSince1970
            migrateAppData(from: dataVersion, to: currentVersion)
            let end = Date().timeIntervalSince1970
            Logger.debug("Migration finished in \(end - start)")
        } else { // currentVersion < dataVersion
            // TODO: Perform data wipe or something
            // Case of old binary over newer data. Used mostly in internal testing
            // Currently app will try to launch with current data
            progressDelegate?.didFinishMigration()
        }
    }
}
