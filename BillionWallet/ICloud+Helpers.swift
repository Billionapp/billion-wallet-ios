//
//  ICloud+Helpers.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 23/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension ICloud {
    
    enum ICloudError: LocalizedError {
        case invalidObjectName
        case invalidData
        case contentParsingError
        case couldntSave
        case noAppVersion
        case incompatableBackup
        case restoringFromJsonError
        
        var errorDescription: String? {
            switch self {
            case .invalidObjectName:
                return "Invalid object name"
            case .invalidData:
                return "Invalid data"
            case .contentParsingError:
                return "Content parsing error"
            case .couldntSave:
                return "Couldn't save"
            case .noAppVersion:
                return "No app version"
            case .incompatableBackup:
                return "Incompatable backup"
            case .restoringFromJsonError:
                return "Error restoring from json"
            }
        }
    }
    
    struct BackupDestination {
        static let contacts = "Contacts"
        static let comments = "Comments"
    }
    
    // MARK: - Restore Config
    
    func restoreConfig(walletProvider: WalletProvider, defaults: Defaults, currentWalletDigest: String) {
        
        let configs = restoreObjectsFromBackup(ICloudConfig.self)

        guard let icloudConfig = configs.first, icloudConfig.walletDigest == currentWalletDigest else {
            let newIcloudConfig = ICloudConfig(walletDigest: currentWalletDigest,
                                               userName: "User",
                                               currencies: [CurrencyFactory.defaultCurrency],
                                               feeSize: FeeSize.custom,
                                               version: Bundle.appVersion)
            try? backup(object: newIcloudConfig)
            return
        }
        
        defaults.currencies = icloudConfig.currencies
        defaults.userName = icloudConfig.userName
    }
    
    // MARK: - Restore Contacts
    
    func restoreContacts(contactsProvider: ContactsProvider) {
        DispatchQueue.global().async { [unowned self] in
            let addrContacts = self.restoreObjectsFromBackup(AddressContact.self) as [ContactProtocol]
            let pcContacts = self.restoreObjectsFromBackup(PaymentCodeContact.self) as [ContactProtocol]
            let friendContacts = self.restoreObjectsFromBackup(FriendContact.self) as [ContactProtocol]
                        
            for contact in [addrContacts, pcContacts, friendContacts].joined() {
                contactsProvider.save(contact)
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .iCloudContactsDidFinishSyncronizationNotitfication, object: nil)
            }
        }
    }
    
    // MARK: - Restore Comments
    
    func restoreComments(walletProvider: WalletProvider) {
        guard let wallet = try? walletProvider.getWallet() else { return }
        let userNotes = restoreObjectsFromBackup(ICloudUserNote.self)
        for userNote in userNotes {
            let unHexed = userNote.txHash.unHexed
            let uint256S = UInt256S(bytes: unHexed)
            
            if wallet.transaction(forHash: uint256S.uint256) != nil {
               let transactionNoteProvider = TransactionNotesProvider()
                transactionNoteProvider.setUserNote(with: userNote.userNote, for: uint256S)
            }
        }
    }
    
    // MARK: - Backup Object
    
    func backup<Object: ICloudBackupProtocol>(object: Object) throws {
        
        if object.destination.isEmpty {
            throw ICloudError.invalidObjectName
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: object.jsonWithAttachPreffix, options: [])
        
        let string = String(data: jsonData, encoding: .utf8)
        
        var url = Object.onlyLocal ? ICloud.DocumentsDirectory.localDocumentsURL : getDocumentDiretoryURL()
        url.appendPathComponent(accountFolder)
        if let folder = Object.folder {
            url.appendPathComponent(folder)
        }
        url.appendPathComponent(object.destination + ".json")
        
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        
        let fileManager = FileManager.default
        
        let icloudFile = url.lastPathComponent
        let icloudFileUrl = url.deletingLastPathComponent().appendingPathComponent(".\(icloudFile).icloud")
        
        if let _ = try? data(at: url) {
            try fileManager.removeItem(at: url)
        }
        if let _ = try? data(at: icloudFileUrl) {
            try fileManager.removeItem(at: icloudFileUrl)
        }
        
        try string?.write(to: url, atomically: false, encoding: .utf8)
        
        if let attachData = object.attach?.data, let attachName = object.attach?.fileName {
            let attachUrl = url.deletingLastPathComponent().appendingPathComponent(attachName)
            if fileManager.fileExists(atPath: attachUrl.absoluteString) {
                try fileManager.removeItem(at: attachUrl)
                try attachData.write(to: attachUrl)
            } else {
                try attachData.write(to: attachUrl)
            }
        }
    }
}

// MARK: - Private methods

extension ICloud {
    
    // TODO: Perform in background
    func restoreObjectsFromBackup<Object: ICloudBackupProtocol>(_ type: Object.Type) -> [Object] {
        
        var url =  type.onlyLocal ? ICloud.DocumentsDirectory.localDocumentsURL : getDocumentDiretoryURL()
        url.appendPathComponent(accountFolder)
        if let folder = Object.folder {
            url.appendPathComponent(folder)
        }
        
        var restoredObjects = [Object]()
        
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
                        
            for content in directoryContents {
                
                let fileUrl = content.isDirectory() ? (content.find(contains: ".json") ?? content) : content
                
                guard let jsonDict = try? json(at: fileUrl) else {
                    continue
                }
                
                var attachData: Data?
                if let attachInfo = jsonDict["attach"] as? [String: String], let fileName = attachInfo["file_name"], let attachUrl = content.find(contains: fileName) ?? content.deletingLastPathComponent().find(contains: fileName) {
                    attachData = try? data(at: attachUrl)
                }
                
                restoredObjects.append(try Object(from: jsonDict, with: attachData))
            }
            
        } catch let error {
            Logger.error(error.localizedDescription)
        }
        
        return restoredObjects
    }
    
    fileprivate func data(at url: URL) throws -> Data {
        var newUrl: URL?
        coordinator.coordinate(readingItemAt: sourceUrl(from: url), options: [], error: nil) { restoredUrl in
            newUrl = restoredUrl
        }
        
        guard let fileUrl = newUrl else {
            throw ICloudError.contentParsingError
        }
        
        return try Data(contentsOf: fileUrl)
    }
    
    
    fileprivate func json(at url: URL) throws -> [String: Any] {
        var newUrl: URL?
        coordinator.coordinate(readingItemAt: url, options: [], error: nil) { restoredUrl in
            newUrl = restoredUrl
        }
        
        guard let fileUrl = newUrl, let jsonString = try? String(contentsOf: sourceUrl(from: fileUrl)), let data = jsonString.data(using: .utf8) else {
            throw ICloudError.contentParsingError
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let jsonObject = json else {
            throw ICloudError.contentParsingError
        }
        
        return jsonObject
    }
    
    fileprivate func sourceUrl(from url: URL) -> URL {
        if !url.absoluteString.contains(".icloud") {
            return url
        }
        
        if url.pathExtension.isEmpty {
            return url
        }
        
        var fileNameComponents = url.lastPathComponent.components(separatedBy: ".")
        fileNameComponents.removeLast()
        fileNameComponents.removeFirst()
        return url.deletingLastPathComponent().appendingPathComponent(fileNameComponents.joined(separator: "."))
    }
    
}

extension Notification.Name {
    
    static var iCloudContactsDidFinishSyncronizationNotitfication: Notification.Name {
        return Notification.Name(rawValue: "iCloudContactsDidFinishSyncronization")
    }
    
}
