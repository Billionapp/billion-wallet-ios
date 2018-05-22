//
//  GroupFolderProviderFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class GroupFolderProviderFactory {
    
    func create() -> GroupFolderProviderProtocol {
        let fileManager = FileManager.default
        guard let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.evogroup.billionwallet")?.appendingPathComponent("ContactIndex") else {
            fatalError("Invalid group id")
        }
        let storage = FileStorage(saveDir: url, fileManager: FileManager.default)
        let coder = ContactIndexCoder()
        let provider = GroupFolderProvider(storage: storage, coder: coder)
        return provider
    }
    
}
