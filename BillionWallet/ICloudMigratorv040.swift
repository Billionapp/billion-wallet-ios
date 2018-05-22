//
//  ICloudMigratorv040.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 21.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class ICloudMigratorv040: VersionMigrator {
    private let movedFolderName: String = "acc0"
    
    private let fileManager: FileManager
    private let accountManager: AccountManager
    
    let oldVersion: Version = "0.0.0"
    let newVersion: Version = "0.4.0"
    
    init(fileManager: FileManager, accountManager: AccountManager) {
        self.fileManager = fileManager
        self.accountManager = accountManager
    }
    
    func migrateData() {
        // Warning! Syncronous icloud access can be heavy on first run.
        guard let walletDigest = accountManager.getOrCreateWalletDigest() else {
            Logger.error("Could not get wallet digest from account manager")
            return
        }
        do {
            if let localUrl = fileManager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last {
                let oldLocalDir = localUrl.appendingPathComponent(movedFolderName)
                let newLocalDir = localUrl.appendingPathComponent(walletDigest)
                try fileManager.moveItem(at: oldLocalDir, to: newLocalDir)
            }
        } catch let error {
            Logger.error("Error moving local directory: \(error.localizedDescription)")
        }
        do {
            if let cloudUrl = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                let oldCloudDir = cloudUrl.appendingPathComponent(movedFolderName)
                let newCloudDir = cloudUrl.appendingPathComponent(walletDigest)
                try fileManager.moveItem(at: oldCloudDir, to: newCloudDir)
            }
        } catch let error {
            Logger.error("Error moving cloud directory: \(error.localizedDescription)")
        }
    }
}
