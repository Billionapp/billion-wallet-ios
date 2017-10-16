//
//  ICloud.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 23/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ICloud {
    
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

    
    // Return the Document directory (Cloud OR Local)
    // To do in a background thread
    
    func getDocumentDiretoryURL() -> URL {
        if isCloudEnabled()  {
            return DocumentsDirectory.iCloudDocumentsURL!
        } else {
            return DocumentsDirectory.localDocumentsURL
        }
    }
    
    // Return true if iCloud is enabled
    
    func isCloudEnabled() -> Bool {
        if DocumentsDirectory.iCloudDocumentsURL != nil { return true }
        else { return false }
    }
    
    // Delete All files at URL
    
    func deleteFilesInDirectory(url: URL?) {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: url!.path)
        while let file = enumerator?.nextObject() as? String {
            
            do {
                try fileManager.removeItem(at: url!.appendingPathComponent(file))
                print("Files deleted")
            } catch let error as NSError {
                print("Failed deleting files : \(error)")
            }
        }
    }
    
    // Copy local files to iCloud
    // iCloud will be cleared before any operation
    // No data merging
    
    func copyFileToCloud() {
        if isCloudEnabled() {
            deleteFilesInDirectory(url: DocumentsDirectory.iCloudDocumentsURL!) // Clear all files in iCloud Doc Dir
            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.localDocumentsURL.path)
            while let file = enumerator?.nextObject() as? String {
                
                do {
                    try fileManager.copyItem(at: DocumentsDirectory.localDocumentsURL.appendingPathComponent(file), to: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file))
                    
                    print("Copied to iCloud")
                } catch let error as NSError {
                    print("Failed to move file to Cloud : \(error)")
                }
            }
        }
    }
    
    // Copy iCloud files to local directory
    // Local dir will be cleared
    // No data merging
    
    func copyFileToLocal() {
        if isCloudEnabled() {
            deleteFilesInDirectory(url: DocumentsDirectory.localDocumentsURL)
            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.iCloudDocumentsURL!.path)
            while let file = enumerator?.nextObject() as? String {
                
                do {
                    try fileManager.copyItem(at: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file), to: DocumentsDirectory.localDocumentsURL.appendingPathComponent(file))
                    
                    print("Moved to local dir")
                } catch let error as NSError {
                    print("Failed to move file to local dir : \(error)")
                }
            }
        }
    }
    
}
