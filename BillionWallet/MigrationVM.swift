//
//  MigrationVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 01/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol MigrationVMDelegate: class {
    func didChangeProgress(_ value: Float)
    func didFinishMigration()
}

class MigrationVM {

    weak var delegate: MigrationVMDelegate?
    private weak var migrationManager: MigrationManagerProtocol!
    private let migrationQueue = DispatchQueue(label: "MigrationQueue")

    init(migrationManager: MigrationManagerProtocol) {
        self.migrationManager = migrationManager
    }
    
    func startMigration() {
        migrationQueue.async {
            guard let versionStr = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                Logger.error("Could not get bundle version string. Migration failed.")
                return
            }
            self.migrationManager.migrateAppData(bundleVersionString: versionStr, progressDelegate: self)
        }
    }

}

extension MigrationVM: MigrationProgressDelegate {
    
    func didChangeProgress(_ value: Int, total: Int) {
        DispatchQueue.main.async {
            self.delegate?.didChangeProgress(Float(value/total))
        }
    }
    
    func didFinishMigration() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.delegate?.didFinishMigration()
        }
    }
}
