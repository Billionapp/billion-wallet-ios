//
//  ICloud.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 23/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ICloud {
    
    private weak var accountManager: AccountManager!
    
    let coordinator = NSFileCoordinator()
    
    lazy var query: NSMetadataQuery = {
        let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        query.predicate = NSPredicate(format: "%K.pathExtension LIKE '*'", NSMetadataItemFSNameKey)
        return query
    }()
    
    struct DocumentsDirectory {
        static let localDocumentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last!
        static let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }

    init(accountManager: AccountManager) {
        self.accountManager = accountManager
    }
    
    var accountFolder: String {
        return self.accountManager.getOrCreateWalletDigest()!
    }
    
    /// Return the Document directory (Cloud OR Local)
    /// To do in a background thread
    func getDocumentDiretoryURL() -> URL {
        if let cloudUrl = DocumentsDirectory.iCloudDocumentsURL {
            return cloudUrl
        } else {
            return DocumentsDirectory.localDocumentsURL
        }
    }
    
    /// Return true if iCloud is enabled
    func isCloudEnabled() -> Bool {
        if DocumentsDirectory.iCloudDocumentsURL != nil { return true }
        else { return false }
    }
    
    /// Delete All files at URL
    func deleteFilesInDirectory(url: URL) {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: url.path)
        while let file = enumerator?.nextObject() as? String {
            
            do {
                try fileManager.removeItem(at: url.appendingPathComponent(file))
                Logger.info("Files deleted in directory: \(url)")
            } catch let error {
                Logger.error("Failed deleting files : \(error.localizedDescription)")
            }
        }
    }
    
    /// Copy local files to iCloud
    /// iCloud will be cleared before any operation
    /// No data merging
    func copyFileToCloud() {
        if let cloudUrl = DocumentsDirectory.iCloudDocumentsURL {
            deleteFilesInDirectory(url: cloudUrl) // Clear all files in iCloud Doc Dir
            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.localDocumentsURL.path)
            while let file = enumerator?.nextObject() as? String {
                
                do {
                    try fileManager.copyItem(at: DocumentsDirectory.localDocumentsURL.appendingPathComponent(file), to: cloudUrl.appendingPathComponent(file))
                    
                    Logger.info("Local files copied to iCloud")
                } catch let error {
                    Logger.error("Failed to move local files to Cloud : \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Copy iCloud files to local directory
    /// Local dir will be cleared
    /// No data merging
    func copyFileToLocal() {
        if let cloudUrl = DocumentsDirectory.iCloudDocumentsURL {
            deleteFilesInDirectory(url: DocumentsDirectory.localDocumentsURL)
            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(atPath: cloudUrl.path)
            while let file = enumerator?.nextObject() as? String {
                
                do {
                    try fileManager.copyItem(at: cloudUrl.appendingPathComponent(file), to: DocumentsDirectory.localDocumentsURL.appendingPathComponent(file))
                    
                    Logger.info("Moved cloud files to local dir")
                } catch let error {
                    Logger.error("Failed to move file to local dir : \(error.localizedDescription)")
                }
            }
        }
    }
    
    func wipe() {
        if let cloudUrl = DocumentsDirectory.iCloudDocumentsURL {
            let fileManager = FileManager.default
            let accountCloudFolder = cloudUrl.appendingPathComponent(accountFolder)
            if fileManager.fileExists(atPath: accountCloudFolder.absoluteString) {
                do {
                    try fileManager.removeItem(at: accountCloudFolder)
                } catch {
                    Logger.error("Could not delete cloud folder: \(accountCloudFolder)")
                }
            } else {
                Logger.info("Nothing to clear, path does not exist: \(accountCloudFolder)")
            }
        }
    }
}
